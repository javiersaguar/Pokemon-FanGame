extends GutTest
## Mochila (contratos.md §9.5).


func test_add_remove_and_count() -> void:
	var bag := Bag.new()
	assert_eq(bag.add(&"potion", 3), 3)
	assert_eq(bag.count(&"potion"), 3)
	assert_true(bag.has(&"potion", 3))
	assert_false(bag.remove(&"potion", 4), "no quita si no hay suficientes")
	assert_eq(bag.count(&"potion"), 3)
	assert_true(bag.remove(&"potion", 3))
	assert_eq(bag.count(&"potion"), 0)
	assert_true(bag.is_empty(), "se borra al llegar a 0")


func test_max_count() -> void:
	var bag := Bag.new()
	bag.add(&"pokeball", Bag.MAX_COUNT - 1)
	assert_eq(bag.add(&"pokeball", 5), 1, "solo cabe 1 más")
	assert_eq(bag.count(&"pokeball"), Bag.MAX_COUNT)


func test_unknown_item_is_rejected() -> void:
	var bag := Bag.new()
	assert_eq(bag.add(&"objeto_que_no_existe", 1), 0)
	assert_push_error("no existe el objeto")


func test_pockets_and_battle_items_keep_order() -> void:
	var bag := Bag.new()
	bag.add(&"repel")
	bag.add(&"potion")
	bag.add(&"pokeball", 2)
	assert_eq(bag.all_items(), [&"repel", &"potion", &"pokeball"] as Array[StringName])
	assert_eq(bag.items_in_pocket(&"medicine"), [&"potion"] as Array[StringName])
	assert_eq(bag.items_in_pocket(&"pokeballs"), [&"pokeball"] as Array[StringName])
	assert_eq(bag.battle_items(), [&"potion", &"pokeball"] as Array[StringName], "el Repelente no se usa en combate")


func test_save_and_load_round_trip() -> void:
	var bag := Bag.new()
	bag.add(&"potion", 2)
	bag.add(&"pokeball", 5)
	var copy := Bag.new()
	copy.from_dict(JSON.parse_string(JSON.stringify(bag.to_dict())))
	assert_eq(copy.all_items(), bag.all_items())
	assert_eq(copy.count(&"pokeball"), 5)


func test_game_state_creates_and_saves_the_bag() -> void:
	GameState.reset()
	assert_true(GameState.bag is Bag, "GameState crea la mochila por su class_name")
	(GameState.bag as Bag).add(&"potion", 4)
	var saved := GameState.to_dict()
	GameState.reset()
	GameState.from_dict(JSON.parse_string(JSON.stringify(saved)))
	assert_eq((GameState.bag as Bag).count(&"potion"), 4)
	GameState.reset()
