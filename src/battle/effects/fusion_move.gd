class_name FusionMoveEffect
extends BattleEffect
## Rayo Fusión y Llama Fusión: el doble de potencia si justo antes, este turno, se ha usado el otro.

static var _last := {"turn": -1, "move": ""}
var partner: StringName = &""


func base_power(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return power * 2 if int(_last["turn"]) == engine.turn and StringName(str(_last["move"])) == partner else power


func on_after_move(engine: BattleEngine, _user: Battler, move: MoveData, _hit: bool) -> void:
	_last = {"turn": engine.turn, "move": String(move.id)}
