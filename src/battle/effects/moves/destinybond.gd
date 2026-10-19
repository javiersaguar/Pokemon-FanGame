extends BattleEffect
## Mismo Destino: si el usuario se debilita por un golpe antes de volver a moverse, se lleva al
## atacante consigo. Seguido falla.


func on_try_move(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> bool:
	if bool(user.get_meta(&"destinybond_last", false)):
		user.set_meta(&"destinybond_last", false)
		engine.message(tr("¡Pero falló!"))
		return false
	return true


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	engine.add_volatile(user, &"destinybond", user)
	user.set_meta(&"destinybond_last", true)
	return HANDLED
