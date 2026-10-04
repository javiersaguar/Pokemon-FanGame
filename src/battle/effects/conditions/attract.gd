extends BattleEffect
## Enamoramiento: la mitad de las veces no se mueve. Se acaba si quien lo enamoró deja el campo.


func before_move_priority() -> int:
	return 2


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s se ha enamorado!") % engine.name_of(holder))
	return true


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	if not (holder as Battler).is_fainted():
		engine.message(tr("¡%s ya no está enamorado!") % engine.name_of(holder))


func on_before_move(engine: BattleEngine, battler: Battler, state: Dictionary, _move: MoveData) -> bool:
	var source := engine.active(int(state.get("source_side", 1 - battler.side)))
	if source == null or source.is_fainted() or source.party_index != int(state.get("source_party", -1)):
		engine.remove_volatile(battler, &"attract")
		return true
	engine.message(tr("¡%s está enamorado %s!") % [engine.name_of(battler), engine.of_name(source)])
	if engine.rng.randi_range(0, 1) == 0:
		engine.message(tr("¡El enamoramiento impide que %s ataque!") % engine.inner_name_of(battler))
		return false
	return true
