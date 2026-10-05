extends GutTest
## Fase 9.7: la IA alta gana claramente a la baja, y el nivel 3 cambia si no puede hacer daño.


func _mon(species: StringName, level: int, moves: Array) -> Pokemon:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var p := Pokemon.create(species, level, rng)
	p.apply_spec({"nature": "hardy", "ivs": 31, "moves": moves})
	return p


func _play(seed_value: int, player_level: int) -> StringName:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.TRAINER
	s.can_run = false
	s.player_party = [_mon(&"charizard", 50, ["splash", "flamethrower"])]
	s.foe_party = [_mon(&"charizard", 50, ["splash", "flamethrower"])]
	s.player_name = "Alta"
	s.ai_level = 0
	s.seed = seed_value
	s.trainers = [{"display_name": "Baja", "base_money": 1, "lose_text": "", "win_text": ""}]
	var engine := BattleEngine.new(s)
	engine.start()
	var steps := 0
	while not engine.is_over() and steps < 40:
		var req := engine.request
		var action: BattleAction
		if req.kind == BattleRequest.Kind.SWITCH:
			action = BattleAction.switch_to(engine.side(BattleEngine.PLAYER).first_able_index())
		elif req.kind == BattleRequest.Kind.LEARN_MOVE:
			action = BattleAction.learn_move(-1)
		else:
			action = BattleAI.choose_action(engine, BattleEngine.PLAYER, 0, player_level)
		engine.submit(action)
		steps += 1
	return engine.result.outcome


func test_la_ia_alta_gana_a_la_baja() -> void:
	var wins := 0
	for seed_value: int in 24:
		if _play(seed_value + 1, 4) == BattleResult.WIN:
			wins += 1
	assert_gte(wins, 18, "la IA 4 gana la mayoría de las 24 peleas iguales contra la IA 0 (ganó %d)" % wins)


func test_el_nivel_3_cambia_si_no_puede_danar() -> void:
	var s := BattleSetup.new()
	s.kind = BattleSetup.Kind.WILD
	s.player_party = [_mon(&"rattata", 30, ["tackle"]), _mon(&"houndoom", 30, ["bite"])]
	s.foe_party = [_mon(&"gengar", 30, ["lick"])]
	s.seed = 1
	var engine := BattleEngine.new(s)
	engine.start()
	var action := BattleAI.choose_action(engine, BattleEngine.PLAYER, 0, 3)
	assert_eq(action.kind, BattleAction.Kind.SWITCH)
	assert_eq(action.party_index, 1)
	var stay := BattleAI.choose_action(engine, BattleEngine.PLAYER, 0, 1)
	assert_eq(stay.kind, BattleAction.Kind.FIGHT, "el nivel 1 no cambia")
