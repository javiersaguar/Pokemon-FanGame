extends BattleEffect
## Sonámbulo: dormido, usa al azar otro de sus movimientos. Despierto falla.

const NO_CALL: Array[StringName] = [&"sleeptalk", &"assist", &"copycat", &"mirrormove", &"metronome", &"mimic",
	&"sketch", &"uproar", &"bide", &"focuspunch", &"beakblast", &"shelltrap", &"chatter", &"belch"]


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if user.pokemon.status != &"slp":
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	var options: Array[MoveData] = []
	for slot: MoveSlot in user.pokemon.moves:
		var m := slot.data()
		if m.id in NO_CALL or m.has_flag(&"nosleeptalk") or m.has_flag(&"charge") or Effects.move(m.id) is TwoTurnMoveEffect:
			continue
		options.append(m)
	if options.is_empty():
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.use_move(user, options[engine.rand_int(&"sleeptalk", 0, options.size() - 1)])
	return HANDLED
