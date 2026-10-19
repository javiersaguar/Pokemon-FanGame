extends BattleEffect
## Clonatipo: el usuario pasa a tener los tipos del objetivo.


func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	var types := target.types()
	if types.is_empty() or user.tera_active != &"":
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	user.type_override.assign(types)
	engine.message(tr("¡%s ha copiado los tipos %s!") % [engine.name_of(user), engine.of_name(target)])
	return HANDLED
