extends BattleEffect
## Hora del Té: todos los que están en el campo se comen su baya.


func on_hit(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	var any := false
	for side_index: int in [BattleEngine.PLAYER, BattleEngine.FOE]:
		for slot: int in engine.slot_count():
			var b := engine.active(side_index, slot)
			if b == null or b.is_fainted():
				continue
			var item := b.pokemon.held_item
			if item == &"" or not DataDB.has_item(item) or DataDB.item(item).pocket != &"berries":
				continue
			any = true
			var berry := Effects.item(item)
			engine.message(tr("¡%s se ha comido su %s!") % [engine.name_of(b), DataDB.item(item).name])
			engine.consume_held_item(b)
			if berry != null:
				var amount := berry.heal_amount(b)
				if amount > 0:
					engine.heal(b, amount, &"item")
				if b.pokemon.status != &"" and berry.cures_status(b.pokemon.status):
					engine.cure_status(b)
	if not any:
		engine.message(tr("¡Pero falló!"))
	return HANDLED
