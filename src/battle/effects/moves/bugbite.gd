extends BattleEffect
## Picadura: si el objetivo lleva una baya, el usuario se la come (de momento, solo se la quita).


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	var item := target.pokemon.held_item
	if item == &"" or not DataDB.has_item(item) or DataDB.item(item).pocket != &"berries" or user.is_fainted():
		return
	target.pokemon.held_item = &""
	engine.message(tr("¡%s se ha comido la %s %s!") % [engine.name_of(user), DataDB.item(item).name, engine.of_name(target)])
