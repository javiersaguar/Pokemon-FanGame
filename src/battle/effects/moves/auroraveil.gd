extends BattleEffect
## Velo Aurora: solo con nieve o granizo. Durante 5 turnos reduce a la mitad el daño físico y especial
## contra el equipo.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if engine.weather() not in [&"snow", &"hail", &"snowscape"] or not engine.add_side_condition(user.side, &"auroraveil", user):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
