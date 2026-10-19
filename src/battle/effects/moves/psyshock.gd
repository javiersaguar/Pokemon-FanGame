extends BattleEffect
## Psicocarga: es especial pero va contra la Defensa del objetivo.


func modify_damage_opts(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, opts: Dictionary) -> void:
	opts["def_stat"] = &"def"
