@tool
class_name Character
extends MapEntity
## Personaje que se mueve de casilla en casilla (jugador y NPCs).
## Escena esperada: Sprite (CharacterSprite), Body (StaticBody2D en la capa
## "entidades" con su CollisionShape2D) y RayCast (RayCast2D).

signal step_finished(tile: Vector2i)
## Al empezar a moverse (paso o salto): de dónde sale, adónde va y cuánto tarda.
## Lo usa el Pokémon que te sigue.
signal step_started(from: Vector2i, to: Vector2i, duration: float)

enum Direction { DOWN, LEFT, RIGHT, UP }

const DIRECTIONS: Array[Vector2i] = [Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]
const WALK_TIME := 0.25
const RUN_TIME := 0.125
## Capas que bloquean el paso: paredes, entidades y agua.
const BLOCKING_MASK := 1 | 2 | 8
## Si un camino está bloqueado, walk() reintenta hasta este tiempo y luego se lo salta.
const WALK_BLOCKED_TIMEOUT := 2.0
## Píxeles de los pies que se hunden en la hierba alta (bush depth de Essentials a ×2).
const BUSH_DEPTH := 24
const GRASS_RUSTLE := preload("res://assets/sprites/characters/effects/grass_rustle.png")
const EXCLAMATION := preload("res://assets/sprites/characters/effects/exclamation.png")
## Terreno (custom data `terrain` del TileSet) que hunde los pies y se mueve al pisarlo.
const TALL_GRASS_TERRAIN := "tall_grass"
const JUMP_TIME := 0.4
const JUMP_HEIGHT := 20.0
const JUMP_DUST := preload("res://assets/sprites/characters/effects/jump_dust.png")

@export var sprite_sheet: Texture2D:
	set(value):
		sprite_sheet = value
		if is_node_ready() and value:
			sprite.set_sheets(value, run_sprite_sheet)
## Hoja para correr (opcional, mismo formato).
@export var run_sprite_sheet: Texture2D:
	set(value):
		run_sprite_sheet = value
		if is_node_ready() and sprite_sheet:
			sprite.set_sheets(sprite_sheet, value)
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
		sprite.set_sheets(sprite_sheet, run_sprite_sheet)
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
## `running` usa la hoja de correr (si la hay).
func step(dir: Vector2i, duration: float = WALK_TIME, ignore_collisions: bool = false,
		running: bool = false) -> bool:
	face(dir)
	if moving or (not ignore_collisions and not can_step(dir)):
		return false
	moving = true
	var target := position + Vector2(dir * Grid.TILE)
	var target_tile := Grid.to_tile(target)
	step_started.emit(Grid.to_tile(position), target_tile, duration)
	# El cuerpo se adelanta para reservar la casilla de destino.
	body.position = Vector2(dir * Grid.TILE)
	sprite.play_step(dir, duration, running)
	var into_grass := _is_tall_grass(target_tile)
	if into_grass:
		_spawn_grass_rustle(target_tile)
		sprite.bush_depth = BUSH_DEPTH
	var tween := create_tween()
	tween.tween_method(_set_position_rounded, position, target, duration)
	await tween.finished
	position = target
	body.position = Vector2.ZERO
	sprite.bush_depth = BUSH_DEPTH if into_grass else 0
	moving = false
	step_finished.emit(tile_position())
	return true


## true si en `tile` no hay pared, agua ni entidad (mira la física, no el TileSet).
func is_tile_free(tile: Vector2i) -> bool:
	if not is_inside_tree():
		return false
	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_parent().to_global(Grid.to_world(tile))
	query.collision_mask = BLOCKING_MASK
	query.exclude = [body.get_rid()]
	return get_world_2d().direct_space_state.intersect_point(query, 1).is_empty()


## Salta `tiles` casillas en `dir` (bordillos), sin mirar colisiones.
func jump(dir: Vector2i, tiles: int = 2) -> void:
	face(dir)
	if moving:
		return
	moving = true
	var from := tile_position()
	var to := from + dir * tiles
	step_started.emit(from, to, JUMP_TIME)
	body.position = Vector2(dir * Grid.TILE * tiles)
	sprite.play_step(dir, JUMP_TIME)
	var tween := create_tween().set_parallel()
	tween.tween_method(_set_position_rounded, position, Grid.to_world(to), JUMP_TIME)
	tween.tween_method(_set_jump_height, 0.0, 1.0, JUMP_TIME)
	await tween.finished
	sprite.position = Vector2.ZERO
	position = Grid.to_world(to)
	body.position = Vector2.ZERO
	sprite.bush_depth = BUSH_DEPTH if _is_tall_grass(to) else 0
	moving = false
	_spawn_effect(JUMP_DUST, to, 0.06)
	step_finished.emit(to)


func _set_jump_height(t: float) -> void:
	sprite.position.y = -Grid.round_to_art_pixel(Vector2(0, sin(t * PI) * JUMP_HEIGHT)).y


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
	sprite.bush_depth = BUSH_DEPTH if _is_tall_grass(tile) else 0


## Muestra un globo sobre la cabeza: "!" con el sprite del pack; otro texto, con
## una etiqueta (hasta que haya sprites de "?", "..." etc.).
func show_emote(text: String = "!", duration: float = 0.6) -> void:
	var bubble: CanvasItem
	if text == "!":
		var icon := Sprite2D.new()
		icon.texture = EXCLAMATION
		icon.position = Vector2(0, -Grid.TILE * 1.75)
		bubble = icon
	else:
		var label := Label.new()
		label.text = text
		label.add_theme_color_override(&"font_outline_color", Color.BLACK)
		label.add_theme_constant_override(&"outline_size", 4)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size = Vector2(Grid.TILE, 20)
		label.position = Vector2(-Grid.TILE / 2.0, -Grid.TILE * 2.25)
		bubble = label
	add_child(bubble)
	await get_tree().create_timer(duration).timeout
	bubble.queue_free()


func _is_tall_grass(tile: Vector2i) -> bool:
	var map := SceneManager.current_map if not Engine.is_editor_hint() else null
	return map != null and map.terrain_at(tile) == TALL_GRASS_TERRAIN


## Animación de la hierba al pisarla (3 cuadros del pack 05), delante de los pies.
func _spawn_grass_rustle(tile: Vector2i) -> void:
	_spawn_effect(GRASS_RUSTLE, tile, 0.1)


## Efecto de cuadros en horizontal (cuadrados) que se reproduce una vez en `tile`.
func _spawn_effect(texture: Texture2D, tile: Vector2i, frame_time: float) -> void:
	var parent := get_parent()
	if parent == null:
		return
	var fx := Sprite2D.new()
	fx.texture = texture
	fx.hframes = maxi(roundi(float(texture.get_width()) / texture.get_height()), 1)
	# Un poco más abajo que el personaje para que el y-sort lo ponga delante.
	fx.position = Grid.to_world(tile) + Vector2(0, 1)
	fx.offset = Vector2(0, -1)
	parent.add_child(fx)
	var tween := fx.create_tween()
	for frame: int in fx.hframes:
		tween.tween_callback(fx.set_frame.bind(frame))
		tween.tween_interval(frame_time)
	tween.tween_callback(fx.queue_free)


## Las posiciones del mundo van en píxeles enteros del arte (a ×2 en pantalla),
## para que no haya temblores de medio píxel al moverse.
func _set_position_rounded(value: Vector2) -> void:
	position = Grid.round_to_art_pixel(value)


static func direction_to(delta: Vector2) -> Vector2i:
	if delta == Vector2.ZERO:
		return Vector2i.ZERO
	if absf(delta.x) > absf(delta.y):
		return Vector2i.RIGHT if delta.x > 0 else Vector2i.LEFT
	return Vector2i.DOWN if delta.y > 0 else Vector2i.UP
