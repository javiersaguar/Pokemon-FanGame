extends BattleEffect
## Moluscañón: físico si así hace más daño (Ataque/Defensa del rival frente a At. Esp./Def. Esp.).


func modify_move(engine: BattleEngine, user: Battler, move: MoveData) -> MoveData:
	var target := engine.foe_of(user)
	if target == null:
		return move
	var physical := float(user.boosted_stat(&"atk")) / target.boosted_stat(&"def")
	var special := float(user.boosted_stat(&"spa")) / target.boosted_stat(&"spd")
	if physical <= special:
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.category = MoveData.Category.PHYSICAL
	return copy
