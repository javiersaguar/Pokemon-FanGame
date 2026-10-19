extends BattleEffect
## Cambio de Cancha: intercambia las condiciones de los dos bandos (trampas, pantallas, Viento Afín...).


func on_hit(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	var a := engine.side(BattleEngine.PLAYER)
	var b := engine.side(BattleEngine.FOE)
	var mine := a.conditions.duplicate(true)
	a.conditions.assign(b.conditions)
	b.conditions.assign(mine)
	engine.message(tr("¡Se han intercambiado los efectos de los dos lados del campo!"))
	return HANDLED
