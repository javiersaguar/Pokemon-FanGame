extends ProtectVariantConditionEffect
## Barrera Espinosa: quita 1/8 de los PS máximos al que le toca.


@warning_ignore("integer_division")
func punish(engine: BattleEngine, user: Battler) -> void:
	engine.deal_damage(user, maxi(1, user.pokemon.max_hp() / 8), &"spikyshield")
	engine.message(tr("¡%s se ha hecho daño con las espinas!") % engine.name_of(user))
