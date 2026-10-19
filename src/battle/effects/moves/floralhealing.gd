extends BattleEffect
## Cura Floral: cura la mitad de los PS del objetivo, o 2/3 con Campo de Hierba.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if target.pokemon.current_hp >= target.pokemon.max_hp():
		engine.message(tr("¡Los PS %s están al máximo!") % engine.of_name(target))
		return HANDLED
	var part := 2.0 / 3.0 if engine.terrain() == &"grassyterrain" else 0.5
	engine.heal(target, roundi(target.pokemon.max_hp() * part))
	engine.message(tr("¡%s ha recuperado PS!") % engine.name_of(target))
	return HANDLED
