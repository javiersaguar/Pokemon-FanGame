extends BattleEffect
## Reducción: sube mucho la Evasión (datos) y, mientras siga en el campo, Pisotón, Golpe Cuerpo y
## compañía le hacen el doble.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	engine.add_volatile(user, &"minimize", user)
	return CONTINUE
