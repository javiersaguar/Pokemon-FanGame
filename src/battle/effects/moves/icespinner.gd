extends BattleEffect
## Pirueta Helada: después de golpear, acaba con el campo que haya.


func on_after_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, _damage: int) -> void:
	if not user.is_fainted() and engine.terrain() != &"":
		engine.clear_terrain()
