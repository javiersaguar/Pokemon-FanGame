extends BattleEffect
## Imitación: el usuario copia la habilidad del objetivo.

const BLOCKED: Array[StringName] = [&"wonderguard", &"multitype", &"stancechange", &"schooling", &"comatose",
	&"shieldsdown", &"disguise", &"rkssystem", &"battlebond", &"powerconstruct", &"iceface", &"gulpmissile",
	&"zerotohero", &"commander", &"illusion", &"imposter", &"trace", &"receiver", &"powerofalchemy", &"tetraform"]


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	if target.ability in BLOCKED or target.ability == &"" or target.ability == user.ability:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	user.ability = target.ability
	engine.message(tr("¡%s ha copiado la habilidad %s!") % [engine.name_of(user), engine.of_name(target)])
	return HANDLED
