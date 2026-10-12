extends RefCounted
func report() -> Dictionary:
	var ability_rows: Array[Dictionary] = []
	var move_rows: Array[Dictionary] = []
	var ability_ids: Array = DataDB._abilities.keys().map(func(id: StringName) -> String: return String(id))
	ability_ids.sort()
	var registered := 0
	var missing_descriptions := 0
	for id: StringName in ability_ids:
		var a := DataDB.ability(id)
		var effect := Effects.ability(id) != null
		if effect: registered += 1
		if a.description.is_empty(): missing_descriptions += 1
		var species: Array[String] = []
		for sid: StringName in DataDB.species_ids():
			if id in DataDB.species(sid).abilities.values(): species.append(String(sid))
		species.sort()
		ability_rows.append({"id":String(id),"num":a.num,"name":a.name,"name_en":a.name_en,"effect_registered":effect,"needs_script":a.needs_script,"description_present":not a.description.is_empty(),"species":species})
	var specific := 0
	var pending_scripts := 0
	var move_ids: Array = DataDB.move_ids().map(func(id: StringName) -> String: return String(id))
	move_ids.sort()
	for id: StringName in move_ids:
		var m := DataDB.move(id)
		var custom := not BattleMoveAnimation.sequence(id).is_empty()
		var effect := Effects.has_move(id)
		if custom: specific += 1
		if m.needs_script and not effect: pending_scripts += 1
		move_rows.append({"id":String(id),"name":m.name,"type":String(m.type),"needs_script":m.needs_script,"effect_registered":effect,"specific_animation":custom})
	return {"summary":{"abilities":ability_rows.size(),"ability_effects_registered":registered,"abilities_without_description":missing_descriptions,"moves":move_rows.size(),"specific_move_animations":specific,"moves_needing_unregistered_script":pending_scripts},"abilities":ability_rows,"moves":move_rows}
