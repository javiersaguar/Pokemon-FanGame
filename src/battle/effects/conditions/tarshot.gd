extends BattleEffect
## Alquitranado: los movimientos de tipo Fuego le hacen el doble.


func damage_modifier(_engine: BattleEngine, _user: Battler, target: Battler, move: MoveData, _crit: bool) -> float:
	return 2.0 if move.type == &"fire" and target.has_volatile(&"tarshot") else 1.0
