extends BattleEffect
## Tras Asalto Espadón: recibe el doble de daño hasta que vuelve a moverse.


func before_move_priority() -> int:
	return 6


func on_before_move(engine: BattleEngine, battler: Battler, _state: Dictionary, _move: MoveData) -> bool:
	engine.remove_volatile(battler, &"glaiverush")
	return true


func damage_modifier(_engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _crit: bool) -> float:
	return 2.0 if user.side != target.side and target.has_volatile(&"glaiverush") else 1.0
