extends BattleEffect
## Puño Certero: se concentra al empezar el turno y golpea al final; si antes le dan un golpe, pierde
## la concentración y no se mueve.


func before_turn(engine: BattleEngine, user: Battler, _move: MoveData) -> void:
	engine.message(tr("¡%s se está concentrando!") % engine.name_of(user))


func on_try_move(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> bool:
	var hurt := user.hurt_by
	if not hurt.is_empty() and int(hurt["turn"]) == engine.turn:
		engine.message(tr("¡%s ha perdido la concentración y no se ha podido mover!") % engine.name_of(user))
		return false
	return true
