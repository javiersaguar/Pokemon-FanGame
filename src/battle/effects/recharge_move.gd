class_name RechargeMoveEffect
extends BattleEffect
## Hiperrayo y similares: si golpea, el turno siguiente toca recargar.


func on_after_hit(engine: BattleEngine, user: Battler, _target: Battler, move: MoveData, _damage: int) -> void:
	if not user.is_fainted():
		engine.add_volatile(user, &"mustrecharge", user, {"move": String(move.id)})
