extends BattleEffect
## Sentencia: del tipo de la tabla que lleve.


func modify_move(_engine: BattleEngine, user: Battler, move: MoveData) -> MoveData:
	var item := user.pokemon.held_item
	var plates: Dictionary = preload("res://src/battle/effects/item_families.gd").TYPE_BOOST
	if not String(item).ends_with("plate") or not plates.has(item):
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.type = plates[item]
	return copy
