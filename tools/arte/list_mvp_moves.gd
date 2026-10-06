extends SceneTree
var pairs: Dictionary = {}
var moves: Dictionary = {}
func _initialize() -> void:
	run.call_deferred()
func collect_rows(value: Variant) -> void:
	if value is Dictionary:
		if value.has("species"):
			var species := str(value.species)
			var minimum := int(value.get("min", value.get("level",5)))
			var maximum := int(value.get("max",minimum))
			for level: int in range(minimum,maximum+1): pairs[species+":"+str(level)] = {"species":species,"level":level,"moves":value.get("moves",[])}
		else:
			for key: Variant in value: collect_rows(value[key])
	elif value is Array:
		for row: Variant in value: collect_rows(row)
func run() -> void:
	await process_frame
	var db = root.get_node("DataDB")
	for id: StringName in db.trainer_ids(): collect_rows(db.trainer(id).get("party",[]))
	for id: StringName in db.encounter_ids(): collect_rows(db.encounter_table(id))
	for id: StringName in db.starter_ids(): collect_rows(db.starter_spec(id))
	for id: StringName in db.gift_ids(): collect_rows(db.gift(id))
	for id: StringName in db.static_ids(): collect_rows(db.static_encounter(id))
	for spec: Dictionary in pairs.values():
		var selected = spec.moves if not spec.moves.is_empty() else db.default_moves(StringName(spec.species), spec.level)
		for id: Variant in selected:
			var detail = db.move(StringName(id))
			moves[str(id)] = {"name":detail.name,"type":str(detail.type),"category":["physical","special","status"][detail.category]}
	var ids: Array = moves.keys(); ids.sort()
	var sorted: Dictionary = {}
	for id: String in ids: sorted[id] = moves[id]
	var f := FileAccess.open("res://data/battle_motion_mvp.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"scope":"Equipo inicial de entrenadores, iniciales y todos los niveles configurados de encuentros/regalos/estáticos; niveles posteriores usan genéricas.","moves":sorted},"  ")+"\n")
	print(sorted)
	quit()
