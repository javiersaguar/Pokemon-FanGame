extends BattleEffect
## Plancha Corporal: usa la Defensa del usuario (con sus niveles) en vez del Ataque.


func modify_damage_opts(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, opts: Dictionary) -> void:
	opts["atk_stat"] = &"def"
