@tool
class_name Follower
extends Character
## Pokémon que te sigue (Fase 14.5): va a la casilla que deja su líder (el jugador
## o un NPC) al moverse, con su misma velocidad, y se mueve aunque esté quieto.
## Hojas del Generation 9 Pack: assets/sprites/pokemon/followers/<id>.png y
## followers_shiny/<id>.png (4×4 cuadros de 64 px, como los personajes).
## Si es shiny, brilla al aparecer (DIRECTRICES §8). No choca con nadie.

const SHEETS_DIR := "res://assets/sprites/pokemon/followers/"
const SHINY_SHEETS_DIR := "res://assets/sprites/pokemon/followers_shiny/"
const SPARKLES := preload("res://assets/sprites/characters/effects/shiny_sparkles.png")
const IDLE_FRAME_TIME := 0.25

@export var species: StringName:
	set(value):
		species = value
		_refresh_sheet()
@export var shiny := false:
	set(value):
		shiny = value
		_refresh_sheet()
## Líder en el mapa (para los Pokémon de los NPCs). El del jugador lo pone SceneManager.
@export var leader_path: NodePath

var leader: Character
var _idle_time := 0.0
var _idle_frame := 0


static func sheet_path(species_id: StringName, is_shiny: bool) -> String:
	return (SHINY_SHEETS_DIR if is_shiny else SHEETS_DIR) + String(species_id) + ".png"


static func has_sheet(species_id: StringName, is_shiny: bool) -> bool:
	return species_id != &"" and ResourceLoader.exists(sheet_path(species_id, is_shiny))


func _ready() -> void:
	super()
	body.collision_layer = 0
	_refresh_sheet()
	if not Engine.is_editor_hint() and not leader_path.is_empty():
		var node := get_node_or_null(leader_path) as Character
		if node:
			follow.call_deferred(node)
			appear.call_deferred()


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or moving or not visible:
		return
	_idle_time += delta
	if _idle_time >= IDLE_FRAME_TIME:
		_idle_time = 0.0
		_idle_frame = (_idle_frame + 1) % 4
		sprite.frame_coords = Vector2i(_idle_frame, sprite.frame_coords.y)


## Empieza a seguir a `who`, colocándose detrás de él.
func follow(who: Character) -> void:
	if leader and leader.step_started.is_connected(_on_leader_step):
		leader.step_started.disconnect(_on_leader_step)
	leader = who
	leader.step_started.connect(_on_leader_step)
	place_behind_leader()


## Detrás del líder si esa casilla está libre; si no, en la suya (y saldrá en
## cuanto el líder se mueva).
func place_behind_leader() -> void:
	if leader == null:
		return
	var behind := leader.tile_position() - leader.facing
	place_at(behind if is_tile_free(behind) else leader.tile_position(), leader.facing)


## Aparece (con brillo si es shiny).
func appear() -> void:
	visible = true
	if shiny:
		AudioManager.play_se(&"shiny")
		_spawn_effect(SPARKLES, tile_position(), 0.15)


func _on_leader_step(from: Vector2i, to: Vector2i, duration: float) -> void:
	var delta := from - tile_position()
	var distance := absi(delta.x) + absi(delta.y)
	if distance == 0:
		face(direction_to(Vector2(to - from)))
	elif distance == 1:
		step(delta, duration, true)
	elif distance == 2 and (delta.x == 0 or delta.y == 0):
		jump(Vector2i(signi(delta.x), signi(delta.y)), 2)
	else:
		place_at(from, direction_to(Vector2(to - from)))


func _refresh_sheet() -> void:
	if not is_node_ready():
		return
	if has_sheet(species, shiny):
		sprite_sheet = load(sheet_path(species, shiny))
		visible = true
	else:
		visible = false
