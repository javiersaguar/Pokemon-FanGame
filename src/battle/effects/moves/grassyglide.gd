extends BattleEffect
## Fitoimpulso: prioridad +1 con Campo de Hierba si el usuario toca el suelo.


func priority_bonus(engine: BattleEngine, user: Battler, _move: MoveData) -> int:
	return 1 if engine.terrain() == &"grassyterrain" and engine.is_grounded(user) else 0
