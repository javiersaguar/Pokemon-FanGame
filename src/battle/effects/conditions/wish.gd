extends BattleEffect
## Deseo: al final del turno siguiente cura la mitad de los PS máximos de quien lo pidió al que esté
## en ese momento en el campo.


func duration(_engine: BattleEngine) -> int:
	return 2


func residual_order() -> int:
	return 4


func on_end(engine: BattleEngine, holder: Variant, state: Dictionary) -> void:
	var b := engine.active((holder as BattleSide).index)
	if b == null or b.is_fainted():
		return
	engine.message(tr("¡El deseo de %s se ha hecho realidad!") % str(state.get("wisher", "")))
	engine.heal(b, int(state.get("hp", 1)), &"wish")
