extends BattleEffect
## Acua Aro: un manto de agua le cura 1/16 de los PS al final de cada turno.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if not engine.add_volatile(user, &"aquaring", user):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
