extends BattleEffect
## Danza Despertar: es del tipo principal del usuario (o de su Teratipo).


func modify_move(_engine: BattleEngine, user: Battler, move: MoveData) -> MoveData:
	var types := user.types()
	if types.is_empty() or types[0] == move.type:
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.type = types[0]
	return copy
