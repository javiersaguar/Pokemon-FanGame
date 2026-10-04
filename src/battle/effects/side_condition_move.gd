class_name SideConditionMoveEffect
extends BattleEffect
## Movimientos que ponen una condición en un bando (Reflejo, Velo Sagrado, Viento Afín, Red Viscosa...).

var condition_id: StringName = &""
## true = en el bando rival (trampas); false = en el propio.
var on_foe_side: bool = false


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var side_index := 1 - user.side if on_foe_side else user.side
	if not engine.add_side_condition(side_index, condition_id, user):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
