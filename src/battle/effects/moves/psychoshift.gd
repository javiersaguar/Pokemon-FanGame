extends BattleEffect
## Psicocambio: pasa su problema de estado al objetivo y se cura.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	var status := user.pokemon.status
	if status == &"" or target.pokemon.status != &"" or not engine.set_status(target, status, user):
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.cure_status(user)
	return HANDLED
