@tool
class_name CursorArrow
extends Control
## Flecha pixel art: cursor de los menús (derecha) o "continuar" del diálogo (abajo).
## Se dibuja fila a fila para que quede nítida a cualquier escala entera.

enum Direction { RIGHT, DOWN }

const BOB_INTERVAL := 0.3

@export var direction := Direction.RIGHT:
	set(value):
		direction = value
		_update_size()
		queue_redraw()
## Sube y baja 1 píxel (la flecha de "continuar").
@export var bob := false:
	set(value):
		bob = value
		_bob_offset = 0
		_bob_time = 0.0
		set_process(bob)
		queue_redraw()

var _bob_offset := 0
var _bob_time := 0.0


func _init() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_update_size()


func _ready() -> void:
	set_process(bob)


func _process(delta: float) -> void:
	_bob_time += delta
	if _bob_time >= BOB_INTERVAL:
		_bob_time -= BOB_INTERVAL
		_bob_offset = 1 - _bob_offset
		queue_redraw()


func _draw() -> void:
	draw_arrow(self, Vector2(0, _bob_offset), direction)


## Dibuja la flecha (con su sombra) en cualquier CanvasItem: los menús de
## rejilla la pintan así junto a la opción elegida.
static func draw_arrow(canvas: CanvasItem, origin: Vector2, dir: Direction = Direction.RIGHT) -> void:
	var color := Color(0.25098, 0.25098, 0.282353)
	var shadow := Color(0.815686, 0.815686, 0.784314)
	if canvas is Control:
		color = (canvas as Control).get_theme_color(&"font_color", &"Label")
		shadow = (canvas as Control).get_theme_color(&"font_shadow_color", &"Label")
	_draw_shape(canvas, origin + Vector2.ONE, dir, shadow)
	_draw_shape(canvas, origin, dir, color)


static func _draw_shape(canvas: CanvasItem, origin: Vector2, dir: Direction, color: Color) -> void:
	if dir == Direction.RIGHT:
		for row: int in 7:
			var width := 4 - absi(row - 3)
			canvas.draw_rect(Rect2(origin + Vector2(0, row), Vector2(width, 1)), color)
	else:
		for row: int in 4:
			var width := 7 - row * 2
			canvas.draw_rect(Rect2(origin + Vector2(row, row), Vector2(width, 1)), color)


func _update_size() -> void:
	custom_minimum_size = Vector2(5, 8) if direction == Direction.RIGHT else Vector2(8, 6)
	size = custom_minimum_size
