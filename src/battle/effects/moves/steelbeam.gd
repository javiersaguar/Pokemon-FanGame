extends BattleEffect
## Metaláser: el usuario pierde la mitad de sus PS máximos al usarlo, acierte o no.


func on_after_move(engine: BattleEngine, user: Battler, _move: MoveData, _hit: bool) -> void:
	if not user.is_fainted():
		engine.deal_damage(user, ceili(user.pokemon.max_hp() / 2.0), &"recoil")
