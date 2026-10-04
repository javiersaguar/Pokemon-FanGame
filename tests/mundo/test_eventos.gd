extends GutTest
## Cutscene, StoryEvent y disparadores (Fase 13.1, Agente 1).


class EventoQueApunta:
	extends StoryEvent

	func run() -> void:
		GameState.set_var(&"test_param", int(param("valor", 0)))
		await Cutscene.wait(0.01)


func before_each() -> void:
	GameState.new_game()


func after_all() -> void:
	GameState.reset()


func test_camino_entre_casillas() -> void:
	var path := Cutscene.path_between(Vector2i(1, 1), Vector2i(3, 0))
	assert_eq(path, [Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.UP] as Array[Vector2i])
	assert_eq(Cutscene.path_between(Vector2i(2, 2), Vector2i(2, 2)), [] as Array[Vector2i])


func test_play_ejecuta_bloquea_y_activa_la_flag() -> void:
	watch_signals(Cutscene)
	var done := [false]
	var play := func() -> void:
		await Cutscene.play(EventoQueApunta, null, {"valor": 7}, &"test_evento_hecho")
		done[0] = true
	play.call()
	assert_true(GameState.is_input_locked_by(&"cutscene"), "bloquea el control mientras dura")
	assert_true(Cutscene.is_running())
	await wait_until(func() -> bool: return done[0], 2.0)
	assert_eq(GameState.var_int(&"test_param"), 7, "recibe los params")
	assert_true(GameState.flag(&"test_evento_hecho"))
	assert_false(GameState.input_locked)
	assert_false(Cutscene.is_running())
	assert_signal_emitted(Cutscene, "event_finished")


func test_dar_un_pokemon() -> void:
	GameState.player_name = "Javi"
	var p := Pokemon.create(&"pikachu", 5)
	var where: String = await Cutscene.give_pokemon(p, false)
	assert_eq(where, "party")
	assert_eq(p.original_trainer, "Javi")
	assert_true((GameState.pokedex as Pokedex).is_caught(&"pikachu"))
	var party := GameState.party as Party
	while not party.is_full():
		party.add(Pokemon.create(&"rattata", 2))
	where = await Cutscene.give_pokemon(Pokemon.create(&"pidgey", 3), false)
	assert_eq(where, "pc", "con el equipo lleno va al PC")


func test_condiciones_del_disparador() -> void:
	var trigger := Trigger.new()
	add_child_autofree(trigger)
	assert_false(trigger.can_fire(), "sin evento no se dispara")
	trigger.event = EventoQueApunta
	assert_true(trigger.can_fire())
	trigger.required_flag = &"test_requisito"
	assert_false(trigger.can_fire())
	GameState.set_flag(&"test_requisito")
	assert_true(trigger.can_fire())
	trigger.once_flag = &"test_una_vez"
	GameState.set_flag(&"test_una_vez")
	assert_false(trigger.can_fire(), "con once_flag activa ya no se repite")
	trigger.position = Grid.to_world(Vector2i(2, 2))
	trigger.size = Vector2i(2, 1)
	assert_true(trigger.contains_tile(Vector2i(3, 2)))
	assert_false(trigger.contains_tile(Vector2i(2, 3)))


func test_inicial_sin_datos() -> void:
	const Choose := preload("res://src/events/common/choose_starter_event.gd")
	if DataDB.has_method(&"starter"):
		pass_test("DataDB.starter() ya existe: lo prueba el test de integración.")
		return
	assert_eq(Choose.resolve(&"starter_1"), {}, "sin DataDB.starter() no inventa especies (R.2)")
