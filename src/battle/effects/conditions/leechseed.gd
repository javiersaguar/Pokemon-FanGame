extends BattleEffect
## Drenadoras: al final de cada turno quita 1/8 de los PS máximos y se los da a quien esté en el campo
## del bando que las sembró.


func residual_order() -> int:
	return 8


@warning_ignore("integer_division")
func on_residual(engine: BattleEngine, holder: Variant, state: Dictionary) -> void:
	var seeded: Battler = holder
	var receiver := engine.active(int(state.get("source_side", 1 - seeded.side)))
	if receiver == null or receiver.is_fainted():
		return
	var drained := engine.deal_damage(seeded, maxi(1, seeded.pokemon.max_hp() / 8), &"leechseed")
	engine.message(tr("¡Las drenadoras han restado salud %s!") % engine.to_name(seeded))
	if drained > 0:
		engine.heal(receiver, drained, &"leechseed")
