extends BattleEffect
## Rencor: quita 4 PP al último movimiento que usó el objetivo.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	var index := engine.move_index_of(target, target.last_move)
	if index < 0 or target.pokemon.moves[index].pp <= 0:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	var slot := target.pokemon.moves[index]
	var lost := mini(4, slot.pp)
	slot.pp -= lost
	engine.message(tr("¡%s ha perdido %d PP de %s!") % [engine.name_of(target), lost, slot.data().name])
	return HANDLED
