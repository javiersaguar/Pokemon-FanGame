class_name ProfessorNPC
extends MapEntity
## Profesor de la intro, anclado a la marca entregada por B; sin modificar el mapa.
func _init() -> void:
	var body := StaticBody2D.new()
	body.name = "Body"
	body.collision_layer = 2
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(28, 28)
	shape.shape = rectangle
	body.add_child(shape)
	add_child(body)

func _ready() -> void:
	var texture := portrait(true)
	if texture:
		var sprite := Sprite2D.new()
		sprite.name = "Sprite"
		sprite.texture = texture
		sprite.scale = Vector2.ONE * (56.0 / texture.get_height())
		sprite.offset.y = 16.0 / sprite.scale.y - texture.get_height() / 2.0
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(sprite)
	var shadow := Sprite2D.new()
	shadow.texture = Character.GROUND_SHADOW
	add_child(shadow)
	move_child(shadow, 0)
	super()

static func portrait(for_map: bool = false) -> AtlasTexture:
	var cfg: Dictionary = JsonFile.read_dict("res://data/new_game_story.json").professor
	var path := str(cfg.get("map_sprite", cfg.sprite) if for_map else cfg.sprite)
	if not ResourceLoader.exists(path): return null
	var source := load(path) as Texture2D
	var out := AtlasTexture.new()
	out.atlas = source
	out.region = Rect2(source.get_image().get_used_rect())
	if for_map and cfg.has("map_rect"):
		var rect: Array = cfg.map_rect
		out.region = Rect2(rect[0],rect[1],rect[2],rect[3])
	return out

func interact(_player: Player) -> void:
	await Cutscene.play(load("res://src/events/new_game_story_event.gd"), self, {"stage": "professor"})
