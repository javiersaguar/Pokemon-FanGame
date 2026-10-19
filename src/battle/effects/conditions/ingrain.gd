extends BattleEffect
## Arraigo: cura 1/16 al final del turno, impide cambiar y huir, y le hace tocar el suelo.


func residual_order() -> int:
	return 7


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s ha echado raíces!") % engine.name_of(holder))
	return true


@warning_ignore("integer_division")
func on_residual(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	var b := holder as Battler
	if engine.heal(b, maxi(1, b.pokemon.max_hp() / 16), &"ingrain") > 0:
		engine.message(tr("¡%s ha absorbido nutrientes con sus raíces!") % engine.name_of(b))


func traps(_engine: BattleEngine, _battler: Battler, _state: Dictionary) -> bool:
	return true


func grounding(_state: Dictionary) -> int:
	return 1
