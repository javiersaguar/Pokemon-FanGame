class_name HealByWeatherMoveEffect
extends BattleEffect
## Síntesis, Sol Matinal, Luz Lunar: la mitad de los PS; 2/3 con sol y 1/4 con otro clima.
## Mismos factores y redondeo que Showdown: this.modify(maxhp, factor), con 0,667 para el sol.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if user.pokemon.current_hp >= user.pokemon.max_hp():
		engine.message(tr("¡Los PS %s están al máximo!") % engine.of_name(user))
		return HANDLED
	var fraction := 0.5
	match engine.weather():
		&"sunnyday":
			fraction = 0.667
		&"raindance", &"sandstorm", &"snow":
			fraction = 0.25
	engine.heal(user, DamageCalc.modify(user.pokemon.max_hp(), fraction), &"move")
	engine.message(tr("¡%s ha recuperado PS!") % engine.name_of(user))
	return HANDLED
