extends BattleEffect
## Alquitranazo: baja la Velocidad (datos) y el objetivo pasa a ser débil al Fuego.


func on_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	if engine.add_volatile(target, &"tarshot"):
		engine.message(tr("¡%s se ha vuelto débil al fuego!") % engine.name_of(target))
	return CONTINUE
