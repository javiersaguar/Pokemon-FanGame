extends BattleEffect
## Alboroto: 3 turnos seguidos; mientras dura, nadie puede dormirse y despierta a los dormidos.


func on_after_move(engine: BattleEngine, user: Battler, _move: MoveData, hit: bool) -> void:
	if hit and not user.is_fainted() and not user.has_volatile(&"uproar"):
		engine.add_volatile(user, &"uproar", user)
