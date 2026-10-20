extends BattleEffect
## Tempestades de Hisui: aciertan siempre con lluvia.


func accuracy(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	return 0 if engine.weather() == &"raindance" else -1
