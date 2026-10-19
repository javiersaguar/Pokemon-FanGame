extends BattleEffect
## Plegaria Vital: revive con la mitad de sus PS al primer compañero debilitado del equipo.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	for p: Pokemon in engine.party(user.side):
		if p.is_fainted():
			p.current_hp = maxi(1, p.max_hp() / 2)
			p.status = &""
			engine.message(tr("¡%s ha vuelto a la vida!") % p.display_name())
			return HANDLED
	engine.message(tr("¡Pero falló!"))
	return HANDLED
