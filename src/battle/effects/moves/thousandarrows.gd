extends "res://src/battle/effects/moves/smackdown.gd"
## Mil Flechas: alcanza a los que vuelan o levitan y los derriba, como Antiaéreo.


func modify_damage_opts(engine: BattleEngine, _user: Battler, target: Battler, move: MoveData, opts: Dictionary) -> void:
	if not engine.is_grounded(target) or target.has_type(&"flying"):
		var total := 1.0
		for t: StringName in target.types():
			total *= 1.0 if t == &"flying" else DataDB.type_effectiveness(move.type, [t])
		opts["effectiveness"] = total
