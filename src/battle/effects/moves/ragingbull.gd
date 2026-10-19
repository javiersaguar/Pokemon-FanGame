extends "res://src/battle/effects/moves/brickbreak.gd"
## Furia Taurina: rompe las pantallas del objetivo. Los Tauros de Paldea la usan de su tipo: Lucha,
## Fuego o Agua.

const TYPES := {&"taurospaldeacombat": &"fighting", &"taurospaldeablaze": &"fire", &"taurospaldeaaqua": &"water"}


func modify_move(_engine: BattleEngine, user: Battler, move: MoveData) -> MoveData:
	if not TYPES.has(user.pokemon.species_id):
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.type = TYPES[user.pokemon.species_id]
	return copy
