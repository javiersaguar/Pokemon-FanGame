extends BattleEffect
## Acua Aro: cura 1/16 de los PS máximos al final de cada turno.


func residual_order() -> int:
	return 6


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s se ha rodeado de un manto de agua!") % engine.name_of(holder))
	return true


@warning_ignore("integer_division")
func on_residual(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	var b := holder as Battler
	if engine.heal(b, maxi(1, b.pokemon.max_hp() / 16), &"aquaring") > 0:
		engine.message(tr("¡%s ha recuperado PS gracias al Acua Aro!") % engine.name_of(b))
