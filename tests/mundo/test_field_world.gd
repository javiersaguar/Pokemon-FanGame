extends GutTest
var original: Dictionary
func before_each() -> void:
	original = GameState.world_config.duplicate(true)
	GameState.new_game()
func after_each() -> void:
	GameState.world_config = original
	GameState.reset()
	SceneManager.current_map = null

func test_conexiones_cuatro_bordes_y_offset() -> void:
	var bounds := Rect2i(0, 0, 10, 8)
	var samples := {"east": [Vector2i(10, 3), Vector2i(0, 5)], "west": [Vector2i(-1, 3), Vector2i(9, 5)],
		"north": [Vector2i(3, -1), Vector2i(5, 7)], "south": [Vector2i(3, 8), Vector2i(5, 0)]}
	for edge: String in samples:
		var connection := MapConnection.new()
		connection.edge = edge
		connection.offset = 2
		assert_true(connection.matches(samples[edge][0], bounds))
		assert_false(connection.matches(Vector2i(4, 4), bounds))
		assert_eq(connection.arrival(samples[edge][0], bounds), samples[edge][1])

func test_herramienta_por_mochila_y_flag_sin_consumo() -> void:
	assert_false(FieldActions.available(&"cut"), "ID pendiente deshabilita")
	GameState.world_config.field.actions.cut = {"item": "bicycle", "required_flag": "test_tool"}
	GameState.bag.add(&"bicycle")
	assert_false(FieldActions.available(&"cut"))
	GameState.set_flag(&"test_tool")
	assert_true(FieldActions.available(&"cut"))
	assert_eq(GameState.bag.count(&"bicycle"), 1)
	var map := MapRoot.new()
	map.data = MapData.new()
	map.data.can_bike = false
	assert_false(FieldActions.available(&"bike", map))
	map.free()

func test_obstaculo_corte_y_fuerza_con_fisica_real() -> void:
	var map: MapRoot = load("res://maps/test/test_room.tscn").instantiate()
	add_child_autofree(map)
	SceneManager.current_map = map
	var player: Player = load("res://src/overworld/player/player.tscn").instantiate()
	map.add_child(player)
	player.set_process(false)
	player.place_at(Vector2i(11, 8), Vector2i.RIGHT)
	var actor = load("res://src/overworld/npc/npc.tscn").instantiate()
	actor.set_script(FieldObstacle)
	map.add_child(actor)
	actor.position = Grid.to_world(Vector2i(12, 8))
	GameState.world_config.field.actions.strength.item = "bicycle"
	GameState.world_config.field.actions.cut.item = "bicycle"
	GameState.bag.add(&"bicycle")
	await wait_physics_frames(2)
	actor.action = "strength"
	await actor.interact(player)
	assert_eq(actor.tile_position(), Vector2i(13, 8))
	assert_eq(GameState.bag.count(&"bicycle"), 1)
	actor.action = "cut"
	await actor.interact(player)
	assert_false(actor.is_present())
	await wait_physics_frames(2)
	assert_null(player.find_entity_at(Vector2i(13, 8)))

func test_transporte_no_activa_sin_arte_y_restauracion() -> void:
	var player: Player = load("res://src/overworld/player/player.tscn").instantiate()
	add_child_autofree(player)
	player.set_process(false)
	GameState.bag.add(&"bicycle")
	GameState.world_config.field.transport_sheets.male.bike = null
	assert_false(player.set_transport_mode(&"bike"), "exige hoja entregada por arte")
	GameState.world_config.field.transport_sheets.male.bike = "res://assets/sprites/characters/player_male.png"
	assert_true(player.set_transport_mode(&"bike"), "fixture usa hoja real, sin generar arte")
	assert_eq(FieldActions.transport(), &"bike")
	assert_eq(GameState.to_dict().vars.transport, "bike")
	assert_true(player.set_transport_mode(&"walk"))
	assert_eq(FieldActions.transport(), &"walk")

func test_vuelo_lista_solo_destinos_visitados() -> void:
	GameState.world_config.field.flight_destinations = [{"id": "prueba", "map": "test/test_room", "spawn": "default"}]
	assert_eq(WorldTravel.destinations().size(), 0)
	var map: MapRoot = load("res://maps/test/test_room.tscn").instantiate()
	WorldTravel.record_visit(map)
	assert_eq(WorldTravel.destinations().size(), 1)
	assert_has(GameState.to_dict().flags, "visited_map:test/test_room")
	assert_eq(await WorldTravel.fly(&"prueba"), ERR_UNAVAILABLE, "sin mapa/herramienta no vuela")
	map.free()
