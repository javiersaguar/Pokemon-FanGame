extends BattleEffect
## Lluvia de electrones (este turno): los movimientos de tipo Normal son de tipo Eléctrico.


func residual_order() -> int:
	return 1


func modify_own_move(_engine: BattleEngine, _user: Battler, _state: Dictionary, move: MoveData) -> MoveData:
	if move.type != &"normal":
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.type = &"electric"
	return copy
