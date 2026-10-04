extends BattleEffect
## Remolino: en un combate salvaje lo termina; contra un entrenador saca a otro de sus Pokémon al azar.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if not engine.force_switch(target):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
