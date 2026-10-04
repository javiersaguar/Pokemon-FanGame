class_name RomPatch
extends RefCounted
## "ROM" de RandomLocke = parche sobre los datos base (Fase R.1). Nunca modifica los datos originales:
## se aplica con DataDB.apply_patch(patch.data) y se guarda con la partida (slot_<n>.rom.json).

const KEYS: Array[String] = [
	"starters", "species_map", "encounters", "trainers", "gifts", "statics", "trades",
	"learnsets", "tm_compat", "abilities", "species", "items", "shops",
]

## {generator_version, seed, seed_code, settings, starters, species_map, encounters, trainers, ...}.
var data: Dictionary = {}


static func create(seed_value: int, settings: RandomizerSettings) -> RomPatch:
	var p := RomPatch.new()
	p.data = {
		"generator_version": Randomizer.GENERATOR_VERSION,
		"seed": seed_value & 0xFFFFFFFF,
		"seed_code": SeedCode.encode(seed_value, settings),
		"settings": settings.to_dict(),
	}
	for key: String in KEYS:
		p.data[key] = {}
	return p


static func from_dict(d: Dictionary) -> RomPatch:
	var p := RomPatch.new()
	p.data = d.duplicate(true)
	return p


func to_dict() -> Dictionary:
	return data.duplicate(true)


func section(key: String) -> Dictionary:
	if not data.has(key):
		data[key] = {}
	return data[key]


func seed_code() -> String:
	return str(data.get("seed_code", ""))


func generator_version() -> int:
	return int(data.get("generator_version", 0))


func settings() -> RandomizerSettings:
	var s := RandomizerSettings.new()
	s.apply_dict(data.get("settings", {}))
	return s


## JSON estable (claves ordenadas): dos ROM iguales dan exactamente el mismo texto.
func to_json() -> String:
	return JSON.stringify(data, "\t", true)


## Aplica la ROM al juego (DataDB). Para quitarla: DataDB.clear_patch().
func apply() -> void:
	DataDB.apply_patch(data)


## Registro de spoilers (Fase R.5): qué ha cambiado, en texto. Solo se enseña si el jugador lo pide;
## la interfaz lo puede exportar a user://randomlocke/<código>_spoilers.txt.
func spoiler_text() -> String:
	var lines: PackedStringArray = ["Pokémon Panchito · RandomLocke", "Código: %s" % seed_code(), ""]
	var name_of := func(id: Variant) -> String:
		var sid := StringName(str(id))
		return DataDB.species(sid).name if DataDB.has_species(sid) else str(id)
	var starters := section("starters")
	if not starters.is_empty():
		lines.append("Iniciales:")
		for key: String in _sorted(starters):
			lines.append("  %s: %s" % [key, name_of.call(starters[key])])
	for kind: Array in [["gifts", "Regalos"], ["statics", "Encuentros estáticos"]]:
		var table := section(kind[0])
		if not table.is_empty():
			lines.append("%s:" % kind[1])
			for key: String in _sorted(table):
				lines.append("  %s: %s" % [key, name_of.call(table[key])])
	var trainers := section("trainers")
	if not trainers.is_empty():
		lines.append("Entrenadores:")
		for key: String in _sorted(trainers):
			var team: PackedStringArray = []
			for spec: Dictionary in trainers[key].get("party", []):
				team.append("%s Nv. %d" % [name_of.call(spec.get("species", "")), int(spec.get("level", 0))])
			lines.append("  %s: %s" % [key, ", ".join(team)])
	var encounters := section("encounters")
	if not encounters.is_empty():
		lines.append("Zonas:")
		for key: String in _sorted(encounters):
			var species := {}
			for entry: Dictionary in RomValidator._entries(encounters[key]):
				species[name_of.call(entry.get("species", ""))] = true
			var names: Array = species.keys()
			names.sort()
			lines.append("  %s: %s" % [key, ", ".join(PackedStringArray(names))])
	return "\n".join(lines) + "\n"


func _sorted(table: Dictionary) -> Array:
	var keys := table.keys()
	keys.sort()
	return keys
