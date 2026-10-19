extends BattleEffect
## Cerca: los rivales no pueden usar ningún movimiento que también conozca el usuario.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var ids: Array = []
	for slot: MoveSlot in user.pokemon.moves:
		ids.append(String(slot.id))
	if not engine.add_volatile(user, &"imprison", user, {"moves": ids}):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
