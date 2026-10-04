@tool
class_name CursorArrow
extends Control
## Flecha de los menús (derecha) o de "continuar" del diálogo (abajo), con la
## versión clara para paneles oscuros. Pixel art en assets/sprites/ui/cursor_*.png.

enum Direction { RIGHT, DOWN }

const TEXTURES := {
	Direction.RIGHT: [preload("res://assets/sprites/ui/cursor_right.png"),
		preload("res://assets/sprites/ui/cursor_right_light.png")],
	Direction.DOWN: [preload("res://assets/sprites/ui/cursor_down.png"),
		preload("res://assets/sprites/ui/cursor_down_light.png")],
}
## Rápido (BIBLIA.md §8): sube y baja 1 píxel de arte.
const BOB_INTERVAL := 0.3

@export var direction := Direction.RIGHT:
	set(value):
		direction = value
		_update_size()
		queue_redraw()
## Versión clara (sobre paneles oscuros).
@export var light := false:
	set(value):
		light = value
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
	draw_texture(texture_for(direction, light), Vector2(0, _bob_offset))


static func texture_for(dir: Direction, light_version: bool = false) -> Texture2D:
	return TEXTURES[dir][1 if light_version else 0]


## Dibuja la flecha en cualquier CanvasItem (los menús de rejilla la pintan así).
static func draw_arrow(canvas: CanvasItem, origin: Vector2, dir: Direction = Direction.RIGHT,
		light_version: bool = false) -> void:
	canvas.draw_texture(texture_for(dir, light_version), origin)


func _update_size() -> void:
	custom_minimum_size = Vector2(texture_for(direction).get_size())
	size = custom_minimum_size
