extends BattleEffect
## Reserva: acumula energía hasta tres veces; cada vez sube la Defensa y la Defensa Especial.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if not user.has_volatile(&"stockpile"):
		engine.add_volatile(user, &"stockpile", user, {"layers": 0, "def": 0, "spd": 0})
	var state: Dictionary = user.volatiles[&"stockpile"]
	if int(state["layers"]) >= 3:
		engine.message(tr("¡%s no puede reservar más energía!") % engine.name_of(user))
		return HANDLED
	state["layers"] = int(state["layers"]) + 1
	engine.message(tr("¡%s ha reservado energía (%d)!") % [engine.name_of(user), int(state["layers"])])
	for stat: StringName in [&"def", &"spd"]:
		var before: int = user.boosts[stat]
		engine.boost(user, {stat: 1})
		state[String(stat)] = int(state[String(stat)]) + user.boosts[stat] - before
	return HANDLED
