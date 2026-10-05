extends GutTest
## Regla R.2 (datos de la historia por id) y parche de RandomLocke en DataDB (Fase R.1).

var _saved: Dictionary


func before_each() -> void:
	_saved = {"starters": DataDB._starters, "gifts": DataDB._gifts, "statics": DataDB._statics, "trades": DataDB._trades}
	DataDB._starters = {"starter_1": "bulbasaur", "starter_2": {"species": "charmander", "level": 5}}
	DataDB._gifts = {"gift_eevee": {"species": "eevee", "level": 10}}
	DataDB._statics = {"static_snorlax": {"species": "snorlax", "level": 30, "randomize": false}}
	DataDB._trades = {"trade_farfetchd": {"give": "pidgey", "receive": {"species": "farfetchd", "nickname": "Puerrete"}}}


func after_each() -> void:
	DataDB.clear_patch()
	DataDB._starters = _saved["starters"]
	DataDB._gifts = _saved["gifts"]
	DataDB._statics = _saved["statics"]
	DataDB._trades = _saved["trades"]


func test_datos_de_la_historia_por_id() -> void:
	assert_eq(DataDB.starter(&"starter_1"), &"bulbasaur")
	assert_eq(DataDB.starter_spec(&"starter_2"), {"species": "charmander", "level": 5})
	assert_eq(DataDB.gift(&"gift_eevee")["species"], "eevee")
	assert_eq(int(DataDB.static_encounter(&"static_snorlax")["level"]), 30)
	assert_eq(DataDB.trade(&"trade_farfetchd")["receive"]["nickname"], "Puerrete")
	assert_eq(DataDB.placed_item(&"ruta_1/ItemBall1", &"potion"), &"potion")


func test_marcadores_de_texto() -> void:
	assert_eq(DataDB.resolve_markers("¡Cuida bien de {gift:gift_eevee}!"), "¡Cuida bien de Eevee!")
	assert_eq(DataDB.resolve_markers("{starter:starter_2} o {species:pikachu}, con {item:potion}."), "Charmander o Pikachu, con Poción.")
	assert_eq(DataDB.resolve_markers("¡{static:static_snorlax} se ha despertado!"), "¡Snorlax se ha despertado!")
	assert_eq(DataDB.resolve_markers("Te doy un {trade:trade_farfetchd}."), "Te doy un Farfetch’d.")
	assert_eq(DataDB.resolve_markers("Sin marcadores {player}."), "Sin marcadores {player}.")


func test_el_parche_cambia_las_consultas_y_se_puede_quitar() -> void:
	var table := DataDB.encounter_table(&"ruta_1")
	DataDB.apply_patch({
		"starters": {"starter_1": "litwick"},
		"gifts": {"gift_eevee": "dratini"},
		"items": {"ruta_1/ItemBall1": "superpotion"},
		"encounters": {"ruta_1": {"land": [{"species": "zubat", "min": 2, "max": 3, "weight": 1}]}},
		"trainers": {"ruta1_manolo": {"party": [{"species": "mareep", "level": 5}]}},
		"learnsets": {"bulbasaur": [[1, "ember"], [5, "bite"]]},
		"abilities": {"bulbasaur": {"0": "levitate"}},
		"species": {"pikachu": {"types": ["water"]}},
	})
	assert_true(DataDB.has_patch())
	assert_eq(DataDB.starter(&"starter_1"), &"litwick")
	assert_eq(DataDB.gift(&"gift_eevee")["species"], "dratini")
	assert_eq(int(DataDB.gift(&"gift_eevee")["level"]), 10, "lo que no cambia se conserva")
	assert_eq(DataDB.resolve_markers("{gift:gift_eevee}"), "Dratini")
	assert_eq(DataDB.placed_item(&"ruta_1/ItemBall1", &"potion"), &"superpotion")
	assert_eq(DataDB.encounter_table(&"ruta_1")["land"][0]["species"], "zubat")
	assert_eq(DataDB.trainer(&"ruta1_manolo")["party"][0]["species"], "mareep")
	assert_eq(DataDB.trainer(&"ruta1_manolo")["class"], "vendedorchupachups")
	assert_eq(DataDB.default_moves(&"bulbasaur", 10), [&"ember", &"bite"] as Array[StringName])
	assert_eq(DataDB.species(&"bulbasaur").ability("0"), &"levitate")
	assert_eq(DataDB.species(&"pikachu").types, [&"water"] as Array[StringName])
	DataDB.clear_patch()
	assert_false(DataDB.has_patch())
	assert_eq(DataDB.starter(&"starter_1"), &"bulbasaur")
	assert_eq(DataDB.encounter_table(&"ruta_1"), table)
	assert_eq(DataDB.species(&"pikachu").types, [&"electric"] as Array[StringName])
	assert_eq(DataDB.default_moves(&"bulbasaur", 5), [&"growl", &"tackle", &"vinewhip"] as Array[StringName])


func test_entrada_del_randomizer() -> void:
	var source := DataDB.randomizer_input()
	var bulbasaur: Dictionary = source.species["bulbasaur"]
	var ivysaur: Dictionary = source.species["ivysaur"]
	var venusaur: Dictionary = source.species["venusaur"]
	assert_eq(int(bulbasaur["stage"]), 0)
	assert_eq(int(ivysaur["stage"]), 1)
	assert_eq(int(ivysaur["min_level"]), 16)
	assert_eq(int(venusaur["min_level"]), 32)
	assert_eq(str(bulbasaur["family_id"]), str(venusaur["family_id"]))
	assert_eq(int(bulbasaur["max_level"]), 25, "el generador le suma 1")
	assert_false(bool(bulbasaur["legendary"]))
	assert_true(bool(source.species["mewtwo"]["legendary"]))
	var input := RandomizerInput.from_dict(source)
	assert_eq(input.fingerprint.length(), 64)
	assert_eq(RandomizerInput.from_datadb().fingerprint, input.fingerprint)


func test_apply_patch_es_atomico() -> void:
	var applied := DataDB.apply_patch({"starters": {"starter_1": "litwick"}})
	assert_eq(applied, [] as Array[String])
	var rejected := DataDB.apply_patch({
		"input_hash": "no-es-el-hash",
		"species": {"pikachu": {"types": ["water"]}},
	})
	assert_false(rejected.is_empty())
	assert_eq(DataDB.starter(&"starter_1"), &"litwick", "un hash malo no quita el parche activo")
	assert_eq(DataDB.species(&"pikachu").types, [&"electric"] as Array[StringName])
	DataDB.clear_patch()
	var unknown := DataDB.apply_patch({"species": {"noexiste": {"types": ["water"]}}})
	assert_false(unknown.is_empty())
	assert_false(DataDB.has_patch())


func test_consultas_de_mt_tutores_objetos_y_shiny() -> void:
	DataDB.apply_patch({
		"tm_moves": {"tm01": {"move": "ember"}},
		"tutor_moves": {"tutor_fuego": "flamethrower"},
		"tm_compat": {"charmander": ["tm01"]},
		"tutor_compat": {"charmander": ["tutor_fuego"]},
		"species": {"charmander": {"held_items": ["charcoal"]}},
		"settings": {"shiny_denominator": 512},
	})
	assert_eq(DataDB.tm_move(&"tm01"), &"ember")
	assert_eq(DataDB.tutor_move(&"tutor_fuego"), &"flamethrower")
	assert_eq(DataDB.tm_compat(&"charmander"), ["tm01"])
	assert_eq(DataDB.tutor_compat(&"charmander"), ["tutor_fuego"])
	assert_eq(DataDB.learnset(&"charmander")["tutor"], ["tutor_fuego"])
	assert_eq(DataDB.species(&"charmander").raw["held_items"], ["charcoal"])
	assert_eq(DataDB.shiny_odds(), 512)
	DataDB.clear_patch()
	assert_eq(DataDB.shiny_odds(), 4096)
	assert_eq(DataDB.tm_move(&"tm01"), &"")
