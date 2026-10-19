extends BattleEffect
## Última Baza: solo funciona si el usuario conoce otros movimientos y ya los ha usado todos desde que salió.


func on_try_move(engine: BattleEngine, user: Battler, _target: Battler, move: MoveData) -> bool:
	var others := 0
	for slot: MoveSlot in user.pokemon.moves:
		if slot.id == move.id:
			continue
		others += 1
		if not user.used_moves.has(slot.id):
			others = -100
	if others <= 0:
		engine.message(tr("¡Pero falló!"))
		return false
	return true
