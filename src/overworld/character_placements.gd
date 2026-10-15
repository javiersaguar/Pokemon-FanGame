class_name CharacterPlacements
extends RefCounted
## Personajes colocados por datos (data/personajes_en_el_mapa.json): famosos, líderes de gimnasio y sus
## entrenadores. Se añaden a Entities al preparar el mapa (MapLoader.prepare), así que no hace falta
## tocar los mapas pintados. Con "requiere", solo salen si tienes esas medallas o ese flag. Las casillas las calcula maps/_tools/colocar_personajes.gd (la libre y
## alcanzable más cercana al sitio que dice "cerca") y un test comprueba que siguen libres.

const DATA := "res://data/personajes_en_el_mapa.json"
const TRAINER_SCENE := "res://src/overworld/trainers/trainer_npc.tscn"
const NPC_SCENE := "res://src/overworld/npc/npc.tscn"
const LEADER_EVENT := "res://src/events/gym_leader_event.gd"
## Combates seguidos ("serie"), premio al ganar ("premio") y detención ("detencion"): ver el evento.
const PERSONAJE_EVENT := "res://src/events/personajes/personaje_event.gd"
const EVENT_OPTIONS: Array[String] = ["serie", "premio", "detencion"]
const FACING := {"abajo": 0, "izquierda": 1, "derecha": 2, "arriba": 3}

static var _by_map: Dictionary = {}
static var _loaded := false


## Entradas colocadas en `map_id` (con "casilla" ya calculada).
static func for_map(map_id: StringName) -> Array:
	if not _loaded:
		_loaded = true
		_by_map.clear()
		for entry: Dictionary in JsonFile.read_dict(DATA).get("colocados", []):
			if entry.has("casilla"):
				var key := StringName(str(entry["mapa"]))
				if not _by_map.has(key):
					_by_map[key] = []
				_by_map[key].append(entry)
	return _by_map.get(map_id, [])


## Sale si cumple su "requiere" ({"medallas": n}: al menos n medallas; {"flag": "..."}: flag activo) y
## todavía no ha llegado su "hasta" (con esas medallas o ese flag se va: las obras de la A-6, por ejemplo).
static func is_available(entry: Dictionary) -> bool:
	var needs: Dictionary = entry.get("requiere", {})
	if GameState.badges.size() < int(needs.get("medallas", 0)):
		return false
	if needs.has("flag") and not GameState.flag(StringName(str(needs["flag"]))):
		return false
	var until: Dictionary = entry.get("hasta", {})
	if until.has("medallas") and GameState.badges.size() >= int(until["medallas"]):
		return false
	return not (until.has("flag") and GameState.flag(StringName(str(until["flag"]))))


static func node_name(entry: Dictionary) -> String:
	return "Personaje_" + str(entry["id"])


static func has_event_options(entry: Dictionary) -> bool:
	for key: String in EVENT_OPTIONS:
		if entry.has(key):
			return true
	return false


## Las opciones del evento de personaje de una entrada ("serie", "premio", "detencion").
static func event_options(entry: Dictionary) -> Dictionary:
	var out := {}
	for key: String in EVENT_OPTIONS:
		if entry.has(key):
			out[key] = entry[key]
	return out


## Añade los personajes de su mapa a Entities (antes de entrar al árbol). Con "sustituye", el personaje
## ocupa el sitio de un nodo del mapa pintado (el vecino «Javier» de San Miguel, por ejemplo), que se quita
## cuando el personaje sale.
static func apply(map: MapRoot) -> void:
	var entities := map.get_entities()
	if entities == null:
		return
	var entries := for_map(map.get_map_id())
	# Las opciones de evento valen para la pareja entera: si una de las dos las tiene, las dos usan el evento.
	var with_options := {}
	for entry: Dictionary in entries:
		if has_event_options(entry):
			with_options[str(entry["id"])] = true
			if entry.has("pareja"):
				with_options[str(entry["pareja"])] = true
	for entry: Dictionary in entries:
		var name := node_name(entry)
		if entities.has_node(name) or not is_available(entry):
			continue
		var replaced: Node = entities.get_node_or_null(NodePath(str(entry["sustituye"]))) if entry.has("sustituye") else null
		if replaced != null:
			entities.remove_child(replaced)
			replaced.free()
		var is_trainer := entry.has("entrenador")
		var node: Node2D = (load(TRAINER_SCENE if is_trainer else NPC_SCENE) as PackedScene).instantiate()
		node.name = name
		var cell: Array = entry["casilla"]
		node.position = Grid.to_world(Vector2i(int(cell[0]), int(cell[1])))
		node.set(&"initial_facing", int(FACING.get(str(entry.get("mira", "abajo")), 0)))
		if is_trainer:
			node.set(&"trainer_id", StringName(str(entry["entrenador"])))
			node.set(&"sight_range", int(entry.get("vista", 0)))
			if entry.has("pareja"):
				node.set(&"partner", NodePath("../Personaje_" + str(entry["pareja"])))
			if bool(entry.get("lider", false)):
				node.set(&"challenge_event", load(LEADER_EVENT))
			elif with_options.has(str(entry["id"])):
				node.set(&"challenge_event", load(PERSONAJE_EVENT))
				node.set_meta(&"personaje", event_options(entry))
		else:
			node.set(&"sprite_sheet", load("res://assets/sprites/characters/%s.png" % str(entry["sprite"])))
			node.set(&"lines", PackedStringArray(entry.get("frases", [])))
		entities.add_child(node)
