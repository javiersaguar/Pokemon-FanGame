class_name PokedexEntry
extends MenuScreen
var species_id: StringName
var _sprite: BattlePokemonSprite
var _active_frame := 0
var _scroll: ScrollContainer
var _detail: Label

static func open(id: StringName) -> void:
	var screen := PokedexEntry.new()
	screen.species_id = id
	SceneManager.push_menu(screen)
	await screen.closed
	SceneManager.pop_menu(screen)

func _ready() -> void:
	var data := DataDB.species(species_id)
	heading.text = "%03d / %s" % [data.num, data.name]
	panel(Rect2(5, 33, 106, 121))
	panel(Rect2(117, 33, 134, 134))
	_sprite = BattlePokemonSprite.new()
	_sprite.position = Vector2(116, 267)
	add_child(_sprite)
	_sprite.set_pokemon({"species": species_id})
	var detail := label("", Rect2(125, 39, 118, 118), Color("382a38"), 8)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail = detail
	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(125, 39)
	_scroll.size = Vector2(118, 120)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	canvas.add_child(_scroll)
	canvas.remove_child(detail)
	detail.position = Vector2.ZERO
	detail.size = Vector2(118, 0)
	detail.custom_minimum_size.x = 118
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(detail)
	detail.text = "%s\n%.1f m / %.1f kg\n%s\n\n%s" % [" / ".join(data.types.map(func(id: StringName) -> String: return DataDB.type_name(id))), data.height, data.weight, data.genus, data.dex_entry if GameState.pokedex.is_caught(species_id) else "Captura a este Pokémon para leer su entrada."]
	hint.text = "A: grito / C: texto / B: volver"
	_active_frame = Engine.get_process_frames()

func _unhandled_input(event: InputEvent) -> void:
	if Engine.get_process_frames() <= _active_frame + 1: return
	if event.is_action_pressed(&"cancel"): closed.emit()
	elif event.is_action_pressed(&"accept"): AudioManager.play_cry(species_id)
	elif event.is_action_pressed(&"menu"):
		var limit := maxi(0, ceili(_detail.get_minimum_size().y - _scroll.size.y))
		_scroll.scroll_vertical = 0 if _scroll.scroll_vertical >= limit else mini(limit, _scroll.scroll_vertical + 32)
	else: return
	get_viewport().set_input_as_handled()
