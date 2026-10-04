class_name BattleAI
extends RefCounted
## IA de combate (Fase 7.9; los niveles 2-4 llegan en la Fase 9.7).
##   0: movimiento al azar (salvajes).
##   1: el movimiento que más daño hace, calculado con el propio motor sin RNG ni críticos.
## Nunca usa información oculta: solo lo que el motor sabe del campo.


static func choose_action(engine: BattleEngine, side: int, slot: int, level: int) -> BattleAction:
	var b := engine.active(side, slot)
	var usable := b.usable_moves()
	if usable.is_empty():
		return BattleAction.fight(-1)
	if level <= 0:
		return BattleAction.fight(usable[engine.rng.randi_range(0, usable.size() - 1)])
	var target := engine.active(1 - side)
	var best := -1
	var best_damage := 0
	for i: int in usable:
		var damage := engine.estimate_damage(b, target, b.pokemon.moves[i].data())
		if damage > best_damage:
			best_damage = damage
			best = i
	if best < 0:
		return BattleAction.fight(usable[engine.rng.randi_range(0, usable.size() - 1)])
	return BattleAction.fight(best)


## Pokémon que saca cuando se le debilita el que tenía: el siguiente del equipo, en orden.
static func choose_replacement(engine: BattleEngine, side: int) -> int:
	return engine.side(side).first_able_index()
