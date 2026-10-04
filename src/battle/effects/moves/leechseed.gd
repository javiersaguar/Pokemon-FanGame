extends BattleEffect
## Drenadoras: siembra al objetivo (no afecta a los de tipo Planta).


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	if target.has_type(&"grass"):
		engine.message(tr("No afecta %s...") % engine.to_name(target))
	elif target.has_volatile(&"leechseed"):
		engine.message(tr("¡Pero falló!"))
	elif engine.add_volatile(target, &"leechseed", user, {"source_side": user.side}):
		engine.message(tr("¡%s ha sido infectado!") % engine.name_of(target))
	return HANDLED
