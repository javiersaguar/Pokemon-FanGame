class_name BattleAI
extends RefCounted
## IA de combate (Fase 9.7).
##   0: movimiento al azar (salvajes).
##   1: el movimiento que más daño hace, sin RNG ni críticos.
##   2: además evita lo inútil (inmune, estado repetido) y usa un estado con sentido si el daño es flojo.
##   3: cambia si el que está no puede hacer daño y otro del equipo sí.
##   4: puntúa el golpe menos el contraataque del rival si no lo debilita.
## Desde el 2, los entrenadores usan los objetos de su ficha (curar a 1/4 de los PS); desde el 3, curan
## estados y cambian al que aguanta mejor si el que está caería antes de moverse. Entre golpes que
## debilitan, el de más prioridad. No usa estados que una habilidad, un tipo o el campo impiden.
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
	var item := _item_choice(engine, b, target, level)
	if item != null:
		return item
	var best := -1
	var best_score := -1
	for i: int in usable:
		var score := _score_move(engine, b, target, b.pokemon.moves[i].data(), level)
		if score > best_score:
			best_score = score
			best = i
	if level >= 3 and target != null and not target.is_fainted() and not engine.is_trapped(b):
		var switch_to := _best_bench(engine, side, target, b.party_index)
		if switch_to >= 0 and best_score <= 0:
			return BattleAction.switch_to(switch_to)
		if best_score < 100000:
			var safer := _safer_bench(engine, side, b, target)
			if safer >= 0:
				return BattleAction.switch_to(safer)
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
	if action.kind == BattleAction.Kind.FIGHT and engine.can_dynamax(b):
		action.dynamax = true
	if action.kind == BattleAction.Kind.FIGHT and engine.can_tera(b):
		action.tera = true
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
		if move.status != &"" and (not engine.can_set_status(target, move.status, user, false) or engine.is_immune(target, move)):
			return -1
		return maxi(1, target.pokemon.max_hp() / 6)
	# Ataques previstos (Premonición, Deseo Oculto): fallan si ya hay uno en camino.
	if level >= 2 and move.id in [&"futuresight", &"doomdesire"] and engine.has_side_condition(target.side, &"futuresight"):
		return -1
	if damage <= 0:
		return -1 if level >= 2 else damage
	if damage >= target.pokemon.current_hp:
		# Entre los que debilitan, el de más prioridad (rematar antes de que actúe).
		return 100000 + engine.move_priority(user, move) * 10000 + mini(damage, target.pokemon.current_hp)
	if level >= 4:
		return damage * 1000 - _best_damage(engine, target, user)
	return damage


## Objeto del entrenador: curar a 1/4 de los PS (nivel 2+) o quitar un estado (nivel 3+).
static func _item_choice(engine: BattleEngine, b: Battler, target: Battler, level: int) -> BattleAction:
	if b.side != BattleEngine.FOE or level < 2 or engine.setup.is_wild():
		return null
	var items := engine.foe_items()
	var hp := b.pokemon.current_hp
	var max_hp := b.pokemon.max_hp()
	var foe_hits := _best_damage(engine, target, b) if target != null and not target.is_fainted() else 0
	if hp * 4 <= max_hp:
		var best := &""
		var best_amount := 0
		for id: StringName in items:
			var it := DataDB.item(id)
			if it.effect not in [&"heal_hp", &"heal_and_cure"]:
				continue
			var amount := int(it.param("amount", 0)) if not it.effect_params.has("fraction") else max_hp
			if amount > best_amount:
				best_amount = amount
				best = id
		# Solo si después de curarse aguanta el siguiente golpe (si no, mejor atacar).
		if best != &"" and mini(max_hp, hp + best_amount) > foe_hits:
			return BattleAction.use_item(best, b.party_index)
	if level >= 3 and b.pokemon.status in [&"slp", &"frz", &"par", &"brn", &"tox"]:
		for id: StringName in items:
			var it := DataDB.item(id)
			if it.effect == &"cure_status" and String(b.pokemon.status) in it.param("statuses", []):
				return BattleAction.use_item(id, b.party_index)
	return null


## Nivel 3+: si el que está caería antes de moverse (el rival es más rápido y lo debilita), el del
## equipo que aguanta su mejor golpe y le hace daño. −1 si no hay ninguno.
static func _safer_bench(engine: BattleEngine, side: int, b: Battler, foe: Battler) -> int:
	if engine.speed_of(foe) <= engine.speed_of(b) or _best_damage(engine, foe, b) < b.pokemon.current_hp:
		return -1
	var party := engine.party(side)
	for i: int in party.size():
		if i == b.party_index or not engine.side(side).can_switch_to(i):
			continue
		var bench := Battler.new(party[i], side, 0, i)
		if _best_damage(engine, foe, bench) * 2 < party[i].current_hp and _best_damage(engine, bench, foe) > 0:
			return i
	return -1


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
