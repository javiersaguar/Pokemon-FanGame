@tool
class_name CharacterSprite
extends Sprite2D
## Sprite de un personaje del mapa. Spritesheet de 4 columnas (quieto, paso A,
## quieto, paso B) × 4 filas (abajo, izquierda, derecha, arriba). Cualquier tamaño
## de frame vale: los pies se apoyan en el borde inferior de la casilla.

const ROWS: Dictionary[Vector2i, int] = {
	Vector2i.DOWN: 0, Vector2i.LEFT: 1, Vector2i.RIGHT: 2, Vector2i.UP: 3,
}

var facing := Vector2i.DOWN:
	set(value):
		facing = value
		_show(0)

var _next_step_frame := 1
var _tween: Tween


func _init() -> void:
	hframes = 4
	vframes = 4
	centered = true
	texture_changed.connect(_fit_to_tile)


func _ready() -> void:
	_fit_to_tile()
	_show(0)


## Pone el frame de paso (alternando pie) y vuelve a "quieto" a mitad de `duration`.
func play_step(dir: Vector2i, duration: float) -> void:
	facing = dir
	_show(_next_step_frame)
	_next_step_frame = 4 - _next_step_frame
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_callback(_show.bind(0)).set_delay(duration / 2.0)


func _show(column: int) -> void:
	if texture:
		frame_coords = Vector2i(column, ROWS.get(facing, 0))


func _fit_to_tile() -> void:
	if texture:
		offset.y = Grid.TILE / 2.0 - texture.get_height() / float(vframes) / 2.0
