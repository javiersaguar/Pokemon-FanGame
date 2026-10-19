extends BattleEffect
## Purificación: cura el problema de estado del objetivo y, si lo consigue, el usuario recupera la
## mitad de sus PS.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	if target.pokemon.status == &"":
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.cure_status(target)
	if engine.heal(user, roundi(user.pokemon.max_hp() / 2.0)) > 0:
		engine.message(tr("¡%s ha recuperado PS!") % engine.name_of(user))
	return HANDLED
