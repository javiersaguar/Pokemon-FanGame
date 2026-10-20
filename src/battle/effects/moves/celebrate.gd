extends BattleEffect
## Celebración: no hace nada en combate.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	engine.message(tr("¡Enhorabuena, %s!") % engine.name_of(user) if id == &"celebrate" else tr("¡Qué alegría hay en el ambiente!"))
	return HANDLED
