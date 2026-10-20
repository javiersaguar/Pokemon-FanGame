extends BattleEffect
## Torm. Diamantes: 50 % de subir dos niveles la Defensa del usuario (los datos la daban siempre).


func modify_move(_engine: BattleEngine, _user: Battler, move: MoveData) -> MoveData:
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.self_boosts.clear()
	return copy


func on_after_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, _damage: int) -> void:
	if not user.is_fainted() and engine.rand_chance(&"secondary", 1, 2):
		engine.boost(user, {&"def": 2}, true)
