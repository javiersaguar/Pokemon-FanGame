extends BattleEffect
## Anticura (Ruido Psíquico): dos turnos sin poder usar movimientos que curan.


func duration(_engine: BattleEngine) -> int:
	return 3


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s no puede curarse!") % engine.name_of(holder))
	return true


func disables_move(_battler: Battler, _state: Dictionary, move: MoveData) -> bool:
	return move.has_flag(&"heal")


func disabled_text(_state: Dictionary) -> String:
	return "¡%s no puede usar %s por Anticura!"
