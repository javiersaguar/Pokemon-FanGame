extends BattleEffect
## Campo de Hierba (5 turnos): cura 1/16 al final del turno a los que tocan el suelo, potencia sus
## movimientos de tipo Planta (×1,3) y debilita Terremoto, Terratemblor y Magnitud contra ellos.


func duration(_engine: BattleEngine) -> int:
	return 5


func residual_order() -> int:
	return 27


func on_start(engine: BattleEngine, _holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡El terreno de combate se ha cubierto de hierba!"))
	return true


func on_end(engine: BattleEngine, _holder: Variant, _state: Dictionary) -> void:
	engine.message(tr("La hierba ha desaparecido."))


@warning_ignore("integer_division")
func on_residual(engine: BattleEngine, _holder: Variant, _state: Dictionary) -> void:
	for side_index: int in [BattleEngine.PLAYER, BattleEngine.FOE]:
		for slot: int in engine.slot_count():
			var b := engine.active(side_index, slot)
			if b == null or b.is_fainted() or not engine.is_grounded(b):
				continue
			if engine.heal(b, maxi(1, b.pokemon.max_hp() / 16), &"grassyterrain") > 0:
				engine.message(tr("¡%s ha recuperado PS gracias al Campo de Hierba!") % engine.name_of(b))


func modify_base_power(engine: BattleEngine, user: Battler, target: Battler, move: MoveData, power: int) -> int:
	if move.type == &"grass" and user != null and engine.is_grounded(user):
		return DamageCalc.modify(power, 1.3)
	if move.id in [&"earthquake", &"bulldoze", &"magnitude"] and target != null and engine.is_grounded(target):
		return DamageCalc.modify(power, 0.5)
	return power
