extends BattleEffect
## Desarme: 1,5 veces más fuerte si el objetivo lleva un objeto que se pueda quitar, y se lo quita.
## Al acabar un combate contra entrenadores, el jugador lo recupera.


func base_power(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, power: int) -> int:
	return DamageCalc.modify(power, 1.5) if engine.item_removable(target) else power


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if user.is_fainted() or not engine.item_removable(target):
		return
	var item := DataDB.item(target.pokemon.held_item).name
	engine.set_held_item(target, &"")
	engine.message(tr("¡%s ha perdido su %s!") % [engine.name_of(target), item])
