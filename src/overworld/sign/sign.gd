@tool
class_name MapSign
extends MapEntity
## Cartel: muestra sus líneas al examinarlo.

@export_multiline var lines: PackedStringArray = []
## Solo se lee desde abajo (mirando hacia arriba), como en los juegos oficiales.
@export var only_from_below := true
## Ocultar el sprite si el cartel ya está dibujado en el tileset.
@export var show_sprite := true:
	set(value):
		show_sprite = value
		if is_node_ready():
			$Sprite.visible = value


func _ready() -> void:
	$Sprite.visible = show_sprite
	super()


func interact(player: Player) -> void:
	if only_from_below and (player.facing != Vector2i.UP or player.tile_position() != tile_position() + Vector2i.DOWN):
		return
	for line: String in lines:
		await Dialogue.say(WorldNames.resolve(line))
