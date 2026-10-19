extends BattleEffect
## Cambiavelocidad: el usuario y el objetivo intercambian su Velocidad.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	var mine: int = user.stat_override.get(&"spe", user.pokemon.stat(&"spe"))
	var theirs: int = target.stat_override.get(&"spe", target.pokemon.stat(&"spe"))
	user.stat_override[&"spe"] = theirs
	target.stat_override[&"spe"] = mine
	engine.message(tr("¡%s ha intercambiado su Velocidad con %s!") % [engine.name_of(user), engine.inner_name_of(target)])
	return HANDLED
