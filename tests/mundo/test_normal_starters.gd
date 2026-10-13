extends GutTest
func after_each() -> void:
	GameState.reset()
	DataDB.clear_patch()

func test_all_generations_and_three_distinct_offers_are_available() -> void:
	var generations: Dictionary = {}
	for id: StringName in NormalStarters.pool(): generations[DataDB.species(id).generation] = true
	for gen: int in range(1, 10): assert_true(generations.has(gen))
	for seed_value: int in range(60):
		var offer := NormalStarters.generate(seed_value)
		assert_eq(offer.size(), 3)
		var species: Array = []
		for id: String in offer:
			assert_true(DataDB.has_species(StringName(offer[id].species)))
			assert_false(species.has(offer[id].species))
			species.append(offer[id].species)
	assert_eq(NormalStarters.generate(77), NormalStarters.generate(77))
	assert_ne(NormalStarters.generate(77), NormalStarters.generate(78))

func test_normal_offer_persists_and_rival_uses_one_of_the_other_choices() -> void:
	GameState.new_game({"starter_seed": 53})
	var offer := GameState.normal_starters.duplicate(true)
	for i: int in range(1,4):
		assert_eq(DataDB.starter(StringName("starter_%d" % i)), StringName(offer["starter_%d" % i].species))
		var rival := DataDB.trainer(StringName("rival_lab_%d" % i))
		assert_eq(rival.party[0].species, offer[rival.starter_slot].species)
		assert_ne(rival.party[0].species, offer["starter_%d" % i].species)
	var serialized: Dictionary = JSON.parse_string(JSON.stringify(GameState.to_dict()))
	GameState.new_game({"starter_seed": 99})
	assert_ne(GameState.normal_starters, offer)
	GameState.from_dict(serialized)
	assert_eq(GameState.normal_starters, offer)
	assert_eq(DataDB.starter(&"starter_1"), StringName(offer.starter_1.species))
	var detached := DataDB.starter_spec(&"starter_1")
	detached.species = "ditto"
	assert_eq(GameState.normal_starters, offer)

func test_randomlocke_and_legacy_saves_keep_their_exact_previous_source() -> void:
	GameState.new_game({"mode": GameState.MODE_RANDOMLOCKE})
	assert_eq(GameState.normal_starters, {})
	assert_eq(DataDB.apply_patch({"generator_version":1,"starters":{"starter_1":"litwick"}}), [] as Array[String])
	assert_eq(DataDB.starter(&"starter_1"), &"litwick")
	DataDB.clear_patch()
	GameState.new_game({"starter_seed": 7})
	var old := GameState.to_dict()
	old.erase("normal_starters")
	GameState.from_dict(old)
	assert_eq(GameState.normal_starters, {})
	var base: Dictionary = DataDB._story_entry(DataDB._starters, "starters", &"starter_1", "el inicial")
	assert_eq(DataDB.starter_spec(&"starter_1"), base)
