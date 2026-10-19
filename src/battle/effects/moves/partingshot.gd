extends BattleEffect
## Última Palabra: baja el Ataque y el Ataque Especial del objetivo (datos) y el usuario se cambia.


func on_after_move(engine: BattleEngine, user: Battler, _move: MoveData, hit: bool) -> void:
	if hit and not user.is_fainted():
		engine.request_switch(user, &"uturn")
