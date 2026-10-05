extends "res://src/battle/effects/moves/spikes.gd"
## Púas tóxicas: hasta 2 capas en el campo rival.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	_stack(engine, user, &"toxicspikes", 2)
	return HANDLED
