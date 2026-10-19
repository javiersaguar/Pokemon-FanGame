extends BattleEffect
## Carga: el siguiente movimiento de tipo Eléctrico tiene el doble de potencia. Sube la Defensa
## Especial (eso va en los datos).


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	engine.remove_volatile(user, &"charge")
	engine.add_volatile(user, &"charge", user)
	return CONTINUE
