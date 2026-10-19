extends BattleEffect
## Reserva: cuántas veces ha acumulado energía y cuánto ha subido cada defensa. Al acabar (Escupir,
## Tragar o al salir del campo) se pierde lo que subió.


func on_end(engine: BattleEngine, holder: Variant, state: Dictionary) -> void:
	var b := holder as Battler
	if b.is_fainted():
		return
	var back := {}
	for stat: String in ["def", "spd"]:
		if int(state.get(stat, 0)) != 0:
			back[StringName(stat)] = -int(state[stat])
	if not back.is_empty():
		engine.boost(b, back, true)
