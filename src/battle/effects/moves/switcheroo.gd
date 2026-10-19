extends BattleEffect
## Trapicheo: intercambia los objetos del usuario y del objetivo. Al acabar un combate contra
## entrenadores, el jugador recupera el suyo.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	var mine := user.pokemon.held_item
	var theirs := target.pokemon.held_item
	var blocked := (mine != &"" and not engine.item_removable(user)) or (theirs != &"" and not engine.item_removable(target))
	if (mine == &"" and theirs == &"") or blocked:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.set_held_item(user, theirs)
	engine.set_held_item(target, mine)
	engine.message(tr("¡%s ha intercambiado su objeto con %s!") % [engine.name_of(user), engine.inner_name_of(target)])
	if theirs != &"":
		engine.message(tr("¡%s ha obtenido %s!") % [engine.name_of(user), DataDB.item(theirs).name])
	if mine != &"":
		engine.message(tr("¡%s ha obtenido %s!") % [engine.name_of(target), DataDB.item(mine).name])
	return HANDLED
