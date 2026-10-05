extends BattleEffect
## Trampa Rocas: al entrar, daño según la efectividad de Roca. También a los que flotan.


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡El equipo %s está rodeado de piedras puntiagudas!") % engine.team_of_name((holder as BattleSide).index))
	return true


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	engine.message(tr("¡Han desaparecido las piedras puntiagudas lanzadas al equipo %s!") % engine.team_of_name((holder as BattleSide).index))


func on_switch_in(engine: BattleEngine, battler: Battler, _state: Dictionary) -> void:
	if battler.is_fainted():
		return
	var effect := DataDB.type_effectiveness(&"rock", battler.types())
	if effect <= 0.0:
		return
	var amount := maxi(1, int(battler.pokemon.max_hp() * effect / 8.0))
	engine.message(tr("¡Unas piedras puntiagudas han dañado a %s!") % engine.name_of(battler))
	engine.deal_damage(battler, amount, &"stealthrock")
