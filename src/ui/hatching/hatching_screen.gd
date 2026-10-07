class_name HatchingScreen
extends MenuScreen
var pokemon: Pokemon
var fast := false
var preview := false
var _egg: Sprite2D
var _cracks: Sprite2D
var _baby: BattlePokemonSprite
var _message: Label
var _complete := false
var _skip := false
var _audio_saved := false
var _active_frame := 0
static func open(p: Pokemon,quick := false) -> void:
	if p == null: return
	var screen := HatchingScreen.new()
	screen.pokemon = p
	screen.fast = quick
	SceneManager.push_menu(screen)
	await screen.closed
	SceneManager.pop_menu(screen)
func _ready() -> void:
	heading.text = "Eclosión"
	canvas.get_child(0).hide()
	var background := Sprite2D.new()
	background.texture = preload("res://assets/sprites/ui/hatching/background.png")
	background.centered = false
	add_child(background); move_child(background,0)
	panel(Rect2(10,142,236,27))
	_message = label("¡El huevo se está abriendo!",Rect2(18,147,220,18),Color("382a38"),8)
	_egg = Sprite2D.new()
	_egg.texture = preload("res://assets/sprites/ui/hatching/egg.png")
	_egg.position = Vector2(256,184)
	add_child(_egg)
	_cracks = Sprite2D.new()
	_cracks.texture = preload("res://assets/sprites/ui/hatching/cracks.png")
	_cracks.hframes = 5
	_cracks.position = _egg.position
	_cracks.hide()
	add_child(_cracks)
	_baby = BattlePokemonSprite.new()
	_baby.position = Vector2(256,264)
	add_child(_baby)
	hint.text = "A / B: omitir animación"
	_active_frame = Engine.get_process_frames()
	if not preview: run.call_deferred()
func run() -> void:
	if not fast:
		AudioManager.save_bgm(); _audio_saved = true
		AudioManager.play_bgm(&"evolution")
	if not fast and not UiPreferences.reduce_motion():
		_cracks.show()
		for step: int in 5:
			if _skip: break
			_cracks.frame = step
			_egg.position.x = 256 + (4 if step % 2 == 0 else -4)
			_cracks.position = _egg.position
			await get_tree().create_timer(0.3).timeout
	show_baby()
	if not fast:
		AudioManager.play_se(&"ball_open")
		AudioManager.play_cry(pokemon.species_id)
	_complete = true
	_active_frame = Engine.get_process_frames()
	if fast: closed.emit()
func show_baby() -> void:
	_egg.hide(); _cracks.hide()
	_baby.set_pokemon({"species":pokemon.species_id,"shiny":pokemon.shiny})
	_message.text = "¡Ha nacido %s!" % pokemon.species().name
	hint.text = "A / B: continuar"
func _unhandled_input(event: InputEvent) -> void:
	if Engine.get_process_frames() <= _active_frame + 1: return
	if event.is_action_pressed(&"accept") or event.is_action_pressed(&"cancel"):
		get_viewport().set_input_as_handled()
		if _complete: closed.emit()
		else: _skip = true
func _exit_tree() -> void:
	if _audio_saved: AudioManager.restore_bgm()
