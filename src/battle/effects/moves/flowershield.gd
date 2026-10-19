extends BattleEffect
## Escudo Floral: sube la Defensa de todos los de tipo Planta que hay en el campo.


func on_hit(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	var any := false
	for side_index: int in [BattleEngine.PLAYER, BattleEngine.FOE]:
		for slot: int in engine.slot_count():
			var b := engine.active(side_index, slot)
			if b != null and not b.is_fainted() and b.has_type(&"grass"):
				engine.boost(b, {&"def": 1})
				any = true
	if not any:
		engine.message(tr("¡Pero falló!"))
	return HANDLED
