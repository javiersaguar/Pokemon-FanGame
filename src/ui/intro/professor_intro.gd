class_name ProfessorIntro
extends MenuScreen
## Presentación con gráficos publicados, sin inventar un retrato del profesor.
static func begin() -> ProfessorIntro:
	if not is_instance_valid(SceneManager.ui_layer): return null
	var screen := ProfessorIntro.new()
	SceneManager.push_menu(screen)
	return screen

static func finish(screen: ProfessorIntro) -> void:
	if is_instance_valid(screen): SceneManager.pop_menu(screen)

func _ready() -> void:
	heading.text = "¡Bienvenido al mundo Pokémon!"
	hint.text = "Realizado por Javier Saguar"
	var scenery := TextureRect.new()
	scenery.texture = load("res://assets/sprites/ui/battle/backgrounds/field.png")
	scenery.scale = Vector2(0.5, 0.5)
	scenery.position = Vector2(32, 31)
	canvas.add_child(scenery)
	canvas.move_child(scenery, 1)
	panel(Rect2(12, 35, 95, 102))
	panel(Rect2(115, 35, 128, 102))
	var professor := Sprite2D.new()
	var path := "res://assets/sprites/trainers/profesor.png"
	if ResourceLoader.exists(path): professor.texture = load(path)
	else:
		var atlas := AtlasTexture.new()
		atlas.atlas = load("res://assets/sprites/characters/profesor.png")
		atlas.region = Rect2(0, 0, 64, 64)
		professor.texture = atlas
	professor.scale = Vector2(0.5, 0.5)
	professor.position = Vector2(60, 85)
	canvas.add_child(professor)
	label("Profesor\n%s" % WorldNames.value(&"professor"), Rect2(19, 109, 82, 27), Color("382a38"), 8)
	var welcome := label("Un mundo de Pokémon\ny una aventura por descubrir.", Rect2(124, 43, 109, 36), Color("382a38"), 8)
	welcome.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	welcome.size = Vector2(104, 54)
	welcome.clip_text = true
	for i: int in 3:
		var species := DataDB.starter(StringName("starter_%d" % (i + 1)))
		if species == &"": continue
		var path_icon := "res://assets/sprites/pokemon/icons/%s.png" % species
		if not ResourceLoader.exists(path_icon): continue
		var sheet := load(path_icon) as Texture2D
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(0, 0, sheet.get_width() / 2, sheet.get_height())
		var icon := Sprite2D.new()
		icon.texture = atlas
		icon.scale = Vector2(0.5, 0.5)
		icon.position = Vector2(139 + i * 36, 103)
		canvas.add_child(icon)
