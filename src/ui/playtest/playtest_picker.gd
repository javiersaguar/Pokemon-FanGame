class_name PlaytestPicker
extends PanelContainer
## Catálogo buscable con teclado, ratón y mando; solo devuelve un identificador.
signal completed(id: String)
var entries: Array[Dictionary] = []
var caption := "Elegir"
var shown: Array[Dictionary] = []
var list: ItemList
var search: LineEdit
var note: Label
var _finished := false
var detail_scroll: ScrollContainer
var detail_hint: Label

static func pick(title: String, catalogue: Array[Dictionary]) -> String:
	var picker := PlaytestPicker.new()
	picker.caption = title
	picker.entries = catalogue
	SceneManager.push_menu(picker)
	var value: String = await picker.completed
	SceneManager.pop_menu(picker)
	return value

static func menu_theme() -> Theme:
	var result := preload("res://src/ui/theme/main_theme.tres").duplicate()
	# El menú de F9 está en la pantalla de 512×384, no en el lienzo ×2.
	# La fuente es de píxel a tamaño 10: aquí se dibuja al doble (20) para verse nítida.
	result.default_font_size = 20
	result.set_stylebox(&"panel",&"TabContainer",result.get_stylebox(&"panel",&"PanelContainer"))
	result.set_color(&"font_selected_color",&"TabContainer",Color("303048"))
	result.set_color(&"font_unselected_color",&"TabContainer",Color("586870"))
	for key: StringName in [&"tab_selected",&"tab_unselected",&"tab_hovered"]:
		result.set_stylebox(key,&"TabContainer",result.get_stylebox(&"panel",&"PanelContainer"))
	for key: StringName in [&"normal",&"focus"]:
		result.set_stylebox(key,&"LineEdit",result.get_stylebox(&"panel",&"PanelContainer"))
	result.set_color(&"font_color",&"LineEdit",Color("303048"))
	for key: StringName in [&"normal",&"hover",&"pressed",&"focus"]:
		result.set_stylebox(key,&"Button",result.get_stylebox(&"panel",&"PanelContainer"))
	result.set_stylebox(&"panel",&"ItemList",result.get_stylebox(&"panel",&"PanelContainer"))
	for key: StringName in [&"selected",&"selected_focus"]:
		result.set_stylebox(key,&"ItemList",result.get_stylebox(&"normal",&"TagLabel"))
	result.set_color(&"font_color",&"ItemList",Color("303048"))
	result.set_color(&"font_selected_color",&"ItemList",Color("fff4d8"))
	return result

func _ready() -> void:
	position = Vector2(8,8)
	size = Vector2(496,368)
	theme = menu_theme()
	var box := VBoxContainer.new()
	add_child(box)
	var title := Label.new()
	title.text = caption
	box.add_child(title)
	search = LineEdit.new()
	search.placeholder_text = "Buscar por nombre o identificador"
	search.text_changed.connect(_filter)
	search.text_submitted.connect(func(_value: String) -> void: list.grab_focus())
	box.add_child(search)
	list = ItemList.new()
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list.item_selected.connect(_show_note)
	list.item_activated.connect(_choose)
	box.add_child(list)
	detail_scroll = ScrollContainer.new()
	detail_scroll.custom_minimum_size.y = 60
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	box.add_child(detail_scroll)
	note = Label.new()
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.add_child(note)
	detail_hint = Label.new()
	box.add_child(detail_hint)
	var row := HBoxContainer.new()
	box.add_child(row)
	var choose := Button.new()
	choose.text = "Elegir"
	choose.pressed.connect(func() -> void:
		if not list.get_selected_items().is_empty(): _choose(list.get_selected_items()[0]))
	row.add_child(choose)
	var cancel := Button.new()
	cancel.text = "Volver / B"
	cancel.pressed.connect(func() -> void: _complete(""))
	row.add_child(cancel)
	_filter("")
	search.grab_focus()

func _filter(value: String) -> void:
	list.clear()
	shown.clear()
	var words := _search_text(value).split(" ", false)
	for entry: Dictionary in entries:
		var haystack := _search_text(str(entry.label)+" "+str(entry.id)+" "+str(entry.get("note","")))
		var matches := true
		for word: String in words:
			if not haystack.contains(word):
				matches = false
				break
		if matches:
			shown.append(entry)
			list.add_item(str(entry.label))
	if not shown.is_empty():
		list.select(0)
		_show_note(0)
	else:
		detail_scroll.scroll_vertical = 0
		note.text = "Sin resultados"

static func _search_text(value: String) -> String:
	var normalized := value.to_lower().strip_edges()
	for pair: Array in [["á","a"],["é","e"],["í","i"],["ó","o"],["ú","u"],["ü","u"],["ñ","n"],["\t"," "],["_"," "],["-"," "]]:
		normalized = normalized.replace(pair[0], pair[1])
	return normalized

func _choose(index: int) -> void:
	if index >= 0 and index < shown.size():
		_complete(str(shown[index].id))

func _show_note(index: int) -> void:
	detail_scroll.scroll_vertical = 0
	note.text = str(shown[index].get("note",""))

func _process(_delta: float) -> void:
	var limit := maxi(0,ceili(note.get_minimum_size().y-detail_scroll.size.y))
	detail_hint.visible = limit > 0
	detail_hint.text = "C/Start %d/%d" % [ceili(float(detail_scroll.scroll_vertical)/48)+1,ceili(float(limit)/48)+1]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"menu"):
		var limit := maxi(0,ceili(note.get_minimum_size().y-detail_scroll.size.y))
		detail_scroll.scroll_vertical = 0 if detail_scroll.scroll_vertical >= limit else mini(limit,detail_scroll.scroll_vertical+48)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"cancel"):
		get_viewport().set_input_as_handled()
		_complete("")
	elif event.is_action_pressed(&"accept") and list.has_focus() and not list.get_selected_items().is_empty():
		get_viewport().set_input_as_handled()
		_choose(list.get_selected_items()[0])

func _complete(id: String) -> void:
	if not _finished:
		_finished = true
		completed.emit(id)
