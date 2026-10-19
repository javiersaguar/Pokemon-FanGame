extends BattleEffect
## Cambiadefensa: intercambia con el objetivo los cambios de Defensa y Defensa Especial.

var stats: Array[StringName] = [&"def", &"spd"]
var text := "¡%s ha intercambiado los cambios de su guardia con %s!"


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	for stat: StringName in stats:
		var mine: int = user.boosts[stat]
		user.boosts[stat] = target.boosts[stat]
		target.boosts[stat] = mine
	engine.message(tr(text) % [engine.name_of(user), engine.inner_name_of(target)])
	return HANDLED
