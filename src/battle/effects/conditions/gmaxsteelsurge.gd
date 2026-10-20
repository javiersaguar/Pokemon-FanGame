extends BattleEffect
## Acero Gigamax: púas de acero en el campo rival; al entrar, daño según la efectividad de Acero.


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡El equipo %s está rodeado de púas de acero!") % engine.team_of_name((holder as BattleSide).index))
	return true


func on_switch_in(engine: BattleEngine, battler: Battler, _state: Dictionary) -> void:
	if battler.is_fainted() or battler.pokemon.held_item == &"heavydutyboots":
		return
	var effect := DataDB.type_effectiveness(&"steel", battler.types())
	if effect <= 0.0:
		return
	engine.message(tr("¡Unas púas de acero han dañado a %s!") % engine.name_of(battler))
	engine.deal_damage(battler, maxi(1, int(battler.pokemon.max_hp() * effect / 8.0)), &"stealthrock")
