extends BattleEffect
## Sacrificio: hace tanto daño como PS le quedan al usuario, que se debilita.


func fixed_damage(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	return user.pokemon.current_hp


func on_after_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, _damage: int) -> void:
	if not user.is_fainted():
		engine.deal_damage(user, user.pokemon.current_hp, &"finalgambit")
