class_name UiPreferences
extends RefCounted
## Preferencias de dispositivo en ui.cfg; correr/estilo de la partida en GameState.
const FRAME_FILES := ["databox","button_amarillo","button_verde"]
const FRAME_NAMES := ["Claro","Amarillo","Verde"]
static var loaded := false
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
	if DisplayServer.get_name() != "headless": DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if values.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
static func set_value(key: String, value: Variant, save := true) -> void:
	initialize()
	values[key] = value
	match key:
		"text_speed": Dialogue.text_speed = int(value)
		"frame": apply_frame()
		"fullscreen":
			if DisplayServer.get_name() != "headless": DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED)
		"battle_style":
			if GameState.in_game: GameState.set_var(&"battle_style",str(value))
		_:
			if StringName(key) in AudioManager.BUSES: AudioManager.set_volume(StringName(key),float(value))
	if save:
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
