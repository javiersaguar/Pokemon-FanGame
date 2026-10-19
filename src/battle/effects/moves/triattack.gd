extends BattleEffect
## Triataque: un 20 % de las veces quema, paraliza o congela (uno de los tres al azar).


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if target.is_fainted() or not engine.rand_chance(&"secondary", 20, 100):
		return
	var status: StringName = [&"brn", &"par", &"frz"][engine.rand_int(&"triattack", 0, 2)]
	engine.set_status(target, status, user, false)
