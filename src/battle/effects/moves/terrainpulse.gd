extends BattleEffect
## Pulso Terreno: con un campo y tocando el suelo, dobla la potencia y toma su tipo.

const TYPES := {&"electricterrain": &"electric", &"grassyterrain": &"grass", &"mistyterrain": &"fairy", &"psychicterrain": &"psychic"}


func modify_move(engine: BattleEngine, user: Battler, move: MoveData) -> MoveData:
	if not TYPES.has(engine.terrain()) or not engine.is_grounded(user):
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.type = TYPES[engine.terrain()]
	copy.power = move.power * 2
	return copy
