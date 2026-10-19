extends BattleEffect
## Arraigo: echa raíces. Cura 1/16 de los PS cada turno, pero ya no puede cambiarse ni huir.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if not engine.add_volatile(user, &"ingrain", user):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
