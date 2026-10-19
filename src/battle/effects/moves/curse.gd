extends BattleEffect
## Maldición: si el usuario es de tipo Fantasma, gasta la mitad de sus PS y maldice al objetivo, que
## pierde 1/4 de sus PS cada turno. Si no, sube Ataque y Defensa y baja la Velocidad.


@warning_ignore("integer_division")
func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	if not user.has_type(&"ghost"):
		engine.boost(user, {&"atk": 1, &"def": 1, &"spe": -1})
		return HANDLED
	if target == user:
		target = engine.foe_of(user)
	if target == null or target.is_fainted() or target.has_volatile(&"curse"):
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.deal_damage(user, maxi(1, user.pokemon.max_hp() / 2), &"curse")
	engine.add_volatile(target, &"curse", user)
	engine.message(tr("¡%s ha gastado PS para maldecir %s!") % [engine.name_of(user), engine.to_name(target)])
	return HANDLED
