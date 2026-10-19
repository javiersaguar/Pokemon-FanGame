extends BattleEffect
## Onda Simple: la habilidad del objetivo pasa a ser Simple.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if target.ability in [&"simple", &"truant", &"multitype", &"stancechange", &"schooling", &"comatose", &"shieldsdown", &"disguise", &"rkssystem", &"battlebond", &"powerconstruct"]:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	target.ability = &"simple"
	var ability_name := DataDB.ability(&"simple").name if DataDB.has_ability(&"simple") else "Simple"
	engine.message(tr("¡%s ha adquirido la habilidad %s!") % [engine.name_of(target), ability_name])
	return HANDLED
