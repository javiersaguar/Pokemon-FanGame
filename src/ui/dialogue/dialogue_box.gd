class_name DialogueBox
extends Control
## Cuadro de texto reutilizable (mundo y combate): letra a letra, páginas de
## LINES_PER_PAGE líneas, flecha de "continuar" y nombre del hablante opcional.
## Lo usa el autoload Dialogue y, con su propia instancia, la BattleScene.

signal _typing_finished
signal _advanced

const LINES_PER_PAGE := 2
## Una línea en blanco fuerza una página nueva.
const PAGE_BREAK := "\n\n"
## Píxeles que el nombre del hablante monta sobre el borde del cuadro.
const NAME_PLATE_OVERLAP := 2

## Caracteres por segundo. 0 = instantáneo.
@export var text_speed := 40

var is_typing := false
var is_waiting := false

var _typed := 0.0
var _typing_end := 0
## Frame en el que el cuadro empezó a esperar input: la pulsación que lo abrió no cuenta.
var _active_frame := -1
var _default_text_width := 0.0

@onready var _frame: Control = $Frame
@onready var _label: RichTextLabel = $Frame/Text
@onready var _arrow: CursorArrow = $Frame/Arrow
@onready var _name_plate: PanelContainer = $NamePlate
@onready var _name_label: Label = $NamePlate/Name


func _ready() -> void:
	_default_text_width = _label.size.x
	set_process(false)
	clear()


func _process(delta: float) -> void:
	_typed += delta * text_speed
	var shown := mini(int(_typed), _typing_end)
	_label.visible_characters = shown
	if shown >= _typing_end:
		_finish_typing()


func _input(event: InputEvent) -> void:
	if not (is_typing or is_waiting) or Engine.get_process_frames() == _active_frame:
		return
	if not (event.is_action_pressed(&"accept") or event.is_action_pressed(&"cancel")):
		return
	get_viewport().set_input_as_handled()
	if is_typing:
		_finish_typing()
	else:
		is_waiting = false
		_advanced.emit()


## Escribe `text` (BBCode) página a página y espera a que el jugador pase cada
## una. En la última solo espera si `wait_last` es true (ask() y los mensajes de
## combate que avanzan solos no esperan).
func play(text: String, speaker_name: String = "", wait_last: bool = true) -> void:
	set_speaker(speaker_name)
	_arrow.hide()
	var segments := text.split(PAGE_BREAK, false)
	if segments.is_empty():
		segments.append("")
	for s: int in segments.size():
		var pages := _layout(segments[s])
		for p: int in pages.size():
			_label.scroll_to_line(p * LINES_PER_PAGE)
			await _type(pages[p].x, pages[p].y)
			var is_last := s == segments.size() - 1 and p == pages.size() - 1
			if is_last and not wait_last:
				return
			await wait_for_advance()


## Muestra la flecha y espera a que el jugador pulse `accept` o `cancel`.
func wait_for_advance() -> void:
	_arrow.show()
	_arrow.bob = true
	is_waiting = true
	_active_frame = Engine.get_process_frames()
	await _advanced
	_arrow.bob = false
	_arrow.hide()
	AudioManager.play_se(&"menu_accept")


func set_speaker(speaker_name: String) -> void:
	_name_label.text = speaker_name
	_name_plate.visible = speaker_name != ""
	_name_plate.reset_size()
	_name_plate.position.y = _frame.position.y - _name_plate.size.y + NAME_PLATE_OVERLAP


## Ancho del texto en píxeles (el combate lo estrecha para dejar sitio al menú).
## Negativo = el ancho normal del cuadro.
func set_text_width(width: float) -> void:
	_label.size.x = _default_text_width if width < 0.0 else width


func clear() -> void:
	_label.text = ""
	_label.visible_characters = 0
	_arrow.hide()
	set_speaker("")


## Número de páginas que ocuparía `text` (sin contar los saltos forzados).
func count_pages(text: String) -> int:
	return _layout(text).size()


## Coloca `text` en la etiqueta (oculto) y devuelve el rango de caracteres
## visibles de cada página: Vector2i(primero, último + 1).
func _layout(text: String) -> Array[Vector2i]:
	_label.text = text
	_label.visible_characters = 0
	var total := _label.get_total_character_count()
	var pages: Array[Vector2i] = []
	var page_start := 0
	var page := 0
	for i: int in total:
		var char_page := _label.get_character_line(i) / LINES_PER_PAGE
		if char_page != page:
			pages.append(Vector2i(page_start, i))
			page_start = i
			page = char_page
	pages.append(Vector2i(page_start, total))
	# Sin líneas de relleno, la última página no podría quedarse sola arriba
	# (una línea vacía al final no ocupa altura: por eso el espacio).
	var missing := pages.size() * LINES_PER_PAGE - _label.get_line_count()
	if missing > 0:
		_label.append_text("\n".repeat(missing) + " ")
	return pages


func _type(from: int, to: int) -> void:
	_label.visible_characters = from
	if text_speed <= 0 or from >= to:
		_label.visible_characters = to
		return
	_typed = from
	_typing_end = to
	is_typing = true
	_active_frame = Engine.get_process_frames()
	set_process(true)
	await _typing_finished


func _finish_typing() -> void:
	_label.visible_characters = _typing_end
	is_typing = false
	set_process(false)
	_typing_finished.emit()
