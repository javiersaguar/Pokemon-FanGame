extends BattleEffect
## Atrapado (Giro Fuego, Torbellino, Acoso...): 4-5 turnos sin poder cambiar ni huir y 1/8 de daño
## al final de cada turno. Se acaba si quien lo atrapó deja el campo.


func duration(engine: BattleEngine) -> int:
	return engine.rng.randi_range(5, 6)


func residual_order() -> int:
	return 13


@warning_ignore("integer_division")
func on_residual(engine: BattleEngine, holder: Variant, state: Dictionary) -> void:
	var trapped: Battler = holder
	var source := engine.active(int(state.get("source_side", 1 - trapped.side)))
	if source == null or source.is_fainted() or source.party_index != int(state.get("source_party", -1)):
		engine.remove_volatile(trapped, &"partiallytrapped")
		return
	engine.message(tr("¡%s sufre el efecto de %s!") % [engine.name_of(trapped), str(state.get("move_name", ""))])
	engine.deal_damage(trapped, maxi(1, trapped.pokemon.max_hp() / 8), &"partiallytrapped")


func on_end(engine: BattleEngine, holder: Variant, state: Dictionary) -> void:
	var trapped: Battler = holder
	if not trapped.is_fainted():
		engine.message(tr("¡%s se ha liberado de %s!") % [engine.name_of(trapped), str(state.get("move_name", ""))])


func traps(_engine: BattleEngine, _battler: Battler, _state: Dictionary) -> bool:
	return true
