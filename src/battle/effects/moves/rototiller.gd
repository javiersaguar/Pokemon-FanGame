extends BattleEffect
## Fertilizante: sube Ataque y Ataque Especial de los de tipo Planta que tocan el suelo.


func on_hit(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	var any := false
	for side_index: int in [BattleEngine.PLAYER, BattleEngine.FOE]:
		for slot: int in engine.slot_count():
			var b := engine.active(side_index, slot)
			if b != null and not b.is_fainted() and b.has_type(&"grass") and engine.is_grounded(b):
				engine.boost(b, {&"atk": 1, &"spa": 1})
				any = true
	if not any:
		engine.message(tr("¡Pero falló!"))
	return HANDLED
