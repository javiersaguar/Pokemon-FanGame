class_name TitleScreen
extends MenuScreen
## Arranque y menú inicial con la portada de Pokémon Spain (assets/sprites/ui/title/portada.png, de
## Javier): la imagen recorre la pantalla de lado a lado, el logo brilla, "Pulsa START" sube y parpadea,
## y al abrir el menú el fondo se oscurece y los botones entran uno a uno. Con "reducir animaciones",
## todo queda quieto en su sitio.
const LABELS := ["Continuar", "Nueva partida", "Cargar partida", "Opciones", "Créditos", "Salir"]
const INTRO_SECONDS := 10.0
const DEMO_SECONDS := 45.0
const PORTADA := "res://assets/sprites/ui/title/portada.png"
## Logo de la portada (en píxeles de la imagen de 682x384): ahí va el brillo.
const LOGO_RECT := Rect2(200, 0, 252, 134)
## Segundos que tarda la imagen en ir de un lado al otro (y vuelta).
const PAN_SECONDS := 26.0
@export var skip_sequence := false
@export_range(0, 2) var logo_variant := 0
var stage: StringName = &"splash"
var footer: Label
var title_group: Control
var layers: Array[TextureRect] = []
var _elapsed := 0.0
var _clock := 0.0
var _active_frame := -1
var _seen := false
var _message: Label
var _start: Label
var _card: Label
var _thumbnail: TextureRect
var _card_panel: PanelContainer
var _subscreen: Control
var _backdrop: Control
var _portada: TextureRect
var _shine: TextureRect
var _flash: ColorRect
var _dim: ColorRect
var _tween: Tween

func _ready() -> void:
	# Pie fijo durante toda la secuencia; la versión sale del proyecto.
	heading.hide()
	hint.hide()
	for node: Node in canvas.get_children():
		if node is ColorRect:
			node.hide()
	fill(Rect2(0, 0, 256, 192), Color("194d70"))
	_build_scenery()
	_flash = fill(Rect2(0, 0, 256, 192), Color.WHITE)
	_flash.modulate.a = 0.0
	_dim = fill(Rect2(0, 0, 256, 192), Color("10101c"))
	_dim.modulate.a = 0.0
	_message = label("", Rect2(18, 51, 220, 80), Color("fff4d8"))
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.add_theme_color_override(&"font_outline_color", Color("194d70"))
	_message.add_theme_constant_override(&"outline_size", 1)
	title_group = Control.new()
	title_group.mouse_filter = MOUSE_FILTER_IGNORE
	canvas.add_child(title_group)
	_start = label("Pulsa START / Intro / Z", Rect2(24, 150, 208, 20), Color("fff4d8"))
	_start.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_start.add_theme_color_override(&"font_outline_color", Color("80342e"))
	_start.add_theme_constant_override(&"outline_size", 2)
	menu = make_menu(LABELS, Rect2(16, 45, 128, 126))
	menu.hide()
	_card_panel = panel(Rect2(150, 35, 98, 134))
	_thumbnail = TextureRect.new()
	_thumbnail.position = Vector2(155, 40)
	_thumbnail.size = Vector2(88, 66)
	_thumbnail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_thumbnail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_thumbnail.mouse_filter = MOUSE_FILTER_IGNORE
	canvas.add_child(_thumbnail)
	_card = label("", Rect2(156, 111, 87, 56), Color("382a38"), 8)
	_card.clip_text = true
	_card.hide()
	fill(Rect2(0, 174, 256, 18), Color("80342e"))
	footer = label("Realizado por Javier Saguar    v%s" % ProjectSettings.get_setting("application/config/version", "0.0.0"),
		Rect2(7, 177, 242, 12), Color("fff4d8"), 8)
	canvas.move_child(heading, -1)
	var config := ConfigFile.new()
	if config.load("user://ui.cfg") == OK:
		_seen = bool(config.get_value("title", "seen", false))
	set_stage(&"title" if skip_sequence else &"splash")

func _build_scenery() -> void:
	# La portada a su tamaño (682x384, un píxel por píxel de pantalla): cuelga de un nodo a escala 0,5
	# dentro del lienzo ×2. El brillo es otra vista del mismo logo, con un shader que lo aclara.
	_backdrop = Control.new()
	_backdrop.scale = Vector2(0.5, 0.5)
	_backdrop.mouse_filter = MOUSE_FILTER_IGNORE
	canvas.add_child(_backdrop)
	var texture := load(PORTADA) as Texture2D
	_portada = TextureRect.new()
	_portada.texture = texture
	_portada.size = texture.get_size() if texture else Vector2(512, 384)
	_portada.mouse_filter = MOUSE_FILTER_IGNORE
	_backdrop.add_child(_portada)
	layers.append(_portada)
	_shine = TextureRect.new()
	var logo_view := AtlasTexture.new()
	logo_view.atlas = texture
	logo_view.region = LOGO_RECT
	_shine.texture = logo_view
	_shine.position = LOGO_RECT.position
	_shine.size = LOGO_RECT.size
	_shine.mouse_filter = MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = preload("res://src/ui/title/portada_brillo.gdshader")
	_shine.material = material
	_portada.add_child(_shine)

func _pan_x() -> float:
	var travel := maxf(_portada.size.x - 512.0, 0.0)
	if UiPreferences.reduce_motion():
		return -round(travel / 2.0)
	return -round(travel * (0.5 - 0.5 * cos(_clock * TAU / PAN_SECONDS)))

func set_stage(value: StringName) -> void:
	stage = value
	_elapsed = 0.0
	_active_frame = Engine.get_process_frames()
	_message.visible = stage in [&"splash", &"notice", &"intro"]
	title_group.visible = stage == &"title"
	_start.visible = stage == &"title"
	menu.visible = stage == &"menu"
	_card.visible = stage == &"menu"
	_card_panel.visible = stage == &"menu"
	_thumbnail.visible = stage == &"menu"
	heading.visible = stage == &"menu"
	heading.text = "Menú principal"
	heading.add_theme_color_override(&"font_color", Color("fff4d8"))
	heading.add_theme_color_override(&"font_outline_color", Color("80342e"))
	heading.add_theme_constant_override(&"outline_size", 3)
	_backdrop.visible = stage in [&"intro", &"title", &"menu", &"flow"]
	_animate_stage()
	match stage:
		&"splash": _message.text = "Javier Saguar presenta"
		&"notice": _message.text = "Fangame sin ánimo de lucro.\nPokémon es propiedad de Nintendo,\nGame Freak y The Pokémon Company."
		&"intro": _message.text = ""
		&"title":
			var config := ConfigFile.new()
			config.load("user://ui.cfg")
			config.set_value("title", "seen", true)
			config.save("user://ui.cfg")
			_seen = true
		&"menu":
			_refresh_card()
			run_menu.call_deferred()

## Entradas animadas: destello al aparecer la portada, "Pulsa START" que sube, y en el menú el
## fondo que se oscurece, el menú que entra por la izquierda con los botones uno a uno y la ficha
## de la partida por la derecha.
func _animate_stage() -> void:
	if _tween:
		_tween.kill()
	var still := UiPreferences.reduce_motion()
	_flash.modulate.a = 0.0
	_dim.modulate.a = 0.45 if stage == &"menu" else 0.0
	_start.position.y = 150
	menu.position.x = 16
	_card_panel.position.x = 150
	for button: Control in menu.get_children():
		button.modulate.a = 1.0
		button.scale = Vector2.ONE
	if still or not is_inside_tree() or not stage in [&"intro", &"title", &"menu"]:
		return
	_tween = create_tween()
	match stage:
		&"intro":
			_flash.modulate.a = 1.0
			_tween.tween_property(_flash, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_OUT)
		&"title":
			_start.position.y = 166
			_tween.tween_property(_start, "position:y", 150.0, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		&"menu":
			_dim.modulate.a = 0.0
			_tween.set_parallel()
			_tween.tween_property(_dim, "modulate:a", 0.45, 0.3)
			menu.position.x = -140
			_tween.tween_property(menu, "position:x", 16.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			_card_panel.position.x = 262
			_tween.tween_property(_card_panel, "position:x", 150.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(0.1)
			var buttons := menu.get_children()
			for i: int in buttons.size():
				var button := buttons[i] as Control
				button.modulate.a = 0.0
				button.pivot_offset = Vector2(0, 9)
				button.scale = Vector2(0.2, 1.0)
				_tween.tween_property(button, "modulate:a", 1.0, 0.2).set_delay(0.15 + i * 0.07)
				_tween.tween_property(button, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.15 + i * 0.07)

func _refresh_card() -> void:
	var slot := SaveManager.last_used_slot()
	var summary := SaveManager.slot_summary(slot) if slot > 0 else {}
	_thumbnail.texture = SaveManager.thumbnail(slot) if slot > 0 else null
	menu.set_disabled(0, summary.is_empty() or summary.get("status", "") == "finished")
	_card.text = "Sin partida guardada" if summary.is_empty() else "%s\n%s / %d med.\n%s\n%d min" % [
		summary.get("player_name", ""), "RandomLocke" if summary.get("mode", "normal") == "randomlocke" else "Normal",
		int(summary.get("badges", 0)), summary.get("map_name", ""), int(float(summary.get("play_time", 0)) / 60)]

func _process(delta: float) -> void:
	_clock += delta
	_elapsed += delta
	_portada.position.x = _pan_x()
	if UiPreferences.reduce_motion():
		_shine.visible = false
		if _start: _start.modulate.a = 1.0
		_message.modulate.a = 1.0
	else:
		_shine.visible = true
		if _start:
			_start.modulate.a = 0.65 + sin(_clock * 3.0) * 0.35
		if _message.visible:
			_message.modulate.a = minf(_elapsed / 0.2, 1.0)
	match stage:
		&"splash":
			if _elapsed >= 1.6: set_stage(&"notice")
		&"notice":
			if _elapsed >= 2.0: set_stage(&"intro")
		&"intro":
			if _elapsed >= INTRO_SECONDS: set_stage(&"title")
		&"title":
			if _elapsed >= DEMO_SECONDS: set_stage(&"intro")

func _unhandled_input(event: InputEvent) -> void:
	if Engine.get_process_frames() == _active_frame or _subscreen != null:
		return
	if stage == &"menu" or not event.is_pressed() or event.is_echo():
		return
	if event is InputEventMouseMotion:
		return
	if stage == &"splash" and not _seen:
		return
	match stage:
		&"splash": set_stage(&"notice")
		&"notice": set_stage(&"intro")
		&"intro": set_stage(&"title")
		&"title": set_stage(&"menu")
	get_viewport().set_input_as_handled()

func run_menu() -> void:
	while is_inside_tree() and stage == &"menu":
		var choice := await menu.choose(1 if menu._is_disabled(0) else -1)
		if choice < 0:
			set_stage(&"title")
			return
		match choice:
			0:
				set_stage(&"flow")
				_runtime().load_from_title(SaveManager.last_used_slot(), self)
				return
			1:
				var slot := await SceneManager.choose_slot(true)
				if slot > 0:
					set_stage(&"flow")
					_runtime().new_from_title(slot, self)
					return
			2:
				var slot := await SceneManager.choose_slot()
				if slot > 0:
					set_stage(&"flow")
					_runtime().load_from_title(slot, self)
					return
			3: await show_subscreen(OptionsScreen.new())
			4: await show_subscreen(load("res://src/ui/title/credits_screen.gd").new())
			5:
				if await Dialogue.ask_yes_no("¿Salir del juego?"):
					get_tree().quit()
					return
		_refresh_card()

func show_subscreen(screen: Control) -> void:
	_subscreen = screen
	add_child(screen)
	screen.hint.position.y = 165
	screen.label(footer.text, Rect2(7, 177, 242, 12), Color("fff4d8"), 8)
	await screen.closed
	screen.queue_free()
	await get_tree().process_frame
	_subscreen = null

func _runtime() -> UiRuntime:
	for node: Node in SceneManager.ui_layer.get_children():
		if node is UiRuntime:
			return node
	return null
