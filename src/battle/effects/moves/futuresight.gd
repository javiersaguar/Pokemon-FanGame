extends BattleEffect
## Premonición: el ataque llega al final del segundo turno siguiente, contra quien esté entonces en
## ese lugar. El daño se calcula al usarlo (con las estadísticas de ese momento).

var text := "¡%s ha previsto un ataque!"


func on_try_move(engine: BattleEngine, user: Battler, target: Battler, move: MoveData) -> bool:
	if engine.has_side_condition(target.side, &"futuresight"):
		engine.message(tr("¡Pero falló!"))
		return false
	var opts := engine._damage_opts(user, target, move, self, false)
	var amount := DamageCalc.calculate(user, target, move, false, engine.rand_int(&"damage_roll", 0, DamageCalc.ROLLS - 1), opts)
	engine.add_side_condition(target.side, &"futuresight", user, {"turns": 3, "damage": amount,
		"move": String(move.id), "user": engine.name_of(user), "type": String(move.type)})
	engine.message(tr(text) % engine.name_of(user))
	return false
