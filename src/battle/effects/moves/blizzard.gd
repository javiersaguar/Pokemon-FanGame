extends BattleEffect
## Ventisca: con nieve o granizo no falla nunca.


func accuracy(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	return 0 if engine.weather() in [&"snow", &"hail", &"snowscape"] else -1
