extends BattleEffect
## Pico Cañón: calienta el pico al empezar el turno; quien le toque antes de que ataque se quema.


func before_turn(engine: BattleEngine, user: Battler, _move: MoveData) -> void:
	engine.add_volatile(user, &"beakblast", user)


func on_after_move(engine: BattleEngine, user: Battler, _move: MoveData, _hit: bool) -> void:
	engine.remove_volatile(user, &"beakblast")
