extends BattleEffect
## Campo Psíquico (5 turnos): los que tocan el suelo no reciben movimientos con prioridad de los
## rivales, y sus movimientos de tipo Psíquico son más fuertes (×1,3).


func duration(_engine: BattleEngine) -> int:
	return 5


func residual_order() -> int:
	return 27


func on_start(engine: BattleEngine, _holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡El terreno de combate se ha vuelto muy extraño!"))
	return true


func on_end(engine: BattleEngine, _holder: Variant, _state: Dictionary) -> void:
	engine.message(tr("Ha desaparecido la extraña sensación del terreno de combate."))


func on_try_hit(engine: BattleEngine, target: Battler, _state: Dictionary, user: Battler, move: MoveData) -> bool:
	if move.priority <= 0 or user.side == target.side or not engine.is_grounded(target) or move.target in MoveData.FIELD_TARGETS:
		return true
	engine.message(tr("¡%s se ha protegido con el Campo Psíquico!") % engine.name_of(target))
	return false


func modify_base_power(engine: BattleEngine, user: Battler, _target: Battler, move: MoveData, power: int) -> int:
	if move.type == &"psychic" and user != null and engine.is_grounded(user):
		return DamageCalc.modify(power, 1.3)
	return power
