extends BattleEffect
## Puntada Sombría: el objetivo no puede escapar mientras siga el usuario.


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if not target.is_fainted():
		engine.add_volatile(target, &"trapped", user, {"source_side": user.side, "source_party": user.party_index})
