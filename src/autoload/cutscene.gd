extends Node
## API de cinemáticas (Fase 13.1). Contrato: docs/contratos.md (sección Cutscene).
## Los eventos (StoryEvent) se ejecutan aquí para sobrevivir a los cambios de mapa.
## Mientras dura un evento, el control del jugador está bloqueado (&"cutscene").

signal event_started(event: StoryEvent)
signal event_finished(event: StoryEvent)

## Evento en curso (null si no hay).
var current: StoryEvent


func is_running() -> bool:
	return current != null


## Ejecuta un evento hasta el final. `event`: script que hereda de StoryEvent o
## una instancia. Si ya hay otro en curso, espera a que termine. `done_flag`
## (opcional) se activa al terminar, aunque el evento haya cambiado de mapa.
func play(event: Variant, source: Node = null, params: Dictionary = {},
		done_flag: StringName = &"") -> void:
	var instance: StoryEvent = (event as GDScript).new() if event is GDScript else event
	if instance == null:
		push_error("Cutscene.play: '%s' no es un StoryEvent." % event)
		return
	while current != null:
		await event_finished
	instance.source = source
	instance.params = params
	instance.map = SceneManager.current_map
	instance.player = SceneManager.player
	current = instance
	lock_player()
	event_started.emit(instance)
	# run() es corrutina en los eventos reales, aunque la base no lo sea.
	@warning_ignore("redundant_await")
	await instance.run()
	if done_flag != &"":
		GameState.set_flag(done_flag)
	unlock_player()
	current = null
	event_finished.emit(instance)


# --- Control ---

func lock_player() -> void:
	GameState.lock_input(&"cutscene")


func unlock_player() -> void:
	GameState.unlock_input(&"cutscene")


func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


# --- Personajes ---

## Recorre `path` (direcciones). Si algo bloquea, espera un poco y se lo salta.
func walk(entity: Character, path: Array[Vector2i], running: bool = false,
		ignore_collisions: bool = false) -> void:
	await entity.walk(path, Character.RUN_TIME if running else Character.WALK_TIME, ignore_collisions)


## Camina hasta la casilla `tile` (primero en horizontal y luego en vertical).
func walk_to(entity: Character, tile: Vector2i, running: bool = false) -> void:
	await walk(entity, path_between(entity.tile_position(), tile), running)


## Camina en línea recta hasta quedarse justo delante de `target` y le mira.
func approach(entity: Character, target: Node2D, running: bool = false) -> void:
	var path := path_between(entity.tile_position(), Grid.to_tile(target.position))
	if not path.is_empty():
		path.pop_back()
	await walk(entity, path, running)
	entity.face_towards(target)


func face(entity: Character, dir: Vector2i) -> void:
	entity.face(dir)


func face_each_other(a: Character, b: Character) -> void:
	a.face_towards(b)
	b.face_towards(a)


## Globo sobre la cabeza ("!", "?", "..."). Espera a que se quite.
func emote(entity: Character, text: String = "!", duration: float = 0.6) -> void:
	await entity.show_emote(text, duration)


## Hace aparecer o desaparecer una entidad (solo mientras dure el mapa; para que
## sea permanente, usa sus flags visible_if_flag / hidden_if_flag).
func show_entity(entity: MapEntity) -> void:
	entity.set_forced_hidden(false)


func hide_entity(entity: MapEntity) -> void:
	entity.set_forced_hidden(true)


## = Grid.path_between(): primero en horizontal y luego en vertical.
func path_between(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	return Grid.path_between(from, to)


# --- Pantalla y sonido ---

func fade_out(duration: float = 0.25) -> void:
	await SceneManager.fade_out(duration)


func fade_in(duration: float = 0.25) -> void:
	await SceneManager.fade_in(duration)


func music(id: StringName, fade_time: float = 0.5) -> void:
	AudioManager.play_bgm(id, fade_time)


func sfx(id: StringName) -> void:
	AudioManager.play_se(id)


## Jingle (pausa la BGM y espera a que acabe).
func jingle(id: StringName) -> void:
	await AudioManager.play_me(id)


## Sacude la cámara del jugador.
func shake(strength: float = 3.0, duration: float = 0.3) -> void:
	var camera := _camera()
	if camera == null:
		return
	var tween := create_tween()
	var steps := maxi(int(duration / 0.05), 1)
	for i: int in steps:
		var offset := Vector2(randf_range(-strength, strength), randf_range(-strength, strength)).round()
		tween.tween_property(camera, ^"offset", offset, duration / steps)
	tween.tween_property(camera, ^"offset", Vector2.ZERO, 0.05)
	await tween.finished


## Lleva la cámara a la casilla `tile` del mapa actual.
func camera_pan(tile: Vector2i, duration: float = 0.6) -> void:
	var camera := _camera()
	if camera == null or SceneManager.current_map == null:
		return
	var start := camera.get_screen_center_position()
	camera.top_level = true
	camera.global_position = start
	var tween := create_tween()
	tween.tween_property(camera, ^"global_position",
		SceneManager.current_map.to_global(Grid.to_world(tile)), duration)
	await tween.finished


## Devuelve la cámara al jugador.
func camera_reset(duration: float = 0.4) -> void:
	var camera := _camera()
	if camera == null:
		return
	var player := SceneManager.player
	var tween := create_tween()
	tween.tween_property(camera, ^"global_position", player.global_position, duration)
	await tween.finished
	player.setup_camera(SceneManager.current_map)


# --- Partida ---

func teleport(map_id: StringName, spawn_id: StringName = MapRoot.DEFAULT_SPAWN,
		facing: Vector2i = Vector2i.ZERO) -> void:
	await SceneManager.change_map(map_id, spawn_id, facing)


func heal_party() -> void:
	var party := GameState.party as Party
	if party:
		party.heal_all()


## Da un objeto (a la mochila, si existe) y lo anuncia. Devuelve si se guardó.
func give_item(item_id: StringName, quantity: int = 1, announce: bool = true) -> bool:
	var bag: Variant = GameState.bag
	var stored: bool = bag is Object and bag.has_method(&"add")
	if stored:
		bag.add(item_id, quantity)
	else:
		push_warning("Cutscene.give_item: no hay mochila; '%s' no se ha guardado." % item_id)
	if announce:
		var data: ItemData = DataDB.item(item_id) if DataDB.has_item(item_id) else null
		var item_name := String(item_id) if data == null else (
			data.name if quantity == 1 else "%d %s" % [quantity, data.name_plural])
		AudioManager.play_me(&"key_item" if data and data.is_key_item() else &"item")
		await Dialogue.say("¡{player} ha recibido {item}!", null, {"item": item_name})
	return stored


## Da un Pokémon (al equipo o, si está lleno, al PC), lo apunta en la Pokédex y lo
## anuncia. Devuelve "party", "pc" o "" si no cabe.
func give_pokemon(pokemon: Pokemon, announce: bool = true) -> String:
	pokemon.original_trainer = GameState.player_name
	pokemon.trainer_id = GameState.trainer_id
	pokemon.met_level = pokemon.level
	pokemon.met_location = GameState.map_id
	pokemon.met_date = Time.get_date_string_from_system()
	var dex := GameState.pokedex as Pokedex
	if dex:
		dex.register(pokemon)
	var where := ""
	var party := GameState.party as Party
	var pc := GameState.pc as PCStorage
	if party and party.add(pokemon):
		where = "party"
	elif pc and pc.deposit(pokemon) != PCStorage.NO_SLOT:
		where = "pc"
	if announce and where != "":
		AudioManager.play_me(&"caught")
		await Dialogue.say("¡{player} ha recibido a {pokemon}!", null, {"pokemon": pokemon.display_name()})
		if where == "pc":
			await Dialogue.say("Como el equipo está lleno, {pokemon} se ha enviado al PC.", null,
				{"pokemon": pokemon.display_name()})
	return where


## Combate contra un entrenador de data/trainers. Si ganas, activa
## trainer_defeated:<id>. `options`: las de BattleSetup.trainer() (can_lose...).
func battle_trainer(trainer_id: StringName, options: Dictionary = {}) -> StringName:
	var outcome: StringName = await SceneManager.start_battle(BattleSetup.trainer(trainer_id, options))
	if outcome == SceneManager.OUTCOME_WIN:
		GameState.set_flag(StringName("trainer_defeated:%s" % trainer_id))
	return outcome


## Combate contra un salvaje (`what`: especie o Pokemon), p. ej. un estático.
func battle_wild(what: Variant, level: int = 5, options: Dictionary = {}) -> StringName:
	return await SceneManager.start_battle(BattleSetup.wild(what, level, options))


func _camera() -> Camera2D:
	return SceneManager.player.camera if SceneManager.player else null
