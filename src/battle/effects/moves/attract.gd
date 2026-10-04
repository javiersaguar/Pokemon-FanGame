extends BattleEffect
## Atracción: enamora a un objetivo de distinto sexo (ninguno puede ser sin sexo).


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	var a := user.pokemon.gender
	var b := target.pokemon.gender
	if a == Pokemon.GENDERLESS or b == Pokemon.GENDERLESS or a == b:
		engine.message(tr("¡Pero falló!"))
	elif not engine.add_volatile(target, &"attract", user, {"source_side": user.side, "source_party": user.party_index}):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
