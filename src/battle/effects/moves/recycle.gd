extends BattleEffect
## Reciclaje: recupera el último objeto que gastó en el combate.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var item := user.consumed_item
	if user.pokemon.held_item != &"" or item == &"" or not DataDB.has_item(item):
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	user.consumed_item = &""
	user.pokemon.held_item = item
	engine.message(tr("¡%s ha reciclado %s!") % [engine.name_of(user), DataDB.item(item).name])
	return HANDLED
