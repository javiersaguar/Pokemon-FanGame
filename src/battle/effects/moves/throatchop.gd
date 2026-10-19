extends BattleEffect
## Golpe Mordaza: durante 2 turnos el objetivo no puede usar movimientos de sonido.


func on_after_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if not target.is_fainted():
		engine.remove_volatile(target, &"throatchop")
		engine.add_volatile(target, &"throatchop")
