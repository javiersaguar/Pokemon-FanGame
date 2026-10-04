extends BattleEffect
## Desarrollo: sube Ataque y Ataque Especial un nivel, o dos con sol.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if engine.weather() != &"sunnyday":
		return CONTINUE
	if not engine.boost(user, {&"atk": 2, &"spa": 2}, false):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
