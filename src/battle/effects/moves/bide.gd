extends BattleEffect
## Venganza: aguanta dos turnos y devuelve el doble del daño que le han hecho entretanto.


## En los datos apunta a sí mismo; al soltarla golpea al rival.
func modify_move(_engine: BattleEngine, _user: Battler, move: MoveData) -> MoveData:
	if move.target == &"normal":
		return move
	var copy := MoveData.from_dict(move.id, move.raw)
	copy.target = &"normal"
	return copy


func on_try_move(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> bool:
	if not user.has_volatile(&"bide"):
		engine.add_volatile(user, &"bide", user, {"stored": 0, "left": 2})
		engine.message(tr("¡%s está acumulando energía!") % engine.name_of(user))
		return false
	var state: Dictionary = user.volatiles[&"bide"]
	state["left"] = int(state["left"]) - 1
	if int(state["left"]) > 0:
		engine.message(tr("¡%s está acumulando energía!") % engine.name_of(user))
		return false
	var stored := int(state["stored"])
	engine.remove_volatile(user, &"bide")
	engine.message(tr("¡%s ha liberado la energía acumulada!") % engine.name_of(user))
	if stored <= 0:
		engine.message(tr("¡Pero falló!"))
		return false
	user.set_meta(&"bide_damage", stored * 2)
	return true


func fixed_damage(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	return int(user.get_meta(&"bide_damage", 1))
