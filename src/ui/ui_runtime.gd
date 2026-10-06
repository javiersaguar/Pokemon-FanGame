class_name UiRuntime
extends Control
## Avisos y peticiones de UI que deben vivir también fuera del menú inicial.
var canvas: UiCanvas
var toast: Label
var _remaining := 0.0
var name_screen: NameKeyboard
var _nickname_active := false
var _generation := 0

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	theme = preload("res://src/ui/theme/main_theme.tres")
	canvas = UiCanvas.new()
	add_child(canvas)
	toast = Label.new()
	toast.position = Vector2(8, 8)
	toast.size = Vector2(240, 18)
	toast.add_theme_color_override(&"font_color", Color("fff4d8"))
	toast.add_theme_color_override(&"font_shadow_color", Color("382a38"))
	toast.add_theme_constant_override(&"shadow_offset_x", 1)
	toast.add_theme_constant_override(&"shadow_offset_y", 1)
	toast.mouse_filter = MOUSE_FILTER_IGNORE
	canvas.add_child(toast)
	toast.hide()
	EventBus.always_run_changed.connect(_run_changed)
	Cutscene.name_requested.connect(_name_requested)
	EventBus.locke_nickname_requested.connect(_nickname_requested)

func _run_changed(enabled: bool) -> void:
	toast.text = "Correr: %s" % ("activado" if enabled else "desactivado")
	toast.show()
	_remaining = 2.0
	# Los menús se añaden después: el aviso debe seguir siendo legible encima.
	get_parent().move_child(self, -1)

func _process(delta: float) -> void:
	_remaining -= delta
	if _remaining <= 0.0:
		toast.hide()

# Las transiciones pueden liberar el título; su corrutina vive aquí.
func new_from_title(slot: int, title: Control) -> void:
	var flow: RefCounted = load("res://src/main/randomlocke_fallback.gd").new()
	await flow.run(slot)
	if is_instance_valid(title) and not GameState.in_game:
		title.set_stage(&"menu")

func load_from_title(slot: int, title: Control) -> void:
	var error := await SceneManager.continue_game(slot)
	if error != OK and is_instance_valid(title):
		await Dialogue.say("No se pudo cargar: %s." % error_string(error))
		if is_instance_valid(title):
			title.set_stage(&"menu")

func _name_requested(kind: StringName, initial: String) -> void:
	# Un listener adicional de pruebas u otra UI puede tomar la petición.
	if Cutscene.name_requested.get_connections().size() > 2 or is_instance_valid(name_screen):
		return
	name_screen = NameKeyboard.new()
	name_screen.kind = kind
	name_screen.initial = initial
	get_parent().add_child(name_screen)
	var keyboard := name_screen
	var generation := _generation
	var value: String = await keyboard.completed
	if generation != _generation:
		return
	name_screen.queue_free()
	name_screen = null
	Cutscene.submit_name(kind, value)

func _nickname_requested(token: String, pokemon: Dictionary) -> void:
	if _nickname_active or GameState.locke == null or not GameState.locke.pending.has(token):
		return
	_nickname_active = true
	name_screen = NameKeyboard.new()
	name_screen.kind = &"nickname"
	name_screen.prompt = "Mote para %s" % DataDB.species(StringName(pokemon.species)).name
	get_parent().add_child(name_screen)
	var keyboard := name_screen
	var generation := _generation
	var value: String = await keyboard.completed
	if generation != _generation:
		return
	if GameState.locke != null:
		GameState.locke.complete_capture(token, value)
	name_screen.queue_free()
	name_screen = null
	_nickname_active = false
	SceneManager.resume_pending_nicknames.call_deferred()

func clear_transient_ui() -> void:
	_generation += 1
	if is_instance_valid(name_screen):
		var keyboard := name_screen
		name_screen = null
		keyboard._finish("") # Despierta la corrutina anterior sin modificar identidad/captura.
		keyboard.queue_free()
	_nickname_active = false
	toast.hide()
