extends BattleEffect
## Intercambio: el usuario y el objetivo intercambian sus habilidades.

const BLOCKED: Array[StringName] = [&"wonderguard", &"multitype", &"stancechange", &"schooling", &"comatose",
	&"shieldsdown", &"disguise", &"rkssystem", &"battlebond", &"powerconstruct", &"iceface", &"gulpmissile",
	&"zerotohero", &"commander", &"illusion", &"neutralizinggas", &"hungerswitch", &"tetraform"]


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	if user.ability in BLOCKED or target.ability in BLOCKED or user.ability == target.ability:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	var mine := user.ability
	user.ability = target.ability
	target.ability = mine
	engine.message(tr("¡%s ha intercambiado su habilidad con %s!") % [engine.name_of(user), engine.inner_name_of(target)])
	return HANDLED
