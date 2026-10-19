extends BattleEffect
## Antojo: si el usuario no lleva nada, se queda con el objeto del objetivo. Al acabar un combate
## contra entrenadores, el jugador lo recupera.


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if user.is_fainted() or user.pokemon.held_item != &"" or not engine.item_removable(target):
		return
	var item := target.pokemon.held_item
	engine.set_held_item(target, &"")
	engine.set_held_item(user, item)
	engine.message(tr("¡%s ha robado %s %s!") % [engine.name_of(user), DataDB.item(item).name, engine.of_name(target)])
