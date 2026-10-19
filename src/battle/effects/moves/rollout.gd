extends BattleEffect
## Rodar: rueda cinco turnos seguidos y cada golpe dobla la potencia (el doble si antes usó Rizo
## Defensa). Si falla, se para.


func base_power(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	var hits := int(user.volatiles.get(&"rollout", {}).get("hits", 0))
	var out := power * int(pow(2, hits))
	return out * 2 if user.has_volatile(&"defensecurl") else out


func on_after_move(engine: BattleEngine, user: Battler, move: MoveData, hit: bool) -> void:
	if not hit or user.is_fainted():
		engine.remove_volatile(user, &"rollout")
		return
	if not user.has_volatile(&"rollout"):
		engine.add_volatile(user, &"rollout", user, {"move": String(move.id), "hits": 0})
	var state: Dictionary = user.volatiles[&"rollout"]
	state["hits"] = int(state["hits"]) + 1
	if int(state["hits"]) >= 5:
		engine.remove_volatile(user, &"rollout")
