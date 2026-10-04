extends GutTest

func _rules(settings: Dictionary = {}) -> LockeRules:
	return LockeRules.new(settings, {"a": "line", "a_evo": "line", "b": "other"}, JsonFile.read("res://data/randomizer/epitafios.json"))

func test_primer_encuentro_consume_zona_antes_de_captura() -> void:
	var rules := _rules()
	var record := rules.register_encounter("cueva", "a", false, "wild", "e1")
	assert_true(record.allowed)
	assert_eq(rules.zone_status("cueva"), "pending")
	assert_false(rules.can_catch("cueva", "b"))
	assert_true(rules.can_catch("cueva", "a", false, "wild", "e1"))
	assert_false(rules.can_catch("cueva", "b", false, "wild", "e1"))
	assert_true(rules.resolve_encounter("e1", "run"))
	assert_eq(rules.zone_status("cueva"), "lost")
	assert_false(rules.can_catch("cueva", "a"))
	assert_false(rules.resolve_encounter("e1", "caught", {"species": "a", "nickname": "Paco"}))

func test_ko_y_captura_con_mote_obligatorio() -> void:
	var rules := _rules()
	rules.register_encounter("ruta", "a", false, "wild", "e1")
	assert_false(rules.resolve_encounter("e1", "caught", {"species": "a"}))
	assert_true(rules.resolve_encounter("e1", "caught", {"species": "a", "nickname": "Paco"}))
	assert_true(rules.resolve_encounter("e1", "caught", {"species": "a", "nickname": "Paco"}))
	assert_eq(rules.snapshot().captures, 1)
	assert_eq(rules.zone_status("ruta"), "caught")
	rules.register_encounter("otra", "b", false, "wild", "e2")
	assert_true(rules.resolve_encounter("e2", "fainted"))
	assert_eq(rules.zone_status("otra"), "lost")

func test_duplicados_por_linea_no_consumen_ni_olvidan_muertos() -> void:
	var rules := _rules()
	rules.register_owned("a")
	assert_false(rules.register_encounter("ruta", "a_evo").allowed)
	assert_eq(rules.zone_status("ruta"), "available")
	rules.register_death({"uid": "1", "species": "a", "nickname": "Paco", "level": 12}, {})
	assert_false(rules.register_encounter("ruta", "a_evo").allowed)
	assert_true(rules.register_encounter("ruta", "b").allowed)
	var no_clause := _rules({"duplicates_clause": false})
	no_clause.register_owned("a")
	assert_true(no_clause.register_encounter("ruta", "a_evo").allowed)

func test_shiny_siempre_capturable_sin_consumir_zona() -> void:
	var rules := _rules()
	rules.register_owned("a")
	assert_true(rules.register_encounter("ruta", "a", true, "wild", "shiny").allowed)
	assert_eq(rules.zone_status("ruta"), "available")
	rules.register_encounter("ruta", "b", false, "wild", "normal")
	rules.resolve_encounter("normal", "run")
	assert_true(rules.register_encounter("ruta", "a", true, "wild", "shiny2").allowed)
	assert_true(rules.resolve_encounter("shiny2", "caught", {"species": "a", "nickname": "Brilli"}))
	assert_eq(rules.zone_status("ruta"), "lost")
	var no_clause := _rules({"shiny_clause": false})
	no_clause.register_encounter("ruta", "a")
	assert_false(no_clause.can_catch("ruta", "b", true))

func test_regalos_estaticos_y_trueques_configurables() -> void:
	for source: String in ["gift", "static", "trade"]:
		var rules := _rules()
		rules.register_encounter("ruta", "a", false, source, "e")
		assert_eq(rules.zone_status("ruta"), "pending", source)
		var free := _rules({"gifts_count": false, "statics_count": false})
		assert_true(free.register_encounter("ruta", "a", false, source, "e").allowed)
		assert_eq(free.zone_status("ruta"), "available", source)

func test_muerte_idempotente_cementerio_y_epitafio() -> void:
	var rules := _rules()
	var pokemon := {"uid": "55", "species": "a", "nickname": "Paco", "level": 9}
	var grave := rules.register_death(pokemon, {"zone_id": "ruta", "opponent": "Manolo"})
	assert_true(grave.dead)
	assert_eq(grave.opponent, "Manolo")
	assert_string_contains(grave.epitaph, "Paco")
	assert_eq(rules.register_death(pokemon, {}), grave)
	assert_eq(rules.snapshot().death_count, 1)
	assert_eq(rules.snapshot().cemetery.size(), 1)
	grave.nickname = "CAMBIADO"
	assert_eq(rules.snapshot().cemetery[0].nickname, "Paco")
	assert_eq(_rules({"permadeath": false}).register_death(pokemon, {}), {})

func test_tope_fijo_y_objetos() -> void:
	var rules := _rules({"level_cap": true, "fixed_battle": true, "battle_items": "limited", "battle_item_limit": 2})
	assert_eq(rules.level_cap(18), 18)
	assert_true(rules.can_gain_exp(17, 18))
	assert_false(rules.can_gain_exp(18, 18))
	assert_eq(rules.battle_mode(), "fixed")
	assert_true(rules.can_use_item(1))
	assert_false(rules.can_use_item(2))
	assert_false(_rules({"battle_items": "forbidden"}).can_use_item(0))
	assert_eq(_rules().level_cap(18), 0)
	assert_true(_rules().can_use_item(50))

func test_game_over_con_pc_huevos_y_cementerio() -> void:
	var rules := _rules()
	assert_false(rules.is_game_over([], []), "partida nueva antes de recibir inicial")
	rules.register_owned("a")
	var dead := {"uid": "1", "species": "a", "hp": 0}
	rules.register_death(dead, {})
	assert_false(rules.is_game_over([dead], [{"uid": "2", "species": "b", "hp": 20}]))
	assert_true(rules.is_game_over([dead], [{"uid": "3", "egg": true}]))
	assert_eq(rules.snapshot().state, "finished")
	assert_false(rules.can_catch("otra", "b", true))
	assert_true(rules.is_game_over([], []))
	var recoverable := _rules({"permadeath": false})
	recoverable.register_owned("a")
	assert_false(recoverable.is_game_over([dead], []))

func test_solo_aleatorio_y_reglas_inmutables() -> void:
	var source := {"first_encounter": false, "nickname_required": false}
	var rules := _rules(source)
	source.first_encounter = true
	var exposed := rules.rules()
	exposed.first_encounter = true
	rules.register_encounter("ruta", "a", false, "wild", "e")
	assert_true(rules.resolve_encounter("e", "caught", {"species": "a"}))
	assert_eq(rules.zone_status("ruta"), "available")
	var solo := _rules({"locke_rules": false})
	assert_true(solo.can_use_item(100))
	assert_eq(solo.battle_mode(), "normal")
	assert_eq(solo.register_death({"uid": "1"}, {}), {})

func test_guardado_json_y_encuentro_pendiente_restaurado() -> void:
	var rules := _rules()
	rules.register_encounter("ruta", "a", false, "wild", "e")
	var restored := LockeRules.from_dict(JSON.parse_string(JSON.stringify(rules.snapshot())))
	assert_eq(JSON.stringify(restored.snapshot(), "", true), JSON.stringify(rules.snapshot(), "", true))
	assert_true(restored.can_catch("ruta", "a", false, "wild", "e"))
	assert_true(restored.resolve_encounter("e", "caught", {"species": "a", "nickname": "Paco"}))
	assert_eq(restored.zone_status("ruta"), "caught")
	assert_eq(restored.register_encounter("ruta", "b", false, "wild", "e"), {}, "ID reutilizado para otro encuentro")
