extends SceneTree
## Pinta los interiores personalizados desde data/interiores/<ciudad>.json (la distribución la
## calcula maps/_tools/planificar_interiores.py). Solo coloca casillas del tileset de
## interiores (Akizakura16, data/interiores/_piezas.json) y entidades: no dibuja arte.
## De la sala que ya existe conserva la salida a la calle (mapa y aparición de vuelta), la zona
## de captura y el regalo de su anfitrión (mismo nodo, data/npc_rewards.json). Si la sala
## cambia de tamaño o de muebles, guarda el área anterior en legacy_save_bounds para recolocar
## las partidas guardadas dentro.
## En los scripts sueltos no hay autoloads: no se usan MapRoot, NPC ni MapSign como tipos.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_interiores_datos.gd -- <ciudad> [<ciudad> ...] [--solo <map_id>]

const TILESET := "res://assets/tilesets/interior/interior.tres"
const DATOS := "res://data/interiores/"
const FONT := "res://assets/fonts/truth_and_ideals/TruthAndIdeals-Normal.ttf"
const MIRA := {"abajo": 0, "izquierda": 1, "derecha": 2, "arriba": 3}
const REWARD_EVENT := "res://src/events/common/npc_reward_event.gd"

var _cat: Dictionary = {}
var _hechas := 0
var _errores := 0


func _initialize() -> void:
	await process_frame
	_cat = JsonFile.read_dict(DATOS + "_piezas.json")
	var args := OS.get_cmdline_user_args()
	var solo := ""
	var ciudades := PackedStringArray()
	var i := 0
	while i < args.size():
		if args[i] == "--solo" and i + 1 < args.size():
			solo = args[i + 1]
			i += 2
			continue
		if not args[i].begins_with("--"):
			ciudades.append(args[i])
		i += 1
	for ciudad: String in ciudades:
		var datos := JsonFile.read_dict(DATOS + ciudad + ".json")
		var nombre_ciudad := str(datos.get("ciudad", ciudad.capitalize()))
		var interiores: Dictionary = datos.get("interiores", {})
		for map_id: String in interiores:
			if solo != "" and map_id != solo:
				continue
			_pintar(map_id, interiores[map_id], nombre_ciudad)
	print("interiores pintados: %d, errores: %d" % [_hechas, _errores])
	quit(1 if _errores > 0 else 0)


func _pintar(map_id: String, e: Dictionary, ciudad: String) -> void:
	if not e.has("muebles"):
		_fallo(map_id, "sin distribución: pasa antes planificar_interiores.py")
		return
	var path := "res://maps/%s.tscn" % map_id
	var antes := _leer_anterior(path)
	var tam := Vector2i(int(e.tamano[0]), int(e.tamano[1]))
	var salida := _salida(e, antes)
	if salida.is_empty():
		_fallo(map_id, "no se sabe a dónde lleva la salida")
		return
	var d := MapData.new()
	d.id = StringName(map_id)
	d.display_name = "%s, %s" % [str(e.nombre), ciudad]
	d.zone_id = StringName(antes.get("zone", e.get("zona", map_id.get_slice("/", 0))))
	d.outdoor = false
	d.fixed_camera = tam.x <= 16 and tam.y <= 12
	d.can_bike = false
	d.can_run = false
	d.can_fly_from = false
	d.followers_allowed = false
	d.battle_background = &"indoor"
	if antes.has("rect"):
		var anterior: Rect2i = antes.rect
		d.legacy_save_bounds = anterior.merge(antes.get("legacy", anterior))
	var p := Pintor.new(_nodo_raiz(map_id), tam, d, 1)
	var tiles: TileSet = load(TILESET)
	for layer: TileMapLayer in [p.ground, p.decor, p.objects, p.above]:
		layer.tile_set = tiles
	p.above.collision_enabled = false
	var huecos: Array[int] = []
	for paso: Dictionary in e.get("pasos", []):
		huecos.append(int(paso.en[0]))
	_suelo_y_paredes(p, e, tam, huecos)
	for m: Array in e.muebles:
		_mueble(p, str(m[0]), Vector2i(int(m[1]), int(m[2])))
	for m: Array in e.get("encima", []):
		var pieza: Dictionary = _cat.muebles[str(m[0])]
		var r: Array = pieza.rect
		p.above.set_cell(Vector2i(int(m[1]), int(m[2])), int(pieza.fuente), Vector2i(int(r[0]), int(r[1])))
	# Personas.
	var regalo_ok := not antes.has("regalo")
	for q: Dictionary in e.get("personas", []):
		var props := {"display_name": str(q.get("nombre", ""))}
		if q.has("regalo"):
			props["event"] = load(REWARD_EVENT)
			props["event_params"] = {"reward_id": str(q.regalo)}
			if antes.has("regalo") and antes.regalo.nodo == str(q.nodo) and antes.regalo.id == str(q.regalo):
				regalo_ok = true
		if q.get("pasea", false):
			props["wander"] = true
			props["wander_radius"] = 1
		var lines := PackedStringArray()
		for f: Variant in q.get("frases", []):
			lines.append(str(f))
		p.npc(str(q.nodo), str(q.get("aspecto", "npc_man")), Vector2i(int(q.en[0]), int(q.en[1])), int(MIRA.get(str(q.get("mira", "abajo")), 0)), lines, props)
	if not regalo_ok:
		_fallo(map_id, "la sala tenía el regalo %s en %s y los datos no lo conservan" % [antes.regalo.id, antes.regalo.nodo])
		p.root.free()
		return
	# Carteles que se examinan (sin poste: el mueble o la pared es lo que se lee).
	for k: Dictionary in e.get("carteles", []):
		var sign: Node2D = (load("res://src/overworld/sign/sign.tscn") as PackedScene).instantiate()
		sign.name = str(k.nodo)
		sign.position = Grid.to_world(Vector2i(int(k.en[0]), int(k.en[1])))
		var lines := PackedStringArray()
		for f: Variant in k.get("frases", []):
			lines.append(str(f))
		sign.set(&"lines", lines)
		sign.set(&"only_from_below", false)
		sign.set(&"show_sprite", false)
		p.entities.add_child(sign)
	if e.has("pc"):
		var pc: Node2D = (load("res://src/overworld/sign/sign.tscn") as PackedScene).instantiate()
		pc.set_script(load("res://src/overworld/hospital_terminal.gd"))
		pc.name = "PC"
		pc.position = Grid.to_world(Vector2i(int(e.pc[0]), int(e.pc[1])))
		p.entities.add_child(pc)
	# Apariciones y pasos.
	for nombre: String in e.get("apariciones", {}):
		var c: Array = e.apariciones[nombre]
		p.spawn(nombre, Vector2i(int(c[0]), int(c[1])))
	var puerta := Vector2i(int(e.puerta[0]), int(e.puerta[1]))
	p.warp("Salida", puerta, StringName(salida.destino), StringName(salida.aparicion))
	p.root.get_node(^"Warps/Salida").set(&"arrival_facing", 1)
	for paso: Dictionary in e.get("pasos", []):
		p.warp(str(paso.nodo), Vector2i(int(paso.en[0]), int(paso.en[1])), StringName(paso.destino), StringName(paso.get("aparicion", "default")))
		p.root.get_node(NodePath("Warps/" + str(paso.nodo))).set(&"arrival_facing", 4)
	_rotulo(p, str(e.get("rotulo", e.nombre)), tam)
	var err := p.save(path)
	if err != OK:
		_fallo(map_id, error_string(err))
		return
	_hechas += 1
	print("%s: %s" % [map_id, error_string(err)])


func _suelo_y_paredes(p: Pintor, e: Dictionary, tam: Vector2i, huecos: Array[int]) -> void:
	var suelo: Array = _cat.suelos[str(e.suelo)]
	var base := Vector2i(int(suelo[0]), int(suelo[1]))
	for c: Vector2i in Pintor.cells(Rect2i(Vector2i.ZERO, tam)):
		p.ground.set_cell(c, 0, base)
	for a: Array in e.get("alfombras", []):
		var s: Array = _cat.suelos[str(a[0])]
		var r: Array = a[1]
		for c: Vector2i in Pintor.cells(Rect2i(int(r[0]), int(r[1]), int(r[2]), int(r[3]))):
			p.ground.set_cell(c, 0, Vector2i(int(s[0]), int(s[1])))
	var puerta := Vector2i(int(e.puerta[0]), int(e.puerta[1]))
	var felpudo: Array = _cat.suelos[str(e.get("felpudo", "moqueta_beige"))]
	p.ground.set_cell(puerta, 0, Vector2i(int(felpudo[0]), int(felpudo[1])))
	# Hueco de paso en la pared de arriba: suelo en sombra (la variante oscura del mismo bloque).
	for x: int in huecos:
		for y: int in [0, 1]:
			p.ground.set_cell(Vector2i(x, y), 0, base + Vector2i(1, 1))
	var b := int(_cat.paredes[str(e.pared)]) * 5
	var w := tam.x
	var h := tam.y
	for x: int in range(1, w - 1):
		if x in huecos:
			continue
		p.decor.set_cell(Vector2i(x, 0), 1, Vector2i(1, b + 3))
		p.decor.set_cell(Vector2i(x, 1), 1, Vector2i(1, b + 4))
	for y: int in range(0, h - 1):
		p.decor.set_cell(Vector2i(0, y), 1, Vector2i(2, b + 1))
		p.decor.set_cell(Vector2i(w - 1, y), 1, Vector2i(0, b + 1))
	for x: int in range(1, w - 1):
		if x != puerta.x:
			p.decor.set_cell(Vector2i(x, h - 1), 1, Vector2i(1, b))
	p.decor.set_cell(Vector2i(puerta.x - 1, h - 1), 1, Vector2i(2, b))
	p.decor.set_cell(Vector2i(puerta.x + 1, h - 1), 1, Vector2i(0, b))
	p.decor.set_cell(Vector2i(0, h - 1), 1, Vector2i(5, b + 4))
	p.decor.set_cell(Vector2i(w - 1, h - 1), 1, Vector2i(6, b + 4))


## Estampa una pieza: la base va a Objects (con colisión); si la pieza está en el suelo y no
## contra la pared de arriba, sus filas altas van a Above (sin colisión, se pasa por detrás).
func _mueble(p: Pintor, nombre: String, en: Vector2i) -> void:
	var pieza: Dictionary = _cat.muebles[nombre]
	var r: Array = pieza.rect
	var w := int(r[2])
	var h := int(r[3])
	var base := int(pieza.get("base", h))
	var contra_muro := en.y <= 1
	for dy: int in h:
		for dx: int in w:
			var c := en + Vector2i(dx, dy)
			var atlas := Vector2i(int(r[0]) + dx, int(r[1]) + dy)
			if not contra_muro and dy < h - base:
				p.above.set_cell(c, int(pieza.fuente), atlas)
			else:
				p.objects.set_cell(c, int(pieza.fuente), atlas)


func _rotulo(p: Pintor, texto: String, tam: Vector2i) -> void:
	var label := Label.new()
	label.name = "Rotulo"
	label.position = Vector2(16, 4)
	label.size = Vector2(tam.x * 32 - 32, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = texto.to_upper()
	label.add_theme_font_override("font", load(FONT))
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("303048"))
	label.add_theme_color_override("font_shadow_color", Color("fff4d8"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	# Si el nombre no cabe en una línea, va en dos: la franja de la pared (dos filas) tiene sitio.
	var font: Font = load(FONT)
	if font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x > label.size.x:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.position.y = 0
		label.size.y = 40
		label.add_theme_constant_override("line_spacing", -4)
	p.root.add_child(label)


func _salida(e: Dictionary, antes: Dictionary) -> Dictionary:
	if e.has("salida"):
		return {"destino": str(e.salida.destino), "aparicion": str(e.salida.aparicion)}
	if antes.has("salida"):
		return antes.salida
	return {}


## Lo que hay que conservar de la sala actual.
func _leer_anterior(path: String) -> Dictionary:
	var out := {}
	if not ResourceLoader.exists(path):
		return out
	var root: Node = (load(path) as PackedScene).instantiate()
	var data: Resource = root.get(&"data")
	if data != null:
		out["zone"] = str(data.get(&"zone_id"))
		var legacy: Rect2i = data.get(&"legacy_save_bounds")
		if legacy.has_area():
			out["legacy"] = legacy
	var ground := root.get_node_or_null(^"Ground") as TileMapLayer
	if ground != null:
		out["rect"] = ground.get_used_rect()
	var salida := root.get_node_or_null(^"Warps/Salida")
	if salida != null:
		out["salida"] = {"destino": str(salida.get(&"target_map")), "aparicion": str(salida.get(&"target_spawn"))}
	var entities := root.get_node_or_null(^"Entities")
	if entities != null:
		for node: Node in entities.get_children():
			var ev: Variant = node.get(&"event")
			if ev is Script and (ev as Script).resource_path == REWARD_EVENT:
				var params: Dictionary = node.get(&"event_params")
				out["regalo"] = {"nodo": str(node.name), "id": str(params.get("reward_id", ""))}
	root.free()
	return out


func _nodo_raiz(map_id: String) -> String:
	var t := map_id.get_file()
	var out := ""
	for part: String in t.split("_"):
		out += part.capitalize().replace(" ", "")
	return out if out != "" else "Sala"


func _fallo(map_id: String, motivo: String) -> void:
	_errores += 1
	push_error("%s: %s" % [map_id, motivo])
	print("ERROR %s: %s" % [map_id, motivo])
