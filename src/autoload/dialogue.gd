extends Node
## Cuadro de texto del mundo (Fase 5.6). Contrato: docs/contratos.md §9.1.
##   await Dialogue.say("¡Hola, {player}!")
##   var i := await Dialogue.ask("¿Eliges a Bulbasaur?", ["Sí", "No"])

## Para ask(): `cancel` no hace nada.
const NO_CANCEL := -2
const DEFAULT_TEXT_SPEED := 40
const LAYER := 30

const BOX_SCENE := preload("res://src/ui/dialogue/dialogue_box.tscn")
const CHOICE_SCENE := preload("res://src/ui/dialogue/choice_box.tscn")
const MAIN_THEME := preload("res://src/ui/theme/main_theme.tres")

signal _released

## true mientras hay un say() o un ask() en curso.
var is_open := false
## Caracteres por segundo (lo cambia Opciones). 0 = instantáneo.
var text_speed := DEFAULT_TEXT_SPEED:
	set(value):
		text_speed = maxi(value, 0)
		if _box:
			_box.text_speed = text_speed

var _box: DialogueBox
var _choice: ChoiceBox
## El cuadro sigue en pantalla un frame tras cada línea, por si llega otra.
var _shown := false
var _session := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var layer := CanvasLayer.new()
	layer.layer = LAYER
	add_child(layer)
	var root := Control.new()
	root.theme = MAIN_THEME
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)
	_box = BOX_SCENE.instantiate()
	_box.text_speed = text_speed
	_box.hide()
	root.add_child(_box)
	_choice = CHOICE_SCENE.instantiate()
	root.add_child(_choice)
	UiDebug.register()


## Muestra `text` y espera a que el jugador lo pase. `speaker`: nombre (String)
## o un objeto con `display_name`.
func say(text: String, speaker: Variant = null, vars: Dictionary = {}) -> void:
	await _begin()
	await _box.play(format_text(text, vars), _speaker_name(speaker, vars))
	_end()


## Pregunta con opciones. Devuelve el índice elegido. `cancel` devuelve
## `cancel_choice` (−1 = la última opción; NO_CANCEL = no se puede cancelar).
func ask(text: String, options: PackedStringArray, speaker: Variant = null,
		cancel_choice: int = -1, vars: Dictionary = {}) -> int:
	if options.is_empty():
		push_error("Dialogue.ask: no hay opciones para '%s'." % text)
		return -1
	await _begin()
	await _box.play(format_text(text, vars), _speaker_name(speaker, vars), false)
	var labels := PackedStringArray()
	for option: String in options:
		labels.append(format_text(option, vars))
	if cancel_choice == -1:
		cancel_choice = options.size() - 1
	elif cancel_choice == NO_CANCEL:
		cancel_choice = -1
	var index := await _choice.choose(labels, cancel_choice)
	_end()
	return index


## Pregunta Sí/No. Devuelve true si elige "Sí" (`cancel` = "No").
func ask_yes_no(text: String, speaker: Variant = null, vars: Dictionary = {}) -> bool:
	return await ask(text, PackedStringArray([tr("Sí"), tr("No")]), speaker, -1, vars) == 0


## Traduce `text` y sustituye {player}, {rival} y las variables de `vars`.
func format_text(text: String, vars: Dictionary = {}) -> String:
	var values := {
		"player": GameState.player_name,
		"rival": GameState.rival_name,
	}
	values.merge(vars, true)
	return tr(text).format(values)


func _begin() -> void:
	while is_open:
		await _released
	is_open = true
	_session += 1
	if _shown:
		return
	_shown = true
	_box.clear()
	_box.show()
	GameState.lock_input(&"dialogue")
	EventBus.dialogue_started.emit()


func _end() -> void:
	is_open = false
	_released.emit()
	var session := _session
	await get_tree().process_frame
	if session != _session or is_open or not _shown:
		return
	_shown = false
	_box.hide()
	_box.clear()
	GameState.unlock_input(&"dialogue")
	EventBus.dialogue_finished.emit()


func _speaker_name(speaker: Variant, vars: Dictionary) -> String:
	if speaker is String or speaker is StringName:
		return format_text(str(speaker), vars)
	if speaker is Object and &"display_name" in speaker:
		return format_text(str(speaker.display_name), vars)
	return ""
