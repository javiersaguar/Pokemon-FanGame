extends BattleEffect
## Grito Dragón: anima al aliado (+1 nivel de crítico, +2 si es de tipo Dragón). Sin aliado falla.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if target == null or target.is_fainted() or not engine.add_volatile(target, &"dragoncheer"):
		engine.message(tr("¡Pero falló!"))
	return HANDLED
