extends SideConditionMoveEffect
## Trampa Rocas.


func _init() -> void:
	condition_id = &"stealthrock"
	on_foe_side = true
