class_name BalanceSim
extends RefCounted
## Simula combates con la IA del motor (Fase 20.2). No cambia el motor: si un resultado es imposible, es un bug para el Agente 5.


static func simulate(player_party: Array, foe_party: Array, games: int, seed_value: int, player_ai: int = 4, foe_ai: int = 1) -> Dictionary:
	var wins := 0
	var losses := 0
	var other := 0
	for game: int in maxi(games, 0):
		var setup := BattleSetup.new()
		setup.kind = BattleSetup.Kind.TRAINER
		setup.can_run = false
		setup.allow_items = false
		setup.exp_enabled = false
		for pokemon: Pokemon in player_party:
			setup.player_party.append(pokemon.clone())
		for pokemon: Pokemon in foe_party:
			setup.foe_party.append(pokemon.clone())
		setup.ai_level = foe_ai
		setup.seed = seed_value + game + 1
		setup.trainers = [{"display_name": "Rival", "base_money": 0, "lose_text": "", "win_text": ""}]
		var outcome := _play(setup, player_ai)
		if outcome == BattleResult.WIN:
			wins += 1
		elif outcome == BattleResult.LOSE:
			losses += 1
		else:
			other += 1
	return {"games": games, "wins": wins, "losses": losses, "other": other, "win_percent": _percent(wins, games)}


static func simulate_trainer(team: Array, trainer_id: StringName, games: int, seed_value: int, player_ai: int = 4) -> Dictionary:
	if not DataDB.has_trainer(trainer_id):
		return {"trainer": String(trainer_id), "error": "no existe", "games": 0, "wins": 0, "win_percent": 0}
	var setup := BattleSetup.trainer(trainer_id)
	var result := simulate(team, setup.foe_party, games, seed_value, player_ai, setup.ai_level)
	result["trainer"] = String(trainer_id)
	return result


static func _play(setup: BattleSetup, player_ai: int) -> StringName:
	var engine := BattleEngine.new(setup)
	engine.start()
	var steps := 0
	while not engine.is_over() and steps < 80:
		var req := engine.request
		if req == null:
			break
		var action: BattleAction
		if req.kind == BattleRequest.Kind.SWITCH:
			var index := engine.side(BattleEngine.PLAYER).first_able_index()
			action = BattleAction.switch_to(index if req.reason != &"shift" else -1)
		elif req.kind == BattleRequest.Kind.LEARN_MOVE:
			action = BattleAction.learn_move(-1)
		else:
			action = BattleAI.choose_action(engine, BattleEngine.PLAYER, req.slot, player_ai)
		engine.submit(action)
		steps += 1
	return engine.result.outcome


static func _percent(wins: int, games: int) -> int:
	if games <= 0:
		return 0
	return int(round(100.0 * float(wins) / float(games)))
