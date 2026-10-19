extends BattleEffect
## Plancha Voladora: es de tipo Lucha y Volador a la vez (se multiplican las dos eficacias).


func modify_damage_opts(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, opts: Dictionary) -> void:
	opts["effectiveness"] = DataDB.type_effectiveness(&"fighting", target.types()) * DataDB.type_effectiveness(&"flying", target.types())
