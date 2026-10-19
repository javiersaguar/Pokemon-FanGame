extends BattleEffect
## Pulpopresa: el objetivo no puede escapar y cada turno pierde un nivel de Defensa y de Defensa Especial.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	if target.has_volatile(&"octolock") or target.has_type(&"ghost") or \
			not engine.add_volatile(target, &"octolock", user, {"source_side": user.side, "source_party": user.party_index}):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
