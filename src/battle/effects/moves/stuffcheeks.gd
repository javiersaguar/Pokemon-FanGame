extends BattleEffect
## Atiborramiento: se come su baya (con su efecto) y sube mucho la Defensa. Sin baya falla.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var item := user.pokemon.held_item
	if item == &"" or not DataDB.has_item(item) or DataDB.item(item).pocket != &"berries":
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.message(tr("¡%s se ha comido su %s!") % [engine.name_of(user), DataDB.item(item).name])
	var berry := Effects.item(item)
	engine.consume_held_item(user)
	if berry != null:
		var amount := berry.heal_amount(user)
		if amount > 0 and engine.heal(user, amount, &"item") > 0:
			engine.message(tr("¡%s ha recuperado PS!") % engine.name_of(user))
		if user.pokemon.status != &"" and berry.cures_status(user.pokemon.status):
			engine.cure_status(user)
	engine.boost(user, {&"def": 2})
	return HANDLED
