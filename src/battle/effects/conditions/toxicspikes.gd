extends BattleEffect
## Púas tóxicas: envenenan al entrar (tóxico con 2 capas). Un tipo Veneno las absorbe.


func on_start(engine: BattleEngine, holder: Variant, state: Dictionary, _source: Battler) -> bool:
	state["layers"] = maxi(1, int(state.get("layers", 1)))
	engine.message(tr("¡El equipo %s ha sido rodeado de púas tóxicas!") % engine.team_of_name((holder as BattleSide).index))
	return true


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	engine.message(tr("¡Las púas tóxicas lanzadas al equipo %s han desaparecido!") % engine.team_of_name((holder as BattleSide).index))


func on_switch_in(engine: BattleEngine, battler: Battler, state: Dictionary) -> void:
	if not engine.is_grounded(battler) or battler.is_fainted():
		return
	if battler.has_type(&"poison"):
		engine.remove_side_condition(battler.side, &"toxicspikes")
		engine.message(tr("¡%s ha absorbido las púas tóxicas!") % engine.name_of(battler))
		return
	var status := &"tox" if int(state.get("layers", 1)) >= 2 else &"psn"
	# La fuente es el rival que está en el campo (como en Showdown): Velo Sagrado las para.
	engine.set_status(battler, status, engine.foe_of(battler), true)
