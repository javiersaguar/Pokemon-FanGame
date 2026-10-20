extends BattleEffect
## Presente: 40, 80 o 120 de potencia (40 %, 30 %, 10 %) o cura 1/4 al objetivo (20 %).


func on_try_move(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> bool:
	_roll = engine.rand_int(&"present", 0, 9)
	if _roll < 2:
		if engine.heal(target, maxi(1, target.pokemon.max_hp() / 4), &"move") <= 0:
			engine.message(tr("¡%s no puede recuperar más PS!") % engine.name_of(target))
		return false
	return true


var _roll := 5


func base_power(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, _power: int) -> int:
	return 120 if _roll == 2 else (80 if _roll < 6 else 40)
