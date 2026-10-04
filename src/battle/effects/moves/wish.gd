extends BattleEffect
## Deseo: al final del turno siguiente, quien esté en su lugar recupera la mitad de los PS máximos del usuario.


@warning_ignore("integer_division")
func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var data := {"hp": maxi(1, user.pokemon.max_hp() / 2), "wisher": user.pokemon.display_name()}
	if engine.add_side_condition(user.side, &"wish", user, data):
		engine.message(tr("¡%s ha pedido un deseo!") % engine.name_of(user))
	else:
		engine.message(tr("¡Pero falló!"))
	return HANDLED
