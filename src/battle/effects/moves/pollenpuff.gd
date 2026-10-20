extends BattleEffect
## Bola de Polen: a un aliado le cura la mitad de sus PS en vez de hacerle daño.


func on_try_move(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> bool:
	if target.side != user.side or target == user:
		return true
	if engine.heal(target, maxi(1, target.pokemon.max_hp() / 2), &"move") <= 0:
		engine.message(tr("¡Pero falló!"))
	return false
