extends BattleEffect
## Triple Patada: tres golpes de potencia creciente (10, 20 y 30).


func hit_count(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	user.set_meta(&"triple_hit", 0)
	return 3


func base_power(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	var i: int = user.get_meta(&"triple_hit", 0)
	user.set_meta(&"triple_hit", i + 1)
	return power * (mini(i, 2) + 1)
