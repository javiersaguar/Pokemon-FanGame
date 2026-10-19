extends BattleEffect
## Mal de Ojo: el objetivo no puede cambiarse ni huir mientras el usuario siga en el campo.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	if target.has_volatile(&"trapped") or target.has_type(&"ghost"):
		engine.message(tr("¡Pero falló!"))
	elif engine.add_volatile(target, &"trapped", user, {"source_side": user.side, "source_party": user.party_index}):
		engine.message(tr("¡%s ya no puede escapar!") % engine.name_of(target))
	return HANDLED
