extends BattleEffect
## Canto Mortal: cuenta atrás de 3; al llegar a 0 se debilita.


func residual_order() -> int:
	return 24


func on_start(_engine: BattleEngine, _holder: Variant, state: Dictionary, _source: Battler) -> bool:
	state["count"] = 4
	return true


func on_residual(engine: BattleEngine, holder: Variant, state: Dictionary) -> void:
	var b := holder as Battler
	state["count"] = int(state["count"]) - 1
	engine.message(tr("¡La cuenta atrás de %s ha bajado a %d!") % [engine.inner_name_of(b), int(state["count"])])
	if int(state["count"]) <= 0:
		engine.deal_damage(b, b.pokemon.current_hp, &"perishsong")
