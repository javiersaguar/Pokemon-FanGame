extends BattleEffect
## Trampa Venenosa: baja Ataque, Ataque Especial y Velocidad del objetivo si está envenenado.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if target.pokemon.status not in [&"psn", &"tox"]:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.boost(target, {&"atk": -1, &"spa": -1, &"spe": -1})
	return HANDLED
