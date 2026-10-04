extends BattleEffect
## Despejar: baja la evasión del objetivo (datos) y quita las trampas de los dos bandos, las pantallas
## y el Velo Sagrado del bando rival, y el campo.

const HAZARDS: Array[StringName] = [&"spikes", &"toxicspikes", &"stealthrock", &"stickyweb"]
const SCREENS: Array[StringName] = [&"reflect", &"lightscreen", &"auroraveil", &"safeguard", &"mist"]


func on_hit(engine: BattleEngine, user: Battler, target: Battler, move: MoveData) -> int:
	engine.boost(target, move.boosts, false)
	for id: StringName in SCREENS:
		engine.remove_side_condition(target.side, id)
	for side_index: int in [user.side, target.side]:
		for id: StringName in HAZARDS:
			engine.remove_side_condition(side_index, id)
	engine.clear_terrain()
	return HANDLED
