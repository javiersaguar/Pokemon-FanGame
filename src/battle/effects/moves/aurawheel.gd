extends BattleEffect
## Rueda Aural: de tipo Siniestro con la forma voraz de Morpeko.


func modify_move(_engine: BattleEngine, user: Battler, move: MoveData) -> MoveData:
	if user.pokemon.species_id != &"morpekohangry":
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.type = &"dark"
	return copy
