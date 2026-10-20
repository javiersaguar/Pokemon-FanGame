extends BattleEffect
## Teraexplosión: con Teracristal, de su teratipo y física si su Ataque es mayor.


func modify_move(_engine: BattleEngine, user: Battler, move: MoveData) -> MoveData:
	if user.tera_active == &"":
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.type = user.tera_active
	if user.boosted_stat(&"atk") > user.boosted_stat(&"spa"):
		copy.category = MoveData.Category.PHYSICAL
	return copy
