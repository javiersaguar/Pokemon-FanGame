extends BattleEffect
## Géiser Fotónico: físico si el Ataque del usuario es mayor que su Ataque Especial.


func modify_move(_engine: BattleEngine, user: Battler, move: MoveData) -> MoveData:
	if user.boosted_stat(&"atk") <= user.boosted_stat(&"spa"):
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.category = MoveData.Category.PHYSICAL
	return copy
