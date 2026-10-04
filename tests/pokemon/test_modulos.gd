extends GutTest
## Party, PCStorage y Pokedex (módulos de GameState).


func _mon(species: StringName, level: int = 5) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	return Pokemon.create(species, level, rng)


func test_equipo() -> void:
	var party := Party.new()
	assert_true(party.is_all_fainted(), "vacío cuenta como derrotado")
	for i: int in Party.MAX_SIZE:
		assert_true(party.add(_mon(&"pidgey", 3 + i)))
	assert_true(party.is_full())
	assert_false(party.add(_mon(&"rattata")))
	party.members[0].take_damage(999)
	assert_eq(party.first_able_index(), 1)
	assert_eq(party.first_able_level(), 4)
	assert_eq(party.able_count(), 5)
	party.swap(0, 1)
	assert_eq(party.members[0].level, 4)
	party.move(5, 0)
	assert_eq(party.members[0].level, 8)
	party.heal_all()
	assert_eq(party.able_count(), 6)
	for p: Pokemon in party.members:
		p.take_damage(999)
	assert_true(party.is_all_fainted())


func test_equipo_guardar_y_cargar() -> void:
	var party := Party.new()
	party.add(_mon(&"bulbasaur"))
	party.add(_mon(&"pikachu", 9))
	var copy := Party.new()
	copy.from_dict(JSON.parse_string(JSON.stringify(party.to_dict())))
	assert_eq(copy.size(), 2)
	assert_eq(copy.to_dict(), party.to_dict())


func test_pc() -> void:
	var pc := PCStorage.new()
	assert_eq(pc.box_count(), 32)
	assert_eq(pc.box_size(), 30)
	assert_eq(pc.box_name(0), "Caja 1")
	var where := pc.deposit(_mon(&"rattata"))
	assert_eq(where, Vector2i(0, 0))
	assert_eq(pc.deposit(_mon(&"pidgey")), Vector2i(0, 1))
	pc.move(0, 0, 3, 7)
	assert_eq(pc.get_pokemon(3, 7).species_id, &"rattata")
	assert_null(pc.get_pokemon(0, 0))
	assert_eq(pc.count(), 2)
	var taken := pc.take(0, 1)
	assert_eq(taken.species_id, &"pidgey")
	assert_eq(pc.count(), 1)
	pc.rename_box(3, "Ratas")
	pc.current_box = 3
	var copy := PCStorage.new()
	copy.from_dict(JSON.parse_string(JSON.stringify(pc.to_dict())))
	assert_eq(copy.box_name(3), "Ratas")
	assert_eq(copy.current_box, 3)
	assert_eq(copy.get_pokemon(3, 7).to_dict(), pc.get_pokemon(3, 7).to_dict())
	assert_eq(copy.deposit(_mon(&"pidgey")), Vector2i(3, 0), "empieza por la caja actual")


func test_pokedex() -> void:
	var dex := Pokedex.new()
	dex.mark_seen(&"raichualola")
	assert_true(dex.is_seen(&"raichu"))
	assert_false(dex.is_caught(&"raichu"))
	assert_eq(dex.forms_seen(&"raichu"), [&"raichualola"] as Array[StringName])
	dex.register(_mon(&"pikachu"))
	assert_true(dex.is_caught(&"pikachu"))
	assert_eq(dex.seen_count(), 2)
	assert_eq(dex.caught_count(), 1)
	var copy := Pokedex.new()
	copy.from_dict(JSON.parse_string(JSON.stringify(dex.to_dict())))
	assert_eq(copy.to_dict(), dex.to_dict())
	assert_true(copy.is_caught(&"pikachu"))


func test_game_state_crea_los_modulos() -> void:
	assert_true(GameState.party is Party)
	assert_true(GameState.pc is PCStorage)
	assert_true(GameState.pokedex is Pokedex)
