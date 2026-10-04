extends GutTest
## DataDB: carga de data/generated, overrides y datos de los demás agentes (Fase 4.5).


func test_criterio_de_hecho_de_la_fase_4() -> void:
	assert_eq(DataDB.species(&"pikachu").name, "Pikachu")
	assert_eq(DataDB.move(&"thunderbolt").name, "Rayo")


func test_especie_tipada() -> void:
	var s := DataDB.species(&"pikachu")
	assert_eq(s.num, 25)
	assert_eq(s.types, [&"electric"] as Array[StringName])
	assert_eq(s.base_stat(&"hp"), 35)
	assert_eq(s.base_stat(&"spe"), 90)
	assert_eq(s.ability("0"), &"static")
	assert_eq(s.ability("H"), &"lightningrod")
	assert_eq(s.catch_rate, 190)
	assert_eq(s.exp_group, &"medium_fast")
	assert_eq(s.ev_yield, {&"spe": 2} as Dictionary[StringName, int])
	assert_eq(s.genus, "Pokémon Ratón")
	assert_almost_eq(s.gender_ratio, 0.5, 0.001)
	assert_false(s.dex_entry.is_empty())


func test_formas() -> void:
	var s := DataDB.species(&"raichualola")
	assert_true(s.is_form())
	assert_eq(s.base_species, &"raichu")
	assert_eq(s.name, "Raichu")
	assert_eq(s.form_name, "Forma de Alola")
	assert_eq(s.types, [&"electric", &"psychic"] as Array[StringName])
	assert_eq(DataDB.species(&"shedinja").fixed_max_hp, 1)
	assert_true(DataDB.species(&"magikarp").is_genderless() == false)
	assert_true(DataDB.species(&"magnemite").is_genderless())


func test_movimiento_tipado() -> void:
	var m := DataDB.move(&"thunderbolt")
	assert_eq(m.type, &"electric")
	assert_eq(m.category, MoveData.Category.SPECIAL)
	assert_eq(m.power, 90)
	assert_eq(m.accuracy, 100)
	assert_eq(m.pp, 15)
	assert_eq(m.max_pp(3), 24)
	assert_eq(m.secondaries.size(), 1)
	assert_eq(m.secondaries[0]["status"], "par")
	assert_false(m.needs_script)
	assert_eq(DataDB.move(&"swordsdance").accuracy, 0, "0 = no falla nunca")
	assert_eq(DataDB.move(&"swordsdance").boosts, {&"atk": 2} as Dictionary[StringName, int])
	assert_eq(DataDB.move(&"pinmissile").multihit_max, 5)
	assert_eq(DataDB.move(&"absorb").drain, [1, 2] as Array[int])
	assert_true(DataDB.move(&"seismictoss").level_damage)
	assert_true(DataDB.move(&"protect").needs_script)


func test_objetos() -> void:
	var potion := DataDB.item(&"potion")
	assert_eq(potion.name, "Poción")
	assert_eq(potion.pocket, &"medicine")
	assert_eq(potion.price, 200)
	assert_eq(potion.sell_price(), 100)
	assert_eq(potion.effect, &"heal_hp")
	assert_eq(int(potion.param("amount")), 20)
	assert_eq(potion.battle_use, ItemData.USE_ON_POKEMON)
	var ball := DataDB.item(&"greatball")
	assert_true(ball.is_ball())
	assert_almost_eq(float(ball.param("multiplier")), 1.5, 0.001)
	assert_eq(DataDB.item(&"leftovers").name, "Restos")


func test_tabla_de_tipos() -> void:
	assert_eq(DataDB.type_ids().size(), 18)
	assert_eq(DataDB.type_name(&"fire"), "Fuego")
	assert_eq(DataDB.type_effectiveness(&"electric", [&"water", &"flying"]), 4.0)
	assert_eq(DataDB.type_effectiveness(&"ground", [&"flying"]), 0.0)
	assert_eq(DataDB.type_effectiveness(&"fire", [&"water", &"rock"]), 0.25)
	assert_eq(DataDB.type_effectiveness(&"normal", [&"ghost"]), 0.0)
	assert_eq(DataDB.type_effectiveness(&"fighting", [&"normal"]), 2.0)
	assert_true(DataDB.type_immune_to(&"fire", &"brn"))
	assert_true(DataDB.type_immune_to(&"electric", &"par"))
	assert_true(DataDB.type_immune_to(&"steel", &"psn"))
	assert_false(DataDB.type_immune_to(&"water", &"brn"))


func test_experiencia() -> void:
	assert_eq(DataDB.exp_for_level(&"medium_fast", 100), 1000000)
	assert_eq(DataDB.exp_for_level(&"medium_fast", 10), 1000)
	assert_eq(DataDB.exp_for_level(&"fast", 100), 800000)
	assert_eq(DataDB.exp_for_level(&"medium_slow", 100), 1059860)
	assert_eq(DataDB.level_for_exp(&"medium_fast", 999), 9)
	assert_eq(DataDB.level_for_exp(&"medium_fast", 1000), 10)
	assert_eq(DataDB.level_for_exp(&"erratic", 600000), 100)


func test_naturalezas() -> void:
	assert_eq(DataDB.nature_ids().size(), 25)
	var adamant := DataDB.nature(&"adamant")
	assert_eq(adamant.name, "Firme")
	assert_eq(adamant.percent(&"atk"), 110)
	assert_eq(adamant.percent(&"spa"), 90)
	assert_eq(adamant.percent(&"spe"), 100)
	assert_eq(DataDB.nature(&"hardy").percent(&"atk"), 100)


func test_learnsets() -> void:
	assert_eq(DataDB.default_moves(&"bulbasaur", 5), [&"growl", &"tackle", &"vinewhip"] as Array[StringName])
	assert_eq(DataDB.default_moves(&"bulbasaur", 15).size(), 4)
	assert_eq(DataDB.moves_learned_at(&"charmander", 4), [&"ember"] as Array[StringName])
	assert_true(DataDB.can_learn(&"pikachu", &"thunderbolt"))
	assert_false(DataDB.can_learn(&"magikarp", &"thunderbolt"))
	assert_false(DataDB.level_up_moves(&"raichualola").is_empty(), "las formas tienen learnset")


func test_overrides_sustituyen_los_intercambios() -> void:
	var evo: Dictionary = DataDB.species(&"kadabra").evolutions[0]
	assert_eq(evo["to"], "alakazam")
	assert_eq(evo["method"], "level")
	assert_eq(int(evo["level"]), 37)
	var onix: Dictionary = DataDB.species(&"onix").evolutions[0]
	assert_eq(onix["method"], "level_hold")
	assert_eq(onix["item"], "metalcoat")
	for id: StringName in DataDB.species_ids():
		for e: Dictionary in DataDB.species(id).evolutions:
			assert_ne(e.get("method", ""), "trade", "%s todavía evoluciona por intercambio" % id)


func test_datos_de_los_demas_agentes() -> void:
	assert_true(DataDB.has_trainer_class(&"vendedorchupachups"))
	assert_eq(int(DataDB.trainer_class(&"vendedorchupachups")["base_money"]), 24)
	assert_true(DataDB.has_trainer(&"ruta1_manolo"))
	assert_eq(DataDB.trainer(&"ruta1_manolo")["class"], "vendedorchupachups")
	assert_true(DataDB.has_encounter_table(&"ruta_1"))
	assert_false(DataDB.encounter_table(&"ruta_1")["land"]["day"].is_empty())
	assert_true(DataDB.has_shop(&"tienda_ciudad2"))
	assert_almost_eq(DataDB.shop_sell_ratio(), 0.5, 0.001)
