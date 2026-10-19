extends BattleEffect
## Niebla Clara: anula los cambios de características del objetivo.


func on_after_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if target.is_fainted():
		return
	for stat: StringName in target.boosts:
		target.boosts[stat] = 0
	engine.message(tr("¡Se han anulado los cambios en las características %s!") % engine.of_name(target))
