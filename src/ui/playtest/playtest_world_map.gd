class_name PlaytestWorldMap
extends PanelContainer
## Mapa de pruebas: los destinos reales viajan con un clic, sin tocar la partida.
## Los puntos salen de data/region.json: ciudades y pueblos, barrios, rutas y transportes (ferris, avión,
## AVE), más las salas de pruebas. Cada punto agrupa sus mapas: los del mismo id (`madrid/...`), los de sus
## viajes y las salas y gimnasios cuya puerta de salida lleva a su exterior. Dos vistas: España y el
## recuadro de Madrid y alrededores (pueblos iniciales, barrios y el sur). Gris = mapa pendiente.
signal completed(id: String)
const BOARD := Vector2(330, 268)
const POINT := Vector2(18, 18)
## Filtro de la lista de zonas: [categoría de PlaytestSession.category(), título].
const CATEGORIES: Array = [["", "Todo"], ["exterior", "Exteriores"], ["interior", "Interiores"],
	["gimnasio", "Gimnasios"], ["transporte", "Transporte"], ["pruebas", "Pruebas"]]
## Letra de cada tipo de transporte en su punto.
const TRANSPORT_TEXT := {"ferry": "F", "plane": "A", "train": "T", "surf": "M"}
var entries: Array[Dictionary] = []
var groups: Dictionary = {}
## Puntos de las dos vistas: {clave: {name, cell, view, text, kind}}.
var places: Dictionary = {}
var buttons: Dictionary = {}
var zone_buttons: Dictionary = {}
var area_name: Label
var detail: Label
var search: LineEdit
var filter: OptionButton
var zones: VBoxContainer
var board: Control
var view_button: Button
var view := "spain"
var category := ""
var _finished := false
var selected_group := ""
var _region: Dictionary = {}
var _textures: Dictionary = {}
## Dentro de una pestaña de F9: no cierra el menú al pulsar y se puede viajar otra vez.
var embedded := false

func _ready() -> void:
	if embedded:
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		size_flags_vertical = Control.SIZE_EXPAND_FILL
	else:
		position = Vector2(8,8)
		size = Vector2(496,368)
	theme = PlaytestPicker.menu_theme()
	var box := VBoxContainer.new()
	add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	var title := Label.new()
	title.text = "Región · clic para viajar"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	view_button = Button.new()
	view_button.text = "Ver Madrid"
	view_button.tooltip_text = "Recuadro de Madrid y alrededores: pueblos iniciales, barrios y el sur"
	view_button.pressed.connect(func() -> void: set_view("spain" if view == "madrid" else "madrid"))
	head.add_child(view_button)
	var back := Button.new()
	back.text = "Volver / B"
	back.pressed.connect(func() -> void: _complete(""))
	head.add_child(back)
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(row)
	board = Control.new()
	board.custom_minimum_size = BOARD
	board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_child(board)
	var side := VBoxContainer.new()
	side.custom_minimum_size.x = 142
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(side)
	area_name = Label.new()
	area_name.text = "Todas las zonas"
	area_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(area_name)
	search = LineEdit.new()
	search.placeholder_text = "Buscar (sin tildes)"
	search.text_changed.connect(func(value: String) -> void: _show_zones("",value))
	side.add_child(search)
	filter = OptionButton.new()
	for item: Array in CATEGORIES:
		filter.add_item(str(item[1]))
	filter.item_selected.connect(func(index: int) -> void:
		category = str(CATEGORIES[index][0])
		_show_zones(selected_group, search.text))
	side.add_child(filter)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	side.add_child(scroll)
	zones = VBoxContainer.new()
	zones.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(zones)
	detail = Label.new()
	detail.text = "Sesión temporal. Pasa por un punto para ver sus zonas.\nPulsa para viajar. Gris: mapa pendiente."
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.custom_minimum_size.y = 52
	box.add_child(detail)
	_region = JsonFile.read_dict("res://data/region.json")
	_build_groups()
	_build_places()
	set_view("spain")
	_show_zones("")
	back.grab_focus()

## Agrupa cada mapa en los puntos a los que pertenece (ver la cabecera).
func _build_groups() -> void:
	groups.clear()
	var by_area := {}
	var exact := {}
	var districts := {}
	for id: String in _region.get("locations", {}):
		var location: Dictionary = _region.locations[id]
		for map: Variant in location.get("maps", [location.get("map", "")]):
			if str(map) != "": by_area[str(map).get_slice("/",0)] = id
	for id: String in _region.get("routes", {}):
		var route: Dictionary = _region.routes[id]
		if str(route.get("map", "")) != "": by_area[str(route.map).get_slice("/",0)] = id
		for map: Variant in route.get("maps", []): exact[str(map)] = id
	for id: String in _region.get("districts", {}):
		districts[str(_region.districts[id].map)] = id
	for entry: Dictionary in entries:
		var keys: Array[String] = []
		var area := str(entry.id).get_slice("/",0)
		if exact.has(entry.id): keys.append(exact[entry.id])
		elif area in ["test", "muestras"]: keys.append("pruebas")
		elif by_area.has(area): keys.append(by_area[area])
		var parent := str(entry.get("parent", entry.id))
		if districts.has(parent): keys.append(districts[parent])
		if keys.is_empty(): keys.append("otros")
		for key: String in keys:
			if not groups.has(key): groups[key] = []
			groups[key].append(entry)

## Un punto por ciudad, pueblo, barrio, ruta y transporte de data/region.json, más el de Madrid (que abre
## su recuadro) y el de las salas de pruebas.
func _build_places() -> void:
	places.clear()
	for id: String in _region.get("locations", {}):
		var location: Dictionary = _region.locations[id]
		places[id] = {"name": str(location.name), "cell": location.cell, "view": "madrid" if location.get("inset") is String and location.inset == "madrid" else "spain",
			"text": "★" if id in _region.get("start", []) else ("%d" % int(location.gym.order) if location.get("gym") is Dictionary else "●"), "kind": str(location.kind)}
	for id: String in _region.get("districts", {}):
		var district: Dictionary = _region.districts[id]
		places[id] = {"name": str(district.name), "cell": district.cell, "view": "madrid", "text": "●", "kind": "district"}
	for id: String in _region.get("routes", {}):
		var route: Dictionary = _region.routes[id]
		if str(route.get("map", "")) == "" and route.get("maps", []).is_empty() and not route.has("map"): continue
		var centre := Vector2.ZERO
		for cell: Array in route.cells: centre += Vector2(cell[0], cell[1])
		centre /= route.cells.size()
		var text: String = id.trim_prefix("ruta_") if id.begins_with("ruta_") else str(TRANSPORT_TEXT.get(str(route.get("kind", "")), id.substr(0, 1).to_upper()))
		places[id] = {"name": str(route.name), "cell": [centre.x, centre.y], "view": "madrid" if route.get("inset") is String and route.inset == "madrid" else "spain",
			"text": text, "kind": str(route.get("kind", "route"))}
	var inset: Array = _region.get("insets", {}).get("madrid", {}).get("rect", [21, 0, 11, 6])
	places["madrid_zoom"] = {"name": "Madrid y alrededores · ver el recuadro", "cell": [inset[0] + inset[2] / 2.0, inset[1] + inset[3] / 2.0], "view": "spain", "text": "Z", "kind": "zoom"}
	places["pruebas"] = {"name": "Salas de pruebas y muestras", "cell": [1.0, 19.5], "view": "spain", "text": "P", "kind": "pruebas"}

## Cambia entre la vista de España y la del recuadro de Madrid y alrededores.
func set_view(value: String) -> void:
	view = value
	view_button.text = "Ver España" if view == "madrid" else "Ver Madrid"
	for node: Node in board.get_children():
		board.remove_child(node)
		node.queue_free()
	buttons.clear()
	var background := TextureRect.new()
	background.texture = _background(view)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if background.texture: background.size = background.texture.get_size()
	board.add_child(background)
	for key: String in places:
		if places[key].view == view: _point(key)

## Plano existente de la región (docs/mundo/mapa_region.svg); en la vista de Madrid, su recuadro ampliado.
func _background(which: String) -> Texture2D:
	if _textures.has(which): return _textures[which]
	var svg := FileAccess.get_file_as_string("res://docs/mundo/mapa_region.svg")
	var image := Image.new()
	var size: Array = _region.get("size", [32, 26])
	var texture: Texture2D = null
	if which == "madrid":
		var rect: Array = _region.get("insets", {}).get("madrid", {}).get("rect", [21, 0, 11, 6])
		var scale := BOARD.x / (float(rect[2]) * 24.0)
		if image.load_svg_from_string(svg, scale) == OK:
			var crop := Rect2i(Vector2i(roundi(rect[0] * 24 * scale), roundi(rect[1] * 24 * scale)), Vector2i(roundi(rect[2] * 24 * scale), roundi(rect[3] * 24 * scale)))
			texture = ImageTexture.create_from_image(image.get_region(crop.intersection(Rect2i(Vector2i.ZERO, image.get_size()))))
	elif image.load_svg_from_string(svg, BOARD.x / (float(size[0]) * 24.0)) == OK:
		texture = ImageTexture.create_from_image(image)
	_textures[which] = texture
	return texture

## Casilla de data/region.json → posición en el tablero de la vista actual.
func board_position(cell: Variant) -> Vector2:
	var at := Vector2(float(cell[0]), float(cell[1]))
	if view == "madrid":
		var rect: Array = _region.get("insets", {}).get("madrid", {}).get("rect", [21, 0, 11, 6])
		var unit := BOARD.x / float(rect[2])
		return (at - Vector2(rect[0], rect[1]) + Vector2(0.5, 0.5)) * unit
	var size: Array = _region.get("size", [32, 26])
	return (at + Vector2(0.5, 0.5)) * Vector2(BOARD.x / float(size[0]), BOARD.y / float(size[1]))

func _point(key: String) -> void:
	var place: Dictionary = places[key]
	var button := Button.new()
	button.text = str(place.text)
	button.add_theme_font_size_override("font_size",10)
	var ideal := board_position(place.cell) - POINT / 2
	button.position = ideal
	var offsets: Array[Vector2] = [Vector2.ZERO]
	for ring: int in range(1,9):
		for x: int in range(-ring,ring+1):
			for y: int in range(-ring,ring+1):
				if maxi(absi(x),absi(y)) == ring: offsets.append(Vector2(x,y)*12)
	offsets.sort_custom(func(a: Vector2,b: Vector2) -> bool: return a.length_squared() < b.length_squared())
	for offset: Vector2 in offsets:
		var candidate := Rect2(ideal+offset,POINT)
		if not Rect2(Vector2.ZERO,BOARD).encloses(candidate): continue
		if buttons.values().any(func(other: Button) -> bool: return candidate.grow(2).intersects(other.get_rect())): continue
		button.position = candidate.position
		break
	button.size = POINT
	button.custom_minimum_size = POINT
	var enabled := _enabled(key)
	for style: StringName in [&"normal",&"hover",&"pressed",&"focus",&"disabled"]:
		var frame := StyleBoxFlat.new()
		frame.bg_color = Color("707a84") if not enabled else _color(str(place.kind))
		if style in [&"hover",&"focus"]: frame.bg_color = Color("80342e")
		frame.set_corner_radius_all(3)
		button.add_theme_stylebox_override(style,frame)
	button.add_theme_color_override("font_color",Color("fff4d8"))
	button.add_theme_color_override("font_disabled_color",Color("d8d8d8"))
	button.tooltip_text = str(place.name)+(" · clic para viajar" if enabled else " · mapa pendiente")
	button.disabled = not enabled
	button.mouse_entered.connect(func() -> void: _show_zones(key))
	button.focus_entered.connect(func() -> void: _show_zones(key))
	button.pressed.connect(func() -> void:
		if key == "madrid_zoom": set_view("madrid")
		else: _complete(_primary(key)))
	board.add_child(button)
	buttons[key] = button

func _enabled(key: String) -> bool:
	return key == "madrid_zoom" or not groups.get(key, []).is_empty()

func _color(kind: String) -> Color:
	match kind:
		"city": return Color("303048")
		"town": return Color("2e6b4a")
		"district": return Color("8a5a10")
		"ferry", "plane", "train", "surf": return Color("2f5f9a")
		"zoom", "pruebas": return Color("5a3a78")
	return Color("4a3a30")

## Mapa al que lleva un punto: el `map` de data/region.json si existe; si no, su primer exterior.
func _primary(key: String) -> String:
	var preferred := ""
	for section: String in ["locations", "districts", "routes"]:
		if _region.get(section, {}).has(key):
			var place: Dictionary = _region[section][key]
			preferred = str(place.get("map", ""))
			if preferred == "" and not place.get("maps", []).is_empty(): preferred = str(place.maps[0])
	var available: Array = groups.get(key,[])
	for entry: Dictionary in available:
		if entry.id == preferred: return str(entry.id)
	for entry: Dictionary in available:
		if entry.get("outdoor",false): return str(entry.id)
	return str(available[0].id) if not available.is_empty() else ""

func _show_zones(key: String, query := "") -> void:
	selected_group = key
	for node: Node in zones.get_children():
		zones.remove_child(node)
		node.queue_free()
	zone_buttons.clear()
	area_name.text = "Todas las zonas" if key == "" else str(places.get(key, {}).get("name", key.replace("_"," ").capitalize()))
	var available: Array = entries if key == "" or key == "madrid_zoom" else groups.get(key,[])
	var words := PlaytestPicker._search_text(query).split(" ",false)
	for entry: Dictionary in available:
		if category != "" and str(entry.get("category", "")) != category: continue
		var haystack := PlaytestPicker._search_text(str(entry.label)+" "+str(entry.id))
		if not Array(words).all(func(word: String) -> bool: return haystack.contains(word)): continue
		var button := Button.new()
		button.text = str(entry.label).replace(" · "," / ")
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size.y = 36
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.tooltip_text = str(entry.id)+" · clic para viajar"
		button.pressed.connect(func() -> void: _complete(str(entry.id)))
		zones.add_child(button)
		zone_buttons[str(entry.id)] = button
	if zones.get_child_count() == 0:
		var label := Label.new()
		label.text = "Mapa pendiente" if key != "" else "Sin resultados"
		zones.add_child(label)

func _unhandled_input(event: InputEvent) -> void:
	if embedded or not is_visible_in_tree():
		return
	if event.is_action_pressed(&"cancel") or event.is_action_pressed(&"debug"):
		get_viewport().set_input_as_handled()
		_complete("")

func _complete(id: String) -> void:
	if _finished: return
	if not embedded:
		_finished = true
	completed.emit(id)
