extends BattleEffect
## Púas: 1/8, 1/6 o 1/4 de los PS al entrar, si toca el suelo. Hasta 3 capas.


func on_start(engine: BattleEngine, holder: Variant, state: Dictionary, _source: Battler) -> bool:
	state["layers"] = maxi(1, int(state.get("layers", 1)))
	engine.message(tr("¡El equipo %s ha sido rodeado de púas!") % engine.team_of_name((holder as BattleSide).index))
	return true


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	engine.message(tr("¡Las púas lanzadas al equipo %s han desaparecido!") % engine.team_of_name((holder as BattleSide).index))


func on_switch_in(engine: BattleEngine, battler: Battler, state: Dictionary) -> void:
	if not engine.is_grounded(battler) or battler.is_fainted():
		return
	var layers := clampi(int(state.get("layers", 1)), 1, 3)
	var denoms: Array[int] = [8, 6, 4]
	var denom: int = denoms[layers - 1]
	engine.message(tr("¡%s es herido por las púas!") % engine.name_of(battler))
	engine.deal_damage(battler, maxi(1, battler.pokemon.max_hp() / denom), &"spikes")
