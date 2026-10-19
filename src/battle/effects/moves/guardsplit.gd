extends BattleEffect
## Isoguardia: el usuario y el objetivo reparten a medias su Defensa y su Defensa Especial.

var stats: Array[StringName] = [&"def", &"spd"]
var text := "¡%s ha compartido su guardia con %s!"


@warning_ignore("integer_division")
func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	for stat: StringName in stats:
		var mine: int = user.stat_override.get(stat, user.pokemon.stat(stat))
		var theirs: int = target.stat_override.get(stat, target.pokemon.stat(stat))
		user.stat_override[stat] = (mine + theirs) / 2
		target.stat_override[stat] = (mine + theirs) / 2
	engine.message(tr(text) % [engine.name_of(user), engine.inner_name_of(target)])
	return HANDLED
