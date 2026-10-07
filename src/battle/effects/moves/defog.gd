extends BattleEffect
## Despejar: baja la evasión del objetivo y quita las trampas de los dos bandos, las pantallas
## y el Velo Sagrado del bando rival, y el campo. La bajada de evasión está en el script de Showdown
## (no en sus datos), así que va aquí y no en move.boosts.

const HAZARDS: Array[StringName] = [&"spikes", &"toxicspikes", &"stealthrock", &"stickyweb"]
const SCREENS: Array[StringName] = [&"reflect", &"lightscreen", &"auroraveil", &"safeguard", &"mist"]
const EVASION_DROP: Dictionary[StringName, int] = {&"evasion": -1}


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	engine.boost(target, EVASION_DROP, false)
	for id: StringName in SCREENS:
		engine.remove_side_condition(target.side, id)
	for side_index: int in [user.side, target.side]:
		for id: StringName in HAZARDS:
			engine.remove_side_condition(side_index, id)
	engine.clear_terrain()
	return HANDLED
