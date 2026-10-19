extends BattleEffect
## Divide Dolor: el usuario y el objetivo se reparten a medias los PS que les quedan.


@warning_ignore("integer_division")
func on_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData) -> int:
	var average := (user.pokemon.current_hp + target.pokemon.current_hp) / 2
	for b: Battler in [user, target]:
		var goal := mini(average, b.pokemon.max_hp())
		if goal > b.pokemon.current_hp:
			engine.heal(b, goal - b.pokemon.current_hp, &"painsplit")
		elif goal < b.pokemon.current_hp:
			engine.deal_damage(b, b.pokemon.current_hp - goal, &"painsplit")
	engine.message(tr("¡Los dos se han repartido sus PS!"))
	return HANDLED
