extends BattleEffect
## Transformación: copia el aspecto (evento forme), tipos, características salvo PS, niveles, habilidad
## y movimientos (5 PP cada uno) del objetivo hasta retirarse.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	if target.has_volatile(&"transform") or user.has_volatile(&"transform") or target.has_volatile(&"substitute"):
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.add_volatile(user, &"transform", user, {"species": String(target.pokemon.species_id)})
	user.type_override = target.types().duplicate()
	for stat: StringName in [&"atk", &"def", &"spa", &"spd", &"spe"]:
		user.stat_override[stat] = target.pokemon.stat(stat)
	user.boosts.assign(target.boosts)
	user.ability = target.ability
	for i: int in mini(4, target.pokemon.moves.size()):
		var slot := MoveSlot.create(target.pokemon.moves[i].id)
		slot.pp = mini(5, slot.max_pp())
		if i < user.pokemon.moves.size():
			engine.replace_move_slot(user, i, slot, true)
		else:
			user.pokemon.moves.append(slot)
	engine.show_forme(user, target.pokemon.species_id)
	engine.message(tr("¡%s se ha transformado en %s!") % [engine.name_of(user), target.pokemon.species().name])
	return HANDLED
