extends BattleEffect
## Campo Eléctrico (5 turnos): los que tocan el suelo no pueden dormirse y sus movimientos de tipo
## Eléctrico son más fuertes (×1,3).


func duration(_engine: BattleEngine) -> int:
	return 5


func residual_order() -> int:
	return 27


func on_start(engine: BattleEngine, _holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡Se ha formado un campo de corriente eléctrica en el terreno de combate!"))
	return true


func on_end(engine: BattleEngine, _holder: Variant, _state: Dictionary) -> void:
	engine.message(tr("El campo de corriente eléctrica ha desaparecido."))


func on_set_status(engine: BattleEngine, target: Battler, status: StringName, _source: Battler, announce: bool) -> bool:
	if status != &"slp" or not engine.is_grounded(target):
		return true
	if announce:
		engine.message(tr("¡%s se ha protegido con el Campo Eléctrico!") % engine.name_of(target))
	return false


func modify_base_power(engine: BattleEngine, user: Battler, _target: Battler, move: MoveData, power: int) -> int:
	if move.type == &"electric" and user != null and engine.is_grounded(user):
		return DamageCalc.modify(power, 1.3)
	return power
