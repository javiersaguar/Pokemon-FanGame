extends BattleEffect
## Ataque previsto (Premonición, Deseo Oculto): al acabar, golpea a quien esté en ese lugar.


func residual_order() -> int:
	return 3


func on_end(engine: BattleEngine, holder: Variant, state: Dictionary) -> void:
	var target := engine.active((holder as BattleSide).index, int(state.get("slot", 0)))
	if target == null or target.is_fainted():
		return
	var move := DataDB.move(StringName(str(state.get("move", "futuresight"))))
	engine.message(tr("¡%s ha recibido el ataque de %s!") % [engine.name_of(target), move.name])
	if DataDB.type_effectiveness(StringName(str(state.get("type", "psychic"))), target.types()) == 0.0:
		engine.message(tr("No afecta %s...") % engine.to_name(target))
		return
	var amount := int(state.get("damage", 0))
	var source: Battler = state.get("source") as Battler
	if source != null:
		var crit := engine._roll_crit(source, move)
		var opts := engine._damage_opts(source, target, move, null, crit)
		amount = DamageCalc.calculate(source, target, move, crit, engine.rand_int(&"damage_roll", 0, DamageCalc.ROLLS - 1), opts)
		if crit:
			engine.message(tr("¡Un golpe crítico!"))
		var effect := DamageCalc.effectiveness(move, target)
		if effect > 1.0:
			engine.message(tr("¡Es supereficaz!"))
		elif effect < 1.0:
			engine.message(tr("No es muy eficaz..."))
	engine.deal_damage(target, maxi(1, amount), &"futuresight")
