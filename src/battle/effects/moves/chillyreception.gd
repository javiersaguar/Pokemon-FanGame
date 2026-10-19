extends BattleEffect
## Fría Acogida: pone nieve y el usuario se cambia.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	engine.message(tr("¡%s está contando un chiste malísimo!") % engine.name_of(user))
	engine.set_weather(&"snow", user)
	engine.request_switch(user, &"uturn")
	return HANDLED
