@tool
class_name Character
extends MapEntity
## Personaje que se mueve de casilla en casilla (jugador y NPCs).
## Escena esperada: Sprite (CharacterSprite), Body (StaticBody2D en la capa
## "entidades" con su CollisionShape2D) y RayCast (RayCast2D).

signal step_finished(tile: Vector2i)

enum Direction { DOWN, LEFT, RIGHT, UP }

const DIRECTIONS: Array[Vector2i] = [Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]
const WALK_TIME := 0.25
const RUN_TIME := 0.125
## Capas que bloquean el paso: paredes, entidades y agua.
const BLOCKING_MASK := 1 | 2 | 8
## Si un camino está bloqueado, walk() reintenta hasta este tiempo y luego se lo salta.
const WALK_BLOCKED_TIMEOUT := 2.0

@export var sprite_sheet: Texture2D:
	set(value):
		sprite_sheet = value
		if is_node_ready() and value:
			sprite.texture = value
@export var initial_facing: Direction = Direction.DOWN:
	set(value):
		initial_facing = value
		if is_node_ready():
			face(DIRECTIONS[value])

var facing := Vector2i.DOWN
var moving := false

@onready var sprite: CharacterSprite = $Sprite
@onready var body: StaticBody2D = $Body
@onready var ray: RayCast2D = $RayCast


func _ready() -> void:
	if sprite_sheet:
		sprite.texture = sprite_sheet
	face(DIRECTIONS[initial_facing])
	ray.add_exception(body)
	ray.collision_mask = BLOCKING_MASK
	ray.target_position = Vector2.ZERO
	super()


func face(dir: Vector2i) -> void:
	if dir == Vector2i.ZERO:
		return
	facing = dir
	sprite.facing = dir


## Mira hacia `target` (por el eje en el que esté más lejos).
func face_towards(target: Node2D) -> void:
	face(direction_to(target.global_position - global_position))


func can_step(dir: Vector2i) -> bool:
	ray.target_position = Vector2(dir * Grid.TILE)
	ray.force_raycast_update()
	return not ray.is_colliding()


## Da un paso en `dir`. Devuelve false (sin moverse, solo girando) si está bloqueado.
func step(dir: Vector2i, duration: float = WALK_TIME, ignore_collisions: bool = false) -> bool:
	face(dir)
	if moving or (not ignore_collisions and not can_step(dir)):
		return false
	moving = true
	var target := position + Vector2(dir * Grid.TILE)
	# El cuerpo se adelanta para reservar la casilla de destino.
	body.position = Vector2(dir * Grid.TILE)
	sprite.play_step(dir, duration)
	var tween := create_tween()
	tween.tween_property(self, ^"position", target, duration)
	await tween.finished
	position = target
	body.position = Vector2.ZERO
	moving = false
	step_finished.emit(tile_position())
	return true


## Recorre una lista de direcciones (cinemáticas). Si algo bloquea el camino,
## espera hasta WALK_BLOCKED_TIMEOUT y se salta ese paso.
func walk(path: Array[Vector2i], duration: float = WALK_TIME, ignore_collisions: bool = false) -> void:
	for dir: Vector2i in path:
		var waited := 0.0
		while not await step(dir, duration, ignore_collisions):
			if waited >= WALK_BLOCKED_TIMEOUT:
				push_warning("%s: camino bloqueado hacia %s." % [name, dir])
				break
			await get_tree().create_timer(0.1).timeout
			waited += 0.1


## Andar en el sitio (choque contra una pared).
func bump(dir: Vector2i, duration: float = WALK_TIME) -> void:
	face(dir)
	sprite.play_step(dir, duration)
	await get_tree().create_timer(duration).timeout


func place_at(tile: Vector2i, dir: Vector2i = Vector2i.ZERO) -> void:
	position = Grid.to_world(tile)
	face(dir)


## Muestra un globo sobre la cabeza ("!" al verte un entrenador...).
func show_emote(text: String = "!", duration: float = 0.6) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override(&"font_size", 8)
	label.add_theme_color_override(&"font_outline_color", Color.BLACK)
	label.add_theme_constant_override(&"outline_size", 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(Grid.TILE, 10)
	label.position = Vector2(-Grid.TILE / 2.0, -Grid.TILE * 2)
	add_child(label)
	await get_tree().create_timer(duration).timeout
	label.queue_free()


static func direction_to(delta: Vector2) -> Vector2i:
	if delta == Vector2.ZERO:
		return Vector2i.ZERO
	if absf(delta.x) > absf(delta.y):
		return Vector2i.RIGHT if delta.x > 0 else Vector2i.LEFT
	return Vector2i.DOWN if delta.y > 0 else Vector2i.UP
