extends BattleEffect
## Gravedad: durante 5 turnos todos tocan el suelo y no se pueden usar los movimientos que vuelan o saltan.


func on_hit(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	if not engine.field_state(&"gravity").is_empty():
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.set_field_state(&"gravity", {"turns": 5})
	engine.message(tr("¡La gravedad se ha intensificado!"))
	for side_index: int in [BattleEngine.PLAYER, BattleEngine.FOE]:
		var b := engine.active(side_index)
		if b != null and str(b.volatiles.get(&"twoturnmove", {}).get("invulnerable", "")) == "air":
			engine.remove_volatile(b, &"twoturnmove")
		if b != null:
			engine.remove_volatile(b, &"magnetrise")
	return HANDLED
