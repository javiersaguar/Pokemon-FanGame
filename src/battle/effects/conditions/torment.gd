extends BattleEffect
## Tormento: no puede repetir el último movimiento que ha usado (Forcejeo sí).


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s sufre el Tormento!") % engine.name_of(holder))
	return true


func disables_move(battler: Battler, _state: Dictionary, move: MoveData) -> bool:
	return move.id == battler.last_move and move.id != &"struggle"


func disabled_text(_state: Dictionary) -> String:
	return "¡%s no puede usar %s dos veces seguidas por el Tormento!"
