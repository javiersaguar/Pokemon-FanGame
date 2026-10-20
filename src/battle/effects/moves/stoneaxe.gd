extends BattleEffect
## Hacha de Piedra: deja Trampa Rocas en el campo del rival.


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if not user.is_fainted():
		engine.add_side_condition(target.side, &"stealthrock", user)
