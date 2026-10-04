class_name SwitchAfterHitMoveEffect
extends BattleEffect
## Ida y Vuelta, Voltiocambio, Viraje: después de golpear, el usuario se cambia por otro del equipo.


func on_after_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, _damage: int) -> void:
	if not user.is_fainted():
		engine.request_switch(user, &"uturn")
