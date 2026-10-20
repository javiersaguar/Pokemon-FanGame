extends BattleEffect
## En Salazón: 1/8 de los PS al final de cada turno (1/4 a los de tipo Agua o Acero) mientras siga.


func residual_order() -> int:
	return 13


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s está en salazón!") % engine.name_of(holder))
	return true


func on_residual(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	var b := holder as Battler
	if b == null or b.is_fainted():
		return
	var denom := 4 if b.has_type(&"water") or b.has_type(&"steel") else 8
	engine.deal_damage(b, maxi(1, b.pokemon.max_hp() / denom), &"saltcure")
	engine.message(tr("¡%s sufre los efectos de la salazón!") % engine.name_of(b))
