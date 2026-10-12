class_name PlaytestWorldMap
extends PanelContainer
## Mapa de pruebas: los destinos reales viajan con un clic, sin tocar la partida.
signal completed(id: String)
var entries: Array[Dictionary] = []
var groups: Dictionary = {}
var buttons: Dictionary = {}
var zone_buttons: Dictionary = {}
var area_name: Label
var detail: Label
var search: LineEdit
var zones: VBoxContainer
var _finished := false
var selected_group := ""

func _ready() -> void:
	position = Vector2(8,8)
	size = Vector2(496,368)
	theme = PlaytestPicker.menu_theme()
	var box := VBoxContainer.new()
	add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	var title := Label.new()
	title.text = "Mapa de pruebas / clic para viajar"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var back := Button.new()
	back.text = "Volver / B"
	back.pressed.connect(func() -> void: _complete(""))
	head.add_child(back)
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(row)
	var board := Control.new()
	board.custom_minimum_size = Vector2(330,278)
	board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_child(board)
	# Plano existente de la región: no se produce arte nuevo para esta herramienta.
	var image := Image.new()
	if image.load_svg_from_string(FileAccess.get_file_as_string("res://docs/mundo/mapa_region.svg")) == OK:
		var background := TextureRect.new()
		background.texture = ImageTexture.create_from_image(image)
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.stretch_mode = TextureRect.STRETCH_SCALE
		background.size = Vector2(330,268)
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board.add_child(background)
	var side := VBoxContainer.new()
	side.custom_minimum_size.x = 142
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(side)
	area_name = Label.new()
	area_name.text = "Todas las zonas"
	area_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(area_name)
	search = LineEdit.new()
	search.placeholder_text = "Buscar cualquier zona"
	search.text_changed.connect(func(value: String) -> void: _show_zones("",value))
	side.add_child(search)
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
	detail.custom_minimum_size.y = 38
	box.add_child(detail)
	for entry: Dictionary in entries:
		var key := str(entry.id).get_slice("/",0)
		if not groups.has(key): groups[key] = []
		groups[key].append(entry)
	var region := JsonFile.read_dict("res://data/region.json")
	for id: String in region.get("locations",{}):
		var location: Dictionary = region.locations[id]
		var key := "pueblo_inicial" if id == "san_miguel_de_bernuy" else id
		if id == "sur_de_madrid": key = "getafe"
		_point(board,key,str(location.name),Vector2(location.cell[0],location.cell[1]),"●")
	# Localidades adicionales de los mapas pintados.
	_point(board,"huelva","Huelva",Vector2(6,20),"●")
	_point(board,"playa_del_ingles","Playa del Inglés",Vector2(4.5,24),"●")
	for id: String in region.get("routes",{}):
		if not id.begins_with("ruta_") and id != "maritima_1": continue
		var route: Dictionary = region.routes[id]
		var centre := Vector2.ZERO
		for cell: Array in route.cells: centre += Vector2(cell[0],cell[1])
		centre /= route.cells.size()
		var number := id.trim_prefix("ruta_") if id != "maritima_1" else "M"
		_point(board,id,str(route.name),centre,number)
	_show_zones("")
	back.grab_focus()

func _point(board: Control, key: String, caption: String, cell: Vector2, text: String) -> void:
	var button := Button.new()
	button.text = text
	button.add_theme_font_size_override("font_size",12)
	var ideal := cell*Vector2(330.0/32,268.0/26)-Vector2(9,9)
	button.position = ideal
	var offsets: Array[Vector2] = [Vector2.ZERO]
	for ring: int in range(1,9):
		for x: int in range(-ring,ring+1):
			for y: int in range(-ring,ring+1):
				if maxi(absi(x),absi(y)) == ring: offsets.append(Vector2(x,y)*12)
	offsets.sort_custom(func(a: Vector2,b: Vector2) -> bool: return a.length_squared() < b.length_squared())
	for offset: Vector2 in offsets:
		var candidate := Rect2(ideal+offset,Vector2(18,18))
		if not Rect2(0,0,330,268).encloses(candidate): continue
		if buttons.values().any(func(other: Button) -> bool: return candidate.grow(2).intersects(other.get_rect())): continue
		button.position = candidate.position
		break
	button.size = Vector2(18,18)
	button.custom_minimum_size = Vector2(18,18)
	for style: StringName in [&"normal",&"hover",&"pressed",&"focus",&"disabled"]:
		var frame := StyleBoxFlat.new()
		frame.bg_color = Color("707a84") if not groups.has(key) else Color("303048")
		if style in [&"hover",&"focus"]: frame.bg_color = Color("80342e")
		frame.set_corner_radius_all(3)
		button.add_theme_stylebox_override(style,frame)
	button.add_theme_color_override("font_color",Color("fff4d8"))
	button.tooltip_text = caption+(" · clic para viajar" if groups.has(key) else " · mapa pendiente")
	button.disabled = not groups.has(key)
	button.mouse_entered.connect(func() -> void: _show_zones(key))
	button.focus_entered.connect(func() -> void: _show_zones(key))
	button.pressed.connect(func() -> void: _complete(_primary(key)))
	board.add_child(button)
	buttons[key] = button

func _primary(key: String) -> String:
	var preferred := {"madrid":"madrid/centro","barcelona":"barcelona/eixample","valencia":"valencia/ciutat_vella","sevilla":"sevilla/centro","las_palmas":"las_palmas/vegueta_triana"}
	var available: Array = groups.get(key,[])
	for entry: Dictionary in available:
		if entry.id == preferred.get(key,""): return str(entry.id)
	for entry: Dictionary in available:
		if entry.get("outdoor",false): return str(entry.id)
	return str(available[0].id) if not available.is_empty() else ""

func _show_zones(key: String, query := "") -> void:
	selected_group = key
	for node: Node in zones.get_children():
		zones.remove_child(node)
		node.queue_free()
	zone_buttons.clear()
	area_name.text = "Todas las zonas" if key == "" else ("Madrid sur" if key == "getafe" else key.replace("_"," ").capitalize())
	var available: Array = entries if key == "" else groups.get(key,[]).duplicate()
	if key == "getafe":
		available.append_array(groups.get("leganes",[]))
		available.append_array(groups.get("mostoles",[]))
	var words := PlaytestPicker._search_text(query).split(" ",false)
	for entry: Dictionary in available:
		var haystack := PlaytestPicker._search_text(str(entry.label)+" "+str(entry.id))
		if not Array(words).all(func(word: String) -> bool: return haystack.contains(word)): continue
		var button := Button.new()
		button.text = str(entry.label).replace(" · "," / ")
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size.y = 30
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
	if event.is_action_pressed(&"cancel") or event.is_action_pressed(&"debug"):
		get_viewport().set_input_as_handled()
		_complete("")

func _complete(id: String) -> void:
	if _finished: return
	_finished = true
	completed.emit(id)
