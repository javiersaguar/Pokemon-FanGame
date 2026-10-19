extends BattleEffect
## Absorbefuerza: recupera tantos PS como Ataque tiene el objetivo y se lo baja un nivel.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	if target.boosts[&"atk"] <= -6:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	var amount := target.boosted_stat(&"atk")
	engine.boost(target, {&"atk": -1})
	if engine.heal(user, amount) > 0:
		engine.message(tr("¡%s ha recuperado PS!") % engine.name_of(user))
	return HANDLED
