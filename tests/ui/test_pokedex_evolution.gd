extends GutTest
var main: Node

func before_each() -> void:
	GameState.reset()
	main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)

func after_each() -> void:
	AudioManager._cry.stop()
	AudioManager._cry.stream = null
	await wait_process_frames(2)
	SceneManager._leave_game()
	main.queue_free()
	await wait_process_frames(2)
	SceneManager.world = null
	SceneManager.ui_layer = null
	SceneManager.battle_layer = null
	SceneManager.transition_layer = null
	SceneManager._fade = null

func press(action: StringName) -> void:
	for down: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = down
		Input.parse_input_event(event)

func test_dex_conceals_unseen_species_and_entry_text_until_caught() -> void:
	GameState.pokedex.mark_seen(&"charmander")
	var screen := PokedexScreen.new()
	screen.species = [&"bulbasaur", &"charmander"]
	SceneManager.push_menu(screen)
	await wait_process_frames(3)
	assert_true("???" in screen.choices[0])
	assert_null(screen.images[0])
	assert_true("Charmander" in screen.choices[1])
	assert_not_null(screen.images[1])
	var entry := PokedexEntry.new()
	entry.species_id = &"charmander"
	SceneManager.push_menu(entry)
	await wait_process_frames(2)
	assert_true("Captura" in entry._detail.text)

func test_cancel_evolution_keeps_species_item_nickname_and_dex() -> void:
	var p := Pokemon.create(&"charmander", 16)
	p.nickname = "Panchito"
	p.held_item = &"oranberry"
	var screen := EvolutionScreen.new()
	screen.pokemon = p
	screen.evolution = {"to": "charmeleon", "method": "level"}
	SceneManager.push_menu(screen)
	await wait_process_frames(3)
	press(&"cancel")
	for frame: int in 150:
		await wait_process_frames(1)
		if screen._completed: break
	assert_true(screen._cancelled)
	assert_eq(p.species_id, &"charmander")
	assert_eq(p.nickname, "Panchito")
	assert_eq(p.held_item, &"oranberry")
	assert_false(GameState.pokedex.is_caught(&"charmeleon"))

func test_item_evolution_cannot_cancel_and_consumes_exactly_one_item() -> void:
	var p := Pokemon.create(&"pikachu", 20)
	p.nickname = "Panchi"
	p.current_hp = p.max_hp() - 3
	GameState.bag.add(&"thunderstone", 2)
	var screen := EvolutionScreen.new()
	screen.pokemon = p
	screen.item_id = &"thunderstone"
	screen.evolution = {"to": "raichu", "method": "item"}
	SceneManager.push_menu(screen)
	await wait_process_frames(3)
	press(&"cancel")
	assert_false(screen._cancelled)
	for frame: int in 250:
		await wait_process_frames(1)
		if screen._completed: break
	assert_eq(p.species_id, &"raichu")
	assert_eq(p.nickname, "Panchi")
	assert_eq(p.max_hp() - p.current_hp, 3)
	assert_eq(GameState.bag.count(&"thunderstone"), 1)
	assert_true(GameState.pokedex.is_caught(&"raichu"))

func test_shedinja_requires_free_party_slot_and_ball() -> void:
	var p := Pokemon.create(&"nincada", 20)
	GameState.party.add(p)
	GameState.bag.add(&"pokeball")
	EvolutionScreen.apply_evolution(p, {"to": "ninjask", "method": "level"})
	assert_eq(GameState.party.size(), 2)
	assert_eq(GameState.party.get_at(1).species_id, &"shedinja")
	assert_ne(GameState.party.get_at(1).uid, p.uid)
	assert_eq(GameState.bag.count(&"pokeball"), 0)
	assert_true(GameState.pokedex.is_caught(&"shedinja"))
	var without_ball := Pokemon.create(&"nincada", 20)
	GameState.party.add(without_ball)
	EvolutionScreen.apply_evolution(without_ball, {"to": "ninjask", "method": "level"})
	assert_eq(GameState.party.size(), 3, "sin Poké Ball no hay extra")
	while not GameState.party.is_full(): GameState.party.add(Pokemon.create(&"pidgey", 2))
	GameState.bag.add(&"pokeball")
	EvolutionScreen.apply_evolution(Pokemon.create(&"nincada", 20), {"to": "ninjask", "method": "level"})
	assert_eq(GameState.bag.count(&"pokeball"), 1, "sin hueco no consume Poké Ball")

func test_battle_scene_applies_engine_pending_evolution_to_actual_party_by_uid() -> void:
	var p := Pokemon.create(&"charmander", 16)
	GameState.party.add(p)
	var scene := load("res://src/battle/scene/battle_scene.tscn").instantiate() as BattleScene
	SceneManager.battle_layer.add_child(scene)
	scene.fast = true
	var setup := BattleSetup.wild(&"pidgey", 2)
	scene._driver = EngineDriver.new(setup)
	(scene._driver as EngineDriver).engine.result.pending_evolutions = [{"uid": p.uid, "to": "charmeleon", "evolution": {"to": "charmeleon", "method": "level"}}]
	await scene._pending_evolutions()
	assert_eq(p.species_id, &"charmeleon")
	assert_true(GameState.pokedex.is_caught(&"charmeleon"))

func test_learn_screen_has_metadata_and_returns_cancel_without_mutation() -> void:
	var p := Pokemon.create(&"charmander", 20)
	var before := p.move_ids()
	var screen := LearnMoveScreen.new()
	screen.request = {"move_id": &"flamethrower", "move_name": "Lanzallamas", "moves": EngineDriver._moves_of(p)}
	SceneManager.push_menu(screen)
	await wait_process_frames(3)
	assert_eq(screen.choices.size(), p.moves.size() + 1)
	assert_true("Pot." in screen.notes[0])
	assert_true("PP" in screen.notes[0])
	watch_signals(screen)
	press(&"cancel")
	await wait_process_frames(2)
	assert_signal_emitted_with_parameters(screen, &"chosen", [-1])
	assert_eq(p.move_ids(), before)

func test_professor_intro_balances_menu_stack_and_uses_current_names() -> void:
	var screen := ProfessorIntro.begin()
	await wait_process_frames(2)
	assert_not_null(screen)
	assert_true(SceneManager.is_menu_open())
	ProfessorIntro.finish(screen)
	await wait_process_frames(2)
	assert_false(SceneManager.is_menu_open())
