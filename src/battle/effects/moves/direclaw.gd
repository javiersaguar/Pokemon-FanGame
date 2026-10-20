extends BattleEffect
## Garra Nociva: 50 % de envenenar, paralizar o dormir (un tercio cada uno).


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if not target.is_fainted() and target.pokemon.status == &"" and engine.rand_chance(&"secondary", 1, 2):
		engine.set_status(target, [&"psn", &"par", &"slp"][engine.rand_int(&"secondary", 0, 2)], user, true)
