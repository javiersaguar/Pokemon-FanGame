extends BattleEffect
## Último Lugar: el objetivo se moverá el último en este turno. Falla si ya se ha movido.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if target.moved_this_turn:
		engine.message(tr("¡Pero falló!"))
	else:
		engine.message(tr("¡%s tendrá que moverse el último!") % engine.name_of(target))
	return HANDLED
