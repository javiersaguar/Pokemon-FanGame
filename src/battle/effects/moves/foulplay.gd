extends BattleEffect
## Juego Sucio: calcula el daño con el Ataque del objetivo (y sus cambios), no con el del usuario.


func modify_damage_opts(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, opts: Dictionary) -> void:
	opts["attacker"] = target
