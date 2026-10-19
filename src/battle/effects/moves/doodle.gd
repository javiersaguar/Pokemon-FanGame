extends BattleEffect
## Dibujo: el usuario (y su aliado) copian la habilidad del objetivo.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	if target.ability == &"" or target.ability == user.ability:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	user.ability = target.ability
	var ally := engine.active(user.side, 1 - user.slot) if engine.is_double() else null
	if ally != null and not ally.is_fainted():
		ally.ability = target.ability
	engine.message(tr("¡%s ha copiado la habilidad %s!") % [engine.name_of(user), engine.of_name(target)])
	return HANDLED
