extends BattleEffect
## Danza Amiga: el objetivo pasa a tener la habilidad del usuario.

const CANT_COPY: Array[StringName] = [&"trace", &"forecast", &"flowergift", &"zenmode", &"illusion", &"imposter", &"powerofalchemy", &"receiver", &"disguise", &"powerconstruct", &"schooling", &"comatose", &"shieldsdown", &"rkssystem", &"multitype", &"stancechange"]
const CANT_CHANGE: Array[StringName] = [&"truant", &"multitype", &"stancechange", &"schooling", &"comatose", &"shieldsdown", &"disguise", &"rkssystem", &"battlebond", &"powerconstruct"]


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	if user.ability == target.ability or user.ability in CANT_COPY or target.ability in CANT_CHANGE:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	target.ability = user.ability
	var ability_name := DataDB.ability(user.ability).name if DataDB.has_ability(user.ability) else String(user.ability)
	engine.message(tr("¡%s ha adquirido la habilidad %s!") % [engine.name_of(target), ability_name])
	return HANDLED
