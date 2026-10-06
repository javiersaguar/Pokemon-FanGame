class_name EvolutionScreen
extends MenuScreen
signal evolved(success: bool)
var pokemon: Pokemon
var evolution: Dictionary
var item_id: StringName = &""
var fast := false
var _sprite: BattlePokemonSprite
var _flash: ShaderMaterial
var _message: Label
var _cancelled := false
var _animating := true
var _completed := false
var _audio_saved := false

static func open(p: Pokemon, evo: Dictionary, item: StringName = &"", quick := false) -> bool:
	if p == null or p.is_fainted() or not DataDB.has_species(StringName(evo.get("to", ""))): return false
	if item != &"" and not GameState.bag.has(item): return false
	var screen := EvolutionScreen.new()
	screen.pokemon = p
	screen.evolution = evo
	screen.item_id = item
	screen.fast = quick
	SceneManager.push_menu(screen)
	var success: bool = await screen.evolved
	SceneManager.pop_menu(screen)
	if success and not quick: await learn_evolution_moves(p)
	return success

func _ready() -> void:
	heading.text = "Evolución"
	fill(Rect2(0, 27, 256, 147), Color("382a38"))
	panel(Rect2(10, 142, 236, 27))
	_message = label("¡%s está evolucionando!" % pokemon.display_name(), Rect2(18, 147, 220, 18), Color("382a38"), 8)
	_sprite = BattlePokemonSprite.new()
	_sprite.position = Vector2(256, 272)
	add_child(_sprite)
	_sprite.set_pokemon({"species": pokemon.species_id, "shiny": pokemon.shiny})
	_flash = ShaderMaterial.new()
	_flash.shader = preload("res://src/ui/evolution/evolution_flash.gdshader")
	_sprite._sprite.material = _flash
	hint.text = "B: detener la evolución" if item_id == &"" else "Evolucionando con un objeto..."
	run.call_deferred()

func run() -> void:
	AudioManager.save_bgm()
	_audio_saved = true
	AudioManager.play_bgm(&"evolution")
	if not fast: AudioManager.play_me(&"evolution")
	var original := pokemon.species_id
	for step: int in 16:
		_sprite.set_pokemon({"species": original if step % 2 == 0 else StringName(evolution.to), "shiny": pokemon.shiny})
		_flash.set_shader_parameter(&"whiten", 1.0)
		await get_tree().create_timer(0.01 if fast else 0.28 - step * 0.013).timeout
		if _cancelled: break
	_animating = false
	_flash.set_shader_parameter(&"whiten", 0.0)
	if _cancelled:
		_sprite.set_pokemon({"species": original, "shiny": pokemon.shiny})
		_message.text = "Se ha detenido la evolución."
	else:
		apply_evolution(pokemon, evolution, item_id)
		_sprite.set_pokemon({"species": pokemon.species_id, "shiny": pokemon.shiny})
		_message.text = "¡Ahora es %s!" % pokemon.species().name
		if not fast:
			AudioManager.play_cry(pokemon.species_id)
			AudioManager.play_se(&"menu_accept")
	hint.text = "A / B: continuar"
	_completed = true
	if fast: _finish()

static func apply_evolution(p: Pokemon, evo: Dictionary, item: StringName = &"") -> void:
	var from := p.species_id
	EvolutionRules.evolve(p, evo)
	if item != &"": GameState.bag.remove(item)
	GameState.pokedex.register(p)
	var shed := EvolutionRules.shed_species(from, p.species_id)
	if shed != &"" and GameState.locke == null and not GameState.party.is_full() and GameState.bag.has(&"pokeball"):
		var extra := Pokemon.from_dict(p.to_dict())
		extra.uid = Pokemon.create(shed, p.level).uid
		extra.evolve_to(shed)
		extra.nickname = ""
		extra.held_item = &""
		extra.ball = &"pokeball"
		GameState.party.add(extra)
		GameState.bag.remove(&"pokeball")
		GameState.pokedex.register(extra)

func _unhandled_input(event: InputEvent) -> void:
	if _animating and item_id == &"" and event.is_action_pressed(&"cancel"):
		_cancelled = true
	elif _completed and (event.is_action_pressed(&"accept") or event.is_action_pressed(&"cancel")): _finish()
	else: return
	get_viewport().set_input_as_handled()

func _finish() -> void:
	_completed = false
	AudioManager.restore_bgm()
	_audio_saved = false
	evolved.emit(not _cancelled)

static func learn_evolution_moves(p: Pokemon) -> void:
	for id: StringName in DataDB.moves_learned_at(p.species_id, 0):
		if p.has_move(id): continue
		if p.try_learn(id):
			await Dialogue.say("¡%s ha aprendido %s!" % [p.display_name(), DataDB.move(id).name])
		else:
			var request := {"move_id": id, "move_name": DataDB.move(id).name, "moves": EngineDriver._moves_of(p)}
			var index := await LearnMoveScreen.choose(request)
			if index >= 0: p.replace_move(index, id)

func _exit_tree() -> void:
	if _audio_saved:
		AudioManager.restore_bgm()
		_audio_saved = false
