extends BattleEffect
## Poltergeist: falla si el objetivo no lleva objeto.


func on_try_move(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> bool:
	if target.pokemon.held_item == &"" or not DataDB.has_item(target.pokemon.held_item):
		engine.message(tr("¡Pero falló!"))
		return false
	engine.message(tr("¡%s va a ser atacado por su %s!") % [engine.name_of(target), DataDB.item(target.pokemon.held_item).name])
	return true
