extends SceneTree
## Genera las escenas de la sala de pruebas con el tileset de exteriores
## (assets/tilesets/exterior). Pide `-- --force` si ya existen, porque las
## sobrescribe. Las coordenadas de entidades, warps y spawns las usan los tests
## (tests/mundo/) y la partida automatizada: si las cambias, cámbialas también ahí.
## Uso: godot --headless --path . -s res://maps/test/build_test_maps.gd -- --force

const ROOM := "res://maps/test/test_room.tscn"
const OUTDOOR := "res://maps/test/test_outdoor.tscn"
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3


func _initialize() -> void:
	await process_frame
	var force := "--force" in OS.get_cmdline_user_args()
	for path: String in [ROOM, OUTDOOR]:
		if FileAccess.file_exists(path) and not force:
			push_error("build_test_maps: '%s' ya existe; usa -- --force para sobrescribirlo." % path)
			quit(1)
			return
	var builder: GDScript = load("res://maps/_tools/map_builder.gd")
	print("%s: %s" % [ROOM, error_string(_room(builder).save(ROOM))])
	print("%s: %s" % [OUTDOOR, error_string(_outdoor(builder).save(OUTDOOR))])
	quit()


## "Sala" de pruebas: un patio cerrado por el bosque (hasta que haya tiles de
## interior), con los NPCs y objetos de prueba.
func _room(builder: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"test/test_room"
	data.display_name = "Sala de pruebas"
	data.healing_spot = &"test/test_room"
	var m: RefCounted = builder.new("TestRoom", Vector2i(20, 12), data, 3)
	m.fill_grass()
	for r: Rect2i in [Rect2i(0, 0, 20, 2), Rect2i(0, 2, 2, 8), Rect2i(18, 2, 2, 8), Rect2i(0, 10, 8, 2),
			Rect2i(12, 10, 8, 2)]:
		m.forest(r)
	m.pattern(Rect2i(2, 2, 16, 8), ExteriorTiles.COBBLE_PINK, Vector2i(4, 2))
	m.pattern(Rect2i(8, 10, 4, 2), ExteriorTiles.COBBLE_PINK, Vector2i(4, 2))
	m.build_forest()
	m.spawn("default", Vector2i(10, 5))
	m.spawn("bedroom", Vector2i(10, 5))
	m.spawn("laboratory", Vector2i(4, 4))
	m.spawn("from_outdoor", Vector2i(9, 9))
	m.warp("ToOutdoor", Vector2i(9, 11), &"test/test_outdoor", &"from_room", 1)
	m.warp("ToOutdoor2", Vector2i(10, 11), &"test/test_outdoor", &"from_room", 1)
	m.npc("Profesor", "professor", Vector2i(10, 4), DOWN, PackedStringArray(),
		{"display_name": "Profesor POR DEFINIR", "event": load("res://src/events/mvp/mvp_story_event.gd"),
		"event_params": {"stage": "professor", "player_name": "POR DEFINIR", "rival_name": "POR DEFINIR"}})
	m.npc("Rival", "rival", Vector2i(7, 4), DOWN, PackedStringArray(),
		{"display_name": "Rival POR DEFINIR", "event": load("res://src/events/mvp/mvp_story_event.gd"),
		"event_params": {"stage": "rival"}, "visible_if_flag": &"starter_chosen", "hidden_if_flag": &"rival_intro_done"})
	for stage: String in ["bedroom", "laboratory"]:
		# Carga diferida: SceneTree -s compila antes de registrar los autoloads.
		var trigger := Node2D.new()
		trigger.set_script(load("res://src/overworld/trigger/trigger.gd"))
		trigger.name = "Historia_" + stage
		trigger.set(&"event", load("res://src/events/mvp/mvp_story_event.gd"))
		trigger.set(&"event_params", {"stage": stage})
		trigger.position = Grid.to_world(Vector2i(10, 6) if stage == "bedroom" else Vector2i(4, 4))
		trigger.set(&"mode", 0 if stage == "bedroom" else 1)
		trigger.set(&"required_flag", &"story_intro_done" if stage == "bedroom" else &"story_bedroom_done")
		trigger.set(&"blocked_by_flag", &"story_bedroom_done" if stage == "bedroom" else &"story_lab_intro_done")
		m.root.get_node(^"Triggers").add_child(trigger)
	var tester: Node = m.npc("Probador", "trainer", Vector2i(4, 6), RIGHT, PackedStringArray(),
		{"display_name": "Probador"})
	tester.set_script(load("res://maps/test/test_battle_npc.gd"))
	tester.set(&"sprite_sheet", load(MapBuilder.CHARACTERS + "trainer.png"))
	tester.set(&"display_name", "Probador")
	tester.set(&"initial_facing", RIGHT)
	m.npc("Paseante", "npc_woman", Vector2i(15, 6), DOWN,
		PackedStringArray(["Doy vueltas por la sala para probar el paseo de los NPCs."]), {"wander": true})
	m.npc("Dependiente", "clerk", Vector2i(9, 7), DOWN, PackedStringArray(),
		{"display_name": "Dependiente", "event": load("res://src/events/common/open_shop_event.gd"), "event_params": {"shop_id": &"tienda_ciudad2"}})
	m.npc("Enfermera", "nurse", Vector2i(15, 3), DOWN, PackedStringArray(),
		{"display_name": "Enfermera", "event": load("res://src/events/common/heal_party_event.gd")})
	m.item("Pocion", Vector2i(17, 8), &"potion")
	m.item("CarameloOculto", Vector2i(2, 8), &"rarecandy", true)
	for i: int in 3:
		var ball: Node2D = (load("res://src/overworld/starter_ball/starter_ball.tscn") as PackedScene).instantiate()
		ball.name = "Inicial%d" % (i + 1)
		ball.position = Grid.to_world(Vector2i(3 + i, 3))
		ball.set(&"starter_slot", StringName("starter_%d" % (i + 1)))
		ball.set(&"starter_index", i + 1)
		ball.set(&"visible_if_flag", &"story_lab_intro_done")
		m.entities.add_child(ball)
	return m


func _outdoor(builder: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"test/test_outdoor"
	data.display_name = "Exterior de pruebas"
	data.encounter_table = &"test_outdoor"
	data.healing_spot = &"test/test_room"
	var m: RefCounted = builder.new("TestOutdoor", Vector2i(30, 20), data, 5)
	m.fill_grass()
	for r: Rect2i in [Rect2i(0, 0, 2, 20), Rect2i(28, 0, 2, 20), Rect2i(10, 0, 18, 2), Rect2i(2, 18, 26, 2)]:
		m.forest(r)
	var path: Array[Vector2i] = []
	for r: Rect2i in [Rect2i(5, 6, 1, 2), Rect2i(5, 7, 17, 1), Rect2i(21, 7, 1, 11)]:
		path.append_array(MapBuilder.cells(r))
	m.terrain(path, ExteriorTiles.TERRAIN_PATH)
	var grass: Array[Vector2i] = []
	for r: Rect2i in [Rect2i(15, 3, 6, 4), Rect2i(2, 11, 5, 3)]:
		grass.append_array(MapBuilder.cells(r))
	m.terrain(grass, ExteriorTiles.TERRAIN_TALL_GRASS)
	m.pond(Rect2i(24, 4, 3, 4))
	m.ledge(13, 20, 13)
	m.build_forest()
	m.object(&"casa_pequena", Vector2i(3, 5))
	m.flowers(Rect2i(3, 9, 2, 1))
	m.flowers(Rect2i(26, 9, 2, 1))
	m.flowers(Rect2i(12, 16, 2, 1))
	m.deco(Vector2i(7, 6), ExteriorTiles.SIGN)
	m.sign("Cartel", Vector2i(7, 6), PackedStringArray(["EXTERIOR DE PRUEBAS",
		"La hierba alta da encuentros si existe data/encounters/test_outdoor.json."]))
	m.warp("ToRoom", Vector2i(5, 4), &"test/test_room", &"from_outdoor", 4)
	m.spawn("default", Vector2i(10, 9))
	m.spawn("from_room", Vector2i(5, 5))
	m.npc("Vecino", "npc_man", Vector2i(12, 9), DOWN, PackedStringArray(["¡Cuidado con la hierba alta!"]),
		{"wander": true})
	m.npc("Abuelo", "npc_old_man", Vector2i(23, 9), LEFT, PackedStringArray(["El agua de ahí no se cruza sin Surf."]))
	m.item("PokeBalls", Vector2i(26, 10), &"pokeball")
	m.item("PocionOculta", Vector2i(27, 3), &"potion", true)
	var trigger := Node2D.new()
	trigger.set_script(load("res://src/overworld/trigger/trigger.gd"))
	trigger.name = "DisparadorDePrueba"
	trigger.position = Grid.to_world(Vector2i(12, 7))
	trigger.set(&"event", load("res://maps/test/test_trigger_event.gd"))
	trigger.set(&"once_flag", &"test_trigger_done")
	m.root.get_node(^"Triggers").add_child(trigger)
	return m
