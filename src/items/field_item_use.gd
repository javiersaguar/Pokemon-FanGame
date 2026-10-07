class_name FieldItemUse
extends RefCounted
## Usos del inventario del MVP, sin recalcular estadísticas ni efectos de combate.
static func can_use(item_id: StringName, p: Pokemon = null, move_index := -1) -> bool:
	if not DataDB.has_item(item_id) or not (GameState.bag is Bag) or not GameState.bag.has(item_id): return false
	var item := DataDB.item(item_id)
	if item.pocket == &"machines":
		if p == null: return false
		if GameState.locke != null and GameState.locke.rules.snapshot().deaths.has(p.uid): return false
		var taught := MoveLessons.machine_move(item_id)
		return taught != &"" and MoveLessons.can_learn_machine(p.species_id,taught) and not p.has_move(taught) and (p.moves.size() < Pokemon.MAX_MOVES or (move_index >= 0 and move_index < p.moves.size()))
	if not item.usable_in_field(): return false
	if item.effect == &"repel": return int(item.param("steps", 0)) > 0
	if p == null: return false
	if GameState.locke != null and GameState.locke.rules.snapshot().deaths.has(p.uid): return false
	match item.effect:
		&"heal_hp": return not p.is_fainted() and p.current_hp < p.max_hp()
		&"heal_and_cure": return not p.is_fainted() and (p.current_hp < p.max_hp() or p.status != &"")
		&"cure_status": return not p.is_fainted() and String(p.status) in item.param("statuses", [])
		&"revive":
			var permadeath := GameState.locke != null and bool(GameState.locke.rules.snapshot().rules.get("permadeath", true))
			return p.is_fainted() and not permadeath
		&"restore_pp":
			for i: int in p.moves.size():
				if (move_index < 0 or i == move_index) and p.moves[i].pp < p.moves[i].max_pp(): return true
	return false

static func use(item_id: StringName, p: Pokemon = null, move_index := -1) -> Error:
	if not can_use(item_id, p, move_index): return ERR_UNAVAILABLE
	var item := DataDB.item(item_id)
	if item.pocket == &"machines":
		if not MoveLessons.use_machine(p,item_id,move_index): return ERR_UNAVAILABLE
		GameState.bag.remove(item_id)
		return OK
	match item.effect:
		&"repel": GameState.set_var(&"repel_steps", int(item.param("steps", 100)))
		&"heal_hp", &"heal_and_cure":
			var amount := int(item.param("amount", 0))
			if item.effect_params.has("fraction"): amount = maxi(1, roundi(p.max_hp() * float(item.param("fraction"))))
			p.heal(amount)
			if item.effect == &"heal_and_cure": p.cure_status()
		&"cure_status": p.cure_status()
		&"revive": p.revive(float(item.param("fraction", 0.5)))
		&"restore_pp":
			for i: int in p.moves.size():
				if bool(item.param("all_moves", false)) or i == move_index or (move_index < 0 and p.moves[i].pp < p.moves[i].max_pp()):
					p.moves[i].restore(-1 if bool(item.param("full", false)) else int(item.param("amount", 10)))
					if not bool(item.param("all_moves", false)): break
	GameState.bag.remove(item_id)
	return OK
