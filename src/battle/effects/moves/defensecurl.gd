extends BattleEffect
## Rizo Defensa: sube la Defensa (datos) y deja la marca que potencia Desenrollar.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	engine.add_volatile(user, &"defensecurl", user)
	return CONTINUE
