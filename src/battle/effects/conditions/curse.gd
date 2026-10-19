extends BattleEffect
## Maldito: pierde 1/4 de sus PS máximos al final de cada turno.


func residual_order() -> int:
	return 12


@warning_ignore("integer_division")
func on_residual(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	var b := holder as Battler
	engine.message(tr("¡%s sufre los efectos de la maldición!") % engine.name_of(b))
	engine.deal_damage(b, maxi(1, b.pokemon.max_hp() / 4), &"curse")
