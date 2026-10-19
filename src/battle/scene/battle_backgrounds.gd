class_name BattleBackgrounds
extends RefCounted
## Qué fondo de combate toca en cada sitio (data/battle_backgrounds.json). Lógica pura: el mapa se
## describe con su id, si es exterior y su nombre, así que el test puede recorrer todos los mapas
## sin cargarlos. SceneManager.prepare_battle() lo usa al empezar cada combate.

const DATA := "res://data/battle_backgrounds.json"
const DIR := "res://assets/sprites/ui/battle/backgrounds/"
const LAYERS_DIR := DIR + "capas/"
const BASES_DIR := "res://assets/sprites/ui/battle/bases/"
## Métodos de pesca (FieldEncounters): el combate es en el agua.
const FISHING: Array[String] = ["oldrod", "goodrod", "superrod", "fishing"]

const INTERIORS_DIR := "res://data/interiores/"

static var _data: Dictionary = {}
## Sala → tipo (casa, bar, museo...) de data/interiores/<ciudad>.json.
static var _room_types: Dictionary = {}


static func data() -> Dictionary:
	if _data.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA))
		_data = parsed if parsed is Dictionary else {}
	return _data


static func has_scene(id: StringName) -> bool:
	return data().get("escenas", {}).has(String(id))


## La escena (fondo, capas, frente, cielo, tono, base, entorno). Los ids antiguos (grass, cave...)
## siguen valiendo.
static func scene(id: StringName) -> Dictionary:
	var scenes: Dictionary = data().get("escenas", {})
	var key := String(id)
	if not scenes.has(key):
		key = String(data().get("antiguos", {}).get(key, data().get("por_defecto", "hierba")))
	return scenes.get(key, {})


static func resolve_id(id: StringName) -> StringName:
	if has_scene(id):
		return id
	return StringName(data().get("antiguos", {}).get(String(id), data().get("por_defecto", "hierba")))


static func scene_ids() -> Array[StringName]:
	var out: Array[StringName] = []
	for key: String in data().get("escenas", {}):
		out.append(StringName(key))
	return out


## Momento del día → {cielo, tono, sol, nubes, estrellas}.
static func period(id: StringName) -> Dictionary:
	var periods: Dictionary = data().get("periodos", {})
	return periods.get(String(id), periods.get("day", {}))


## Escena de un mapa: {"escena": id, "regla": cómo se ha decidido}. La regla "defecto" quiere decir
## que ninguna regla lo cubre (el test lo prohíbe).
static func for_map(map_id: String, outdoor: bool, display_name: String = "") -> Dictionary:
	var d := data()
	var by_map: Dictionary = d.get("mapas", {})
	if by_map.has(map_id):
		return {"escena": StringName(by_map[map_id]), "regla": "mapa"}
	var city := map_id.get_slice("/", 0)
	var room := map_id.get_slice("/", 1)
	if room.begins_with("gimnasio_") and d.get("gimnasios", {}).has(city):
		return {"escena": StringName(d["gimnasios"][city]), "regla": "gimnasio"}
	for prefix: String in d.get("prefijos", {}):
		if map_id.begins_with(prefix):
			return {"escena": StringName(d["prefijos"][prefix]), "regla": "prefijo"}
	if outdoor:
		var outdoors: Dictionary = d.get("exteriores", {})
		if outdoors.has(map_id):
			return {"escena": StringName(outdoors[map_id]), "regla": "exterior"}
	else:
		var kind := room_type(map_id)
		if kind != "" and d.get("tipos_interior", {}).has(kind):
			return {"escena": StringName(d["tipos_interior"][kind]), "regla": "tipo:" + kind}
		var text := " %s %s " % [_plain(display_name), _plain(room.replace("_", " "))]
		for rule: Dictionary in d.get("interiores", []):
			for key: String in rule["claves"]:
				if text.contains(key):
					return {"escena": StringName(rule["escena"]), "regla": "interior:" + key}
	return {"escena": StringName(d.get("por_defecto", "hierba")), "regla": "defecto"}


## Tipo de sala que le da data/interiores/<ciudad>.json ("" si no está personalizada).
static func room_type(map_id: String) -> String:
	if _room_types.is_empty():
		_room_types["_"] = ""
		for file: String in DirAccess.get_files_at(INTERIORS_DIR):
			if not file.ends_with(".json") or file.begins_with("_"):
				continue
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(INTERIORS_DIR + file))
			var rooms: Variant = parsed.get("interiores", {}) if parsed is Dictionary else {}
			if rooms is Dictionary:
				for key: String in rooms:
					_room_types[key] = String(rooms[key].get("tipo", ""))
	return String(_room_types.get(map_id, ""))


## Escena para un combate que empieza ahora en `map` (MapRoot o null). Surf y pesca van al agua;
## la nieve y la arena bajo los pies del jugador cambian el fondo del exterior.
static func for_battle(map: Node, context: Dictionary = {}, surfing: bool = false, tile: Variant = null) -> StringName:
	if surfing or String(context.get("method", "")) in FISHING:
		return &"agua"
	if map == null or not map.has_method("get_map_id") or map.data == null:
		return StringName(data().get("por_defecto", "hierba"))
	var info := for_map(String(map.get_map_id()), map.data.outdoor, map.data.display_name)
	var id: StringName = info["escena"]
	if map.data.outdoor and tile is Vector2i and map.has_method("terrain_at"):
		var terrain := String(map.terrain_at(tile))
		if terrain == "water":
			return &"agua"
		if terrain == "snow" and id != &"nieve":
			return &"nieve"
		if terrain == "sand" and id not in [&"playa", &"desierto", &"gimnasio_playa_del_ingles"]:
			return &"playa"
	return id


static func backdrop_path(id: StringName) -> String:
	return DIR + String(scene(id).get("fondo", "field")) + ".png"


static func front_path(id: StringName) -> String:
	var front := String(scene(id).get("frente", ""))
	return "" if front.is_empty() else DIR + front + ".png"


static func layer_path(name: String) -> String:
	return LAYERS_DIR + name + ".png"


static func base_path(id: StringName) -> String:
	return BASES_DIR + String(scene(id).get("base", "default")) + ".png"


## Todos los archivos que necesita una escena (el test comprueba que existen).
static func files(id: StringName) -> PackedStringArray:
	var s := scene(id)
	var out := PackedStringArray([backdrop_path(id), base_path(id)])
	if not front_path(id).is_empty():
		out.append(front_path(id))
	for layer: Dictionary in s.get("capas", []):
		out.append(layer_path(String(layer["img"])))
	if bool(s.get("cielo", false)):
		for p: String in data().get("periodos", {}):
			out.append(layer_path(String(period(StringName(p))["cielo"])))
		out.append_array([layer_path("sol"), layer_path("estrella")])
	return out


static func _plain(text: String) -> String:
	var out := text.to_lower()
	for pair: Array in [["á", "a"], ["é", "e"], ["í", "i"], ["ó", "o"], ["ú", "u"], ["ü", "u"], ["ñ", "n"], ["à", "a"], ["è", "e"], ["ò", "o"], ["ï", "i"], ["ç", "c"], ["·", " "], [",", " "]]:
		out = out.replace(pair[0], pair[1])
	return out
