class_name BattleAI
extends RefCounted
## IA de combate (Fase 9.7).
##   0: movimiento al azar (salvajes).
##   1: el movimiento que más daño hace, sin RNG ni críticos.
##   2: además evita lo inútil (inmune, estado repetido) y usa un estado con sentido si el daño es flojo.
##   3: cambia si el que está no puede hacer daño y otro del equipo sí.
##   4: puntúa el golpe menos el contraataque del rival si no lo debilita.
## Nunca usa información oculta: solo lo que el motor sabe del campo.


static func choose_action(engine: BattleEngine, side: int, slot: int, level: int) -> BattleAction:
	if engine.slot_count() > 1:
		return _choose_double(engine, side, slot, level)
	var b := engine.active(side, slot)
	var usable := b.usable_moves()
	if usable.is_empty():
		return BattleAction.fight(-1)
	if level <= 0:
		return _with_mega(engine, b, BattleAction.fight(usable[engine.rng.randi_range(0, usable.size() - 1)]))
	var target := engine.active(1 - side)
	if level == 1:
		return _with_mega(engine, b, _most_damage(engine, b, target, usable))
	var best := -1
	var best_score := -1
	for i: int in usable:
		var score := _score_move(engine, b, target, b.pokemon.moves[i].data(), level)
		if score > best_score:
			best_score = score
			best = i
	if level >= 3 and target != null and not target.is_fainted():
		var switch_to := _best_bench(engine, side, target, b.party_index)
		if switch_to >= 0 and best_score <= 0:
			return BattleAction.switch_to(switch_to)
	if best < 0:
		return _with_mega(engine, b, BattleAction.fight(usable[engine.rng.randi_range(0, usable.size() - 1)]))
	return _with_mega(engine, b, BattleAction.fight(best))


## Pokémon que saca cuando se le debilita el que tenía.
## Desde el nivel 3, el que más daño haría al rival que queda; si no, el siguiente del equipo.
static func choose_replacement(engine: BattleEngine, side: int) -> int:
	var level := engine.setup.ai_level if side == BattleEngine.FOE else 0
	var foe := engine.active(1 - side)
	if level >= 3 and foe != null and not foe.is_fainted():
		var best := _best_bench(engine, side, foe, -1)
		if best >= 0:
			return best
	return engine.side(side).first_able_index()


static func _choose_double(engine: BattleEngine, side: int, slot: int, level: int) -> BattleAction:
	var b := engine.active(side, slot)
	var usable := b.usable_moves()
	if usable.is_empty():
		return BattleAction.fight(-1)
	if level <= 0:
		return _with_mega(engine, b, BattleAction.fight(usable[engine.rng.randi_range(0, usable.size() - 1)]))
	var best_move := usable[0]
	var best_slot := 0
	var best_score := -1000000
	for i: int in usable:
		var move := b.pokemon.moves[i].data()
		for foe_slot: int in engine.slot_count():
			var foe := engine.active(1 - side, foe_slot)
			if foe == null or foe.is_fainted():
				continue
			var score := engine.estimate_damage(b, foe, move) if level < 2 else _score_move(engine, b, foe, move, level)
			if score > best_score:
				best_score = score
				best_move = i
				best_slot = foe_slot
	return _with_mega(engine, b, BattleAction.fight(best_move, best_slot))


static func _with_mega(engine: BattleEngine, b: Battler, action: BattleAction) -> BattleAction:
	if action.kind == BattleAction.Kind.FIGHT and engine.can_mega(b):
		action.mega = true
	if action.kind == BattleAction.Kind.FIGHT and engine.can_z(b, action.move_index):
		action.z = true
	return action


static func _most_damage(engine: BattleEngine, user: Battler, target: Battler, usable: Array[int]) -> BattleAction:
	var best := -1
	var best_damage := 0
	for i: int in usable:
		var damage := engine.estimate_damage(user, target, user.pokemon.moves[i].data())
		if damage > best_damage:
			best_damage = damage
			best = i
	if best < 0:
		return BattleAction.fight(usable[engine.rng.randi_range(0, usable.size() - 1)])
	return BattleAction.fight(best)


static func _score_move(engine: BattleEngine, user: Battler, target: Battler, move: MoveData, level: int) -> int:
	if target == null or target.is_fainted():
		return 0
	var damage := engine.estimate_damage(user, target, move)
	if move.is_status():
		if level < 2 or not _status_is_useful(user, target, move):
			return -1
		return maxi(1, target.pokemon.max_hp() / 6)
	if damage <= 0:
		return -1 if level >= 2 else damage
	if damage >= target.pokemon.current_hp:
		return 100000 + damage
	if level >= 4:
		return damage * 1000 - _best_damage(engine, target, user)
	return damage


static func _status_is_useful(user: Battler, target: Battler, move: MoveData) -> bool:
	if move.status != &"":
		if target.pokemon.status != &"":
			return false
		for type_id: StringName in target.types():
			if DataDB.type_immune_to(type_id, move.status):
				return false
		return true
	if not move.boosts.is_empty():
		for stat: StringName in move.boosts:
			var stage: int = target.boosts.get(stat, 0)
			if move.boosts[stat] < 0 and stage > -6:
				return true
			if move.boosts[stat] > 0 and stage < 6:
				return true
		return false
	if not move.self_boosts.is_empty():
		for stat: StringName in move.self_boosts:
			if user.boosts.get(stat, 0) < 6 and move.self_boosts[stat] > 0:
				return true
		return false
	if not move.heal.is_empty():
		return user.pokemon.current_hp < user.pokemon.max_hp()
	return false


static func _best_damage(engine: BattleEngine, user: Battler, target: Battler) -> int:
	var best := 0
	for i: int in user.usable_moves():
		best = maxi(best, engine.estimate_damage(user, target, user.pokemon.moves[i].data()))
	return best


## Índice del reserva que más daño haría, o -1 si ninguno supera al que está (party_index).
static func _best_bench(engine: BattleEngine, side: int, foe: Battler, current: int) -> int:
	var best := -1
	var best_damage := 0
	if current >= 0:
		var active := engine.active(side)
		if active != null:
			best_damage = _best_damage(engine, active, foe)
	var party := engine.party(side)
	for i: int in party.size():
		if i == current or not engine.side(side).can_switch_to(i):
			continue
		var bench := Battler.new(party[i], side, 0, i)
		var damage := _best_damage(engine, bench, foe)
		if damage > best_damage:
			best_damage = damage
			best = i
	return best
