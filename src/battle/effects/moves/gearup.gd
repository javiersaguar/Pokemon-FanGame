extends BattleEffect
## Piñón Auxiliar: sube Ataque y Ataque Especial de los suyos con Más o Menos.

var stats := {&"atk": 1, &"spa": 1}


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var any := false
	for slot: int in engine.slot_count():
		var b := engine.active(user.side, slot)
		if b != null and not b.is_fainted() and b.ability in [&"plus", &"minus"]:
			engine.boost(b, stats)
			any = true
	if not any:
		engine.message(tr("¡Pero falló!"))
	return HANDLED
