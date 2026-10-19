extends BattleEffect
## Llave Giro: después de golpear, saca al objetivo del combate (contra un salvaje lo acaba; contra
## un entrenador entra otro al azar).


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if target.is_fainted() or user.is_fainted() or target.has_volatile(&"ingrain") or target.dynamax_turns > 0:
		return
	engine.force_switch(target)
