extends BattleEffect
## Proliferación: hasta 10 golpes, cada uno con su comprobación de precisión (con Dado Trucado, 4 a 10 sin comprobar).


func hit_count(engine: BattleEngine, user: Battler, _target: Battler, move: MoveData) -> int:
	if user.pokemon.held_item == &"loadeddice":
		return engine.rand_int(&"multihit", 4, 10)
	if user.ability == &"skilllink":
		return 10
	var hits := 1
	while hits < 10 and engine.rand_chance(&"accuracy", move.accuracy, 100):
		hits += 1
	return hits
