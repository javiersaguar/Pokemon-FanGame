extends BattleEffect
## Velo Sagrado (5 turnos): su bando no sufre estados ni confusión causados por los rivales.


func duration(_engine: BattleEngine) -> int:
	return 5


func residual_order() -> int:
	return 26


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡Un velo místico protege %s!") % engine.team_to_name((holder as BattleSide).index))
	return true


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	engine.message(tr("¡%s ya no está protegido por Velo Sagrado!") % BattleText.capitalize(engine.team_name((holder as BattleSide).index)))


func on_set_status(engine: BattleEngine, target: Battler, _status: StringName, source: Battler, announce: bool) -> bool:
	if source == null or source.side == target.side or not engine.has_side_condition(target.side, &"safeguard"):
		return true
	if announce:
		engine.message(tr("¡%s está protegido por Velo Sagrado!") % engine.name_of(target))
	return false


func on_try_confuse(engine: BattleEngine, target: Battler, source: Battler, announce: bool) -> bool:
	return on_set_status(engine, target, &"confusion", source, announce)
