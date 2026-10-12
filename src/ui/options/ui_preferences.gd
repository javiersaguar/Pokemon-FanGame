class_name UiPreferences
extends RefCounted
## Preferencias de dispositivo en ui.cfg; correr/estilo de la partida en GameState.
const FRAME_FILES := ["databox","button_amarillo","button_verde"]
const FRAME_NAMES := ["Claro","Amarillo","Verde"]
static var loaded := false
static var _display_hooked := false
static var _pinning := false
static var values: Dictionary = {"always_run":false,"text_speed":40,"frame":0,"fullscreen":false,"reduce_animations":false,"real_photos":true,"battle_style":"fixed","BGM":1.0,"SE":1.0,"ME":1.0,"Cries":1.0,"Ambient":1.0}
static func initialize() -> void:
	if loaded: return
	loaded = true
	values.always_run = bool(GameState.world_config.get("new_game",{}).get("always_run",false))
	var config := ConfigFile.new()
	if config.load("user://ui.cfg") == OK:
		for key: String in values:
			values[key] = config.get_value("options",key,values[key])
	values.text_speed = int(values.text_speed) if int(values.text_speed) in [0,20,40,80] else 40
	values.frame = clampi(int(values.frame),0,2)
	values.battle_style = "shift" if values.battle_style == "shift" else "fixed"
	Dialogue.text_speed = values.text_speed
	for bus: StringName in AudioManager.BUSES: AudioManager.set_volume(bus,clampf(float(values[String(bus)]),0,1))
	apply_frame()
	apply_display()
static func set_value(key: String, value: Variant, save := true) -> void:
	initialize()
	values[key] = value
	match key:
		"text_speed": Dialogue.text_speed = int(value)
		"frame": apply_frame()
		"fullscreen":
			apply_display()
		"battle_style":
			if GameState.in_game: GameState.set_var(&"battle_style",str(value))
		_:
			if StringName(key) in AudioManager.BUSES: AudioManager.set_volume(StringName(key),float(value))
	if save and not SaveManager.test_session_active:
		var config := ConfigFile.new()
		config.load("user://ui.cfg")
		for field: String in values: config.set_value("options",field,values[field])
		config.save("user://ui.cfg")
static func battle_style() -> StringName:
	initialize()
	return StringName(GameState.var_str(&"battle_style",str(values.battle_style)) if GameState.in_game else str(values.battle_style))
static func apply_frame() -> void:
	var theme: Theme = load("res://src/ui/theme/main_theme.tres")
	var texture: Texture2D = load("res://assets/sprites/ui/battle/%s.png" % FRAME_FILES[int(values.frame)])
	for type: StringName in [&"Panel",&"PanelContainer",&"SmallFrame"]:
		var style := theme.get_stylebox(&"panel",type) as StyleBoxTexture
		if style: style.texture = texture

static func reduce_motion() -> bool:
	initialize()
	return bool(values.reduce_animations)

## Fotos reales de los personajes en combate (si existen; ver RealPhoto).
static func real_photos() -> bool:
	initialize()
	return bool(values.real_photos)

static func always_run() -> bool:
	initialize()
	return GameState.always_run if GameState.in_game else bool(values.always_run)


## Escala entera de 512×384 que cabe en `area` (al menos ×1).
static func integer_scale(area: Vector2i, base: Vector2i) -> int:
	if base.x < 1 or base.y < 1:
		return 1
	return maxi(1, mini(area.x / base.x, area.y / base.y))


static func fitted_window(area: Vector2i, base: Vector2i) -> Vector2i:
	return base * integer_scale(area, base)


static func base_size() -> Vector2i:
	return Vector2i(int(ProjectSettings.get_setting("display/window/size/viewport_width", 512)),
			int(ProjectSettings.get_setting("display/window/size/viewport_height", 384)))


## La pantalla completa del modo de ventana (exclusiva o sin bordes del sistema) cambia el
## swapchain de OpenGL al tamaño del monitor y, con el renderizador de compatibilidad, baja
## mucho los fotogramas. Se queda en modo ventana: sin bordes y del tamaño del monitor si está
## activa, o la mayor escala entera que quepa si no. El juego sigue dibujándose a 512×384.
static func apply_display() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	var window := tree.root
	var screen := window.current_screen
	window.mode = Window.MODE_WINDOWED
	if values.fullscreen:
		window.borderless = true
		window.size = DisplayServer.screen_get_size(screen)
		window.position = DisplayServer.screen_get_position(screen)
	else:
		window.borderless = false
		var usable := DisplayServer.screen_get_usable_rect(screen)
		var area := usable.size
		if area.x < 1 or area.y < 1:
			area = DisplayServer.screen_get_size(screen)
			usable.position = DisplayServer.screen_get_position(screen)
		var fitted := fitted_window(area, base_size())
		window.size = fitted
		window.position = usable.position + (area - fitted) / 2
	_pin_pixel_scale(window)
	if not _display_hooked:
		_display_hooked = true
		window.size_changed.connect(_on_window_resized)


static func _on_window_resized() -> void:
	if _pinning:
		return
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree:
		_pin_pixel_scale(tree.root)


static func _pin_pixel_scale(window: Window) -> void:
	_pinning = true
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	window.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	window.content_scale_size = base_size()
	window.content_scale_factor = 1.0
	_pinning = false
