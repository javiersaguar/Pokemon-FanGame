class_name LockedMoveEffect
extends BattleEffect
## Golpe, Danza Pétalo, Enfado: se repiten 2-3 turnos seguidos y al acabar el usuario se queda confuso.


func on_after_move(engine: BattleEngine, user: Battler, move: MoveData, hit: bool) -> void:
	if user.is_fainted():
		return
	if not user.has_volatile(&"lockedmove"):
		if hit:
			engine.add_volatile(user, &"lockedmove", user, {"move": String(move.id), "uses_left": engine.rand_int(&"lockedmove_turns", 2, 3) - 1})
		return
	var state: Dictionary = user.volatiles[&"lockedmove"]
	state["uses_left"] = int(state["uses_left"]) - 1
	if not hit or int(state["uses_left"]) <= 0:
		engine.remove_volatile(user, &"lockedmove")
		if hit and not user.has_volatile(&"confusion"):
			engine.message(tr("¡%s está agotado!") % engine.name_of(user))
			engine.confuse(user, user, false)
