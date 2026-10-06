extends GutTest
## Dinamax: solo si el combate lo permite, PS al doble, movimiento máximo y tres turnos.


func _mon(species: StringName, level: int, moves: Array) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 13
	var p := Pokemon.create(species, level, rng)
	p.apply_spec({"nature": "hardy", "ivs": 31, "moves": moves})
	return p


func _setup(player: Pokemon, foe: Pokemon, enabled: bool) -> BattleSetup:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.WILD
	s.player_party = [player]
	s.foe_party = [foe]
	s.seed = 4
	s.dynamax = enabled
	return s


func _dyn() -> BattleAction:
	var action := BattleAction.fight(0)
	action.dynamax = true
	return action


func _move_id(events: Array) -> String:
	for event: BattleEvent in events:
		if event.type == BattleEvent.MOVE and event.side == BattleEngine.PLAYER:
			return str(event.value("move"))
	return ""


func test_sin_el_ajuste_no_dinamaxiza() -> void:
	var rat := _mon(&"rattata", 40, ["tackle"])
	var before := rat.max_hp()
	var engine := BattleEngine.new(_setup(rat, _mon(&"snorlax", 50, ["splash"]), false))
	engine.start()
	assert_false(engine.request.can_dynamax)
	var events := engine.submit(_dyn())
	assert_eq(_move_id(events), "tackle")
	assert_eq(rat.max_hp(), before)
	assert_eq(rat.battle_hp_scale, 1)


func test_dobla_los_ps_tres_turnos_y_el_placaje_es_maxiataque() -> void:
	var rat := _mon(&"rattata", 40, ["tackle"])
	var base := rat.max_hp()
	var engine := BattleEngine.new(_setup(rat, _mon(&"snorlax", 80, ["splash"]), true))
	engine.start()
	assert_true(engine.request.can_dynamax)
	var events := engine.submit(_dyn())
	assert_eq(_move_id(events), "maxstrike")
	assert_eq(rat.battle_hp_scale, 2)
	assert_eq(rat.max_hp(), base * 2)
	assert_eq(engine.active(BattleEngine.FOE).boosts[&"spe"], -1)
	engine.submit(BattleAction.fight(0))
	engine.submit(BattleAction.fight(0))
	assert_eq(rat.battle_hp_scale, 1)
	assert_eq(rat.max_hp(), base)
	assert_eq(rat.current_hp, base)


func test_maxignicion_cambia_el_clima() -> void:
	var engine := BattleEngine.new(_setup(
		_mon(&"charmander", 40, ["ember"]),
		_mon(&"snorlax", 80, ["splash"]), true))
	engine.start()
	var events := engine.submit(_dyn())
	assert_eq(_move_id(events), "maxflare")
	assert_eq(engine.weather(), &"sunnyday")


func test_el_rival_tambien_dinamaxiza_si_el_combate_lo_permite() -> void:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.dynamax = true
	s.ai_level = 1
	s.seed = 4
	s.player_party = [_mon(&"snorlax", 80, ["splash"])]
	s.foe_party = [_mon(&"rattata", 40, ["tackle"])]
	var engine := BattleEngine.new(s)
	engine.start()
	var events := engine.submit(BattleAction.fight(0))
	var started := false
	for event: BattleEvent in events:
		if event.type == BattleEvent.DYNAMAX and event.side == BattleEngine.FOE:
			started = true
	assert_true(started)
	assert_eq(s.foe_party[0].battle_hp_scale, 2)
