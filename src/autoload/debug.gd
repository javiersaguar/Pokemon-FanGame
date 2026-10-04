extends Node
## Menú y consola de depuración (acción `debug`, F9). Solo en builds de debug.
## Contrato: docs/contratos.md (sección Debug). Cada agente añade sus comandos
## con Debug.register_command() desde su propio código, sin tocar este archivo.

## Trucos que consulta el mundo.
var noclip := false
var encounters_disabled := false

var is_open := false

var _commands: Dictionary[String, Dictionary] = {}
var _panel: PanelContainer
var _tabs: TabContainer
var _maps: ItemList
var _flags: ItemList
var _flag_input: LineEdit
var _vars_label: Label
var _noclip_check: CheckBox
var _encounters_check: CheckBox
var _hour_spin: SpinBox
var _buttons_box: HFlowContainer
var _log: RichTextLabel
var _console_input: LineEdit


## La interfaz se crea en _init para que otros autoloads puedan registrar
## comandos en su _ready (los autoloads se instancian todos antes del primer _ready).
func _init() -> void:
	if not OS.is_debug_build():
		set_process_input(false)
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_register_builtin_commands()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug"):
		get_viewport().set_input_as_handled()
		toggle()


func toggle() -> void:
	if is_open:
		close()
	else:
		open()


func open() -> void:
	if is_open or not OS.is_debug_build():
		return
	is_open = true
	GameState.lock_input(&"debug")
	_refresh()
	_panel.show()
	_tabs.get_tab_bar().grab_focus()


func close() -> void:
	if not is_open:
		return
	is_open = false
	_panel.hide()
	GameState.unlock_input(&"debug")


## Añade un comando a la consola. `callable` recibe los argumentos
## (PackedStringArray) y devuelve el texto a mostrar. Si `button_label` no está
## vacío, aparece también como botón (sin argumentos) en la pestaña Trucos.
func register_command(command: String, callable: Callable, help: String = "",
		button_label: String = "") -> void:
	if not OS.is_debug_build():
		return
	_commands[command] = {"callable": callable, "help": help}
	if button_label != "":
		var button := Button.new()
		button.text = button_label
		button.pressed.connect(_exec.bind(command))
		_buttons_box.add_child(button)


## Ejecuta una línea de consola ("tp test/test_room") y devuelve su salida.
func run_command(line: String) -> String:
	var parts := line.strip_edges().split(" ", false)
	if parts.is_empty():
		return ""
	var command := parts[0]
	if not _commands.has(command):
		return "Comando desconocido: %s (prueba 'help')." % command
	var result: Variant = _commands[command]["callable"].call(parts.slice(1))
	return "" if result == null else str(result)


# --- Comandos de serie ---

func _register_builtin_commands() -> void:
	register_command("help", _cmd_help, "Lista los comandos.")
	register_command("tp", _cmd_tp, "tp <mapa> [spawn] · tp <mapa> <x> <y>")
	register_command("flag", _cmd_flag, "flag <clave> [on|off]")
	register_command("var", _cmd_var, "var <clave> [valor]")
	register_command("money", _cmd_money, "money <cantidad>")
	register_command("hour", _cmd_hour, "hour <desplazamiento en horas>")
	register_command("noclip", _cmd_noclip, "noclip [on|off]")
	register_command("encounters", _cmd_encounters, "encounters [on|off]")
	register_command("save", _cmd_save, "save [ranura] (por defecto, la de la partida)", "Guardar")
	register_command("load", _cmd_load, "load [ranura] (por defecto, la última usada)", "Cargar")
	register_command("slots", _cmd_slots, "Lista las partidas guardadas.")
	register_command("battle", _cmd_battle, "Combate de prueba (se puede perder).",
		"Combate de prueba")
	register_command("title", _cmd_title, "Vuelve a la pantalla de título.", "Título")


func _cmd_help(_args: PackedStringArray) -> String:
	var lines := PackedStringArray()
	var names := _commands.keys()
	names.sort()
	for command: String in names:
		lines.append("%s  %s" % [command, _commands[command]["help"]])
	return "\n".join(lines)


func _cmd_tp(args: PackedStringArray) -> String:
	if args.is_empty():
		return "Uso: tp <mapa> [spawn] · tp <mapa> <x> <y>"
	var map_id := StringName(args[0])
	if not SceneManager.map_exists(map_id):
		return "No existe el mapa %s." % map_id
	close()
	if args.size() >= 3:
		SceneManager.change_map_at(map_id, Vector2i(args[1].to_int(), args[2].to_int()))
	else:
		SceneManager.change_map(map_id, StringName(args[1]) if args.size() > 1
			else MapRoot.DEFAULT_SPAWN)
	return "Teletransporte a %s." % map_id


func _cmd_flag(args: PackedStringArray) -> String:
	if args.is_empty():
		return "Uso: flag <clave> [on|off]"
	var key := StringName(args[0])
	if args.size() > 1:
		GameState.set_flag(key, _parse_on(args[1]))
		_refresh()
	return "%s = %s" % [key, GameState.flag(key)]


func _cmd_var(args: PackedStringArray) -> String:
	if args.is_empty():
		return "Uso: var <clave> [valor]"
	var key := StringName(args[0])
	if args.size() > 1:
		var value: Variant = args[1]
		if args[1].is_valid_int():
			value = args[1].to_int()
		elif args[1].is_valid_float():
			value = args[1].to_float()
		GameState.set_var(key, value)
		_refresh()
	return "%s = %s" % [key, GameState.get_var(key)]


func _cmd_money(args: PackedStringArray) -> String:
	if not args.is_empty():
		GameState.add_money(args[0].to_int() - GameState.money)
	return "Dinero: %d" % GameState.money


func _cmd_hour(args: PackedStringArray) -> String:
	if not args.is_empty():
		Clock.set_debug_hour_offset(args[0].to_int())
		_hour_spin.set_value_no_signal(Clock.debug_hour_offset)
	return "Hora: %02d:%02d (%s)" % [Clock.hour(), Clock.minute(), Clock.period()]


func _cmd_noclip(args: PackedStringArray) -> String:
	noclip = _parse_on(args[0]) if not args.is_empty() else not noclip
	_noclip_check.set_pressed_no_signal(noclip)
	return "Atravesar paredes: %s" % _on_text(noclip)


func _cmd_encounters(args: PackedStringArray) -> String:
	encounters_disabled = not _parse_on(args[0]) if not args.is_empty() else not encounters_disabled
	_encounters_check.set_pressed_no_signal(encounters_disabled)
	return "Encuentros: %s" % _on_text(not encounters_disabled)


func _cmd_save(args: PackedStringArray) -> String:
	var slot := args[0].to_int() if not args.is_empty() else SaveManager.current_slot()
	var err := SaveManager.save_game(slot)
	return "Guardado en la ranura %d." % slot if err == OK else "Error al guardar: %s" % error_string(err)


func _cmd_load(args: PackedStringArray) -> String:
	var slot := args[0].to_int() if not args.is_empty() else SaveManager.last_used_slot()
	if not SaveManager.has_save(slot):
		return "La ranura %d está vacía." % slot
	close()
	SceneManager.continue_game(slot)
	return "Cargando la ranura %d..." % slot


func _cmd_slots(_args: PackedStringArray) -> String:
	var lines := PackedStringArray()
	for summary: Dictionary in SaveManager.list_slots():
		if summary.is_empty():
			continue
		lines.append("%d: %s · %s · %s · %d medallas · %s" % [summary["slot"], summary.get("mode", "normal"),
			summary.get("player_name", ""), summary.get("map_name", ""), summary.get("badges", 0),
			summary.get("saved_at", "")])
	var last := SaveManager.last_used_slot()
	lines.append("Ranuras: %d · en curso: %d · última usada: %d" % [SaveManager.slot_count(), GameState.slot, last])
	return "\n".join(lines)


func _cmd_battle(_args: PackedStringArray) -> String:
	close()
	SceneManager.start_battle({"can_lose": true, "debug": true})
	return "Combate de prueba."


func _cmd_title(_args: PackedStringArray) -> String:
	close()
	SceneManager.go_to_title()
	return "Volviendo al título."


static func _parse_on(text: String) -> bool:
	return text.to_lower() in ["on", "1", "true", "si", "sí"]


static func _on_text(value: bool) -> String:
	return "sí" if value else "no"


# --- Interfaz ---

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.offset_left = 4
	_panel.offset_top = 4
	_panel.offset_right = -4
	_panel.offset_bottom = -4
	layer.add_child(_panel)
	_panel.hide()

	_tabs = TabContainer.new()
	_panel.add_child(_tabs)

	_maps = ItemList.new()
	_maps.name = "Mapas"
	_maps.item_activated.connect(func(i: int) -> void: _exec("tp " + _maps.get_item_text(i)))
	_tabs.add_child(_maps)

	var flags_tab := VBoxContainer.new()
	flags_tab.name = "Flags"
	_tabs.add_child(flags_tab)
	var flag_row := HBoxContainer.new()
	flags_tab.add_child(flag_row)
	_flag_input = LineEdit.new()
	_flag_input.placeholder_text = "clave de la flag"
	_flag_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_flag_input.text_submitted.connect(func(_t: String) -> void: _activate_typed_flag())
	flag_row.add_child(_flag_input)
	var flag_button := Button.new()
	flag_button.text = "Activar"
	flag_button.pressed.connect(_activate_typed_flag)
	flag_row.add_child(flag_button)
	_flags = ItemList.new()
	_flags.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_flags.item_activated.connect(func(i: int) -> void: _exec("flag %s off" % _flags.get_item_text(i)))
	flags_tab.add_child(_flags)
	_vars_label = Label.new()
	_vars_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	flags_tab.add_child(_vars_label)

	var cheats := VBoxContainer.new()
	cheats.name = "Trucos"
	_tabs.add_child(cheats)
	_noclip_check = CheckBox.new()
	_noclip_check.text = "Atravesar paredes"
	_noclip_check.toggled.connect(func(on: bool) -> void: _exec("noclip " + ("on" if on else "off")))
	cheats.add_child(_noclip_check)
	_encounters_check = CheckBox.new()
	_encounters_check.text = "Sin encuentros"
	_encounters_check.toggled.connect(func(on: bool) -> void: _exec("encounters " + ("off" if on else "on")))
	cheats.add_child(_encounters_check)
	var hour_row := HBoxContainer.new()
	cheats.add_child(hour_row)
	var hour_label := Label.new()
	hour_label.text = "Desplazar la hora"
	hour_row.add_child(hour_label)
	_hour_spin = SpinBox.new()
	_hour_spin.min_value = -23
	_hour_spin.max_value = 23
	_hour_spin.value_changed.connect(func(v: float) -> void: _exec("hour %d" % int(v)))
	hour_row.add_child(_hour_spin)
	_buttons_box = HFlowContainer.new()
	cheats.add_child(_buttons_box)

	var console := VBoxContainer.new()
	console.name = "Consola"
	_tabs.add_child(console)
	_log = RichTextLabel.new()
	_log.scroll_following = true
	_log.selection_enabled = true
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	console.add_child(_log)
	_console_input = LineEdit.new()
	_console_input.placeholder_text = "comando (help para la lista)"
	_console_input.keep_editing_on_text_submit = true
	_console_input.text_submitted.connect(_on_console_submitted)
	console.add_child(_console_input)


func _on_console_submitted(text: String) -> void:
	_print("> " + text)
	_exec(text)
	_console_input.clear()


func _exec(line: String) -> void:
	_print(run_command(line))


func _refresh() -> void:
	if _maps == null:
		return
	_maps.clear()
	for map_id: StringName in SceneManager.list_maps():
		_maps.add_item(String(map_id))
	_flags.clear()
	var keys := GameState.flags.keys()
	keys.sort()
	for key: StringName in keys:
		_flags.add_item(String(key))
	var var_lines := PackedStringArray()
	for key: StringName in GameState.vars:
		var_lines.append("%s = %s" % [key, GameState.vars[key]])
	_vars_label.text = "Variables: " + (", ".join(var_lines) if not var_lines.is_empty() else "ninguna")


func _activate_typed_flag() -> void:
	if _flag_input.text.strip_edges() == "":
		return
	_exec("flag %s on" % _flag_input.text.strip_edges())
	_flag_input.clear()


func _print(text: String) -> void:
	if text == "":
		return
	print("[Debug] ", text)
	if _log:
		_log.add_text(text + "\n")
