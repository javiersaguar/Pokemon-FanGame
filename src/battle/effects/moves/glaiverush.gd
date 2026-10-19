extends BattleEffect
## Asalto Espadón: hasta que vuelva a moverse, recibe el doble de daño.


func on_after_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, _damage: int) -> void:
	if not user.is_fainted():
		engine.remove_volatile(user, &"glaiverush")
		engine.add_volatile(user, &"glaiverush", user)
