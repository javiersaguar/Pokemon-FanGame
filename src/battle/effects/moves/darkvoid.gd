extends BattleEffect
## Brecha Negra: solo Darkrai puede usarla.


func on_try_move(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> bool:
	if user.pokemon.species_id != &"darkrai":
		engine.message(tr("¡Pero %s no puede usar este movimiento!") % engine.name_of(user))
		return false
	return true
