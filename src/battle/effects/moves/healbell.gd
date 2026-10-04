extends BattleEffect
## Campana Cura: cura los problemas de estado de todo el equipo del usuario.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	engine.message(tr("¡Ha sonado una campana!"))
	for p: Pokemon in engine.party(user.side):
		if p.status == &"" or p.is_fainted():
			continue
		var on_field := engine.active(user.side)
		if on_field != null and on_field.pokemon == p:
			engine.cure_status(on_field)
		else:
			p.cure_status()
	return HANDLED
