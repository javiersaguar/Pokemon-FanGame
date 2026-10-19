extends "res://src/battle/effects/conditions/trapped.gd"
## Pulpopresa: atrapado mientras siga quien lo atrapó; pierde Defensa y Defensa Especial cada turno.


func residual_order() -> int:
	return 14


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s ha quedado atrapado por la pulpopresa!") % engine.name_of(holder))
	return true


func on_residual(engine: BattleEngine, holder: Variant, state: Dictionary) -> void:
	var b := holder as Battler
	if traps(engine, b, state):
		engine.boost(b, {&"def": -1, &"spd": -1}, true)
	else:
		engine.remove_volatile(b, &"octolock")
