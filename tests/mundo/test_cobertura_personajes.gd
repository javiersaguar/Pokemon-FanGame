extends GutTest
## Cobertura de los personajes: para cada entrenador de data/trainers/*.json comprueba que tiene
## sprite de mapa propio, retrato de combate propio y un sitio en el mundo (data/personajes_en_el_mapa.json,
## un mapa pintado, una sala de gimnasio de maps/_pintura/gimnasios_salas.json o un evento documentado).
## Comprueba también que cada personaje del registro de arte (data/character_art.json) sale en algún sitio.
## Escribe el informe docs/mundo/cobertura_personajes.md y falla si algo falta sin explicación
## documentada en data/personajes_en_el_mapa.json ("pendientes", "por_evento", "sprites_prestados",
## "arte_sin_uso").

const PLACEMENTS := "res://data/personajes_en_el_mapa.json"
const GYM_ROOMS := "res://maps/_pintura/gimnasios_salas.json"
const TRAINERS_DIR := "res://data/trainers"
const REPORT := "res://docs/mundo/cobertura_personajes.md"

var _doc: Dictionary
var _rows: Array[Dictionary] = []
var _npc_rows: Array[Dictionary] = []
var _map_trainers: Dictionary = {}
var _map_art: Dictionary = {}


func before_all() -> void:
	_doc = JsonFile.read_dict(PLACEMENTS)
	_scan_maps()
	_build_rows()
	_build_npc_rows()
	_write_report()


func _scan_maps() -> void:
	var trainer_re := RegEx.create_from_string("trainer_id = &\"([a-z0-9_]+)\"")
	var art_re := RegEx.create_from_string("art_id = &\"([a-z0-9_]+)\"")
	for map_id: StringName in MapRoot.list_all():
		var text := FileAccess.get_file_as_string(MapRoot.path_from_id(map_id))
		for found: RegExMatch in trainer_re.search_all(text):
			_append(_map_trainers, found.get_string(1), String(map_id))
		for found: RegExMatch in art_re.search_all(text):
			_append(_map_art, found.get_string(1), String(map_id))


static func _append(table: Dictionary, key: String, value: String) -> void:
	if not table.has(key):
		table[key] = []
	if not value in table[key]:
		table[key].append(value)


## {id: motivo} de una lista de explicaciones del JSON de colocaciones.
func _explained(section: String) -> Dictionary:
	var out := {}
	for entry: Dictionary in _doc.get(section, []):
		out[str(entry.get("id", ""))] = str(entry.get("motivo", ""))
	return out


func _files_by_trainer() -> Dictionary:
	var out := {}
	var files := Array(DirAccess.get_files_at(TRAINERS_DIR))
	files.sort()
	for file: String in files:
		if not file.ends_with(".json"):
			continue
		for id: String in JsonFile.read_dict(TRAINERS_DIR.path_join(file)):
			if not id.begins_with("_"):
				out[id] = file
	return out


## Dónde sale cada entrenador: [{kind, where}].
func _placements() -> Dictionary:
	var out := {}
	for entry: Dictionary in _doc.get("colocados", []):
		if not entry.has("entrenador"):
			continue
		var cell: Array = entry.get("casilla", [])
		var where := str(entry["mapa"])
		if cell.size() == 2:
			where += " (%d, %d)" % [int(cell[0]), int(cell[1])]
		_add_place(out, str(entry["entrenador"]), "datos", where, str(entry.get("lugar", "")))
	var gyms := JsonFile.read_dict(GYM_ROOMS)
	for city: String in gyms:
		var gym: Dictionary = gyms[city]
		_add_place(out, str(gym.get("lider", "")), "gimnasio", "%s/gimnasio_lider" % city, "Líder del gimnasio")
		var rooms: Array = gym.get("salas", [])
		for index: int in rooms.size():
			for trainer: Dictionary in rooms[index].get("entrenadores", []):
				_add_place(out, str(trainer.get("id", "")), "gimnasio", "%s/gimnasio_%d" % [city, index + 1], str(rooms[index].get("titulo", "")))
	for id: String in _map_trainers:
		for map_id: String in _map_trainers[id]:
			_add_place(out, id, "mapa", map_id, "")
	for entry: Dictionary in _doc.get("por_evento", []):
		_add_place(out, str(entry.get("id", "")), "evento", str(entry.get("archivo", "")), str(entry.get("motivo", "")))
	return out


static func _add_place(table: Dictionary, id: String, kind: String, where: String, note: String) -> void:
	if id.is_empty():
		return
	if not table.has(id):
		table[id] = []
	for place: Dictionary in table[id]:
		if place["kind"] == kind and place["where"].get_slice(" (", 0) == where.get_slice(" (", 0):
			return
	table[id].append({"kind": kind, "where": where, "note": note})


## Sprite de la clase: propio si el archivo se llama como la clase (con _f para la versión de chica).
static func _class_sheet(path: String, class_id: String) -> String:
	if path.is_empty() or not ResourceLoader.exists(path):
		return "FALTA"
	var base := path.get_file().get_basename()
	if base == class_id or base == class_id + "_f":
		return "propio"
	return "PRESTADO (%s)" % path.get_file()


func _build_rows() -> void:
	var files := _files_by_trainer()
	var places := _placements()
	var ids: Array = files.keys()
	ids.sort()
	for id: String in ids:
		var raw := DataDB.trainer(StringName(id))
		var class_id := str(raw.get("class", ""))
		var trainer := TrainerData.get_trainer(StringName(id))
		var art := String(trainer.get("art_id", ""))
		var map_sheet := ""
		var battle := ""
		if art != "" and CharacterArt.walk_frames(StringName(art)).size() == 16 and not CharacterArt.walk_frames(StringName(art)).has(null):
			map_sheet = "atlas `%s`" % art
		else:
			var state := _class_sheet(str(trainer.get("overworld_sprite", "")), class_id)
			map_sheet = "hoja de la clase" if state == "propio" else state
		if art != "" and CharacterArt.battle_texture(StringName(art)) != null:
			battle = "atlas `%s`" % art
		else:
			var state := _class_sheet(str(trainer.get("battle_sprite", "")), class_id)
			battle = "retrato de la clase" if state == "propio" else state
		_rows.append({"id": id, "file": files[id], "class": class_id, "name": str(trainer.get("display_name", id)),
			"map": map_sheet, "battle": battle, "places": places.get(id, [])})


func _build_npc_rows() -> void:
	var used := {}
	for row: Dictionary in _rows:
		used[row["id"]] = true
		used[row["class"]] = true
	var data_npcs := {}
	for entry: Dictionary in _doc.get("colocados", []):
		if not entry.has("entrenador") and entry.has("arte"):
			_append(data_npcs, str(entry["arte"]), "%s (%s)" % [entry["mapa"], str(entry.get("lugar", ""))])
	var entries := CharacterArt.entries()
	var ids: Array = entries.keys()
	ids.sort()
	for id: String in ids:
		if used.has(id):
			continue
		var where: Array = []
		where.append_array(_map_art.get(id, []))
		where.append_array(data_npcs.get(id, []))
		_npc_rows.append({"id": id, "name": str(entries[id].get("name", id)), "where": where})


static func _cell(text: String) -> String:
	return text.replace("|", "/").replace("\n", " ")


func _place_text(places: Array) -> String:
	if places.is_empty():
		return "—"
	var prefixes := {"datos": "", "gimnasio": "sala: ", "mapa": "pintado: ", "evento": "evento: "}
	var parts := PackedStringArray()
	for place: Dictionary in places:
		parts.append(str(prefixes.get(place["kind"], "")) + str(place["where"]))
	return ", ".join(parts)


func _write_report() -> void:
	var pending := _explained("pendientes")
	var borrowed := _explained("sprites_prestados")
	var events := _explained("por_evento")
	var unused := _explained("arte_sin_uso")
	var total := _rows.size()
	var own_map := 0
	var own_battle := 0
	var placed := 0
	for row: Dictionary in _rows:
		own_map += 1 if not _is_gap(row["map"]) else 0
		own_battle += 1 if not _is_gap(row["battle"]) else 0
		placed += 1 if not row["places"].is_empty() else 0
	var lines := PackedStringArray()
	lines.append("# Cobertura de personajes")
	lines.append("")
	lines.append("> Lo genera `tests/mundo/test_cobertura_personajes.gd` (no se edita a mano). Para cada entrenador de `data/trainers/*.json`: sprite del mapa, retrato de combate y dónde sale. Las explicaciones de lo que falta están en `data/personajes_en_el_mapa.json` (`pendientes`, `por_evento`, `sprites_prestados` y `arte_sin_uso`). Los sitios de los famosos son **propuesta**: los decide Javier.")
	lines.append("")
	lines.append("**Resumen:** %d entrenadores · %d con sprite de mapa propio · %d con retrato de combate propio · %d colocados · %d pendientes con motivo · %d personajes sin combate." % [total, own_map, own_battle, placed, pending.size(), _npc_rows.size()])
	lines.append("")
	lines.append("- **atlas `id`**: el diseño propio del personaje (`data/character_art.json`): retrato de combate y dieciséis poses de mapa. Si la clase del entrenador es la del personaje, el atlas sale por la clase.")
	lines.append("- **hoja / retrato de la clase**: las piezas del pack 11 o el sprite del pack de su clase, con el nombre de la clase (los entrenadores genéricos de una misma clase comparten diseño, como en los juegos).")
	lines.append("- **PRESTADO**: usa el sprite de otra clase. **FALTA**: no tiene.")
	lines.append("- **Dónde**: `datos` = `data/personajes_en_el_mapa.json` (mapa y casilla); `sala` = sala de gimnasio; `pintado` = nodo del mapa; `evento` = lo lanza un evento.")
	lines.append("")
	var groups := {}
	for row: Dictionary in _rows:
		_append(groups, row["file"], row["id"])
	var by_id := {}
	for row: Dictionary in _rows:
		by_id[row["id"]] = row
	var order: Array = groups.keys()
	order.sort_custom(func(a: String, b: String) -> bool:
		var rank := {"liga.json": 0, "famosos.json": 1, "gimnasios.json": 2, "clases_nuevas.json": 3}
		var ra: int = rank.get(a, 9)
		var rb: int = rank.get(b, 9)
		return ra < rb or (ra == rb and a < b))
	for file: String in order:
		lines.append("## `%s`" % file)
		lines.append("")
		lines.append("| Entrenador | Id | Mapa | Combate | Dónde | Nota |")
		lines.append("|---|---|---|---|---|---|")
		for id: String in groups[file]:
			var row: Dictionary = by_id[id]
			var notes := PackedStringArray()
			if pending.has(id):
				notes.append("Pendiente: " + pending[id])
			if borrowed.has(id):
				notes.append("Sprite: " + borrowed[id])
			if events.has(id):
				notes.append(events[id])
			for place: Dictionary in row["places"]:
				if place["kind"] == "datos" and str(place["note"]) != "":
					notes.append(str(place["note"]))
			lines.append("| %s | `%s` | %s | %s | %s | %s |" % [_cell(row["name"]), id, row["map"], row["battle"], _cell(_place_text(row["places"])), _cell(" · ".join(notes))])
		lines.append("")
	lines.append("## Personajes sin combate")
	lines.append("")
	lines.append("Personajes del registro de arte que no son entrenadores (ni por id ni por clase).")
	lines.append("")
	lines.append("| Personaje | Id | Dónde | Nota |")
	lines.append("|---|---|---|---|")
	for row: Dictionary in _npc_rows:
		var where := ", ".join(PackedStringArray(row["where"])) if not row["where"].is_empty() else "—"
		lines.append("| %s | `%s` | %s | %s |" % [_cell(row["name"]), row["id"], _cell(where), _cell(unused.get(row["id"], ""))])
	lines.append("")
	var file := FileAccess.open(REPORT, FileAccess.WRITE)
	if file:
		file.store_string("\n".join(lines) + "\n")
		file.close()


static func _is_gap(state: String) -> bool:
	return state.begins_with("PRESTADO") or state == "FALTA"


func test_cada_entrenador_tiene_sprite_de_mapa_y_retrato_propios() -> void:
	var borrowed := _explained("sprites_prestados")
	for row: Dictionary in _rows:
		if borrowed.has(row["id"]):
			assert_false(borrowed[row["id"]].is_empty(), "%s: la explicación del sprite está vacía" % row["id"])
			continue
		assert_false(_is_gap(row["map"]), "%s: sprite de mapa %s sin explicación" % [row["id"], row["map"]])
		assert_false(_is_gap(row["battle"]), "%s: retrato de combate %s sin explicación" % [row["id"], row["battle"]])


func test_cada_entrenador_esta_colocado_o_explicado() -> void:
	var pending := _explained("pendientes")
	assert_false(_rows.is_empty(), "no hay entrenadores")
	for row: Dictionary in _rows:
		var explained: bool = pending.has(row["id"]) and not pending[row["id"]].is_empty()
		assert_true(not row["places"].is_empty() or explained, "%s (%s) no sale en ningún sitio y no está en «pendientes» con su motivo" % [row["id"], row["file"]])


func test_las_explicaciones_no_sobran() -> void:
	assert_true(_doc.has("colocados"), "data/personajes_en_el_mapa.json sin «colocados»")
	var known := {}
	for row: Dictionary in _rows:
		known[row["id"]] = row
	for entry: Dictionary in _doc.get("sprites_prestados", []):
		var id := str(entry.get("id", ""))
		assert_true(known.has(id), "sprites_prestados: %s no es un entrenador" % id)
		if known.has(id):
			assert_true(_is_gap(known[id]["map"]) or _is_gap(known[id]["battle"]), "sprites_prestados: %s ya tiene sprites propios; quita la explicación" % id)
	for entry: Dictionary in _doc.get("por_evento", []):
		var id := str(entry.get("id", ""))
		var path := str(entry.get("archivo", ""))
		assert_true(known.has(id), "por_evento: %s no es un entrenador" % id)
		assert_false(str(entry.get("motivo", "")).is_empty(), "por_evento: %s sin motivo" % id)
		assert_true(FileAccess.file_exists(path) and FileAccess.get_file_as_string(path).contains("\"%s\"" % id), "por_evento: %s no aparece en %s" % [id, path])
	var art := CharacterArt.entries()
	for entry: Dictionary in _doc.get("arte_sin_uso", []):
		var id := str(entry.get("id", ""))
		assert_true(art.has(id), "arte_sin_uso: %s no está en data/character_art.json" % id)
		for row: Dictionary in _npc_rows:
			if row["id"] == id:
				assert_true(row["where"].is_empty(), "arte_sin_uso: %s ya sale en %s; quita la explicación" % [id, row["where"]])


func test_cada_personaje_del_registro_de_arte_sale_en_algun_sitio() -> void:
	var unused := _explained("arte_sin_uso")
	assert_false(CharacterArt.entries().is_empty(), "data/character_art.json vacío")
	for row: Dictionary in _npc_rows:
		var explained: bool = unused.has(row["id"]) and not unused[row["id"]].is_empty()
		assert_true(not row["where"].is_empty() or explained, "%s (%s) tiene arte pero no es entrenador ni sale en ningún mapa" % [row["name"], row["id"]])


func test_las_salas_de_gimnasio_existen() -> void:
	var gyms := JsonFile.read_dict(GYM_ROOMS)
	for city: String in gyms:
		var rooms: Array = gyms[city].get("salas", [])
		for index: int in rooms.size():
			var map_id := "%s/gimnasio_%d" % [city, index + 1]
			assert_true(ResourceLoader.exists(MapRoot.path_from_id(StringName(map_id))), "no existe %s" % map_id)
			for trainer: Dictionary in rooms[index].get("entrenadores", []):
				assert_true(DataDB.has_trainer(StringName(str(trainer.get("id", "")))), "%s: falta el entrenador %s" % [map_id, trainer.get("id", "")])


func test_el_informe_esta_escrito() -> void:
	assert_true(FileAccess.file_exists(REPORT))
	assert_true(FileAccess.get_file_as_string(REPORT).contains("# Cobertura de personajes"))
