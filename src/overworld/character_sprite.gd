@tool
class_name CharacterSprite
extends Sprite2D
## Sprite de un personaje del mapa. Spritesheet de 4 columnas (quieto, paso A,
## quieto, paso B) × 4 filas (abajo, izquierda, derecha, arriba), como las hojas
## de Essentials (cuadros de 64 px a la escala del juego). Los pies se apoyan en el
## borde inferior de la casilla.
## Hierba alta: con `bush_depth` > 0, los últimos píxeles del cuadro se ven medio
## transparentes, como si el personaje estuviera metido en la hierba (Essentials).

const ROWS: Dictionary[Vector2i, int] = {
	Vector2i.DOWN: 0, Vector2i.LEFT: 1, Vector2i.RIGHT: 2, Vector2i.UP: 3,
}
const BUSH_SHADER := preload("res://src/overworld/bush_depth.gdshader")

var facing := Vector2i.DOWN:
	set(value):
		facing = value
		_show(0)

## Hoja para andar (la de `texture` al empezar) y, si la hay, para correr.
var walk_texture: Texture2D
var run_texture: Texture2D

## Píxeles de abajo que quedan "dentro" de la hierba (0 = nada).
var bush_depth := 0:
	set(value):
		bush_depth = value
		_apply_bush()

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


func set_sheets(walk: Texture2D, run: Texture2D = null) -> void:
	walk_texture = walk
	run_texture = run
	texture = walk


## Pone el frame de paso (alternando pie) y vuelve a "quieto" a mitad de `duration`.
## Corriendo usa la hoja de correr, si la hay, y al acabar vuelve a la de andar.
func play_step(dir: Vector2i, duration: float, running: bool = false) -> void:
	if walk_texture == null:
		walk_texture = texture
	texture = run_texture if running and run_texture else walk_texture
	facing = dir
	_show(_next_step_frame)
	_next_step_frame = 4 - _next_step_frame
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_callback(_show.bind(0)).set_delay(duration / 2.0)
	if running and run_texture:
		_tween.tween_callback(_back_to_walk).set_delay(duration / 2.0 + 0.05)


func _back_to_walk() -> void:
	if walk_texture and texture != walk_texture:
		texture = walk_texture
		_show(0)


func _show(column: int) -> void:
	if texture:
		frame_coords = Vector2i(column, ROWS.get(facing, 0))


func _fit_to_tile() -> void:
	if texture:
		offset.y = Grid.TILE / 2.0 - texture.get_height() / float(vframes) / 2.0
		_apply_bush()


func _apply_bush() -> void:
	if bush_depth <= 0 or texture == null:
		material = null
		return
	if not (material is ShaderMaterial):
		material = ShaderMaterial.new()
		(material as ShaderMaterial).shader = BUSH_SHADER
	var frame_height := texture.get_height() / float(vframes)
	(material as ShaderMaterial).set_shader_parameter(&"cut", 1.0 - bush_depth / frame_height)
	(material as ShaderMaterial).set_shader_parameter(&"vframes", float(vframes))
