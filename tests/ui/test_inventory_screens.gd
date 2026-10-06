extends GutTest
var main: Node

func before_each() -> void:
	GameState.reset()
	main = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	add_child(main)
	SceneManager.register_main(main)

func after_each() -> void:
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

func test_held_item_exchange_is_atomic_when_bag_is_full() -> void:
	var p := Pokemon.create(&"charmander", 5)
	p.held_item = &"oranberry"
	GameState.bag.add(&"potion", 2)
	GameState.bag.add(&"oranberry", Bag.MAX_COUNT)
	assert_eq(PartyItems.equip(p, &"potion"), ERR_OUT_OF_MEMORY)
	assert_eq(p.held_item, &"oranberry")
	assert_eq(GameState.bag.count(&"potion"), 2)
	GameState.bag.remove(&"oranberry")
	assert_eq(PartyItems.equip(p, &"potion"), OK)
	assert_eq(p.held_item, &"potion")
	assert_eq(GameState.bag.count(&"potion"), 1)
	assert_eq(GameState.bag.count(&"oranberry"), Bag.MAX_COUNT)
	assert_eq(PartyItems.take(p), OK)
	assert_eq(p.held_item, &"")
	assert_eq(GameState.bag.count(&"potion"), 2)

func test_shop_buy_and_sell_preserve_money_and_reject_invalid_operations() -> void:
	GameState.money = 1000
	var unit := ShopTransactions.price(&"tienda_ciudad2", &"potion")
	assert_eq(ShopTransactions.buy(&"tienda_ciudad2", &"potion", 3), OK)
	assert_eq(GameState.money, 1000 - unit * 3)
	assert_eq(GameState.bag.count(&"potion"), 3)
	var before := GameState.money
	assert_eq(ShopTransactions.buy(&"tienda_ciudad2", &"potion", 999), ERR_OUT_OF_MEMORY)
	assert_eq(ShopTransactions.buy(&"tienda_ciudad2", &"potion", 0), ERR_INVALID_PARAMETER)
	assert_eq(ShopTransactions.buy(&"tienda_ciudad2", &"masterball", 1), ERR_INVALID_PARAMETER)
	assert_eq(GameState.money, before)
	assert_eq(ShopTransactions.sell(&"potion", 4), ERR_INVALID_PARAMETER)
	assert_eq(ShopTransactions.sell(&"potion", 2), OK)
	assert_eq(GameState.money, before + 2 * ShopTransactions.sale_price(&"potion"))
	assert_eq(GameState.bag.count(&"potion"), 1)
	GameState.money = GameState.max_money()
	assert_eq(ShopTransactions.sell(&"potion", 1), ERR_UNAVAILABLE)
	assert_eq(GameState.bag.count(&"potion"), 1)
	GameState.money = 0
	assert_eq(ShopTransactions.buy(&"tienda_ciudad2", &"potion", 1), ERR_UNAVAILABLE)
	assert_eq(GameState.bag.count(&"potion"), 1)

func test_medicine_only_consumes_when_effective_and_restores_pp() -> void:
	var p := Pokemon.create(&"charmander", 5)
	GameState.bag.add(&"potion", 2)
	assert_eq(FieldItemUse.use(&"potion", p), ERR_UNAVAILABLE)
	assert_eq(GameState.bag.count(&"potion"), 2)
	p.current_hp = 1
	assert_eq(FieldItemUse.use(&"potion", p), OK)
	assert_eq(p.current_hp, p.max_hp())
	assert_eq(GameState.bag.count(&"potion"), 1)
	p.moves[0].pp = 0
	GameState.bag.add(&"ether")
	assert_eq(FieldItemUse.use(&"ether", p), OK)
	assert_gt(p.moves[0].pp, 0)
	assert_eq(GameState.bag.count(&"ether"), 0)
	GameState.bag.add(&"repel")
	assert_eq(FieldItemUse.use(&"repel"), OK)
	assert_eq(GameState.var_int(&"repel_steps"), 100)

func test_party_menu_reorders_actual_members_with_controller_actions() -> void:
	var first := Pokemon.create(&"charmander", 5)
	var second := Pokemon.create(&"pidgey", 7)
	GameState.party.add(first)
	GameState.party.add(second)
	var screen := PartyScreen.new()
	SceneManager.push_menu(screen)
	await wait_process_frames(3)
	press(&"accept")
	await wait_process_frames(3)
	var actions := SceneManager.ui_layer.get_child(SceneManager.ui_layer.get_child_count() - 1) as ChoiceScreen
	assert_not_null(actions)
	actions.menu.select(1)
	press(&"accept")
	await wait_process_frames(3)
	var target := SceneManager.ui_layer.get_child(SceneManager.ui_layer.get_child_count() - 1) as ChoiceScreen
	target.menu.select(1)
	press(&"accept")
	await wait_process_frames(3)
	assert_eq(GameState.party.get_at(0).uid, second.uid)
	assert_eq(GameState.party.get_at(1).uid, first.uid)

func test_bag_has_eight_pockets_and_shop_contract_opens_real_screen() -> void:
	var bag := BagScreen.new()
	SceneManager.push_menu(bag)
	await wait_process_frames(3)
	assert_eq(bag.menu.get_child_count(), 8)
	press(&"cancel")
	await wait_process_frames(2)
	SceneManager.pop_menu(bag)
	ShopScreen.open(&"tienda_ciudad2")
	await wait_process_frames(3)
	var shop := SceneManager.ui_layer.get_child(SceneManager.ui_layer.get_child_count() - 1) as ShopScreen
	assert_not_null(shop)
	assert_true(SceneManager.is_menu_open())
	press(&"cancel")
	await wait_process_frames(3)
	assert_false(SceneManager.is_menu_open())

func test_quantity_picker_clamps_and_cancels_without_inventory_changes() -> void:
	var picker := QuantityPicker.new()
	picker.maximum = 4
	SceneManager.push_menu(picker)
	await wait_process_frames(3)
	press(&"move_up")
	await wait_process_frames(2)
	assert_eq(picker.quantity, 4)
	press(&"move_down")
	await wait_process_frames(2)
	assert_eq(picker.quantity, 1)
	watch_signals(picker)
	press(&"cancel")
	await wait_process_frames(2)
	assert_signal_emitted_with_parameters(picker, &"chosen", [0])
	SceneManager.pop_menu(picker)

func test_revive_respects_locke_permadeath_and_shop_badge_tiers() -> void:
	var p := Pokemon.create(&"charmander", 5)
	p.current_hp = 0
	GameState.bag.add(&"revive", 2)
	GameState.locke = WorldLocke.new({"settings": {"permadeath": true}})
	assert_eq(FieldItemUse.use(&"revive", p), ERR_UNAVAILABLE)
	assert_eq(GameState.bag.count(&"revive"), 2)
	GameState.locke = WorldLocke.new({"settings": {"permadeath": false}})
	assert_eq(FieldItemUse.use(&"revive", p), OK)
	assert_gt(p.current_hp, 0)
	assert_false(&"greatball" in ShopTransactions.stock(&"tienda_ciudad2"))
	GameState.badges.append(&"test")
	assert_true(&"greatball" in ShopTransactions.stock(&"tienda_ciudad2"))

func test_choice_pagination_returns_absolute_index() -> void:
	var screen := ChoiceScreen.new()
	screen.choices = ["Uno", "Dos", "Tres", "Cuatro", "Cinco", "Seis", "Siete"]
	SceneManager.push_menu(screen)
	await wait_process_frames(3)
	press(&"move_right")
	await wait_process_frames(3)
	assert_eq(screen.page, 1)
	assert_eq(screen.menu.get_child_count(), 1)
	watch_signals(screen)
	press(&"accept")
	await wait_process_frames(2)
	assert_signal_emitted_with_parameters(screen, &"chosen", [6])
	SceneManager.pop_menu(screen)
