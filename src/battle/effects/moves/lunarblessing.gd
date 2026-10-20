extends BattleEffect
## Cura 1/4 de los PS y los problemas de estado del usuario y de su aliado.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var any := false
	for b: Battler in [user, engine.ally_of(user)]:
		if b == null or b.is_fainted():
			continue
		if engine.heal(b, maxi(1, b.pokemon.max_hp() / 4), &"move") > 0:
			any = true
		if b.pokemon.status != &"":
			engine.cure_status(b)
			any = true
	if not any:
		engine.message(tr("¡Pero falló!"))
	return HANDLED
