extends BattleEffect
## Bilis: anula la habilidad del objetivo mientras siga en el campo.

const PERMANENT: Array[StringName] = [&"multitype", &"stancechange", &"schooling", &"comatose", &"shieldsdown",
	&"disguise", &"rkssystem", &"battlebond", &"powerconstruct", &"iceface", &"gulpmissile", &"asoneglastrier",
	&"asonespectrier", &"zerotohero", &"commander", &"tetraform"]


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if target.ability == &"" or target.ability in PERMANENT:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	target.ability = &""
	engine.message(tr("¡Se ha anulado la habilidad %s!") % engine.of_name(target))
	return HANDLED
