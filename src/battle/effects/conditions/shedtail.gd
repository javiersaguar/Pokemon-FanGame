extends BattleEffect
## Cola dejada (Autotomía): el siguiente que sale al campo de ese bando se queda con el sustituto.


func on_switch_in(engine: BattleEngine, battler: Battler, state: Dictionary) -> void:
	engine.remove_side_condition(battler.side, &"shedtail")
	engine.add_volatile(battler, &"substitute", battler, {"hp": int(state.get("hp", 1))})
