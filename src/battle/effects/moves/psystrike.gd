extends BattleEffect
## Onda Mental y Sable Místico: especiales contra la Defensa.


func modify_damage_opts(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, opts: Dictionary) -> void:
	opts["def_stat"] = &"def"
