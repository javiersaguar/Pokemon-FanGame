class_name TitleScreen
extends MenuScreen
## Arranque y menú inicial. El logo de texto es una propuesta pendiente de Javier.
const LABELS := ["Continuar", "Nueva partida", "Cargar partida", "Opciones", "Créditos", "Salir"]
const INTRO_SECONDS := 10.0
const DEMO_SECONDS := 45.0
@export var skip_sequence := false
@export_range(0, 2) var logo_variant := 0
var stage: StringName = &"splash"
var footer: Label
var title_group: Control
var logo: Label
var pokemon: Array[Sprite2D] = []
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

func _ready() -> void:
	# Pie fijo durante toda la secuencia; la versión sale del proyecto.
	heading.hide()
	hint.hide()
	for node: Node in canvas.get_children():
		if node is ColorRect:
			node.hide()
	fill(Rect2(0, 0, 256, 192), Color("194d70"))
	_build_scenery()
	_message = label("", Rect2(18, 51, 220, 80), Color("fff4d8"))
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.add_theme_color_override(&"font_outline_color", Color("194d70"))
	_message.add_theme_constant_override(&"outline_size", 1)
	title_group = Control.new()
	title_group.mouse_filter = MOUSE_FILTER_IGNORE
	canvas.add_child(title_group)
	_build_logo()
	_start = label("Pulsa START / Intro / Z", Rect2(24, 139, 208, 20), Color("fff4d8"))
	_start.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
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
	# Texturas del pack a su tamaño nativo: capas recortadas, no pintadas por código.
	var scenery := load("res://assets/sprites/ui/battle/backgrounds/field.png") as Texture2D
	if scenery == null:
		scenery = load("res://assets/sprites/ui/battle/backgrounds/grass.png")
	for i: int in 3:
		var layer := TextureRect.new()
		var atlas := AtlasTexture.new()
		atlas.atlas = scenery
		atlas.region = [Rect2(0, 0, 384, 100), Rect2(0, 100, 384, 92), Rect2(0, 192, 384, 116)][i]
		layer.texture = atlas
		layer.position = Vector2(0, [0, 100, 192][i])
		layer.size = Vector2(576, 192 if i == 2 else atlas.region.size.y)
		layer.scale = Vector2(0.5, 0.5)
		layer.position *= 0.5
		layer.stretch_mode = TextureRect.STRETCH_TILE
		layer.texture_repeat = CanvasItem.TEXTURE_REPEAT_MIRROR
		layer.mouse_filter = MOUSE_FILTER_IGNORE
		canvas.add_child(layer)
		layers.append(layer)
	for i: int in 3:
		var sprite := Sprite2D.new()
		sprite.texture = load("res://assets/sprites/pokemon/front/%s.png" % ["bulbasaur", "charmander", "squirtle"][i])
		sprite.scale = Vector2(0.5, 0.5)
		sprite.position = Vector2(50 + i * 78, 108)
		canvas.add_child(sprite)
		pokemon.append(sprite)

func _build_logo() -> void:
	logo = Label.new()
	logo.text = "PANCHITO"
	logo.add_theme_color_override(&"font_color", Color("f0b030"))
	logo.add_theme_color_override(&"font_outline_color", Color("194d70"))
	logo.add_theme_constant_override(&"outline_size", 2)
	logo.position = Vector2(42, 47)
	logo.scale = Vector2(2, 2)
	var glint := ShaderMaterial.new()
	glint.shader = preload("res://src/ui/title/logo_glint.gdshader")
	logo.material = glint
	title_group.add_child(logo)
	var prefix := Label.new()
	prefix.text = "POKÉMON"
	prefix.position = Vector2(82, 27)
	prefix.add_theme_color_override(&"font_color", Color("fff4d8"))
	title_group.add_child(prefix)
	if logo_variant == 1:
		logo.position = Vector2(42, 45)
		logo.add_theme_color_override(&"font_color", Color("fff4d8"))
		logo.add_theme_color_override(&"font_outline_color", Color("80342e"))
		prefix.text = "P O K É M O N"
		prefix.position = Vector2(62, 24)
	elif logo_variant == 2:
		logo.text = "Panchito"
		logo.position = Vector2(52, 45)
		logo.add_theme_color_override(&"font_color", Color("8cc65a"))
		prefix.position = Vector2(91, 27)

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
	heading.text = "Pokémon Panchito"
	heading.add_theme_color_override(&"font_color", Color("fff4d8"))
	for sprite: Sprite2D in pokemon:
		sprite.visible = stage in [&"intro", &"title"]
	match stage:
		&"splash": _message.text = "Javier Saguar presenta"
		&"notice": _message.text = "Fangame sin ánimo de lucro.\nPokémon es propiedad de Nintendo,\nGame Freak y The Pokémon Company."
		&"intro": _message.text = "Pokémon Panchito"
		&"title":
			var config := ConfigFile.new()
			config.load("user://ui.cfg")
			config.set_value("title", "seen", true)
			config.save("user://ui.cfg")
			_seen = true
		&"menu":
			_refresh_card()
			run_menu.call_deferred()

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
	if UiPreferences.reduce_motion():
		for layer: TextureRect in layers: layer.position.x = 0
		for sprite: Sprite2D in pokemon: sprite.position.y = 108
		if logo: logo.position.y = 45; logo.modulate = Color.WHITE
		if _start: _start.modulate.a = 1.0
		_message.modulate.a = 1.0
	else:
		for i: int in layers.size():
			layers[i].position.x = -float(int(_clock * (i + 1) * 2.0) % 64) * 0.5
		for i: int in pokemon.size():
			pokemon[i].position.y = 108 + round(sin(_clock * 2.0 + i * 1.6) * 2.0)
		if logo:
			logo.position.y = 45 + round(sin(_clock * 1.4)) - round(12 * pow(maxf(0.0, 1.0 - _elapsed / 0.25), 2))
			logo.modulate = Color.WHITE.lerp(Color("fff4d8"), maxf(sin(_clock * 0.8), 0.0) * 0.3)
		if _start:
			_start.modulate.a = 0.65 + sin(_clock * 2.0) * 0.25
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
