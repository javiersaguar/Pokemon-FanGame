extends BattleEffect
## Bostezo: el objetivo se adormila y al final del turno siguiente se duerme.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if target.pokemon.status != &"" or target.has_volatile(&"yawn") or not engine.can_set_status(target, &"slp", null, false):
		engine.message(tr("¡Pero falló!"))
	else:
		engine.add_volatile(target, &"yawn")
	return HANDLED
