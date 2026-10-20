extends BattleEffect
## Envidia Ardiente: quema a quien haya subido alguna característica este turno.


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if not target.is_fainted() and target.raised_turn == engine.turn:
		engine.set_status(target, &"brn", user)
