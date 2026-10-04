extends TwoTurnMoveEffect
## Rayo Solar: carga un turno (no con sol) y con lluvia, arena o nieve tiene la mitad de potencia.


func _init() -> void:
	charge_text = "¡%s está absorbiendo luz!"
	skip_in_sun = true


func base_power(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return DamageCalc.modify(power, 0.5) if engine.weather() in [&"raindance", &"sandstorm", &"snow"] else power
