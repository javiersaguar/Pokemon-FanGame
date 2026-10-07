class_name RomPatch
extends RefCounted
## "ROM" de RandomLocke = parche sobre los datos base (Fase R.1). Nunca modifica los datos originales:
## se aplica con DataDB.apply_patch(patch.data) y se guarda con la partida (slot_<n>.rom.json).

const KEYS: Array[String] = [
	"starters", "species_map", "encounters", "trainers", "gifts", "statics", "trades",
	"learnsets", "tm_compat", "tm_moves", "tutor_compat", "tutor_moves", "abilities", "species", "items", "shops",
]

## {generator_version, seed, seed_code, settings, starters, species_map, encounters, trainers, ...}.
var data: Dictionary = {}
var input: RandomizerInput
var errors: Array[String] = []


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
	p.errors.assign(d.get("errors", []))
	return p


func to_dict() -> Dictionary:
	var result := data.duplicate(true)
	if not errors.is_empty():
		result["errors"] = errors.duplicate()
	return result


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
	return JSON.stringify(JSON.parse_string(JSON.stringify(to_dict())), "\t", true)


## Aplica la ROM al juego (DataDB). Para quitarla: DataDB.clear_patch().
func apply() -> void:
	if not errors.is_empty() or data.has("errors"):
		push_error("No se puede aplicar una ROM inválida: %s" % str(errors))
		return
	var db: Node = (Engine.get_main_loop() as SceneTree).root.get_node("DataDB")
	db.apply_patch(data)


## Registro de spoilers (Fase R.5): qué ha cambiado, en texto. Solo se enseña si el jugador lo pide;
## la interfaz lo puede exportar a user://randomlocke/<código>_spoilers.txt.
func spoiler_text() -> String:
	return SpoilerLog.render(input if input != null else RandomizerInput.from_datadb(), self)


## Escribe el registro en user://randomlocke/<código>_spoilers.txt. Devuelve la ruta, o "" si falla.
func export_spoilers() -> String:
	var folder := DirAccess.open("user://")
	if folder == null or (not folder.dir_exists("randomlocke") and folder.make_dir("randomlocke") != OK):
		return ""
	var path := "user://randomlocke/%s_spoilers.txt" % seed_code()
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(spoiler_text())
	return path

func canonical_json() -> String:
	return to_json()

func is_valid() -> bool:
	return errors.is_empty() and data.has("input_hash")
