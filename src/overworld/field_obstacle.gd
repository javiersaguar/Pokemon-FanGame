@tool
class_name FieldObstacle
extends MapEntity
## A4 aporta sprite/collider. Corte/Golpe Roca eliminan, Fuerza empuja una casilla.
## Por defecto temporal (vuelve al cargar mapa); authored cleared_flag lo hace permanente.
@export_enum("cut", "rock_smash", "strength") var action := "cut"
@export var cleared_flag: StringName
var moving := false
func _ready() -> void:
	super()
	if not Engine.is_editor_hint() and cleared_flag != &"" and GameState.flag(cleared_flag):
		set_forced_hidden(true)
func interact(player: Player) -> void:
	if moving or not FieldActions.available(StringName(action), player.get_map_root()):
		return
	if action == "strength":
		await push(player)
	else:
		if cleared_flag != &"":
			GameState.set_flag(cleared_flag)
		set_forced_hidden(true)
func push(player: Player) -> bool:
	var destination := tile_position() + player.facing
	var map := player.get_map_root()
	if map == null or not map.get_ground().get_used_rect().has_point(destination) or map.terrain_at(destination) in ["water", "waterfall"] or not player.is_tile_free(destination):
		return false
	moving = true
	var body := get_node_or_null("Body") as Node2D
	if body:
		body.position = Vector2(player.facing * Grid.TILE)
	var tween := create_tween()
	tween.tween_property(self, "position", Grid.to_world(destination), Character.WALK_TIME)
	await tween.finished
	position = Grid.to_world(destination)
	if body:
		body.position = Vector2.ZERO
	moving = false
	return true
