extends GutTest
## Recorrido de prototipo con escenas, teclado, guion y motor reales; no usa Debug.
const SLOT := 98
var main: Node
var _speed: int
var _done := false
func before_each() -> void:
	GameState.reset()
	DataDB.clear_patch()
	SaveManager.delete_save(SLOT)
	_speed = Dialogue._box.text_speed
	Dialogue._box.text_speed = 0
	main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)
func after_each() -> void:
	SaveManager.delete_save(SLOT)
	Dialogue._box.text_speed = _speed
	SceneManager._leave_game()
	main.queue_free()
	await wait_physics_frames(2)
	SceneManager.world = null
	SceneManager.ui_layer = null
	SceneManager.battle_layer = null
	SceneManager.transition_layer = null
	SceneManager._fade = null
	MapLoader.clear()
func press(action: StringName = &"accept") -> void:
	for down: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = down
		Input.parse_input_event(event)
func autoplay() -> void:
	for frame: int in 2400:
		await wait_physics_frames(1)
		for node: Node in SceneManager.ui_layer.get_children():
			if node.get_script() == load("res://src/main/identity_fallback.gd"):
				node.entry.text_submitted.emit("Panchito" if node.kind == &"nickname" else ("Javi" if node.kind == &"player" else "Azul"))
		if Dialogue.is_open:
			press()
		for node: Node in SceneManager.battle_layer.get_children():
			if node is BattleScene:
				node.fast = true
				var menu: GridMenu
				if node._command_menu.is_choosing:
					menu = node._command_menu
				elif node._move_menu.is_choosing:
					menu = node._move_menu
				elif node._list_menu.is_choosing:
					menu = node._list_menu
				if menu != null:
					for index: int in menu.disabled.size():
						if not menu.disabled[index]:
							menu.select(index)
							break
					press()
		if _done and not Cutscene.is_running() and not SceneManager.is_busy() and not GameState.input_locked:
			return
	assert_true(false, "El recorrido no termina dentro del límite")
func event(script: GDScript, params: Dictionary = {}) -> void:
	_done = false
	var start := func() -> void:
		await Cutscene.play(script, null, params)
		_done = true
	start.call()
	await autoplay()

func walkthrough(randomlocke: bool) -> void:
	if randomlocke:
		var rom := Randomizer.generate(42, RandomizerSettings.from_preset("clasico"))
		assert_eq(await SceneManager.start_randomlocke(rom, SLOT, false), OK)
	else:
		assert_eq(await SceneManager.start_new_game(&"", &"", {"slot": SLOT}), OK)
	await event(load("res://src/events/mvp/mvp_story_event.gd"), {"stage": "intro"})
	await event(load("res://src/events/mvp/mvp_story_event.gd"), {"stage": "bedroom"})
	assert_true(GameState.flag(&"story_lab_intro_done"))
	var expected := DataDB.starter_spec(&"starter_1")
	await event(load("res://src/events/common/choose_starter_event.gd"), {"slot": "starter_1", "index": 1})
	assert_true(GameState.flag(&"starter_chosen"))
	assert_eq(GameState.party.size(), 1)
	assert_eq(String(GameState.party.get_at(0).species_id), str(expected.get("species", "") if expected is Dictionary else expected))
	if randomlocke:
		assert_eq(GameState.party.get_at(0).nickname, "Panchito")
		assert_eq(GameState.locke.rules.zone_status(String(SceneManager.current_map.get_zone_id())), "available")
	await event(load("res://src/events/mvp/mvp_story_event.gd"), {"stage": "rival"})
	assert_true(GameState.flag(&"rival_intro_done"))
	assert_eq(GameState.party.get_at(0).current_hp, GameState.party.get_at(0).max_hp())
	if randomlocke:
		assert_eq(GameState.randomlocke.deaths, 0, "Tutorial sin muertes")
	await event(load("res://src/events/mvp/mvp_story_event.gd"), {"stage": "rewards"})
	assert_true(GameState.flag(&"got_pokedex"))
	assert_true(GameState.flag(&"story_rewards_done"))
	var reward: Dictionary = GameState.world_config.mvp_story.reward
	var item := DataDB.placed_item(StringName(reward.placement_id), &"pokeball")
	assert_eq(GameState.bag.count(item), 5)
	GameState.party.get_at(0).current_hp = 1
	await event(load("res://src/events/common/heal_party_event.gd"), {"spawn": "laboratory"})
	assert_eq(GameState.party.get_at(0).current_hp, GameState.party.get_at(0).max_hp())
	assert_eq(GameState.healing_spawn, &"laboratory")
	assert_eq(await SceneManager.change_map(&"test/test_outdoor", &"default"), OK)
	GameState.set_always_run(true)
	assert_true(SceneManager.player.running_requested(false))
	await wait_physics_frames(2)
	var before := SceneManager.player.tile_position()
	for direction: Vector2i in [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]:
		if SceneManager.player.is_tile_free(before + direction):
			await SceneManager.player.step(direction, Character.RUN_TIME, false, true)
			break
	assert_ne(SceneManager.player.tile_position(), before)
	await wait_seconds(0.4)
	var state := GameState.to_dict()
	assert_eq(SaveManager.save_game(SLOT), OK)
	SceneManager._leave_game()
	await wait_physics_frames(2)
	assert_eq(await SceneManager.continue_game(SLOT), OK)
	assert_true(GameState.always_run)
	assert_eq(GameState.player_name, "Javi")
	assert_eq(GameState.flags.keys(), state.flags.map(func(key: Variant) -> StringName: return StringName(key)))
	assert_eq(GameState.mode, &"randomlocke" if randomlocke else &"normal")
	assert_false(GameState.input_locked)
func test_recorrido_prototipo_normal_motor_y_guardado() -> void:
	await walkthrough(false)
func test_recorrido_prototipo_randomlocke_motor_mote_y_rom() -> void:
	await walkthrough(true)
