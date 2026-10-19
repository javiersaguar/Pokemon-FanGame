extends BattleEffect
## Capa Mágica: este turno devuelve al rival sus movimientos de estado que se pueden reflejar.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if not engine.add_volatile(user, &"magiccoat", user):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
