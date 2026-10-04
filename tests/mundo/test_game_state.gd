extends GutTest
## GameState: flags, variables, dinero, bloqueo de input y guardado (Agente 1).


func before_each() -> void:
	GameState.new_game()


func after_all() -> void:
	GameState.reset()


func test_flags() -> void:
	assert_false(GameState.flag(&"got_pokedex"))
	watch_signals(EventBus)
	GameState.set_flag(&"got_pokedex")
	assert_true(GameState.flag(&"got_pokedex"))
	assert_signal_emitted_with_parameters(EventBus, "flag_changed", [&"got_pokedex", true])
	GameState.clear_flag(&"got_pokedex")
	assert_false(GameState.flag(&"got_pokedex"))
	assert_false(GameState.flags.has(&"got_pokedex"), "las flags apagadas no se guardan")


func test_variables() -> void:
	GameState.set_var(&"starter", 2)
	GameState.set_var(&"nombre", &"texto")
	assert_eq(GameState.var_int(&"starter"), 2)
	assert_eq(GameState.get_var(&"nombre"), "texto", "StringName se guarda como String")
	assert_eq(GameState.var_int(&"no_existe", 7), 7)
	GameState.clear_var(&"starter")
	assert_false(GameState.has_var(&"starter"))


func test_dinero() -> void:
	var start := GameState.money
	GameState.add_money(500)
	assert_eq(GameState.money, start + 500)
	assert_false(GameState.spend_money(GameState.money + 1))
	assert_true(GameState.spend_money(500))
	assert_eq(GameState.money, start)
	GameState.add_money(-10_000_000)
	assert_eq(GameState.money, 0, "nunca baja de 0")
	GameState.add_money(100_000_000)
	assert_eq(GameState.money, GameState.max_money())


func test_bloqueo_de_input_por_motivo() -> void:
	assert_false(GameState.input_locked)
	GameState.lock_input(&"menu")
	GameState.lock_input(&"menu")
	GameState.lock_input(&"dialogue")
	GameState.unlock_input(&"menu")
	assert_true(GameState.input_locked)
	GameState.unlock_input(&"menu")
	assert_true(GameState.is_input_locked_by(&"dialogue"))
	GameState.unlock_input(&"dialogue")
	assert_false(GameState.input_locked)
	GameState.unlock_input(&"nada")
	assert_false(GameState.input_locked, "desbloquear un motivo que no estaba no hace nada")


func test_ida_y_vuelta_por_json() -> void:
	GameState.player_name = "Javi"
	GameState.player_gender = &"female"
	GameState.set_flag(&"starter_chosen")
	GameState.set_var(&"starter", 3)
	GameState.set_var(&"ratio", 0.5)
	GameState.set_var(&"activo", true)
	GameState.add_badge(&"badge_1")
	GameState.map_id = &"test/test_outdoor"
	GameState.player_tile = Vector2i(4, 7)
	GameState.player_facing = Vector2i.LEFT
	GameState.set_healing_spot(&"test/test_room", &"default")
	var before := GameState.to_dict()
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(before))
	GameState.reset()
	GameState.from_dict(parsed)
	assert_eq(GameState.player_name, "Javi")
	assert_eq(GameState.player_gender, &"female")
	assert_true(GameState.flag(&"starter_chosen"))
	assert_true(GameState.get_var(&"starter") is int, "los int siguen siendo int tras pasar por JSON")
	assert_eq(GameState.var_int(&"starter"), 3)
	assert_almost_eq(float(GameState.get_var(&"ratio")), 0.5, 0.0001)
	assert_eq(GameState.get_var(&"activo"), true)
	assert_true(GameState.has_badge(&"badge_1"))
	assert_eq(GameState.player_tile, Vector2i(4, 7))
	assert_eq(GameState.player_facing, Vector2i.LEFT)
	assert_eq(GameState.healing_map, &"test/test_room")
	assert_eq(JSON.stringify(GameState.to_dict()), JSON.stringify(before))


func test_direcciones() -> void:
	for dir: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		assert_eq(GameState.dir_from_name(GameState.dir_name(dir)), dir)
	assert_eq(GameState.dir_from_name("cualquiera"), Vector2i.DOWN)
