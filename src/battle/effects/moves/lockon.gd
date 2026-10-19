extends BattleEffect
## Fijar Blanco: el siguiente movimiento del usuario contra ese objetivo acierta seguro.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	engine.remove_volatile(user, &"lockon")
	engine.add_volatile(user, &"lockon", user, {"side": target.side, "slot": target.slot, "uid": target.pokemon.uid})
	engine.message(tr("¡%s ha fijado su objetivo en %s!") % [engine.name_of(user), engine.inner_name_of(target)])
	return HANDLED
