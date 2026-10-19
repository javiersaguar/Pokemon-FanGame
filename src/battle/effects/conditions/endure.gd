extends BattleEffect
## Aguante (un turno): un golpe que le debilitaría le deja con 1 PS.


func duration(_engine: BattleEngine) -> int:
	return 1


func residual_order() -> int:
	return 99


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s se ha preparado para aguantar!") % engine.name_of(holder))
	return true


func on_damage(engine: BattleEngine, battler: Battler, _state: Dictionary, amount: int, _source: StringName, _move: MoveData) -> int:
	if amount >= battler.pokemon.current_hp and battler.pokemon.current_hp > 0:
		engine.message(tr("¡%s ha aguantado el golpe!") % engine.name_of(battler))
		return battler.pokemon.current_hp - 1
	return amount
