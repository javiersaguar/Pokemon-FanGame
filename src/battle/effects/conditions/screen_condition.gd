class_name ScreenConditionEffect
extends BattleEffect
## Reflejo y Pantalla de Luz: 5 turnos, la mitad de daño físico o especial contra su bando (salvo
## golpes críticos).

var physical: bool = true
var screen_name: String = ""


func duration(_engine: BattleEngine) -> int:
	return 5


func residual_order() -> int:
	return 26


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	var kind := tr("los ataques físicos") if physical else tr("los ataques especiales")
	engine.message(tr("¡%s ha aumentado la resistencia %s a %s!") % [tr(screen_name), engine.team_of_name((holder as BattleSide).index), kind])
	return true


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	engine.message(tr("¡Los efectos de %s %s se han disipado!") % [tr(screen_name), engine.team_of_name((holder as BattleSide).index)])


func damage_modifier(_engine: BattleEngine, user: Battler, target: Battler, move: MoveData, crit: bool) -> float:
	if crit or user.side == target.side or move.is_physical() != physical or move.is_status() or user.ability == &"infiltrator":
		return 1.0
	return 0.5
