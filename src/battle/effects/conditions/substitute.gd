extends BattleEffect
## Sustituto: se lleva el daño de los movimientos (salvo los de sonido) y bloquea los de estado de
## los rivales que no lo atraviesan. Se rompe al quedarse sin PS.


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s ha creado un sustituto!") % engine.name_of(holder))
	return true


func _bypasses(engine: BattleEngine, move: MoveData) -> bool:
	var user: Battler = engine._move_user
	return move == null or move.has_flag(&"sound") or move.has_flag(&"bypasssub") or (user != null and user.ability == &"infiltrator")


func on_try_hit(engine: BattleEngine, target: Battler, _state: Dictionary, user: Battler, move: MoveData) -> bool:
	if not move.is_status() or user == target or _bypasses(engine, move):
		return true
	engine.message(tr("¡Pero falló!"))
	return false


func on_damage(engine: BattleEngine, battler: Battler, state: Dictionary, amount: int, _source: StringName, move: MoveData) -> int:
	var user: Battler = engine._move_user
	if user == battler or _bypasses(engine, move):
		return amount
	var hp := int(state.get("hp", 0))
	var left := hp - amount
	state["hp"] = left
	engine.hit_absorbed = true
	engine.absorbed_damage = mini(amount, hp)
	engine.message(tr("¡El sustituto ha recibido el daño en lugar de %s!") % engine.inner_name_of(battler))
	if left <= 0:
		engine.remove_volatile(battler, &"substitute")
		engine.message(tr("¡El sustituto %s se ha roto!") % engine.of_name(battler))
	return -1
