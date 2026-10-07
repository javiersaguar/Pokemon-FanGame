extends GutTest
func after_each() -> void:
	GameState.reset()
	for node: Node in AudioManager.get_children():
		if node is AudioStreamPlayer: node.stop(); node.stream = null
	await wait_process_frames(2)
func test_daycare_transfer_preserves_last_able_identity_and_full_party() -> void:
	GameState.reset()
	var daycare := Daycare.new(8)
	var p := Pokemon.create(&"charmander",5)
	p.held_item = &"everstone"
	GameState.party.add(p)
	assert_eq(DaycareScreen.deposit_member(daycare,0),ERR_UNAVAILABLE)
	GameState.party.add(Pokemon.create(&"pidgey",5))
	assert_eq(DaycareScreen.deposit_member(daycare,0),OK)
	assert_same(daycare.slots[0],p)
	assert_eq(p.held_item,&"everstone")
	for i: int in 5: GameState.party.add(Pokemon.create(&"pidgey",5))
	assert_eq(DaycareScreen.withdraw_member(daycare,0),ERR_OUT_OF_MEMORY)
	assert_same(daycare.slots[0],p)
	GameState.party.remove_at(5)
	assert_eq(DaycareScreen.withdraw_member(daycare,0),OK)
	assert_same(GameState.party.get_at(5),p)
	assert_true(daycare.slots.is_empty())
func test_egg_request_does_not_consume_service_without_persistent_caller() -> void:
	GameState.reset()
	var daycare := Daycare.new(8)
	daycare.deposit(Pokemon.create(&"charmander",5)); daycare.deposit(Pokemon.create(&"ditto",5))
	daycare.egg_ready = true
	var screen := DaycareScreen.new()
	screen.service = daycare
	add_child_autofree(screen)
	await wait_process_frames(3)
	screen.menu.select(3)
	var event := InputEventAction.new(); event.action = &"accept"; event.pressed = true
	Input.parse_input_event(event)
	await wait_process_frames(3)
	assert_true(screen.requested_egg)
	assert_true(daycare.egg_ready)
	assert_eq(daycare.slots.size(),2)
func test_hatching_is_presentation_and_does_not_change_party_or_pokemon() -> void:
	GameState.reset()
	var p := Pokemon.create(&"charmander",1)
	var before := p.to_dict()
	var screen := HatchingScreen.new()
	screen.pokemon = p; screen.fast = true
	add_child_autofree(screen)
	await wait_process_frames(3)
	assert_true(screen._complete)
	assert_false(screen._egg.visible)
	assert_true(screen._baby.visible)
	assert_eq(p.to_dict(),before)
	assert_true(GameState.party.is_empty())
	assert_false(GameState.pokedex.is_caught(&"charmander"))
