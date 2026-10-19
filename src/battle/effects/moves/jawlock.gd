extends BattleEffect
## Presa Maxilar: mientras los dos sigan en el campo, ninguno puede cambiarse ni huir.


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if user.is_fainted() or target.is_fainted():
		return
	engine.add_volatile(target, &"trapped", user, {"source_side": user.side, "source_party": user.party_index})
	engine.add_volatile(user, &"trapped", target, {"source_side": target.side, "source_party": target.party_index})
	engine.message(tr("¡Ninguno de los dos puede escapar!"))
