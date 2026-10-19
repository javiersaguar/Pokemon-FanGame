extends BattleEffect
## Puño Plasma: después de golpear, los movimientos de tipo Normal son de tipo Eléctrico este turno.


func on_after_hit(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, _damage: int) -> void:
	if engine.field_state(&"iondeluge").is_empty():
		engine.set_field_state(&"iondeluge", {"turns": 1})
		engine.message(tr("¡Una lluvia de electrones cae sobre el terreno de combate!"))
