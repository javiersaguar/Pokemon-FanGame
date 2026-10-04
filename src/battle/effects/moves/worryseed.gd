extends BattleEffect
## Abatidoras: la habilidad del objetivo pasa a ser Insomnio.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if target.ability in [&"insomnia", &"truant", &"multitype", &"stancechange", &"schooling", &"comatose", &"shieldsdown", &"disguise", &"rkssystem", &"battlebond", &"powerconstruct"]:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	target.ability = &"insomnia"
	var ability_name := DataDB.ability(&"insomnia").name if DataDB.has_ability(&"insomnia") else "Insomnio"
	engine.message(tr("¡%s ha adquirido la habilidad %s!") % [engine.name_of(target), ability_name])
	if target.pokemon.status == &"slp":
		engine.cure_status(target)
	return HANDLED
