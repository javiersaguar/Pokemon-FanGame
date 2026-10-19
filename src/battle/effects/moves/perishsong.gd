extends BattleEffect
## Canto Mortal: todos los que lo oyen se debilitan al cabo de tres turnos si siguen en el campo.


func on_hit(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	var any := false
	for side_index: int in [BattleEngine.PLAYER, BattleEngine.FOE]:
		for slot: int in engine.slot_count():
			var b := engine.active(side_index, slot)
			if b == null or b.is_fainted() or b.ability == &"soundproof":
				continue
			any = engine.add_volatile(b, &"perishsong") or any
	if any:
		engine.message(tr("¡Todos los que han oído el canto se debilitarán en tres turnos!"))
	else:
		engine.message(tr("¡Pero falló!"))
	return HANDLED
