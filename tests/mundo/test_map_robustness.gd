extends GutTest
const SLOT := 98
var main: Node
func before_each() -> void:
	GameState.reset()
	SaveManager.delete_save(SLOT)
	main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)
func after_each() -> void:
	SaveManager.delete_save(SLOT)
	SceneManager._leave_game()
	main.queue_free()
	await wait_physics_frames(2)
	SceneManager.world = null
	SceneManager.ui_layer = null
	SceneManager.battle_layer = null
	SceneManager.transition_layer = null
	SceneManager._fade = null
	MapLoader.clear()

func test_todos_los_mapas_instanciados_warps_y_menos_medio_segundo() -> void:
	await SceneManager.start_new_game()
	for id: StringName in MapRoot.list_all():
		var prepared := MapLoader.prepare(id)
		assert_eq(prepared.error, OK, String(id))
		if prepared.error != OK:
			continue
		var map: MapRoot = prepared.map
		var spawns := map.get_node_or_null(^"Spawns")
		assert_not_null(spawns, String(id))
		for spawn: Node2D in spawns.get_children():
			assert_true(MapLoader.valid_tile(map, MapLoader.spawn_tile(map, spawn.name)), "%s/%s" % [id, spawn.name])
		for warp: Warp in map.get_warps():
			assert_eq(MapLoader.check_spawn(warp.target_map, warp.target_spawn), OK, "%s/%s" % [id, warp.name])
		var spawn: StringName = spawns.get_child(0).name
		map.free()
		assert_eq(await SceneManager.change_map(id, spawn, Vector2i.DOWN, false), OK)
		assert_lt(SceneManager.last_map_load_usec, 500000, String(id))
		await wait_physics_frames(2)
		assert_eq(SceneManager.current_map.get_map_id(), id)
		assert_false(GameState.input_locked)

func test_destino_invalido_conserva_mapa_partida_y_control() -> void:
	await SceneManager.start_new_game(&"", &"", {"slot": SLOT})
	var map := SceneManager.current_map
	var tile := GameState.player_tile
	GameState.player_name = "Javi"
	assert_eq(await SceneManager.change_map(&"no/existe"), ERR_FILE_NOT_FOUND)
	assert_eq(await SceneManager.change_map(map.get_map_id(), &"no_existe"), ERR_INVALID_DATA)
	assert_eq(await SceneManager.change_map_at(map.get_map_id(), Vector2i(999, 999)), ERR_INVALID_DATA)
	assert_eq(await SceneManager.start_new_game(&"no/existe"), ERR_FILE_NOT_FOUND)
	assert_eq(SceneManager.current_map, map)
	assert_eq(GameState.player_tile, tile)
	assert_eq(GameState.player_name, "Javi")
	assert_eq(GameState.slot, SLOT)
	assert_false(GameState.input_locked)
	assert_false(SceneManager.is_changing_map)
	SceneManager.is_changing_map = true
	assert_eq(await SceneManager.change_map(map.get_map_id()), ERR_BUSY)
	assert_eq(await SceneManager.continue_game(SLOT), ERR_BUSY)
	SceneManager.is_changing_map = false

func test_guardado_con_posicion_mala_no_reemplaza_partida() -> void:
	await SceneManager.start_new_game(&"", &"", {"slot": SLOT})
	GameState.player_name = "Javi"
	assert_eq(SaveManager.save_game(SLOT), OK)
	var file := FileAccess.open(SaveManager.slot_path(SLOT), FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	data.state.position.tile = [999, 999]
	file = FileAccess.open(SaveManager.slot_path(SLOT), FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	var map := SceneManager.current_map
	assert_eq(await SceneManager.continue_game(SLOT), ERR_INVALID_DATA)
	assert_eq(GameState.player_name, "Javi")
	assert_eq(SceneManager.current_map, map)
	assert_true(GameState.in_game)
	assert_false(GameState.input_locked)

func test_cache_packed_no_comparte_instancias_de_mapa() -> void:
	var first := MapLoader.prepare(&"test/test_room")
	var second := MapLoader.prepare(&"test/test_room")
	assert_eq(first.error, OK)
	assert_eq(second.error, OK)
	assert_ne(first.map, second.map)
	first.map.get_node("Entities/Profesor").position = Vector2(999, 999)
	assert_ne(first.map.get_node("Entities/Profesor").position, second.map.get_node("Entities/Profesor").position)
	first.map.free()
	second.map.free()

func test_mapa_explicito_sin_spawn_usa_default_y_boot_normal_usa_intro() -> void:
	assert_eq(await SceneManager.start_new_game(&"muestras/ruta"), OK)
	var expected: Vector2i = MapLoader.spawn_tile(SceneManager.current_map, &"default")
	assert_eq(GameState.player_tile, expected)
	SceneManager._leave_game()
	assert_eq(await SceneManager.start_new_game(), OK)
	var config := MvpLocations.new_game_config()
	expected = MapLoader.spawn_tile(SceneManager.current_map, StringName(config.spawn))
	assert_eq(GameState.player_tile, expected)
