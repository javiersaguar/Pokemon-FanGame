extends BattleEffect
## Aguijón Letal: si debilita al objetivo, sube tres niveles el Ataque del usuario.


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if target.is_fainted() and not user.is_fainted():
		engine.boost(user, {&"atk": 3}, false)
