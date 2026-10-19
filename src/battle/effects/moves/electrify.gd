extends BattleEffect
## Electrificación: el siguiente movimiento del objetivo en este turno es de tipo Eléctrico.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if target.moved_this_turn or not engine.add_volatile(target, &"electrify"):
		engine.message(tr("¡Pero falló!"))
	else:
		engine.message(tr("¡Los movimientos de %s se han electrificado!") % engine.inner_name_of(target))
	return HANDLED
