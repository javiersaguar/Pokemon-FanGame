extends BattleEffect
## Mar de llamas (Voto Fuego + Voto Planta): 4 turnos, 1/8 de los PS al final de cada turno a los que no
## son de tipo Fuego del bando.


func duration(_engine: BattleEngine) -> int:
	return 4


func residual_order() -> int:
	return 9


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡Un mar de llamas rodea al equipo %s!") % engine.team_of_name((holder as BattleSide).index))
	return true


func on_residual(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	for slot: int in engine.slot_count():
		var b := engine.active((holder as BattleSide).index, slot)
		if b != null and not b.is_fainted() and not b.has_type(&"fire"):
			engine.message(tr("¡El mar de llamas quema a %s!") % engine.name_of(b))
			engine.deal_damage(b, maxi(1, b.pokemon.max_hp() / 8), &"firepledge")
