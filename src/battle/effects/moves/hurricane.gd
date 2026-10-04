extends BattleEffect
## Vendaval: con lluvia no falla nunca y con sol tiene un 50 % de precisión.


func accuracy(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	match engine.weather():
		&"raindance":
			return 0
		&"sunnyday":
			return 50
	return -1
