extends GutTest
var main: Node
var old_speed: int
func before_each() -> void:
	GameState.reset()
	DataDB.clear_patch()
	old_speed = Dialogue._box.text_speed
	Dialogue._box.text_speed = 0
	main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)
func after_each() -> void:
	SceneManager._leave_game()
	main.queue_free()
	await wait_physics_frames(2)
	SceneManager.world = null
	SceneManager.ui_layer = null
	SceneManager.battle_layer = null
	SceneManager.transition_layer = null
	SceneManager._fade = null
	Dialogue._box.text_speed = old_speed
	GameState.reset()
	DataDB.clear_patch()
	MapLoader.clear()
func press(action: StringName = &"accept") -> void:
	for down: bool in [true,false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = down
		Input.parse_input_event(event)
func test_professor_consumes_only_the_laboratory_marker_without_editing_placements() -> void:
	var prepared := MapLoader.prepare(&"madrid/laboratorio")
	assert_eq(prepared.error, OK)
	var lab: MapRoot = prepared.map
	var professor := lab.get_entities().get_node("ProfesorUnicoos") as ProfessorNPC
	assert_not_null(professor)
	assert_eq(professor.tile_position(), MapLoader.spawn_tile(lab, &"profesor"))
	NewGameStory.apply(lab)
	assert_eq(lab.get_entities().find_children("ProfesorUnicoos", "", false, false).size(), 1)
	lab.free()
	var town := MapLoader.prepare(&"pozuelo/exterior")
	assert_false((town.map as MapRoot).get_entities().has_node("ProfesorUnicoos"))
	town.map.free()
	assert_eq(WorldNames.value(&"professor"), "Unicoos")
	assert_not_null(ProfessorNPC.portrait())
	assert_eq(ProfessorNPC.portrait(true).atlas.resource_path, "res://assets/sprites/characters/unicoos_mapa.png")
	assert_eq(ProfessorNPC.portrait(true).region, Rect2(380,185,465,925))

func test_receive_tutorial_and_rewards_are_continuous_and_do_not_repeat() -> void:
	assert_eq(await SceneManager.start_new_game(&"madrid/laboratorio", &"default", {"starter_seed":53}), OK)
	GameState.player_name = "Javi"
	GameState.rival_name = "Rival de prueba"
	GameState.set_flag(&"story_intro_done")
	var done: Array = []
	var play := func() -> void:
		await Cutscene.play(NewGameStoryEvent, null, {"stage":"professor"})
		done.append(true)
	play.call()
	for frame: int in 1600:
		await wait_physics_frames(1)
		if Dialogue.is_open: press()
		for node: Node in SceneManager.battle_layer.get_children():
			if node is BattleScene:
				node.fast = true
				for menu: GridMenu in [node._command_menu,node._move_menu,node._list_menu]:
					if menu.is_choosing: press()
		if not done.is_empty(): break
	assert_eq(done, [true])
	assert_eq(GameState.map_id, &"madrid/laboratorio")
	assert_true(GameState.flag(&"starter_chosen"))
	assert_true(GameState.flag(&"rival_intro_done"))
	assert_true(GameState.flag(&"story_rewards_done"))
	assert_true(GameState.flag(&"got_pokedex"))
	assert_eq(GameState.bag.count(&"pokeball"), 5)
	assert_eq(GameState.party.members[0].species_id, &"dhelmise")
	assert_eq(GameState.party.members[0].current_hp, GameState.party.members[0].max_hp())
	await Cutscene.play(NewGameStoryEvent, null, {"stage":"professor"})
	assert_eq(GameState.bag.count(&"pokeball"), 5)
	assert_eq(GameState.party.size(), 1)
	assert_false(GameState.input_locked)
