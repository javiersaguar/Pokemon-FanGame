extends BattleEffect
## Campo de Niebla (5 turnos): los que tocan el suelo no pueden sufrir estados ni confusión, y los
## movimientos de tipo Dragón les hacen la mitad.


func duration(_engine: BattleEngine) -> int:
	return 5


func residual_order() -> int:
	return 27


func on_start(engine: BattleEngine, _holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡La niebla ha envuelto el terreno de combate!"))
	return true


func on_end(engine: BattleEngine, _holder: Variant, _state: Dictionary) -> void:
	engine.message(tr("La niebla se ha disipado."))


func on_set_status(engine: BattleEngine, target: Battler, _status: StringName, _source: Battler, announce: bool) -> bool:
	if not engine.is_grounded(target):
		return true
	if announce:
		engine.message(tr("¡%s se ha protegido con el Campo de Niebla!") % engine.name_of(target))
	return false


func on_try_confuse(engine: BattleEngine, target: Battler, source: Battler, announce: bool) -> bool:
	return on_set_status(engine, target, &"confusion", source, announce)


func modify_base_power(engine: BattleEngine, _user: Battler, target: Battler, move: MoveData, power: int) -> int:
	if move.type == &"dragon" and target != null and engine.is_grounded(target):
		return DamageCalc.modify(power, 0.5)
	return power
