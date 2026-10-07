extends BattleEffect
## Picoteo: si el objetivo lleva una baya, el usuario se la come y le hace efecto (aunque el golpe lo debilite).


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	engine.steal_and_eat_berry(user, target)
