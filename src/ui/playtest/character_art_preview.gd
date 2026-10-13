class_name CharacterArtPreview
extends MenuScreen
var art_id: StringName
var _poses: Array[CharacterArtSprite] = []
var _time := 0.0
var _frame := 0
var walking := true

static func open(id: StringName) -> void:
	var screen := CharacterArtPreview.new()
	screen.art_id = id
	SceneManager.push_menu(screen)
	await screen.closed
	SceneManager.pop_menu(screen)

func _ready() -> void:
	heading.text = str(CharacterArt.info(art_id).get("name", art_id))
	panel(Rect2(8,34,110,132))
	panel(Rect2(126,34,122,132))
	label("Combate",Rect2(16,38,95,14),Color("382a38"),8)
	label("Mapa / 4 direcciones",Rect2(132,38,110,14),Color("382a38"),8)
	var portrait := Sprite2D.new()
	portrait.texture = CharacterArt.battle_texture(art_id)
	if portrait.texture:
		var factor := CharacterArt.display_scale(portrait.texture.get_size(),Vector2(184,240))
		portrait.scale = Vector2.ONE * factor
		portrait.offset = Vector2(-portrait.texture.get_width()*0.5,-portrait.texture.get_height())
		portrait.centered = false
		portrait.position = Vector2(126,316)
		add_child(portrait)
	for i: int in 4:
		var sprite := CharacterArtSprite.new()
		add_child(sprite)
		sprite.set_art(art_id)
		sprite.facing = [Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP][i]
		sprite.position = Vector2(316+(i%2)*112,165+floori(float(i)/2.0)*102)
		_poses.append(sprite)
	hint.text = "A: andar / parar    B: volver"

func _process(delta: float) -> void:
	if not walking: return
	_time += delta
	if _time < 0.2: return
	_time = 0.0
	_frame = (_frame+1)%4
	for sprite: CharacterArtSprite in _poses: sprite._show([0,1,0,3][_frame])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"cancel"): closed.emit()
	elif event.is_action_pressed(&"accept"):
		walking = not walking
		for sprite: CharacterArtSprite in _poses: sprite._show(0)
	else: return
	get_viewport().set_input_as_handled()
