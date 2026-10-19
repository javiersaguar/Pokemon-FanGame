extends BattleEffect
## Aria Burbuja: después de golpear, cura las quemaduras del objetivo.


func on_after_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if not target.is_fainted() and target.pokemon.status == &"brn":
		engine.cure_status(target)
