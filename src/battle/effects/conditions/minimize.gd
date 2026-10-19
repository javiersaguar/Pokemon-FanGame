extends BattleEffect
## Reducido: los movimientos que aplastan le hacen el doble.

const CRUSH: Array[StringName] = [&"stomp", &"bodyslam", &"dragonrush", &"heatcrash", &"heavyslam", &"flyingpress",
	&"steamroller", &"maliciousmoonsault", &"supercellslam"]


func damage_modifier(_engine: BattleEngine, _user: Battler, target: Battler, move: MoveData, _crit: bool) -> float:
	return 2.0 if move.id in CRUSH and target.has_volatile(&"minimize") else 1.0
