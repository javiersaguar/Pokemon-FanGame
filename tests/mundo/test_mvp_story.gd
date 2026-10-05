extends GutTest
## Guion con UI sustituida y motor/datos reales; prueba de sala y teletransporte reales.

class StoryHarness:
	extends MvpStoryEvent
	var messages: Array[String] = []
	var destinations: Array[String] = []
	var requested_names: Array[StringName] = []
	var gender := 1
	var last_setup: BattleSetup
	var last_context: Dictionary
	func say(text: String, values: Dictionary = {}) -> void:
		messages.append(DataDB.resolve_markers(Dialogue.format_text(text, values)))
	func choose(_text: String, _options: PackedStringArray) -> int:
		return gender
	func request_name(kind: StringName, _initial: String) -> String:
		requested_names.append(kind)
		return "Javi" if kind == &"player" else "Rival de prueba"
	func travel(destination: String) -> void:
		destinations.append(destination)
	func give_item(item: StringName, quantity: int) -> bool:
		return await Cutscene.give_item(item, quantity, false)
	func battle(setup: BattleSetup, context: Dictionary) -> StringName:
		last_setup = setup
		last_context = context
		setup.seed = 123
		var prepared: Variant = SceneManager.prepare_battle(setup, context)
		var driver := EngineDriver.new(prepared)
		driver.start()
		for turn: int in 100:
			if driver.is_over():
				break
			driver.submit({"type": &"fight", "move_slot": 0})
		driver.finish()
		return driver.outcome()

class TeleportStory:
	extends StoryEvent
	func run() -> void:
		await Cutscene.teleport(&"test/test_room", &"laboratory")
		GameState.set_flag(&"test_teleport_finished")

var _config: Dictionary
var _starters: Dictionary

func before_each() -> void:
	_config = GameState.world_config.duplicate(true)
	_starters = DataDB._starters.duplicate(true)
	DataDB._starters = {"starter_1": {"species": "bulbasaur", "level": 5}, "starter_2": {"species": "charmander", "level": 5}, "starter_3": {"species": "squirtle", "level": 5}}
	GameState.new_game()

func after_each() -> void:
	GameState.world_config = _config
	DataDB._starters = _starters
	GameState.reset()
	SaveManager.apply_rom_patch()

func test_intro_identidad_habitacion_laboratorio_y_flags_idempotentes() -> void:
	var story := StoryHarness.new()
	await Cutscene.play(story, null, {"stage": "intro"})
	assert_eq(GameState.player_gender, &"female")
	assert_eq(GameState.player_name, "Javi")
	assert_eq(GameState.rival_name, "Rival de prueba")
	assert_eq(story.requested_names, [&"player", &"rival"] as Array[StringName])
	assert_eq(story.destinations, ["bedroom"] as Array[String])
	assert_true(GameState.flag(&"story_intro_done"))
	await Cutscene.play(story, null, {"stage": "bedroom"})
	assert_true(GameState.flag(&"story_bedroom_done"))
	await Cutscene.play(story, null, {"stage": "laboratory"})
	assert_true(GameState.flag(&"story_lab_intro_done"))
	assert_eq(GameState.var_int(&"story_progress"), 30)
	assert_true(story.messages[-1].contains("Bulbasaur"))
	var count := story.messages.size()
	await Cutscene.play(story, null, {"stage": "intro"})
	assert_eq(story.messages.size(), count, "no repite intro ni vuelve a pedir identidad")
	assert_false(GameState.input_locked)

func test_secuencia_invalida_no_avanza() -> void:
	var story := StoryHarness.new()
	for stage: String in ["bedroom", "laboratory", "rival", "rewards"]:
		await Cutscene.play(story, null, {"stage": stage})
	assert_eq(GameState.flags, {})
	assert_eq(GameState.party.size(), 0)
	assert_eq(GameState.bag.count(&"pokeball"), 0)

func test_tres_rivales_se_resuelven_desde_datadb() -> void:
	var story := StoryHarness.new()
	for index: int in range(1, 4):
		GameState.set_var(&"starter", index)
		var setup := story.rival_setup()
		assert_not_null(setup)
		assert_eq(setup.trainers[0].id, "rival_lab_%d" % index)
		var spec: Dictionary = DataDB.trainer(StringName(setup.trainers[0].id)).party[0]
		assert_eq(setup.foe_party[0].species_id, StringName(spec.species))
		assert_true(setup.can_lose)
		assert_false(setup.locke_rules)

func test_rival_perdido_randomlocke_cura_y_avanza_sin_muerte() -> void:
	GameState.new_game({"mode": "randomlocke", "randomlocke": {"families": {"bulbasaur": "bulbasaur"}, "settings": {"nickname_required": false}}})
	var pokemon := Pokemon.create(&"bulbasaur", 5)
	pokemon.moves = [MoveSlot.create(&"splash")]
	pokemon.current_hp = 1
	await Cutscene.give_pokemon(pokemon, false, "starter")
	GameState.set_var(&"starter", 1)
	var story := StoryHarness.new()
	await Cutscene.play(story, null, {"stage": "rival"})
	assert_eq(story.last_context, {"tutorial": true})
	assert_true(GameState.flag(&"rival_intro_done"))
	assert_eq(GameState.var_int(&"story_progress"), 40)
	assert_eq(pokemon.current_hp, pokemon.max_hp())
	assert_eq(GameState.locke.rules.snapshot().death_count, 0)
	assert_eq(GameState.randomlocke.status, "in_progress")

func test_regalo_por_id_y_una_sola_vez_con_parche() -> void:
	GameState.set_flag(&"rival_intro_done")
	DataDB.apply_patch({"items": {"test/test_outdoor/PokeBalls": "greatball"}})
	var story := StoryHarness.new()
	await Cutscene.play(story, null, {"stage": "rewards"})
	assert_true(GameState.flag(&"got_pokedex"))
	assert_true(GameState.flag(&"story_rewards_done"))
	assert_eq(GameState.bag.count(&"greatball"), 5)
	assert_eq(GameState.bag.count(&"pokeball"), 0)
	await Cutscene.play(story, null, {"stage": "rewards"})
	assert_eq(GameState.bag.count(&"greatball"), 5)
	DataDB.clear_patch()

func test_cantidad_no_decidida_no_inventa_regalo() -> void:
	GameState.set_flag(&"rival_intro_done")
	GameState.world_config.mvp_story.reward.quantity = null
	await Cutscene.play(StoryHarness.new(), null, {"stage": "rewards"})
	assert_true(GameState.flag(&"got_pokedex"))
	assert_false(GameState.flag(&"story_rewards_done"))
	assert_eq(GameState.bag.count(&"pokeball"), 0)

func test_nombre_vacio_o_de_otro_campo_no_completa() -> void:
	var result := {"value": ""}
	var ask := func() -> void:
		result.value = await Cutscene.request_name(&"player")
	ask.call()
	assert_false(Cutscene.submit_name(&"rival", "No"))
	assert_false(Cutscene.submit_name(&"player", "  "))
	assert_true(Cutscene.submit_name(&"player", " Javi "))
	await wait_physics_frames(2)
	assert_eq(result.value, "Javi")

func test_sala_contiene_eventos_y_tres_bolas_con_visibilidad() -> void:
	var map := load("res://maps/test/test_room.tscn").instantiate() as MapRoot
	assert_eq(map.get_spawn(&"bedroom").name, &"bedroom")
	assert_eq(map.get_spawn(&"laboratory").name, &"laboratory")
	assert_eq(map.get_node("Entities/Profesor").event_params.stage, "professor")
	assert_eq(map.get_node("Entities/Rival").event_params.stage, "rival")
	assert_eq(map.get_node("Entities/Dependiente").event_params.shop_id, &"tienda_ciudad2")
	for index: int in range(1, 4):
		var ball := map.get_node("Entities/Inicial%d" % index) as StarterBall
		assert_false(ball.is_present())
		GameState.set_flag(&"story_lab_intro_done")
		assert_true(ball.is_present())
		GameState.clear_flag(&"story_lab_intro_done")
	assert_true(DataDB.has_shop(&"tienda_ciudad2"))
	map.free()

func _press() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"accept"
		event.pressed = pressed
		Input.parse_input_event(event)

func test_teletransporte_en_cinematica_no_bloquea_evento_de_entrada() -> void:
	var main: Node = (load("res://src/main/main.tscn") as PackedScene).instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)
	GameState.set_flag(&"story_intro_done")
	GameState.set_flag(&"story_bedroom_done")
	var speed := Dialogue.text_speed
	Dialogue.text_speed = 0
	var done := [false]
	var launch := func() -> void:
		await Cutscene.play(TeleportStory)
		done[0] = true
	launch.call()
	for frame: int in 180:
		await wait_physics_frames(1)
		if Dialogue.is_open:
			_press()
		if done[0] and GameState.flag(&"story_lab_intro_done") and not Cutscene.is_running():
			break
	assert_true(done[0], "cinemática que cambia mapa termina")
	assert_true(GameState.flag(&"test_teleport_finished"))
	assert_true(GameState.flag(&"story_lab_intro_done"), "evento ON_ENTER ejecutado después")
	assert_false(Cutscene.is_running())
	# Derrota normal: reaparece en el punto de curación y recupera el equipo.
	var pokemon := Pokemon.create(&"pidgey", 5)
	pokemon.current_hp = 0
	GameState.party.add(pokemon)
	GameState.set_healing_spot(&"test/test_room", &"default")
	await SceneManager._whiteout()
	assert_eq(GameState.map_id, &"test/test_room")
	assert_eq(GameState.player_tile, Vector2i(10, 5))
	assert_eq(pokemon.current_hp, pokemon.max_hp())
	# Evento de enfermera real: pregunta y fija el punto de reaparición.
	pokemon.current_hp = 1
	var nurse_done := [false]
	var heal := func() -> void:
		await Cutscene.play(load("res://src/events/common/heal_party_event.gd"), null, {"spawn": "laboratory"})
		nurse_done[0] = true
	heal.call()
	for frame: int in 180:
		await wait_physics_frames(1)
		if Dialogue.is_open:
			_press()
		if nurse_done[0]:
			break
	assert_true(nurse_done[0])
	assert_eq(pokemon.current_hp, pokemon.max_hp())
	assert_eq(GameState.healing_spawn, &"laboratory")
	Dialogue.text_speed = speed
	SceneManager._leave_game()
	main.queue_free()
	SceneManager.world = null
	SceneManager.battle_layer = null
	SceneManager.ui_layer = null
	SceneManager.transition_layer = null
	SceneManager._fade = null
	await wait_physics_frames(2)
