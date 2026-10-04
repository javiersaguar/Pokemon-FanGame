extends BattleEffect
## Foco Energía: +2 niveles de crítico.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if not engine.add_volatile(user, &"focusenergy", user):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
