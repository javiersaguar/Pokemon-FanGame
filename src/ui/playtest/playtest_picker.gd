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
	result.default_font = result.get_font(&"font",&"SmallLabel")
	result.default_font_size = 16
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
	list.item_selected.connect(func(index: int) -> void: note.text = str(shown[index].get("note","")))
	list.item_activated.connect(_choose)
	box.add_child(list)
	note = Label.new()
	note.clip_text = true
	box.add_child(note)
	var row := HBoxContainer.new()
	box.add_child(row)
	var choose := Button.new()
	choose.text = "Elegir"
	choose.pressed.connect(func() -> void:
		if not list.get_selected_items().is_empty(): _choose(list.get_selected_items()[0]))
	row.add_child(choose)
	var cancel := Button.new()
	cancel.text = "Volver / B"
	cancel.pressed.connect(func() -> void: completed.emit(""))
	row.add_child(cancel)
	_filter("")
	search.grab_focus()

func _filter(value: String) -> void:
	list.clear()
	shown.clear()
	for entry: Dictionary in entries:
		if value.is_empty() or (str(entry.label)+" "+str(entry.id)+" "+str(entry.get("note",""))).to_lower().contains(value.to_lower()):
			shown.append(entry)
			list.add_item(str(entry.label))
	if not shown.is_empty():
		list.select(0)
		note.text = str(shown[0].get("note",""))
	else: note.text = "Sin resultados"

func _choose(index: int) -> void:
	completed.emit(str(shown[index].id))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"cancel"):
		get_viewport().set_input_as_handled()
		completed.emit("")
	elif event.is_action_pressed(&"accept") and list.has_focus() and not list.get_selected_items().is_empty():
		get_viewport().set_input_as_handled()
		_choose(list.get_selected_items()[0])
