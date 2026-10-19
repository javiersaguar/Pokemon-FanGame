extends BattleEffect
## No puede escapar (Mal de Ojo, Bloqueo): mientras siga en el campo quien se lo hizo.


func traps(engine: BattleEngine, battler: Battler, state: Dictionary) -> bool:
	var source := engine.active(int(state.get("source_side", 1 - battler.side)))
	return source != null and not source.is_fainted() and source.party_index == int(state.get("source_party", -1))
