class_name LockedMoveEffect
extends BattleEffect
## Golpe, Danza Pétalo, Enfado: se repiten 2-3 turnos seguidos y al acabar el usuario se queda confuso.
## La cuenta la lleva el volátil "lockedmove" (conditions/lockedmove.gd), igual que en Showdown: cada
## golpe que acierta lo pone o lo renueva, y tras el último turno del arrebato se quita.


func on_after_move(engine: BattleEngine, user: Battler, move: MoveData, hit: bool) -> void:
	if user.is_fainted():
		return
	if hit:
		if not user.has_volatile(&"lockedmove"):
			engine.add_volatile(user, &"lockedmove", user, {"move": String(move.id)})
		else:
			var started: Dictionary = user.volatiles[&"lockedmove"]
			if int(started["true_turns"]) >= 2:
				started["turns"] = 2
	if user.has_volatile(&"lockedmove") and int(user.volatiles[&"lockedmove"]["turns"]) == 1:
		engine.remove_volatile(user, &"lockedmove")
