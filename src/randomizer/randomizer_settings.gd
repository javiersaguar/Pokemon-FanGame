class_name RandomizerSettings
extends RefCounted
## Ajustes de una ROM de RandomLocke (Fase R.3 y R.7). Los presets están en data/randomizer/presets.json.
## El orden y el tamaño de los campos FIELDS + EXTRA_FIELDS forman parte del código de semilla: si se cambian,
## hay que subir Randomizer.GENERATOR_VERSION.

const STARTER_MODES: Array[String] = ["off", "random", "triangle", "three_stage"]
const WILD_MODES: Array[String] = ["off", "per_zone", "global", "chaos"]
const LEARNSET_MODES: Array[String] = ["off", "random", "type_preference"]
## Presets con número fijo para el código de semilla (7 = personalizado).
const PRESETS: Array[String] = ["clasico", "solo_aleatorio", "caos"]
const CUSTOM := "personalizado"
const EXTRA_FIELDS: Array[Array] = [
	["gifts", "bool", 1], ["statics", "bool", 1], ["trades", "bool", 1],
	["trainer_duplicates", "bool", 1], ["leader_ace", "bool", 1], ["rival_starter", "bool", 1],
	["tm_compat", "bool", 1], ["tm_content", "bool", 1], ["tutor_compat", "bool", 1], ["tutor_content", "bool", 1],
	["tm_percent", "int", 7], ["tutor_percent", "int", 7], ["shiny_denominator", "enum:shiny", 2],
	["first_encounter", "bool", 1], ["permadeath", "bool", 1], ["nickname_required", "bool", 1],
	["duplicates_clause", "bool", 1], ["shiny_clause", "bool", 1], ["gifts_count", "bool", 1], ["statics_count", "bool", 1],
	["level_cap", "bool", 1], ["fixed_battle", "bool", 1], ["battle_items", "enum:items", 2],
	["battle_item_limit", "int", 5], ["game_over", "bool", 1],
]
var gifts: bool = true
var statics: bool = true
var trades: bool = true
var trainer_duplicates: bool = false
var leader_ace: bool = true
var rival_starter: bool = true
var tm_compat: bool = false
var tm_content: bool = false
var tutor_compat: bool = false
var tutor_content: bool = false
var tm_percent: int = 50
var tutor_percent: int = 50
var shiny_denominator: int = 4096
var first_encounter: bool = true
var permadeath: bool = true
var nickname_required: bool = true
var duplicates_clause: bool = true
var shiny_clause: bool = true
var gifts_count: bool = true
var statics_count: bool = true
var level_cap: bool = false
var fixed_battle: bool = false
var battle_items: String = "allowed"
var battle_item_limit: int = 3
var game_over: bool = true
# Preparar antes de lanzar un hilo. Todas las instancias llevan su propia copia.
var preset_reference: Dictionary = {}
static var _preset_catalog: Dictionary = {}


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
	prepare()
	var presets: Dictionary = _preset_catalog
	if preset_name == "caos_panchito":
		preset_name = "caos"
	if not presets.has(preset_name):
		push_error("RandomizerSettings: no existe el preset '%s'." % preset_name)
		return s
	s.apply_dict(presets[preset_name].get("settings", {}))
	s.preset_reference = s.to_dict()
	s.preset = preset_name
	return s


static func prepare() -> void:
	if _preset_catalog.is_empty():
		_preset_catalog = JsonFile.read_dict("res://data/randomizer/presets.json")

func apply_dict(d: Dictionary) -> void:
	for field: Array in FIELDS + EXTRA_FIELDS:
		var key: String = field[0]
		if not d.has(key):
			continue
		match str(field[1]).get_slice(":", 0):
			"bool":
				set(key, bool(d[key]))
			"int":
				set(key, clampi(int(d[key]), 0, (1 << int(field[2])) - 1))
			_:
				set(key, int(d[key]) if key == "shiny_denominator" else str(d[key]))
	if d.has("preset"):
		preset = str(d["preset"])
	if _preset_catalog.has(preset):
		preset_reference = _preset_catalog[preset].get("settings", {}).duplicate(true)


func to_dict() -> Dictionary:
	var d := {"preset": preset}
	for field: Array in FIELDS + EXTRA_FIELDS:
		d[field[0]] = get(field[0])
	return d


## ¿Coincide con su preset? (si no, el código de semilla lleva los ajustes completos).
func matches_preset() -> bool:
	if preset not in PRESETS:
		return false
	if preset_reference.is_empty():
		return false
	for field: Array in FIELDS + EXTRA_FIELDS:
		if get(field[0]) != preset_reference.get(field[0]):
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


static func _enum_values(kind: String) -> Array:
	match kind.get_slice(":", 1):
		"starters":
			return STARTER_MODES
		"wild":
			return WILD_MODES
		"learnsets":
			return LEARNSET_MODES
		"shiny":
			return [4096, 1024, 512, 100]
		"items":
			return ["allowed", "limited", "forbidden"]
	return []

static func defaults() -> Dictionary:
	return RandomizerSettings.new().to_dict()
static func normalize(source: Dictionary) -> Dictionary:
	var s := RandomizerSettings.new()
	s.apply_dict(source)
	return s.to_dict()
static func preset_dict(id: String) -> Dictionary:
	return from_preset(id).to_dict()
static func errors(source: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var keys: Dictionary = {"preset": true}
	for field: Array in FIELDS + EXTRA_FIELDS:
		var key: String = field[0]
		keys[key] = true
		if not source.has(key):
			continue
		var value: Variant = source[key]
		var kind: String = field[1]
		if kind == "bool" and value is not bool:
			result.append("El ajuste %s debe ser booleano." % key)
		elif kind == "int" and (value is not int and value is not float or float(value) != floorf(float(value)) or int(value) < 0 or int(value) > (100 if key.ends_with("percent") or key == "strength_tolerance" else 20)):
			result.append("El ajuste %s está fuera de rango." % key)
		elif kind.begins_with("enum:") and (int(value) if kind == "enum:shiny" and (value is int or value is float and float(value) == floorf(float(value))) else value) not in _enum_values(kind):
			result.append("Opción desconocida para %s." % key)
	for key: Variant in source:
		if not keys.has(key):
			result.append("Ajuste desconocido: %s." % key)
	return result

func payload() -> String:
	var binary := ""
	for field: Array in FIELDS + EXTRA_FIELDS:
		var kind: String = field[1]
		var raw: Variant = get(field[0])
		var value: int = (1 if raw else 0) if kind == "bool" else (int(raw) if kind == "int" else _enum_values(kind).find(raw))
		for bit: int in range(int(field[2]) - 1, -1, -1):
			binary += "1" if value & (1 << bit) else "0"
	while binary.length() % 5 != 0:
		binary += "0"
	var result := ""
	for start: int in range(0, binary.length(), 5):
		var value := 0
		for bit: int in 5:
			value = (value << 1) | (1 if binary[start + bit] == "1" else 0)
		result += SeedCode.ALPHABET[value]
	return result

static func from_payload(payload_text: String) -> RandomizerSettings:
	var binary := ""
	for char: String in payload_text:
		var value := SeedCode.ALPHABET.find(char)
		for bit: int in range(4, -1, -1):
			binary += "1" if value & (1 << bit) else "0"
	var s := RandomizerSettings.new()
	var offset := 0
	for field: Array in FIELDS + EXTRA_FIELDS:
		var value := 0
		for bit: int in int(field[2]):
			value = (value << 1) | (1 if binary[offset + bit] == "1" else 0)
		offset += int(field[2])
		var kind: String = field[1]
		if kind == "bool":
			s.set(field[0], value == 1)
		elif kind == "int":
			s.set(field[0], value)
		else:
			var options := _enum_values(kind)
			if value >= options.size():
				return null
			s.set(field[0], options[value])
	s.preset = CUSTOM
	return s if s.payload() == payload_text and errors(s.to_dict()).is_empty() else null
static func payload_chars() -> int:
	var bits := total_bits()
	for field: Array in EXTRA_FIELDS:
		bits += int(field[2])
	return ceili(bits / 5.0)
