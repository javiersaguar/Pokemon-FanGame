extends BattleEffect
## Alboroto: 3 turnos seguidos usando Alboroto; mientras dura, nadie puede dormirse.


func duration(_engine: BattleEngine) -> int:
	return 3


func residual_order() -> int:
	return 28


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s ha montado un alboroto!") % engine.name_of(holder))
	for side_index: int in [BattleEngine.PLAYER, BattleEngine.FOE]:
		var b := engine.active(side_index)
		if b != null and not b.is_fainted() and b.pokemon.status == &"slp":
			engine.message(tr("¡El alboroto ha despertado %s!") % engine.to_name(b))
			engine.cure_status(b)
	return true


func on_residual(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	engine.message(tr("¡%s sigue armando alboroto!") % engine.name_of(holder))


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	if not (holder as Battler).is_fainted():
		engine.message(tr("¡%s se ha calmado!") % engine.name_of(holder))


func on_set_status(engine: BattleEngine, _target: Battler, status: StringName, _source: Battler, announce: bool) -> bool:
	if status != &"slp":
		return true
	if announce:
		engine.message(tr("¡Con este alboroto no hay quien duerma!"))
	return false


func forced_action(engine: BattleEngine, battler: Battler, _state: Dictionary) -> BattleAction:
	return BattleAction.fight(engine.move_index_of(battler, &"uproar"))
