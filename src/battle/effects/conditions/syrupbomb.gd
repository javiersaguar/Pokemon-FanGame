extends BattleEffect
## Bomba Caramelo: baja un nivel de Velocidad al final de cada turno durante tres turnos.


func duration(_engine: BattleEngine) -> int:
	return 4


func residual_order() -> int:
	return 14


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s está cubierto de caramelo!") % engine.name_of(holder))
	return true


func on_residual(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	var b := holder as Battler
	if b != null and not b.is_fainted():
		engine.boost(b, {&"spe": -1}, true)
