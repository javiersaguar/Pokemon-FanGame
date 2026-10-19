extends BattleEffect
## Contraataque: devuelve el doble del daño físico recibido de un rival en este turno. Si no, falla.

var physical := true
var multiplier := 2.0


func _hurt(engine: BattleEngine, user: Battler) -> Dictionary:
	var hurt := user.hurt_by
	if hurt.is_empty() or int(hurt["turn"]) != engine.turn or int(hurt["side"]) == user.side:
		return {}
	if physical != bool(hurt["physical"]) and multiplier == 2.0:
		return {}
	return hurt


func on_try_move(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> bool:
	if _hurt(engine, user).is_empty():
		engine.message(tr("¡Pero falló!"))
		return false
	return true


func fixed_damage(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var hurt := _hurt(engine, user)
	return maxi(1, int(int(hurt.get("amount", 0)) * multiplier)) if not hurt.is_empty() else -1
