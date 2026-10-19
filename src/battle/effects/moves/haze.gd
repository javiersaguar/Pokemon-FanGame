extends BattleEffect
## Niebla: anula los cambios de características de todos los que están en el campo.


func on_hit(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> int:
	for side_index: int in [BattleEngine.PLAYER, BattleEngine.FOE]:
		for slot: int in engine.slot_count():
			var b := engine.active(side_index, slot)
			if b != null:
				for stat: StringName in b.boosts:
					b.boosts[stat] = 0
	engine.message(tr("¡Se han anulado todos los cambios en las características!"))
	return HANDLED
