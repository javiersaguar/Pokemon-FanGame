extends BattleEffect
## Deseo Cura: cura del todo (PS y estado) al siguiente que sale al campo de ese bando.


func on_switch_in(engine: BattleEngine, battler: Battler, _state: Dictionary) -> void:
	engine.remove_side_condition(battler.side, &"healingwish")
	engine.heal(battler, battler.pokemon.max_hp(), &"healingwish")
	engine.cure_status(battler)
	engine.message(tr("¡El deseo cura se ha cumplido para %s!") % engine.inner_name_of(battler))
