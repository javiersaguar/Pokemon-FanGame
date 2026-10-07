extends GutTest
var old := false
func before_each() -> void:
	UiPreferences.initialize()
	old = UiPreferences.reduce_motion()
	UiPreferences.set_value("reduce_animations",true,false)
	GameState.reset()
func after_each() -> void:
	UiPreferences.set_value("reduce_animations",old,false)
	GameState.reset()
	for node: Node in AudioManager.get_children():
		if node is AudioStreamPlayer: node.stop(); node.stream = null
	await wait_process_frames(2)
func _press(button: JoyButton) -> void:
	var event := InputEventJoypadButton.new(); event.button_index = button; event.pressed = true
	Input.parse_input_event(event)
	var release := event.duplicate() as InputEventJoypadButton; release.pressed = false
	Input.parse_input_event(release)
func test_reduced_title_cursor_and_sprite_are_static_but_stages_remain() -> void:
	var title := TitleScreen.new(); title.skip_sequence = true
	add_child_autofree(title)
	title._process(0.8)
	var positions: Array = title.layers.map(func(node: Control) -> Vector2: return node.position)
	title._process(0.8)
	assert_eq(title.layers.map(func(node: Control) -> Vector2: return node.position),positions)
	assert_eq(title._start.modulate.a,1.0)
	var cursor := CursorArrow.new(); cursor.bob = true
	add_child_autofree(cursor)
	cursor._process(1.0)
	assert_eq(cursor._bob_offset,0)
	var sprite := BattlePokemonSprite.new()
	add_child_autofree(sprite)
	sprite.set_pokemon({"species":&"charmander"})
	sprite._process(1.0)
	assert_eq(sprite._sprite.position.y,0.0)
func test_hp_and_credits_keep_values_and_manual_navigation_without_motion() -> void:
	var bar := HpBar.new()
	add_child_autofree(bar)
	await bar.animate_to(0.25,1.0)
	assert_eq(bar.ratio,0.25)
	assert_eq(bar.ghost,0.25)
	var credits := CreditsScreen.new()
	add_child_autofree(credits)
	credits._process(10.0)
	assert_eq(credits._scroll,0.0)
	await wait_process_frames(3)
	var down := InputEventAction.new(); down.action = &"move_down"; down.pressed = true
	credits._unhandled_input(down)
	assert_gt(credits._scroll,0.0)
func test_reduced_evolution_waits_for_choice_and_controller_cancel_keeps_species() -> void:
	var pokemon := Pokemon.create(&"charmander",16)
	var screen := EvolutionScreen.new()
	screen.pokemon = pokemon; screen.evolution = {"to":"charmeleon","method":"level"}
	add_child_autofree(screen)
	await wait_process_frames(3)
	assert_true(screen._reduced_waiting)
	assert_eq(pokemon.species_id,&"charmander")
	_press(JOY_BUTTON_B)
	await wait_process_frames(3)
	assert_true(screen._completed)
	assert_true(screen._cancelled)
	assert_eq(pokemon.species_id,&"charmander")
func test_reduced_evolution_controller_accept_and_hatching_preserve_outcome() -> void:
	var pokemon := Pokemon.create(&"charmander",16)
	var screen := EvolutionScreen.new()
	screen.pokemon = pokemon; screen.evolution = {"to":"charmeleon","method":"level"}
	add_child_autofree(screen)
	await wait_process_frames(3)
	_press(JOY_BUTTON_A)
	await wait_process_frames(3)
	assert_true(screen._completed)
	assert_eq(pokemon.species_id,&"charmeleon")
	var hatch := HatchingScreen.new()
	hatch.pokemon = Pokemon.create(&"pidgey",1)
	add_child_autofree(hatch)
	await wait_process_frames(3)
	assert_true(hatch._complete)
	assert_false(hatch._egg.visible)

func test_nature_stat_modifiers_have_written_signs_as_well_as_color() -> void:
	var p := Pokemon.create(&"charmander",16); p.nature = &"adamant"
	var screen := SummaryScreen.new()
	add_child_autofree(screen)
	screen.show_party([p]); screen.show_page(2)
	var texts := PackedStringArray()
	for node: Node in screen._page_root.get_children():
		if node is Label: texts.append(node.text)
	assert_true(texts.has("Ataque +"))
	assert_true(texts.has("At. Esp. -"))
