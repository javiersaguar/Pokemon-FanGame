extends BattleEffect
## Patada Salto Alta: si falla (o no afecta), el usuario se estrella y pierde la mitad de sus PS máximos.


func on_miss(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> void:
	if user.is_fainted():
		return
	engine.message(tr("¡%s ha fallado y se ha caído al suelo!") % engine.name_of(user))
	engine.deal_damage(user, maxi(1, roundi(user.pokemon.max_hp() / 2.0)), &"crash")
