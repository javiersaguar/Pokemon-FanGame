extends GutTest
## Evento de los personajes colocados por datos (src/events/personajes/personaje_event.gd): combates seguidos
## con curación, premio al ganar (las joyas de Zapatero) y la policía que se lleva a Ábalos y Koldo.
## Los combates son falsos (ganan o pierden al momento) para no depender de la escena de combate.

const TRAINER_SCENE := preload("res://src/overworld/trainers/trainer_npc.tscn")
const PLAYER_SCENE := preload("res://src/overworld/player/player.tscn")
const EVENT := preload("res://src/events/personajes/personaje_event.gd")


class FakeEvent extends "res://src/events/personajes/personaje_event.gd":
	static var fought: Array[StringName] = []
	static var lose_at: StringName = &""
	static var heals := 0

	func battle(t: TrainerNPC) -> StringName:
		fought.append(t.trainer_id)
		if t.trainer_id == lose_at:
			return SceneManager.OUTCOME_LOSE
		GameState.set_flag(StringName(TrainerNPC.DEFEATED_FLAG % t.trainer_id))
		return SceneManager.OUTCOME_WIN

	func battle_group(group: Array[TrainerNPC]) -> StringName:
		for t: TrainerNPC in group:
			fought.append(t.trainer_id)
			GameState.set_flag(StringName(TrainerNPC.DEFEATED_FLAG % t.trainer_id))
		return SceneManager.OUTCOME_WIN

	func screen_fade(_out: bool) -> void:
		pass

var _world: Node2D
var _player: Player
var _saved_player: Player
var _saved_speed: int


func before_each() -> void:
	GameState.reset()
	FakeEvent.fought.clear()
	FakeEvent.lose_at = &""
	_saved_speed = Dialogue.text_speed
	Dialogue.text_speed = 0
	_world = Node2D.new()
	add_child_autofree(_world)
	_player = PLAYER_SCENE.instantiate()
	_world.add_child(_player)
	_saved_player = SceneManager.player
	SceneManager.player = _player


func after_each() -> void:
	SceneManager.player = _saved_player
	Dialogue.text_speed = _saved_speed
	GameState.clear_input_locks()
	for voice: AudioStreamPlayer in AudioManager._se:
		voice.stop()
		voice.stream = null
	await wait_process_frames(2)


func _trainer(id: StringName, tile: Vector2i, options: Dictionary, sight := 0) -> TrainerNPC:
	var t: TrainerNPC = TRAINER_SCENE.instantiate()
	t.name = "Personaje_" + String(id)
	t.trainer_id = id
	t.sight_range = sight
	t.challenge_event = FakeEvent
	t.set_meta(&"personaje", options)
	_world.add_child(t)
	t.place_at(tile, Vector2i.DOWN)
	return t


func _press_accept() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"accept"
		event.pressed = pressed
		Input.parse_input_event(event)


func _finish_cutscene(timeout := 8.0) -> void:
	var waited := 0.0
	while (Cutscene.is_running() or Dialogue.is_open) and waited < timeout:
		if Dialogue.is_open:
			_press_accept()
		await wait_physics_frames(2)
		waited += 2.0 / Engine.physics_ticks_per_second


func test_los_datos_dan_el_evento_a_las_parejas_y_las_series() -> void:
	var prepared := MapLoader.prepare(&"las_palmas/canteras")
	var map: MapRoot = prepared["map"]
	var zapatero := map.get_entities().get_node_or_null(^"Personaje_zapatero") as TrainerNPC
	var maduro := map.get_entities().get_node_or_null(^"Personaje_maduro") as TrainerNPC
	assert_not_null(zapatero)
	assert_not_null(maduro)
	if zapatero and maduro:
		assert_eq(zapatero.challenge_event.resource_path, CharacterPlacements.PERSONAJE_EVENT)
		assert_eq(maduro.challenge_event.resource_path, CharacterPlacements.PERSONAJE_EVENT, "la pareja también usa el evento")
		assert_eq(str(EVENT.options_of(zapatero)["premio"]["objeto"]), "joyas_zapatero")
		assert_true(EVENT.options_of(maduro).is_empty())
	map.free()
	prepared = MapLoader.prepare(&"rocafonda/exterior")
	map = prepared["map"]
	for id: String in ["lamine", "hustlehard304", "keyne"]:
		var member := map.get_entities().get_node_or_null(NodePath("Personaje_" + id)) as TrainerNPC
		assert_not_null(member, id)
		if member:
			assert_eq(EVENT.options_of(member)["serie"], ["keyne", "hustlehard304", "lamine"], id)
	map.free()


func test_las_joyas_de_zapatero_existen_y_valen_mucho() -> void:
	assert_true(DataDB.has_item(&"joyas_zapatero"))
	var item := DataDB.item(&"joyas_zapatero")
	assert_eq(item.name, "Joyas de Zapatero")
	assert_gte(item.sell_price(), 50000, "se venden por muchas monedas (decisión de Javier)")
	assert_true(ResourceLoader.exists("res://assets/sprites/items/joyas_zapatero.png"))


func test_zapatero_da_las_joyas_al_perder_y_solo_una_vez() -> void:
	var options := {"premio": {"objeto": "joyas_zapatero", "cantidad": 1}}
	var zapatero := _trainer(&"zapatero", Vector2i(4, 4), options)
	var maduro := _trainer(&"maduro", Vector2i(5, 4), {})
	zapatero.partner = zapatero.get_path_to(maduro)
	_player.place_at(Vector2i(4, 5), Vector2i.UP)
	await wait_physics_frames(2)
	maduro.interact(_player)
	await _finish_cutscene()
	assert_eq(FakeEvent.fought, [&"maduro", &"zapatero"] as Array[StringName], "un combate doble, por cualquiera de los dos")
	assert_eq(GameState.bag.count(&"joyas_zapatero"), 1)
	var event := FakeEvent.new()
	await event.give_reward(zapatero, options["premio"])
	assert_eq(GameState.bag.count(&"joyas_zapatero"), 1, "no las da dos veces")


func test_la_policia_se_lleva_a_abalos_y_koldo() -> void:
	var options := {"detencion": {"texto": "¡Alto! ¡Policía Nacional!"}}
	var abalos := _trainer(&"abalos", Vector2i(6, 4), options)
	var koldo := _trainer(&"koldo", Vector2i(6, 6), {})
	abalos.partner = abalos.get_path_to(koldo)
	_player.place_at(Vector2i(3, 4), Vector2i.RIGHT)
	await wait_physics_frames(2)
	abalos.interact(_player)
	var saw_police := false
	var saw_car := false
	var waited := 0.0
	while (Cutscene.is_running() or Dialogue.is_open) and waited < 10.0:
		saw_police = saw_police or _world.get_node_or_null(^"Policia_abalos") != null
		saw_car = saw_car or _world.get_node_or_null(^"CochePolicia") != null
		if Dialogue.is_open:
			_press_accept()
		await wait_physics_frames(2)
		waited += 2.0 / Engine.physics_ticks_per_second
	assert_true(saw_car, "llega el coche de policía")
	assert_true(saw_police, "un agente se pone al lado")
	assert_true(GameState.flag(&"detenido:abalos"))
	assert_true(GameState.flag(&"detenido:koldo"))
	assert_false(abalos.is_present(), "se lo llevan")
	assert_false(koldo.is_present())
	await wait_process_frames(2)
	assert_null(_world.get_node_or_null(^"CochePolicia"), "el coche se va")
	assert_null(_world.get_node_or_null(^"Policia_abalos"))
	assert_false(CharacterPlacements.is_available({"hasta": {"flag": "detenido:abalos"}}), "no vuelven a salir en ese sitio")


func test_la_serie_son_tres_combates_seguidos_en_orden() -> void:
	var serie := {"serie": ["keyne", "hustlehard304", "lamine"]}
	var lamine := _trainer(&"lamine", Vector2i(4, 2), serie)
	_trainer(&"hustlehard304", Vector2i(6, 2), serie)
	_trainer(&"keyne", Vector2i(8, 2), serie)
	_player.place_at(Vector2i(4, 3), Vector2i.UP)
	await wait_physics_frames(2)
	lamine.interact(_player)
	await _finish_cutscene()
	assert_eq(FakeEvent.fought, [&"keyne", &"hustlehard304", &"lamine"] as Array[StringName])
	for id: String in ["keyne", "hustlehard304", "lamine"]:
		assert_true(GameState.flag(StringName("trainer_defeated:" + id)), id)


func test_si_pierdes_la_serie_se_para_y_luego_sigue_por_donde_iba() -> void:
	var serie := {"serie": ["pokealex", "sekiam", "folagor"]}
	var folagor := _trainer(&"folagor", Vector2i(4, 2), serie)
	_trainer(&"sekiam", Vector2i(6, 2), serie)
	_trainer(&"pokealex", Vector2i(8, 2), serie)
	_player.place_at(Vector2i(4, 3), Vector2i.UP)
	await wait_physics_frames(2)
	FakeEvent.lose_at = &"sekiam"
	folagor.interact(_player)
	await _finish_cutscene()
	assert_eq(FakeEvent.fought, [&"pokealex", &"sekiam"] as Array[StringName], "pierdes con Sekiam y se acaba")
	FakeEvent.fought.clear()
	FakeEvent.lose_at = &""
	folagor.interact(_player)
	await _finish_cutscene()
	assert_eq(FakeEvent.fought, [&"sekiam", &"folagor"] as Array[StringName], "el ya ganado no repite")
