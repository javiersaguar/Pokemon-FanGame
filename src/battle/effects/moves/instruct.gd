extends BattleEffect
## Mandato: el objetivo repite enseguida su último movimiento.


const NO: Array[StringName] = [&"instruct", &"bide", &"focuspunch", &"beakblast", &"shelltrap", &"sketch",
	&"transform", &"mimic", &"kingsshield", &"struggle", &"outrage", &"thrash", &"petaldance", &"uproar"]


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	var last := target.last_move
	if last == &"" or last in NO or not DataDB.has_move(last) or engine.move_index_of(target, last) < 0 \
			or Effects.move(last) is TwoTurnMoveEffect or Effects.move(last) is RechargeMoveEffect:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.message(tr("¡%s sigue las instrucciones!") % engine.name_of(target))
	engine.use_move(target, DataDB.move(last))
	return HANDLED
