extends BattleEffect
## Liofilización: es supereficaz contra los de tipo Agua.


func modify_damage_opts(_engine: BattleEngine, _user: Battler, target: Battler, move: MoveData, opts: Dictionary) -> void:
	var total := 1.0
	for t: StringName in target.types():
		total *= 2.0 if t == &"water" else DataDB.type_effectiveness(move.type, [t])
	opts["effectiveness"] = total
