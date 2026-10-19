class_name ProtectVariantConditionEffect
extends BattleEffect
## Protección con castigo (un turno): bloquea lo que respeta Protección y castiga al que la toca.

## false = solo bloquea los movimientos que hacen daño (Escudo Real, Telatrampa, Obstrucción).
var blocks_status: bool = true


func duration(_engine: BattleEngine) -> int:
	return 1


func residual_order() -> int:
	return 99


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s se está protegiendo!") % engine.name_of(holder))
	return true


func on_try_hit(engine: BattleEngine, target: Battler, _state: Dictionary, user: Battler, move: MoveData) -> bool:
	if not move.has_flag(&"protect") or (move.is_status() and not blocks_status):
		return true
	engine.message(tr("¡%s se ha protegido!") % engine.name_of(target))
	if move.has_flag(&"contact") and not user.is_fainted():
		punish(engine, user)
	return false


## Lo que le pasa al que la toca.
func punish(_engine: BattleEngine, _user: Battler) -> void:
	pass
