extends BattleEffect
## Ataque previsto (Premonición, Deseo Oculto): al acabar, golpea a quien esté en ese lugar.


func residual_order() -> int:
	return 3


func on_end(engine: BattleEngine, holder: Variant, state: Dictionary) -> void:
	var target := engine.active((holder as BattleSide).index)
	if target == null or target.is_fainted():
		return
	var move := DataDB.move(StringName(str(state.get("move", "futuresight"))))
	engine.message(tr("¡%s ha recibido el ataque de %s!") % [engine.name_of(target), move.name])
	if DataDB.type_effectiveness(StringName(str(state.get("type", "psychic"))), target.types()) == 0.0:
		engine.message(tr("No afecta %s...") % engine.to_name(target))
		return
	engine.deal_damage(target, int(state.get("damage", 1)), &"futuresight")
