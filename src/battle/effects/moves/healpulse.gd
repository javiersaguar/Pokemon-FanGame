extends BattleEffect
## Pulso Cura: cura la mitad de los PS máximos del objetivo.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if target.pokemon.current_hp >= target.pokemon.max_hp():
		engine.message(tr("¡Los PS %s están al máximo!") % engine.of_name(target))
		return HANDLED
	engine.heal(target, roundi(target.pokemon.max_hp() / 2.0))
	engine.message(tr("¡%s ha recuperado PS!") % engine.name_of(target))
	return HANDLED
