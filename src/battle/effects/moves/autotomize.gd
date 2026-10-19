extends BattleEffect
## Aligerar: sube dos niveles la Velocidad (datos) y el usuario pesa 100 kg menos.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if user.boosts[&"spe"] >= 6:
		return CONTINUE
	user.weight_delta -= 100.0
	engine.message(tr("¡%s se ha vuelto más ligero!") % engine.name_of(user))
	return CONTINUE
