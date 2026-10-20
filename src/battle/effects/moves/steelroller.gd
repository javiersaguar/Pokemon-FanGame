extends BattleEffect
## Allanador: falla sin campo; si golpea, lo quita.


func on_try_move(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData) -> bool:
	if engine.terrain() == &"":
		engine.message(tr("¡Pero falló!"))
		return false
	return true


func on_after_hit(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, _damage: int) -> void:
	engine.clear_terrain()
