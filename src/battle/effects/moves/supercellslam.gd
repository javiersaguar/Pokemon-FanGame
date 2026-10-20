extends BattleEffect
## Supercarga Voltio: si falla, el usuario pierde la mitad de sus PS (como Patada Salto Alta).


func on_miss(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> void:
	if not user.is_fainted():
		engine.message(tr("¡%s ha caído al suelo!") % engine.name_of(user))
		engine.deal_damage(user, maxi(1, user.pokemon.max_hp() / 2), &"crash")
