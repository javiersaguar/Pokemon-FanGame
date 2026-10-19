extends BattleEffect
## Escupir: suelta la energía reservada; 100 de potencia por cada vez que se reservó. Falla sin Reserva.


func on_try_move(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> bool:
	if user.has_volatile(&"stockpile") and int(user.volatiles[&"stockpile"].get("layers", 0)) > 0:
		return true
	engine.message(tr("¡Pero no ha conseguido escupir nada!"))
	return false


func base_power(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, _power: int) -> int:
	return 100 * int(user.volatiles.get(&"stockpile", {}).get("layers", 1))


func on_after_move(engine: BattleEngine, user: Battler, _move: MoveData, _hit: bool) -> void:
	engine.remove_volatile(user, &"stockpile")
