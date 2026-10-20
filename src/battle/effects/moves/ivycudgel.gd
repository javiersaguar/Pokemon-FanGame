extends BattleEffect
## Garrote Liana: del tipo de la máscara de Ogerpon.


const MASKS := {&"wellspringmask": &"water", &"hearthflamemask": &"fire", &"cornerstonemask": &"rock"}


func modify_move(_engine: BattleEngine, user: Battler, move: MoveData) -> MoveData:
	if not MASKS.has(user.pokemon.held_item):
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.type = MASKS[user.pokemon.held_item]
	return copy
