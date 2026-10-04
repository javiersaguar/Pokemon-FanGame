class_name SpoilerLog
extends RefCounted

static func render(input: RandomizerInput, patch: RomPatch) -> String:
	var lines: PackedStringArray = ["Pokémon Panchito · RandomLocke", "Código: %s" % patch.seed_code(), "Generador: %d" % patch.generator_version(), ""]
	for group: Array in [["starters", "Iniciales"], ["gifts", "Regalos"], ["statics", "Encuentros estáticos"]]:
		var table := patch.section(group[0])
		if not table.is_empty():
			lines.append(group[1] + ":")
		for id: String in _ids(table):
			lines.append("  %s: %s" % [id, _name(input, table[id])])
	if not patch.section("trainers").is_empty():
		lines.append("Entrenadores:")
	for id: String in _ids(patch.section("trainers")):
		var team: PackedStringArray = []
		for pokemon: Dictionary in patch.section("trainers")[id].get("party", []):
			team.append("%s Nv. %d" % [_name(input, pokemon.species), int(pokemon.level)])
		lines.append("  %s: %s" % [id, ", ".join(team)])
	if not patch.section("encounters").is_empty():
		lines.append("Zonas:")
	for id: String in _ids(patch.section("encounters")):
		var table: Dictionary = patch.section("encounters")[id]
		var names: Dictionary = {}
		for row: Dictionary in RomValidator._entries(table):
			names[_name(input, row.species)] = true
		lines.append("  %s (%s): %s" % [id, table.get("zone_id", id), ", ".join(_ids(names))])
	for section: String in ["trades", "tm_moves", "tutor_moves", "items", "shops", "species", "abilities", "learnsets", "tm_compat", "tutor_compat"]:
		if patch.section(section).is_empty():
			continue
		lines.append("Cambios de %s:" % section)
		for id: String in _ids(patch.section(section)):
			lines.append("  %s: %s" % [id, JSON.stringify(patch.section(section)[id], "", true)])
	lines.append("Ajustes: " + JSON.stringify(patch.data.get("settings", {}), "", true))
	return "\n".join(lines) + "\n"
static func _ids(table: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	ids.assign(table.keys())
	ids.sort()
	return ids
static func _name(input: RandomizerInput, id: Variant) -> String:
	return input.species(StringName(str(id))).name if input.has_species(StringName(str(id))) else str(id)
