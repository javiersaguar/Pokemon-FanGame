extends BattleEffect
## Aguzar: el próximo golpe es crítico seguro (sube su nivel de crítico al máximo mientras dura).


func duration(_engine: BattleEngine) -> int:
	return 2


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	(holder as Battler).crit_stage += 3
	engine.message(tr("¡%s se está concentrando al máximo!") % engine.name_of(holder))
	return true


func on_end(_engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	(holder as Battler).crit_stage = maxi(0, (holder as Battler).crit_stage - 3)


func before_move_priority() -> int:
	return 4


func on_before_move(_engine: BattleEngine, _battler: Battler, state: Dictionary, move: MoveData) -> bool:
	if not move.is_status() and move.id != &"laserfocus":
		state["turns"] = 1
	return true
