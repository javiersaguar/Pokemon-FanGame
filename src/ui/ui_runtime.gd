class_name UiRuntime
extends Control
## Avisos y peticiones de UI que deben vivir también fuera del menú inicial.
var zone: LockeZoneIndicator
var _game_over_active := false
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
	zone = LockeZoneIndicator.new()
	canvas.add_child(zone)
	EventBus.locke_zone_entered.connect(_zone_entered)
	EventBus.locke_game_over.connect(_game_over_requested)
	EventBus.menu_opened.connect(func(_menu: Node) -> void:
		SceneManager.hide_flow_status()
		zone.hide())
	EventBus.menu_closed.connect(_menu_closed)
	EventBus.always_run_changed.connect(_run_changed)
	Cutscene.name_requested.connect(_name_requested)
	EventBus.locke_nickname_requested.connect(_nickname_requested)

func _run_changed(enabled: bool) -> void:
	toast.text = "Correr: %s" % ("activado" if enabled else "desactivado")
	toast.show()
	_remaining = 2.0
	zone.hide()
	# Los menús se añaden después: el aviso debe seguir siendo legible encima.
	get_parent().move_child(self, -1)

func _process(delta: float) -> void:
	_remaining -= delta
	if _remaining <= 0.0 and toast.visible:
		toast.hide()
		_restore_zone()

# Las transiciones pueden liberar el título; su corrutina vive aquí.
func new_from_title(slot: int, title: Control) -> void:
	var flow: RefCounted = load("res://src/ui/randomlocke/randomlocke_flow.gd").new()
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
	SceneManager.hide_flow_status()
	zone.hide()
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
	_restore_zone.call_deferred()

func _nickname_requested(token: String, pokemon: Dictionary) -> void:
	if _nickname_active or GameState.locke == null or not GameState.locke.pending.has(token):
		return
	_nickname_active = true
	SceneManager.hide_flow_status()
	zone.hide()
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
	_restore_zone.call_deferred()

func clear_transient_ui() -> void:
	_generation += 1
	if is_instance_valid(name_screen):
		var keyboard := name_screen
		name_screen = null
		keyboard._finish("") # Despierta la corrutina anterior sin modificar identidad/captura.
		keyboard.queue_free()
	_nickname_active = false
	_game_over_active = false
	zone.hide()
	toast.hide()

func load_from_pause(slot: int, pause: Control) -> void:
	var error := await SceneManager.continue_game(slot)
	if error != OK and is_instance_valid(pause):
		await Dialogue.say("No se pudo cargar: %s." % error_string(error))
		if is_instance_valid(pause): pause.run.call_deferred()

func _menu_closed(_menu: Node) -> void:
	_restore_zone.call_deferred()

func _restore_zone() -> void:
	if GameState.in_game and not SceneManager.is_menu_open() and not is_instance_valid(name_screen):
		SceneManager.update_zone_indicator()

func _zone_entered(zone_id: String, status: String) -> void:
	SceneManager.hide_flow_status()
	var visible_here := GameState.in_game and GameState.locke != null and not SceneManager.is_menu_open() and not is_instance_valid(name_screen) and _remaining <= 0.0
	if not visible_here:
		zone.hide()
		return
	var rules := GameState.locke.rules.rules()
	var limit := bool(rules.get("locke_rules",true)) and bool(rules.get("first_encounter",true))
	var map_name := SceneManager.current_map.get_display_name() if is_instance_valid(SceneManager.current_map) else zone_id
	zone.set_zone(map_name,status,limit)
	zone.show()
func _game_over_requested(snapshot: Dictionary) -> void:
	if _game_over_active: return
	_game_over_active = true
	var generation := _generation
	while SceneManager.in_battle:
		await get_tree().process_frame
		if generation != _generation: return
	if generation != _generation or not GameState.in_game: return
	var screen := LockeGameOverScreen.new()
	screen.snapshot = snapshot.duplicate(true)
	SceneManager.push_menu(screen)
