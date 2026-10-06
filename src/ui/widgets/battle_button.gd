class_name BattleButton
extends NinePatchRect
## Botón de pixel art (assets/sprites/ui/battle/button_<color>.png y _foco) con su
## texto centrado. Lo usan los menús del combate dentro de un GridMenu.

const TEXTURE_PATH := "res://assets/sprites/ui/battle/button_%s.png"
const MARGIN := 4
## El contorno del botón con el foco alterna entre blanco y amarillo (BIBLIA.md §8).
const FOCUS_BLINK := 0.3
## Más letras que esto no caben al lado del icono de tipo: se usa la letra pequeña.
const LONG_TEXT := 12

## rojo, amarillo, verde, azul o claro (texto oscuro).
@export var color: StringName = &"claro":
	set(value):
		color = value
		_refresh()
@export var text := "":
	set(value):
		text = value
		if _label:
			_label.text = value
			_refresh()

## Texto a la izquierda (botones de movimiento, con el icono de tipo a la derecha).
var compact := false
var content_left := 8.0
var align_left := false:
	set(value):
		align_left = value
		if _label:
			_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if value else HORIZONTAL_ALIGNMENT_CENTER
			_refresh()
var focused := false
var disabled := false

var _label: Label
var _type_icon: TextureRect
var _blink_time := 0.0
var _blink_on := false
var _pressed := false


func _init() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	patch_margin_left = MARGIN
	patch_margin_top = MARGIN
	patch_margin_right = MARGIN
	patch_margin_bottom = MARGIN
	_label = Label.new()
	_label.set_anchors_preset(PRESET_FULL_RECT)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_label)


func _ready() -> void:
	_label.text = text
	set_process(false)
	_refresh()


func _process(delta: float) -> void:
	_blink_time += delta
	if _blink_time >= FOCUS_BLINK:
		_blink_time -= FOCUS_BLINK
		_blink_on = not _blink_on
		_refresh()


## Respuesta al pulsar: se hunde un píxel un instante (rápido, 0,08 s).
func press() -> void:
	_pressed = true
	_refresh()
	await get_tree().create_timer(0.08).timeout
	_pressed = false
	_refresh()


## Icono de tipo (Loaky) a la derecha; &"" lo quita.
func set_type_icon(type: StringName) -> void:
	if _type_icon == null:
		_type_icon = TypeIcons.make_rect(&"normal")
		add_child(_type_icon)
	_type_icon.visible = type != &""
	if _type_icon.visible:
		_type_icon.texture = TypeIcons.texture(type)
	_type_icon.position = Vector2(size.x - TypeIcons.ICON_SIZE.x / 2.0 - 4.0, 2.0)


func set_focused(on: bool) -> void:
	focused = on
	_blink_time = 0.0
	_blink_on = false
	set_process(on)
	_refresh()


func set_disabled(on: bool) -> void:
	disabled = on
	_refresh()


func _refresh() -> void:
	if _label == null:
		return
	var id := "gris" if disabled else String(color) + (("_foco2" if _blink_on else "_foco") if focused else "")
	texture = load(TEXTURE_PATH % id)
	var dark_text := color == &"claro" or disabled
	if align_left and (compact or text.length() > LONG_TEXT):
		_label.theme_type_variation = &"SmallLabel" if dark_text else &"SmallLightLabel"
	else:
		_label.theme_type_variation = &"" if dark_text else &"LightLabel"
	var lift := 1.0 if _pressed else (-1.0 if focused else 0.0)
	_label.offset_left = content_left if align_left else 0.0
	_label.offset_right = 0.0
	_label.offset_top = lift
	_label.offset_bottom = lift
	if _type_icon:
		_type_icon.position.y = 2.0 + lift
