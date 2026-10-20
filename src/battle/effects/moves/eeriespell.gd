extends BattleEffect
## Conjuro Funesto: quita 3 PP al último movimiento del objetivo.


func on_after_hit(engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	if target.is_fainted() or target.last_move == &"":
		return
	for slot: MoveSlot in target.pokemon.moves:
		if slot.id == target.last_move and slot.pp > 0:
			slot.pp = maxi(0, slot.pp - 3)
			engine.message(tr("¡%s ha perdido PP!") % engine.name_of(target))
