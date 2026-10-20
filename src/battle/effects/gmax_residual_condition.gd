class_name GmaxResidualCondition
extends BattleEffect
## Fuego, lluvia de agua, látigos o rocas de los Gigamax (Llamarada, Cañonazo, Latigazo y Ceniza Gigamax):
## durante 4 turnos, 1/6 de los PS al final de cada turno a los del bando que no sean de `immune_type`.

var immune_type: StringName = &""


func duration(_engine: BattleEngine) -> int:
	return 4


func residual_order() -> int:
	return 9


func on_residual(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	var side := holder as BattleSide
	if side == null:
		return
	for slot: int in engine.slot_count():
		var b := engine.active(side.index, slot)
		if b != null and not b.is_fainted() and not b.has_type(immune_type):
			engine.message(tr("¡%s sufre el efecto del Gigamax!") % engine.name_of(b))
			engine.deal_damage(b, maxi(1, b.pokemon.max_hp() / 6), &"gmax")
