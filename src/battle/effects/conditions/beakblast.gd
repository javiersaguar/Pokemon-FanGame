extends BattleEffect
## Pico caliente: quien le golpea con contacto se quema.


func duration(_engine: BattleEngine) -> int:
	return 1


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s ha empezado a calentar su pico!") % engine.name_of(holder))
	return true


func on_damage(engine: BattleEngine, _battler: Battler, _state: Dictionary, amount: int, _source: StringName, move: MoveData) -> int:
	var attacker: Battler = engine._move_user
	if move != null and move.has_flag(&"contact") and attacker != null and not attacker.is_fainted():
		engine.set_status(attacker, &"brn", null, false)
	return amount
