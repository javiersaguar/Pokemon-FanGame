extends WeatherConditionEffect
## Tormenta de arena: daña 1/16 al final del turno a quien no sea Roca, Tierra ni Acero, y los de
## tipo Roca tienen ×1,5 de Defensa Especial.


func _init() -> void:
	start_text = "¡Se ha desatado una tormenta de arena!"
	continue_text = "La tormenta de arena sigue soplando."
	end_text = "La tormenta de arena ha amainado."


@warning_ignore("integer_division")
func on_residual(engine: BattleEngine, _holder: Variant, _state: Dictionary) -> void:
	engine.message(tr(continue_text))
	# Nube Nueve o Bucle Aire en el campo: la arena sigue, pero no hace daño.
	if engine.weather() != &"sandstorm":
		return
	for side_index: int in [BattleEngine.PLAYER, BattleEngine.FOE]:
		for slot: int in engine.slot_count():
			var b := engine.active(side_index, slot)
			if b == null or b.is_fainted() or b.has_type(&"rock") or b.has_type(&"ground") or b.has_type(&"steel") \
					or b.ability in [&"overcoat", &"sandveil", &"sandrush", &"sandforce"] or b.pokemon.held_item == &"safetygoggles":
				continue
			engine.message(tr("¡La tormenta de arena zarandea %s!") % engine.to_name(b))
			engine.deal_damage(b, maxi(1, b.pokemon.max_hp() / 16), &"sandstorm")


func stat_modifier(engine: BattleEngine, battler: Battler, stat: StringName) -> float:
	return 1.5 if stat == &"spd" and battler.has_type(&"rock") and engine.weather() == &"sandstorm" else 1.0
