extends BattleEffect
## Electrificado (este turno): su movimiento pasa a ser de tipo Eléctrico.


func duration(_engine: BattleEngine) -> int:
	return 1


func modify_own_move(_engine: BattleEngine, _user: Battler, _state: Dictionary, move: MoveData) -> MoveData:
	if move.type == &"electric":
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.type = &"electric"
	return copy
