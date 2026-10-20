extends GutTest
## Objetos equipados de combate (fase 9.5, segunda parte): un test por familia, con los valores de la
## 9.ª generación de Showdown.


func _mon(species: StringName, level: int, moves: Array, item: String = "") -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var p := Pokemon.create(species, level, rng)
	p.apply_spec({"nature": "hardy", "ivs": 31, "moves": moves})
	p.held_item = StringName(item)
	return p


func _engine(player: Array[Pokemon], foes: Array[Pokemon], oracle: Dictionary = {"*": 0.5, "crit": 0.99, "secondary": 0.99}) -> BattleEngine:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.player_party = player
	s.foe_party = foes
	s.player_name = "Ash"
	s.seed = 3
	s.trainers = [{"display_name": "Entrenador Prueba", "base_money": 10, "lose_text": "Vaya."}]
	s.foe_controller = func(_e: BattleEngine, _side: int, _slot: int) -> BattleAction: return BattleAction.fight(0)
	if not oracle.is_empty():
		s.rng_oracle = func(tag: StringName, _turn: int) -> float: return float(oracle.get(tag, oracle.get("*", 0.5)))
	var engine := BattleEngine.new(s)
	engine.start()
	engine.active(0).ability = &"runaway"
	engine.active(1).ability = &"runaway"
	return engine


func _sum(events: Array[BattleEvent], type: StringName, side: int, source: String = "") -> int:
	var total := 0
	for e: BattleEvent in events:
		if e.type == type and e.side == side and (source == "" or e.value("source") == source):
			total += int(e.value("amount"))
	return total


func _hit(move: String, item: String, def_item: String = "") -> int:
	var engine := _engine([_mon(&"arcanine", 50, [move], item)], [_mon(&"snorlax", 50, ["splash"], def_item)])
	return _sum(engine.submit(BattleAction.fight(0)), BattleEvent.DAMAGE, 1, "move")


func test_los_objetos_de_combate_tienen_efecto() -> void:
	for id: StringName in [&"charcoal", &"flameplate", &"muscleband", &"expertbelt", &"eviolite", &"quickclaw",
			&"kingsrock", &"shellbell", &"weaknesspolicy", &"airballoon", &"blacksludge", &"toxicorb", &"whiteherb",
			&"lightclay", &"heatrock", &"powerherb", &"bigroot", &"loadeddice", &"covertcloak", &"clearamulet",
			&"liechiberry", &"leftovers", &"lifeorb", &"focussash", &"choiceband", &"assaultvest", &"rockyhelmet",
			&"sitrusberry", &"lumberry", &"occaberry"]:
		assert_not_null(Effects.item(id), String(id))


func test_potenciadores_de_tipo_y_de_categoria() -> void:
	var plain := _hit("flamethrower", "")
	assert_almost_eq(float(_hit("flamethrower", "charcoal")) / plain, 1.2, 0.06, "Carbón")
	var physical := _hit("crunch", "")
	assert_almost_eq(float(_hit("crunch", "muscleband")) / physical, 1.1, 0.06, "Cinta Fuerte")
	assert_eq(_hit("flamethrower", "muscleband"), plain, "la Cinta Fuerte no sube los especiales")


func test_mineral_evolutivo_y_cinta_experto() -> void:
	# Golpe Roca (40) contra un Porygon2 de nivel 80: no llega a debilitarlo.
	var engine := _engine([_mon(&"machamp", 40, ["rocksmash"])], [_mon(&"porygon2", 80, ["splash"])])
	var vs_plain := _sum(engine.submit(BattleAction.fight(0)), BattleEvent.DAMAGE, 1, "move")
	var evio := _engine([_mon(&"machamp", 40, ["rocksmash"])], [_mon(&"porygon2", 80, ["splash"], "eviolite")])
	assert_almost_eq(float(_sum(evio.submit(BattleAction.fight(0)), BattleEvent.DAMAGE, 1, "move")) / vs_plain, 2.0 / 3.0, 0.08, "Mineral Evolutivo")
	var belt := _engine([_mon(&"machamp", 40, ["rocksmash"], "expertbelt")], [_mon(&"porygon2", 80, ["splash"])])
	assert_almost_eq(float(_sum(belt.submit(BattleAction.fight(0)), BattleEvent.DAMAGE, 1, "move")) / vs_plain, 1.2, 0.06, "Cinta Experto")


func test_al_recibir_seguro_debilidad_y_globo() -> void:
	var engine := _engine([_mon(&"machamp", 50, ["closecombat", "earthquake"])], [_mon(&"snorlax", 80, ["splash"], "weaknesspolicy")])
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(1).boosts[&"atk"], 2, "Seguro Debilidad")
	assert_eq(engine.active(1).pokemon.held_item, &"")
	var balloon := _engine([_mon(&"machamp", 50, ["earthquake", "tackle"])], [_mon(&"snorlax", 80, ["splash"], "airballoon")])
	assert_eq(_sum(balloon.submit(BattleAction.fight(0)), BattleEvent.DAMAGE, 1, "move"), 0, "Globo Helio")
	balloon.submit(BattleAction.fight(1))
	assert_eq(balloon.active(1).pokemon.held_item, &"", "el globo explota al recibir un golpe")


func test_final_del_turno_lodo_negro_y_toxisfera() -> void:
	var engine := _engine([_mon(&"muk", 50, ["splash"], "blacksludge")], [_mon(&"snorlax", 50, ["splash"], "toxicorb")])
	var muk := engine.active(0)
	muk.pokemon.current_hp = muk.pokemon.max_hp() / 2
	var before := muk.pokemon.current_hp
	engine.submit(BattleAction.fight(0))
	assert_gt(muk.pokemon.current_hp, before, "Lodo Negro cura a los de tipo Veneno")
	assert_eq(engine.active(1).pokemon.status, &"tox", "Toxisfera")


func test_hierba_blanca_y_amuleto_claro() -> void:
	var engine := _engine([_mon(&"machamp", 50, ["closecombat"], "whiteherb")], [_mon(&"snorlax", 80, ["splash"])])
	engine.submit(BattleAction.fight(0))
	assert_eq(engine.active(0).boosts[&"def"], 0, "Hierba Blanca deshace la bajada")
	var amulet := _engine([_mon(&"rattata", 50, ["growl"])], [_mon(&"snorlax", 50, ["splash"], "clearamulet")])
	amulet.submit(BattleAction.fight(0))
	assert_eq(amulet.active(1).boosts[&"atk"], 0, "Amuleto Claro")


func test_duracion_refleluz_y_hierba_unica() -> void:
	var engine := _engine([_mon(&"alakazam", 50, ["reflect", "solarbeam"], "lightclay")], [_mon(&"snorlax", 50, ["splash"])])
	engine.submit(BattleAction.fight(0))
	assert_eq(int(engine.side_condition(0, &"reflect").get("turns", 0)), 7, "Refleluz: 8 turnos (ya ha pasado uno)")
	var herb := _engine([_mon(&"venusaur", 50, ["solarbeam"], "powerherb")], [_mon(&"snorlax", 50, ["splash"])])
	assert_gt(_sum(herb.submit(BattleAction.fight(0)), BattleEvent.DAMAGE, 1, "move"), 0, "Hierba Única: golpea sin cargar")


func test_bayas_de_apuro_y_garra_rapida() -> void:
	var engine := _engine([_mon(&"machamp", 50, ["tackle"])], [_mon(&"snorlax", 50, ["splash"], "liechiberry")])
	var foe := engine.active(1)
	foe.pokemon.current_hp = foe.pokemon.max_hp() / 4 + 5
	engine.submit(BattleAction.fight(0))
	assert_eq(foe.boosts[&"atk"], 1, "baya Lichi a 1/4 de los PS")
	var claw := _engine([_mon(&"snorlax", 50, ["tackle"], "quickclaw")], [_mon(&"jolteon", 50, ["splash"])], {"*": 0.5, "crit": 0.99, "quickclaw": 0.0})
	var first := -1
	for e: BattleEvent in claw.submit(BattleAction.fight(0)):
		if e.type == BattleEvent.MOVE and first < 0:
			first = e.side
	assert_eq(first, 0, "Garra Rápida: el lento actúa primero")
