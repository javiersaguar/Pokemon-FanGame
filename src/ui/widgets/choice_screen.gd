class_name ChoiceScreen
extends MenuScreen
## Lista con páginas, descripción e icono a su tamaño nativo.
signal chosen(index: int)
const ROWS := 6
var caption := ""
var choices := PackedStringArray()
var notes := PackedStringArray()
var images: Array[Texture2D] = []
var page := 0
## Opciones: lista a todo el ancho y la explicación con la fuente normal (tamaño 10).
var wide := false
var _detail_scroll: ScrollContainer
var _detail_hint: Label
var _body: Label
var _icon: Sprite2D
var _done := false
var _frame_time := 0.0

static func pick(title: String, labels: PackedStringArray, descriptions := PackedStringArray(), textures: Array[Texture2D] = []) -> int:
	if labels.is_empty(): return -1
	var screen := ChoiceScreen.new()
	screen.caption = title
	screen.choices = labels
	screen.notes = descriptions
	screen.images = textures
	SceneManager.push_menu(screen)
	var index: int = await screen.chosen
	SceneManager.pop_menu(screen)
	return index

func _ready() -> void:
	if wide:
		fill(Rect2(4, 146, 248, 26), Color("fff4d8"))
	else:
		panel(Rect2(160, 34, 88, 130))
	_icon = Sprite2D.new()
	_icon.position = Vector2(204, 58)
	_icon.scale = Vector2(0.5, 0.5)
	canvas.add_child(_icon)
	var detail := Rect2(168, 83, 72, 78) if not wide else Rect2(8, 148, 240, 24)
	var detail_size := 8 if not wide else 10
	_body = label("", detail, Color("382a38"), detail_size)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_scroll = ScrollContainer.new()
	_detail_scroll.position = detail.position
	_detail_scroll.size = detail.size
	_detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_detail_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	canvas.add_child(_detail_scroll)
	canvas.remove_child(_body)
	_body.position = Vector2.ZERO
	_body.size = Vector2(detail.size.x - 2, 0)
	_body.custom_minimum_size.x = detail.size.x - 2
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_scroll.add_child(_body)
	_detail_hint = label("", Rect2(168, 151, 72, 10), Color("382a38"), 8)
	_detail_hint.visible = not wide
	_refresh()
	run.call_deferred()

func _refresh() -> void:
	if menu:
		canvas.remove_child(menu)
		menu.queue_free()
	heading.text = caption
	var count := ceili(float(choices.size()) / ROWS)
	if wide:
		hint.add_theme_font_size_override(&"font_size", 10)
		hint.position = Vector2(8, 175)
		hint.size = Vector2(240, 16)
		hint.text = "Izq/Der  %d/%d     A: elegir     B: volver" % [page + 1, maxi(count, 1)]
	else:
		hint.text = "Izq/Der %d/%d / Z/A: elegir / X/B: volver" % [page + 1, maxi(count, 1)]
	var labels := choices.slice(page * ROWS, mini((page + 1) * ROWS, choices.size()))
	if labels.is_empty(): labels = ["Sin contenido"]
	menu = make_menu(labels, Rect2(8, 28, 240, 118) if wide else Rect2(12, 34, 140, 126))
	if wide:
		menu.add_theme_constant_override(&"v_separation", 1)
	for button: BattleButton in menu.get_children():
		button.compact = not wide
		button.align_left = not wide
	menu.set_disabled(0, choices.is_empty())
	menu.selection_changed.connect(_show_detail)
	_show_detail(0)

func _show_detail(index: int) -> void:
	var absolute := page * ROWS + index
	_detail_scroll.scroll_vertical = 0
	_body.text = notes[absolute] if absolute < notes.size() else ""
	_icon.texture = images[absolute] if absolute < images.size() else null
	_icon.visible = _icon.texture != null

func run() -> void:
	while is_inside_tree() and not _done:
		var index := await menu.choose()
		if index == -2:
			_refresh()
			continue
		_done = true
		chosen.emit(page * ROWS + index if index >= 0 else -1)
		return

func _unhandled_input(event: InputEvent) -> void:
	if _done or not menu.is_choosing or Engine.get_process_frames() == menu._active_frame : return
	if event.is_action_pressed(&"menu"):
		var limit := maxi(0, ceili(_body.get_minimum_size().y - _detail_scroll.size.y))
		_detail_scroll.scroll_vertical = 0 if _detail_scroll.scroll_vertical >= limit else mini(limit, _detail_scroll.scroll_vertical + 32)
		get_viewport().set_input_as_handled()
		return
	if choices.size() <= ROWS: return
	if event.is_action_pressed(&"move_left", true) or event.is_action_pressed(&"move_right", true):
		page = wrapi(page + (1 if event.is_action_pressed(&"move_right", true) else -1), 0, ceili(float(choices.size()) / ROWS))
		get_viewport().set_input_as_handled()
		menu._finish(-2)

func _process(delta: float) -> void:
	if wide:
		_detail_hint.visible = false
	elif _detail_scroll:
		var limit := maxi(0, ceili(_body.get_minimum_size().y - _detail_scroll.size.y))
		_detail_hint.visible = limit > 0
		_detail_hint.text = "C/Start %d/%d" % [ceili(float(_detail_scroll.scroll_vertical) / 32) + 1, ceili(float(limit) / 32) + 1]
	if UiPreferences.reduce_motion(): return
	_frame_time += delta
	var atlas := _icon.texture as AtlasTexture if _icon else null
	if atlas and _frame_time >= 0.25:
		_frame_time = 0.0
		atlas.region.position.x = 0.0 if atlas.region.position.x > 0.0 else atlas.region.size.x
