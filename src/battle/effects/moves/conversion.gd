extends BattleEffect
## Conversión: el usuario pasa a ser del tipo de su primer movimiento.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var t := user.pokemon.moves[0].data().type if not user.pokemon.moves.is_empty() else &""
	if t == &"" or user.types() == [t] or user.tera_active != &"":
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	user.type_override.assign([t])
	engine.message(tr("¡%s ha cambiado de tipo!") % engine.name_of(user))
	return HANDLED
