extends "res://src/battle/effects/conditions/quickguard.gd"
## Vasta Guardia (un turno): bloquea los movimientos de los rivales que alcanzan a varios.


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡Vasta Guardia protege %s!") % engine.team_to_name((holder as BattleSide).index))
	return true


func _blocks(move: MoveData) -> bool:
	return move.target in [&"all_adjacent_foes", &"all_adjacent"]
