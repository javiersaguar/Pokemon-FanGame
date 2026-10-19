extends BattleEffect
## Truco Fuerza: intercambia su Ataque y su Defensa.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var atk: int = user.stat_override.get(&"atk", user.pokemon.stat(&"atk"))
	var def: int = user.stat_override.get(&"def", user.pokemon.stat(&"def"))
	user.stat_override[&"atk"] = def
	user.stat_override[&"def"] = atk
	engine.message(tr("¡%s ha intercambiado su Ataque y su Defensa!") % engine.name_of(user))
	return HANDLED
