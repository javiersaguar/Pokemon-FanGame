extends GutTest
func after_each() -> void:
	GameState.reset()
	for node: Node in AudioManager.get_children():
		if node is AudioStreamPlayer: node.stop(); node.stream = null
	await wait_process_frames(2)
func test_pc_last_able_full_party_and_identity_are_protected() -> void:
	GameState.reset()
	var a := Pokemon.create(&"charmander",5)
	var b := Pokemon.create(&"pidgey",5)
	a.held_item = &"potion"
	GameState.party.add(a)
	assert_eq(PCScreen.deposit_member(0,0,0),ERR_UNAVAILABLE)
	GameState.party.add(b)
	b.current_hp = 0
	assert_eq(PCScreen.deposit_member(0,0,0),ERR_UNAVAILABLE)
	b.heal_full()
	assert_eq(PCScreen.deposit_member(0,0,0),OK)
	assert_same(GameState.pc.get_pokemon(0,0),a)
	assert_eq(a.held_item,&"potion")
	assert_eq(PCScreen.deposit_member(0,0,0),ERR_ALREADY_EXISTS)
	GameState.pc.move(0,0,2,29)
	assert_eq(GameState.pc.find_uid(a.uid),Vector2i(2,29))
	for i: int in 5: GameState.party.add(Pokemon.create(&"pidgey",5))
	assert_eq(PCScreen.withdraw_member(2,29),ERR_OUT_OF_MEMORY)
	assert_same(GameState.pc.get_pokemon(2,29),a)
	GameState.party.remove_at(5)
	assert_eq(PCScreen.withdraw_member(2,29),OK)
	assert_same(GameState.party.get_at(5),a)
	assert_null(GameState.pc.get_pokemon(2,29))
func test_pc_boxes_and_dex_forms_do_not_show_unseen_variants() -> void:
	GameState.reset()
	GameState.pc.rename_box(1,"Reserva")
	GameState.pc.current_box = 1
	GameState.pc.set_pokemon(1,0,Pokemon.create(&"pidgey",5))
	var pc := PCScreen.new()
	add_child_autofree(pc)
	assert_eq(pc.choices.size(),GameState.pc.box_size())
	assert_true(pc.caption.contains("Reserva"))
	assert_not_null(pc.images[0])
	GameState.pokedex.mark_seen(&"raichualola",true)
	var entry := PokedexEntry.new()
	entry.species_id = &"raichualola"
	add_child_autofree(entry)
	assert_eq(entry.forms,[&"raichualola"])
	assert_false(entry._detail.text.contains(DataDB.species(&"raichualola").dex_entry))
	assert_true(PokedexEntry.areas(&"pidgey").has("ruta 1"))
	assert_false(PokedexEntry.areas(&"mew").has("ruta 1"))
func test_region_destinations_only_visited_and_card_saved_badges() -> void:
	GameState.reset()
	var old: Array = GameState.world_config.field.flight_destinations.duplicate(true)
	GameState.world_config.field.flight_destinations = [{"id":"a","name":"Prueba","map":"fixture"},{"id":"b","map":"unvisited"}]
	GameState.set_flag(&"visited_map:fixture")
	var region := RegionMapScreen.new()
	add_child_autofree(region)
	assert_eq(region.destinations.size(),1)
	assert_eq(region.choices[0],"Prueba")
	GameState.badges.assign([&"fixture_badge"])
	var card := TrainerCardScreen.new()
	add_child_autofree(card)
	assert_eq(GameState.to_dict().player.badges,["fixture_badge"])
	GameState.world_config.field.flight_destinations = old
