class_name RandomizerSettings
extends RefCounted
## Ajustes de una ROM de RandomLocke (Fase R.3 y R.7). Los presets están en data/randomizer.json.
## El orden y el tamaño de los campos de FIELDS forman parte del código de semilla: si se cambian,
## hay que subir Randomizer.GENERATOR_VERSION.

const STARTER_MODES: Array[String] = ["off", "random", "triangle", "three_stage"]
const WILD_MODES: Array[String] = ["off", "per_zone", "global", "chaos"]
const LEARNSET_MODES: Array[String] = ["off", "random", "type_preference"]
## Presets con número fijo para el código de semilla (7 = personalizado).
const PRESETS: Array[String] = ["clasico", "solo_aleatorio", "caos"]
const CUSTOM := "personalizado"

## [nombre, tipo, bits]. Tipos: "enum:<lista>", "bool", "int".
const FIELDS: Array[Array] = [
	["starters", "enum:starters", 2],
	["wild", "enum:wild", 2],
	["trainers", "bool", 1],
	["keep_type_themes", "bool", 1],
	["story_pokemon", "bool", 1],
	["allow_legendaries", "bool", 1],
	["learnsets", "enum:learnsets", 2],
	["guarantee_stab", "bool", 1],
	["scaled_power", "bool", 1],
	["abilities", "bool", 1],
	["types", "bool", 1],
	["base_stats", "bool", 1],
	["evolutions", "bool", 1],
	["items", "bool", 1],
	["shops", "bool", 1],
	["similar_strength", "bool", 1],
	["strength_tolerance", "int", 7],
	["level_appropriate", "bool", 1],
	["no_early_legendaries", "bool", 1],
	["only_implemented_moves", "bool", 1],
	["locke_rules", "bool", 1],
]

var starters: String = "triangle"
var wild: String = "per_zone"
var trainers: bool = true
var keep_type_themes: bool = true
## Regalos, estáticos e intercambios.
var story_pokemon: bool = true
var allow_legendaries: bool = false
var learnsets: String = "type_preference"
var guarantee_stab: bool = true
var scaled_power: bool = true
var abilities: bool = false
var types: bool = false
var base_stats: bool = false
var evolutions: bool = false
var items: bool = true
var shops: bool = false
var similar_strength: bool = true
## ±% del total de estadísticas base (0-100).
var strength_tolerance: int = 15
var level_appropriate: bool = true
var no_early_legendaries: bool = true
var only_implemented_moves: bool = true
var locke_rules: bool = true
## Nombre del preset del que salen (o "personalizado").
var preset: String = "clasico"


static func from_preset(preset_name: String) -> RandomizerSettings:
	var s := RandomizerSettings.new()
	var presets: Dictionary = JsonFile.read_dict(Randomizer.CONFIG_PATH).get("presets", {})
	if not presets.has(preset_name):
		push_error("RandomizerSettings: no existe el preset '%s'." % preset_name)
		return s
	s.apply_dict(presets[preset_name])
	s.preset = preset_name
	return s


func apply_dict(d: Dictionary) -> void:
	for field: Array in FIELDS:
		var key: String = field[0]
		if not d.has(key):
			continue
		match str(field[1]).get_slice(":", 0):
			"bool":
				set(key, bool(d[key]))
			"int":
				set(key, clampi(int(d[key]), 0, (1 << int(field[2])) - 1))
			_:
				set(key, str(d[key]))
	if d.has("preset"):
		preset = str(d["preset"])


func to_dict() -> Dictionary:
	var d := {"preset": preset}
	for field: Array in FIELDS:
		d[field[0]] = get(field[0])
	return d


## ¿Coincide con su preset? (si no, el código de semilla lleva los ajustes completos).
func matches_preset() -> bool:
	if preset not in PRESETS:
		return false
	var reference := RandomizerSettings.from_preset(preset)
	for field: Array in FIELDS:
		if get(field[0]) != reference.get(field[0]):
			return false
	return true


func to_bits() -> int:
	var bits := 0
	var shift := 0
	for field: Array in FIELDS:
		var value := 0
		var kind: String = field[1]
		var raw: Variant = get(field[0])
		if kind == "bool":
			value = 1 if raw else 0
		elif kind == "int":
			value = int(raw)
		else:
			value = maxi(0, _enum_values(kind).find(str(raw)))
		bits |= (value & ((1 << int(field[2])) - 1)) << shift
		shift += int(field[2])
	return bits


static func from_bits(bits: int) -> RandomizerSettings:
	var s := RandomizerSettings.new()
	var shift := 0
	for field: Array in FIELDS:
		var value := (bits >> shift) & ((1 << int(field[2])) - 1)
		shift += int(field[2])
		var kind: String = field[1]
		if kind == "bool":
			s.set(field[0], value == 1)
		elif kind == "int":
			s.set(field[0], value)
		else:
			var values := _enum_values(kind)
			s.set(field[0], values[value] if value < values.size() else values[0])
	s.preset = CUSTOM
	return s


static func total_bits() -> int:
	var n := 0
	for field: Array in FIELDS:
		n += int(field[2])
	return n


static func _enum_values(kind: String) -> Array[String]:
	match kind.get_slice(":", 1):
		"starters":
			return STARTER_MODES
		"wild":
			return WILD_MODES
		"learnsets":
			return LEARNSET_MODES
	return []
