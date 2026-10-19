extends BattleEffect
## Cambio de Banda: en dobles, intercambia el sitio con el aliado. En individuales falla.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if not engine.is_double():
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	var ally := engine.active(user.side, 1 - user.slot)
	if ally == null or ally.is_fainted():
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	var side := engine.side(user.side)
	var a := user.slot
	var b := ally.slot
	side.active[a] = ally
	side.active[b] = user
	user.slot = b
	ally.slot = a
	engine.message(tr("¡%s y %s han intercambiado su sitio!") % [engine.name_of(user), engine.inner_name_of(ally)])
	return HANDLED
