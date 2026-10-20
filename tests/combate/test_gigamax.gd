extends GutTest
## Gigamax: con el factor Gigamax, al dinamaxizarse toma su forma Gigamax y sus golpes del tipo de su
## movimiento Gigamax se convierten en él, con su efecto propio. Un caso por familia.


func _mon(species: StringName, level: int, moves: Array, gmax: bool = false) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 13
	var p := Pokemon.create(species, level, rng)
	p.apply_spec({"nature": "hardy", "ivs": 31, "moves": moves, "gigantamax": gmax})
	return p


func _engine(player: Pokemon, foe: Pokemon) -> BattleEngine:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.player_party = [player]
	s.foe_party = [foe]
	s.player_name = "Ash"
	s.seed = 4
	s.dynamax = true
	s.trainers = [{"display_name": "Entrenador Prueba", "base_money": 10, "lose_text": "Vaya."}]
	s.foe_controller = func(_e: BattleEngine, _side: int, _slot: int) -> BattleAction: return BattleAction.fight(0)
	s.rng_oracle = func(tag: StringName, _turn: int) -> float: return 0.99 if tag == &"crit" else 0.0
	var engine := BattleEngine.new(s)
	engine.start()
	engine.active(1).ability = &"runaway"
	return engine


func _dyn() -> BattleAction:
	var action := BattleAction.fight(0)
	action.dynamax = true
	return action


func _move_id(events: Array[BattleEvent]) -> String:
	for e: BattleEvent in events:
		if e.type == BattleEvent.MOVE and e.side == BattleEngine.PLAYER:
			return str(e.value("move"))
	return ""


func test_toma_la_forma_y_el_movimiento_gigamax() -> void:
	var zard := _mon(&"charizard", 50, ["flamethrower"], true)
	var engine := _engine(zard, _mon(&"snorlax", 60, ["splash"]))
	var events := engine.submit(_dyn())
	assert_eq(zard.species_id, &"charizardgmax", "forma Gigamax")
	assert_eq(_move_id(events), "gmaxwildfire", "Llamarada Gigamax en vez de Llamarada Dinamax")
	var plain := _engine(_mon(&"charizard", 50, ["flamethrower"]), _mon(&"snorlax", 60, ["splash"]))
	assert_eq(_move_id(plain.submit(_dyn())), "maxflare", "sin el factor, el Dinamax de siempre")


func test_dano_residual_cuatro_turnos() -> void:
	var engine := _engine(_mon(&"charizard", 50, ["flamethrower"], true), _mon(&"snorlax", 60, ["splash"]))
	engine.submit(_dyn())
	assert_true(engine.has_side_condition(1, &"gmaxwildfire"))
	var hp := engine.active(1).pokemon.current_hp
	var events := engine.submit(BattleAction.fight(0))
	var gmax := 0
	for e: BattleEvent in events:
		if e.type == BattleEvent.DAMAGE and e.side == 1 and e.value("source") == "gmax":
			gmax += int(e.value("amount"))
	assert_eq(gmax, engine.active(1).pokemon.max_hp() / 6, "1/6 al final del turno")
	assert_lt(engine.active(1).pokemon.current_hp, hp)


func test_estado_a_los_rivales() -> void:
	var engine := _engine(_mon(&"pikachu", 50, ["thunderbolt"], true), _mon(&"snorlax", 60, ["splash"]))
	engine.submit(_dyn())
	assert_eq(engine.active(1).pokemon.status, &"par", "Voltiataque Gigamax paraliza")


func test_atrapa_y_campo() -> void:
	var centi := _engine(_mon(&"centiskorch", 50, ["flamethrower"], true), _mon(&"snorlax", 60, ["splash"]))
	centi.submit(_dyn())
	assert_true(centi.active(1).has_volatile(&"partiallytrapped"), "Ciempiés Gigamax atrapa")
	var orbeetle := _engine(_mon(&"orbeetle", 50, ["psychic"], true), _mon(&"snorlax", 60, ["splash"]))
	orbeetle.submit(_dyn())
	assert_false(orbeetle.field_state(&"gravity").is_empty(), "Gravedad Gigamax")


func test_su_bando_y_trampas() -> void:
	var machamp := _engine(_mon(&"machamp", 50, ["closecombat"], true), _mon(&"snorlax", 60, ["splash"]))
	var crit := machamp.active(0).crit_stage
	machamp.submit(_dyn())
	assert_eq(machamp.active(0).crit_stage, crit + 1, "Bombardeo Gigamax: +1 crítico")
	var drednaw := _engine(_mon(&"drednaw", 50, ["liquidation"], true), _mon(&"snorlax", 60, ["splash"]))
	drednaw.submit(_dyn())
	assert_true(drednaw.has_side_condition(1, &"stealthrock"), "Pedrada Gigamax deja Trampa Rocas")


func test_los_de_160_ignoran_la_habilidad_y_vuelve_al_acabar() -> void:
	var cinder := _mon(&"cinderace", 50, ["pyroball"], true)
	var engine := _engine(cinder, _mon(&"heatran", 60, ["splash"]))
	engine.active(1).ability = &"flashfire"
	var events := engine.submit(_dyn())
	var hit := 0
	for e: BattleEvent in events:
		if e.type == BattleEvent.DAMAGE and e.side == 1 and e.value("source") == "move":
			hit += int(e.value("amount"))
	assert_gt(hit, 0, "Balón Ígneo Gigamax pasa por alto Absorbe Fuego")
	engine.submit(BattleAction.fight(0))
	engine.submit(BattleAction.fight(0))
	assert_eq(cinder.species_id, &"cinderace", "al acabar el Dinamax vuelve a su forma")
