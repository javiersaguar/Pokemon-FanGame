class_name PokedexEntry
extends MenuScreen
var species_id: StringName
var _sprite: BattlePokemonSprite
var _active_frame := 0
var _scroll: ScrollContainer
var _detail: Label
var forms: Array[StringName] = []
var form_index := 0
var shiny := false
var show_area := false

static func open(id: StringName) -> void:
	var screen := PokedexEntry.new()
	screen.species_id = id
	SceneManager.push_menu(screen)
	await screen.closed
	SceneManager.pop_menu(screen)

func _ready() -> void:
	forms = GameState.pokedex.forms_seen(species_id)
	if forms.is_empty(): forms.append(species_id)
	form_index = maxi(0,forms.find(species_id))
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
	_refresh_entry()
	_active_frame = Engine.get_process_frames()

func _refresh_entry() -> void:
	var data := DataDB.species(species_id)
	heading.text = "%03d / %s" % [data.num,data.name]
	_sprite.set_pokemon({"species":species_id,"shiny":shiny})
	_detail.text = "Áreas registradas\n\n" + "\n".join(areas(species_id)) if show_area else "%s\n%.1f m / %.1f kg\n%s\n%s\n\n%s" % [" / ".join(data.types.map(func(id: StringName) -> String: return DataDB.type_name(id))),data.height,data.weight,data.genus.replace("Pokemon","Pokémon") + ("\n" + data.form_name if not data.form_name.is_empty() else ""),"Variocolor" if shiny else "Color normal",data.dex_entry if GameState.pokedex.is_caught(species_id) else "Captura a este Pokémon para leer su entrada."]
	_scroll.scroll_vertical = 0
	hint.text = "Izq/Der: forma / R/Y: color / C: área / B: salir"

static func areas(id: StringName) -> PackedStringArray:
	var found := PackedStringArray()
	for table: StringName in DataDB.encounter_ids():
		if _contains_species(DataDB.encounter_table(table),id): found.append(String(table).replace("_"," "))
	if found.is_empty(): found.append("Sin encuentros registrados.")
	return found
static func _contains_species(value: Variant,id: StringName) -> bool:
	if value is Dictionary:
		if StringName(value.get("species","")) == id: return true
		for child: Variant in value.values():
			if _contains_species(child,id): return true
	elif value is Array:
		for child: Variant in value:
			if _contains_species(child,id): return true
	return false
func _unhandled_input(event: InputEvent) -> void:
	if Engine.get_process_frames() <= _active_frame + 1: return
	if event.is_action_pressed(&"cancel"): closed.emit()
	elif event.is_action_pressed(&"accept"): AudioManager.play_cry(species_id)
	elif event.is_action_pressed(&"move_left") or event.is_action_pressed(&"move_right"):
		form_index = wrapi(form_index + (1 if event.is_action_pressed(&"move_right") else -1),0,forms.size())
		species_id = forms[form_index]
		_refresh_entry()
	elif event.is_action_pressed(&"run_toggle"):
		if GameState.pokedex.is_shiny_seen(species_id): shiny = not shiny; _refresh_entry()
	elif event.is_action_pressed(&"menu"): show_area = not show_area; _refresh_entry()
	elif event.is_action_pressed(&"move_down") or event.is_action_pressed(&"move_up"):
		_scroll.scroll_vertical = maxi(0,_scroll.scroll_vertical + (32 if event.is_action_pressed(&"move_down") else -32))
	else: return
	get_viewport().set_input_as_handled()
