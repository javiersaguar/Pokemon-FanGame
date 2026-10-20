extends BattleEffect
## Limpieza General: quita trampas y sustitutos de todo el campo y sube Ataque y Velocidad.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	for side_index: int in [BattleEngine.PLAYER, BattleEngine.FOE]:
		for hazard: StringName in [&"spikes", &"toxicspikes", &"stealthrock", &"stickyweb"]:
			engine.remove_side_condition(side_index, hazard)
		for slot: int in engine.slot_count():
			engine.remove_volatile(engine.active(side_index, slot), &"substitute")
	engine.message(tr("¡Todo está limpio!"))
	engine.boost(user, {&"atk": 1, &"spe": 1})
	return HANDLED
