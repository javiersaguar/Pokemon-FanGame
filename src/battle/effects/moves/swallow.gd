extends BattleEffect
## Tragar: se traga la energía reservada y recupera 1/4, 1/2 o todos los PS según cuántas veces reservó.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var layers := int(user.volatiles.get(&"stockpile", {}).get("layers", 0))
	if layers <= 0:
		engine.message(tr("¡Pero no ha conseguido tragar nada!"))
		return HANDLED
	var max_hp := user.pokemon.max_hp()
	if user.pokemon.current_hp >= max_hp:
		engine.message(tr("¡Los PS %s están al máximo!") % engine.of_name(user))
	else:
		engine.heal(user, roundi(max_hp * [0.25, 0.5, 1.0][layers - 1]))
		engine.message(tr("¡%s ha recuperado PS!") % engine.name_of(user))
	engine.remove_volatile(user, &"stockpile")
	return HANDLED
