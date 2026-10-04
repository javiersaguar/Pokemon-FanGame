extends BattleEffect
## Descanso: recupera todos los PS y se duerme 2 turnos (quita cualquier otro estado).


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var p := user.pokemon
	if p.current_hp >= p.max_hp() or p.status == &"slp" or user.ability in [&"insomnia", &"vitalspirit"]:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	if not engine.can_set_status(user, &"slp", user, true):
		return HANDLED
	engine.force_status(user, &"slp", 3)
	engine.message(tr("¡%s se ha echado a dormir y está como nuevo!") % engine.name_of(user))
	engine.heal(user, p.max_hp(), &"move")
	return HANDLED
