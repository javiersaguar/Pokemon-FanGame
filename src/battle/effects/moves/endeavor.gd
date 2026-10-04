extends BattleEffect
## Esfuerzo: deja al objetivo con los mismos PS que el usuario. Falla si el usuario tiene los mismos o más.


func on_try_move(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> bool:
	if user.pokemon.current_hp < target.pokemon.current_hp:
		return true
	engine.message(tr("¡Pero falló!"))
	return false


func fixed_damage(_engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	return maxi(0, target.pokemon.current_hp - user.pokemon.current_hp)
