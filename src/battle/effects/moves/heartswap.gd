extends BattleEffect
## Cambiaalmas: intercambia todos los cambios de características con el objetivo.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	var mine := user.boosts.duplicate()
	user.boosts.assign(target.boosts)
	target.boosts.assign(mine)
	engine.message(tr("¡%s ha intercambiado sus cambios de características con el objetivo!") % engine.name_of(user))
	return HANDLED
