extends BattleEffect
## Premonición (y Deseo Oculto, que hereda): golpea dos turnos después al que esté en ese sitio. El
## daño se calcula al golpear (5.ª generación en adelante), con las características que tenga entonces
## quien lo usó, aunque se haya retirado.

var text := "¡%s ha previsto un ataque!"


func on_try_move(engine: BattleEngine, user: Battler, target: Battler, move: MoveData) -> bool:
	if engine.has_side_condition(target.side, &"futuresight"):
		engine.message(tr("¡Pero falló!"))
		return false
	engine.add_side_condition(target.side, &"futuresight", user, {"turns": 3, "move": String(move.id),
		"user": engine.name_of(user), "type": String(move.type), "slot": target.slot, "source": user})
	engine.message(tr(text) % engine.name_of(user))
	return false
