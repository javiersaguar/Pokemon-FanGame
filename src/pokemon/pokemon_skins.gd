class_name PokemonSkins
extends RefCounted
## Rutas de arte predeterminado por especie. Sin entrada aprobada se usa el pack base.

const CONFIG := "res://data/pokemon_skins.json"
const ROOT := "res://assets/sprites/pokemon/"
const VIEWS: Array[String] = ["front", "back", "icons", "followers"]
static var _skins: Dictionary = {}
static var _loaded := false


static func entries() -> Dictionary:
	if not _loaded:
		_loaded = true
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG))
		_skins = data.get("skins", {}) if data is Dictionary else {}
	return _skins.duplicate(true)


static func path(species_id: StringName, view: String, shiny: bool = false, definitions: Dictionary = {}) -> String:
	var folder := view + ("_shiny" if shiny else "")
	var fallback := "%s%s/%s.png" % [ROOT, folder, species_id]
	var all_entries := definitions if not definitions.is_empty() else entries()
	var entry: Variant = all_entries.get(String(species_id), {})
	if entry is not Dictionary or not entry.has(folder):
		return fallback
	var custom: String = str(entry[folder])
	return custom if custom.begins_with("res://") and ResourceLoader.exists(custom) else fallback
