extends "res://src/overworld/trainers/trainer_challenge_event.gd"
## Desafío de un personaje colocado por datos (data/personajes_en_el_mapa.json, CharacterPlacements) con algo
## más que el combate. Las opciones las deja CharacterPlacements en el metadato "personaje" de cada entrenador:
## - "serie": [ids]: combates seguidos contra todos, en ese orden, y el equipo se cura después de cada uno
##   (decisión de Javier del 2026-10-13: Lamine y su familia; Folagor, Sekiam y PokeAlex).
## - "premio": {"objeto": id, "cantidad": n, "texto": "..."}: al ganarle te da ese objeto, una sola vez
##   (las joyas de Zapatero). Regla R.2: el objeto viene por id de los datos.
## - "detencion": {"texto": "..."} o true: al ganarle llegan coches de policía y se lo llevan (Ábalos y Koldo).
##   Activa "detenido:<id>" (la colocación lleva "hasta": {"flag": "detenido:<id>"} para no volver a salir).
## - "al_ganar": {"flag": "...", "texto": "..."}: al ganarle activa ese flag y lo anuncia (Pedro Sánchez:
##   "liga_superada", y el rey Felipe VI sale en la Plaza de la Armería).

const META := &"personaje"
const POLICE_SHEET := "res://assets/sprites/characters/policia.png"
const POLICE_CAR := "res://assets/sprites/characters/coche_policia.png"
const NPC_SCENE := "res://src/overworld/npc/npc.tscn"
const ARRESTED_FLAG := "detenido:%s"
const REWARD_FLAG := "premio_personaje:%s"
const CAR_TIME := 0.6


static func options_of(trainer: Node) -> Dictionary:
	if trainer == null or not trainer.has_meta(META):
		return {}
	var value: Variant = trainer.get_meta(META)
	return value if value is Dictionary else {}


func run() -> void:
	var trainer := source as TrainerNPC
	if trainer == null:
		return
	var options := options_of(trainer)
	if options.has("serie"):
		await run_series(trainer, options["serie"])
		return
	var group := trainer.group()
	if group.is_empty():
		return
	await super()
	for t: TrainerNPC in group:
		if not t.is_defeated():
			return
	for t: TrainerNPC in group:
		var reward: Variant = options_of(t).get("premio")
		if reward is Dictionary:
			await give_reward(t, reward)
	for t: TrainerNPC in group:
		var won: Variant = options_of(t).get("al_ganar")
		if won is Dictionary:
			await announce_win(won)
	for t: TrainerNPC in group:
		if options_of(t).has("detencion"):
			await arrest(group, options_of(t)["detencion"])
			break


## Activa el flag de "al_ganar" y lo anuncia.
func announce_win(details: Dictionary) -> void:
	var flag := StringName(str(details.get("flag", "")))
	if flag != &"":
		GameState.set_flag(flag)
	var text := str(details.get("texto", ""))
	if text != "":
		AudioManager.play_me(&"level_up")
		await Dialogue.say(text)


## Los entrenadores de la serie que siguen en el mapa y sin derrotar, en su orden.
func series_members(trainer: TrainerNPC, ids: Array) -> Array[TrainerNPC]:
	var out: Array[TrainerNPC] = []
	var parent := trainer.get_parent()
	for id: Variant in ids:
		var member: TrainerNPC = null
		for node: Node in parent.get_children() if parent else []:
			if node is TrainerNPC and String((node as TrainerNPC).trainer_id) == str(id):
				member = node
				break
		if member != null and member.is_present() and not member.is_defeated():
			out.append(member)
	return out


## Combates seguidos con curación después de cada uno. Si pierdes uno, se acaba la serie.
func run_series(trainer: TrainerNPC, ids: Array) -> void:
	var members := series_members(trainer, ids)
	if members.is_empty():
		return
	var map_bgm := AudioManager.current_bgm
	var intro_bgm := StringName(str(trainer.data.get("intro_bgm", "")))
	if intro_bgm != &"":
		AudioManager.play_bgm(intro_bgm, 0.0)
	if bool(param("spotted", false)):
		trainer.face_towards(player)
		await Cutscene.emote(trainer, "!")
		await Cutscene.approach(trainer, player)
	for member: TrainerNPC in members:
		member.face_towards(player)
		player.face_towards(member)
		var intro := str(member.data.get("intro_text", ""))
		if intro != "":
			await Dialogue.say(intro, member.display_name)
		if await battle(member) != SceneManager.OUTCOME_WIN:
			return
		Cutscene.heal_party()
		AudioManager.play_se(&"party")
		await Dialogue.say("Tu equipo se ha recuperado del todo." if member == members.back() else "Tu equipo se ha recuperado para el siguiente combate.")
	if map_bgm != &"":
		AudioManager.play_bgm(map_bgm)


## Da el objeto del premio una sola vez.
func give_reward(t: TrainerNPC, reward: Dictionary) -> void:
	var flag := StringName(REWARD_FLAG % t.trainer_id)
	var item := StringName(str(reward.get("objeto", "")))
	var count := int(reward.get("cantidad", 1))
	if GameState.flag(flag) or not DataDB.has_item(item) or count <= 0:
		return
	var text := str(reward.get("texto", ""))
	if text != "":
		await Dialogue.say(text, t.display_name)
	if await Cutscene.give_item(item, count):
		GameState.set_flag(flag)


## Llegan los coches de policía, los agentes se ponen al lado de cada detenido y se los llevan.
func arrest(group: Array[TrainerNPC], details: Variant) -> void:
	if group.is_empty() or not is_instance_valid(group[0]):
		return
	var parent := group[0].get_parent()
	var from_right := player == null or player.position.x <= group[0].position.x
	var car := police_car(parent, group, from_right)
	var officers: Array[Node2D] = []
	for t: TrainerNPC in group:
		var officer := police_officer(parent, t, from_right)
		if officer != null:
			officers.append(officer)
	var tween := car.create_tween()
	tween.tween_method(func(x: float) -> void: car.position.x = roundf(x), car.position.x, float(car.get_meta(&"stop_x")), CAR_TIME)
	await tween.finished
	for officer: Node2D in officers:
		officer.visible = true
	var text := str((details as Dictionary).get("texto", "")) if details is Dictionary else ""
	await Dialogue.say(text if text != "" else "¡Alto! ¡Policía Nacional! Quedan detenidos.", "Policía")
	var names := PackedStringArray()
	for t: TrainerNPC in group:
		names.append(str(t.data.get("name", t.display_name)))
		GameState.set_flag(StringName(ARRESTED_FLAG % t.trainer_id))
	await screen_fade(true)
	for t: TrainerNPC in group:
		Cutscene.hide_entity(t)
	for officer: Node2D in officers:
		officer.queue_free()
	car.queue_free()
	await screen_fade(false)
	await Dialogue.say("La policía se ha llevado a %s." % " y ".join(names))


## Fundido de la pantalla mientras se los llevan (las pruebas lo sustituyen: sin escena principal no hay fundido).
func screen_fade(out: bool) -> void:
	if out:
		await Cutscene.fade_out(0.3)
	else:
		await Cutscene.fade_in(0.3)


## El coche entra por el lado contrario al jugador y para a tres casillas del grupo.
func police_car(parent: Node, group: Array[TrainerNPC], from_right: bool) -> Sprite2D:
	var car := Sprite2D.new()
	car.name = "CochePolicia"
	car.texture = load(POLICE_CAR)
	car.flip_h = not from_right
	var center := Vector2.ZERO
	for t: TrainerNPC in group:
		center += t.position
	center /= group.size()
	var side := 1.0 if from_right else -1.0
	var stop_x := roundf(center.x + side * Grid.TILE * 3.0)
	car.position = Vector2(stop_x + side * 512.0, roundf(center.y + Grid.TILE))
	car.set_meta(&"stop_x", stop_x)
	parent.add_child(car)
	return car


## Un agente en una casilla libre junto al detenido (por el lado del coche si se puede), mirándole.
func police_officer(parent: Node, t: TrainerNPC, from_right: bool) -> Node2D:
	var tile := t.tile_position()
	var sides: Array[Vector2i] = [Vector2i.RIGHT if from_right else Vector2i.LEFT, Vector2i.DOWN, Vector2i.LEFT if from_right else Vector2i.RIGHT, Vector2i.UP]
	for side: Vector2i in sides:
		var cell := tile + side
		if player != null and player.tile_position() == cell:
			continue
		if not t.is_tile_free(cell):
			continue
		var officer: NPC = (load(NPC_SCENE) as PackedScene).instantiate()
		officer.name = "Policia_%s" % t.trainer_id
		officer.sprite_sheet = load(POLICE_SHEET)
		officer.visible = false
		officer.position = Grid.to_world(cell)
		parent.add_child(officer)
		officer.face(-side)
		return officer
	return null
