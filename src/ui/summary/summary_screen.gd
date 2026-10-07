class_name SummaryScreen
extends Control
## Ficha de un Pokémon (Fase 15.3, "Datos del Pokémon"). Diseño propio: interfaz
## de pixel art a ×2 en un UiCanvas, y el sprite y los iconos de los packs a 1:1.
## Páginas: Datos, Notas y Estadísticas (←/→); ↑/↓ cambia de Pokémon del equipo;
## `cancel` cierra.   await SummaryScreen.open(parent, party, index)

signal closed

const UI := "res://assets/sprites/ui/"
const PAGES: Array[String] = ["Datos", "Notas", "Estad."]
const STATS: Array[StringName] = [&"hp", &"atk", &"def", &"spa", &"spd", &"spe"]
const STAT_NAMES: Dictionary[StringName, String] = {
	&"hp": "PS", &"atk": "Ataque", &"def": "Defensa", &"spa": "At. Esp.", &"spd": "Def. Esp.", &"spe": "Velocidad",
}
const ICON_FRAME_TIME := 0.25
## Trozo del fondo "Field" (píxeles del archivo) que se ve detrás del Pokémon: cielo y horizonte.
const SCENERY_REGION := Rect2(80, 20, 224, 184)
## Centro de los pies del sprite en la ventana (píxeles de pantalla).
const SPRITE_FEET := Vector2(112, 256)
const TAB_ICONS := "res://assets/sprites/ui/summary/tab_icons.png"
## Carácter a partir del IV más alto (una frase por estadística).
const TRAITS: Dictionary[StringName, String] = {
	&"hp": "Resistente.", &"atk": "Luchador.", &"def": "Aguanta bien.",
	&"spa": "Muy curioso.", &"spd": "Mal genio.", &"spe": "Muy rápido.",
}

var party: Array[Pokemon] = []
var index := 0
var page := 0

var _canvas: UiCanvas
var _page_root: Control
var _tabs: Array[NinePatchRect] = []
var _name: Label
var _gender: TextureRect
var _star: TextureRect
var _level: Label
var _ball: TextureRect
var _sprite: BattlePokemonSprite
var _slots: Array[NinePatchRect] = []
var _icons: Array[TextureRect] = []
var _icon_time := 0.0
var _icon_frame := 0
var _detail_open := false


static func open(parent: Node, members: Array[Pokemon], start: int = 0) -> void:
	var screen := SummaryScreen.new()
	parent.add_child(screen)
	screen.show_party(members, start)
	await screen.closed
	screen.queue_free()


func _init() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE
	theme = preload("res://src/ui/theme/main_theme.tres")
	_canvas = UiCanvas.new()
	add_child(_canvas)
	var background := TextureRect.new()
	background.texture = load(UI + "summary/background_tile.png")
	background.stretch_mode = TextureRect.STRETCH_TILE
	background.size = UiCanvas.SIZE
	_canvas.add_child(background)
	_build_header()
	_build_card()
	_add_panel(UI + "battle/databox.png", Rect2(114, 22, 138, 132), 4)
	_page_root = Control.new()
	_page_root.mouse_filter = MOUSE_FILTER_IGNORE
	_canvas.add_child(_page_root)
	_build_party_band()
	_sprite = BattlePokemonSprite.new()
	_sprite.position = SPRITE_FEET
	add_child(_sprite)


func show_party(members: Array[Pokemon], start: int = 0) -> void:
	party = members
	index = clampi(start, 0, maxi(party.size() - 1, 0))
	_refresh()


func show_page(new_page: int) -> void:
	page = wrapi(new_page, 0, PAGES.size())
	_refresh_page()


func _process(delta: float) -> void:
	if UiPreferences.reduce_motion(): return
	_icon_time += delta
	if _icon_time >= ICON_FRAME_TIME:
		_icon_time -= ICON_FRAME_TIME
		_icon_frame = 1 - _icon_frame
		for i: int in _icons.size():
			var atlas := _icons[i].texture as AtlasTexture
			if atlas:
				atlas.region.position.x = (_icon_frame if i == index else 0) * atlas.region.size.x


func _unhandled_input(event: InputEvent) -> void:
	if party.is_empty() or _detail_open:
		return
	if event.is_action_pressed(&"move_right") or event.is_action_pressed(&"move_left"):
		show_page(page + (1 if event.is_action_pressed(&"move_right") else -1))
		AudioManager.play_se(&"cursor")
	elif event.is_action_pressed(&"move_down") or event.is_action_pressed(&"move_up"):
		index = wrapi(index + (1 if event.is_action_pressed(&"move_down") else -1), 0, party.size())
		AudioManager.play_se(&"cursor")
		_refresh()
	elif event.is_action_pressed(&"menu"):
		get_viewport().set_input_as_handled()
		_open_details()
		return
	elif event.is_action_pressed(&"cancel"):
		AudioManager.play_se(&"cancel")
		closed.emit()
	else:
		return
	get_viewport().set_input_as_handled()


# --- Construcción ---

func _build_header() -> void:
	_add_panel(UI + "battle/button_azul.png", Rect2(0, 0, 256, 20), 4)
	_add_label(tr("Ficha"), Vector2(8, 3), &"LightLabel")
	_add_label("C / Start: detalle", Vector2(48, 5), &"SmallLabel")
	var icons: Texture2D = load(TAB_ICONS)
	for i: int in PAGES.size():
		var tab := _add_panel(UI + "battle/button_claro.png", Rect2(168 + i * 28, 2, 26, 16), 4)
		var icon := TextureRect.new()
		var atlas := AtlasTexture.new()
		atlas.atlas = icons
		atlas.region = Rect2(i * 8, 0, 8, 8)
		icon.texture = atlas
		icon.position = Vector2(9, 3)
		icon.mouse_filter = MOUSE_FILTER_IGNORE
		tab.add_child(icon)
		_tabs.append(tab)


func _build_card() -> void:
	_add_panel(UI + "battle/databox.png", Rect2(4, 22, 108, 132), 4)
	# Paisaje del fondo de combate a 1:1 (escala 0,5 en el UiCanvas), con el marco encima.
	var scenery := TextureRect.new()
	var crop := AtlasTexture.new()
	crop.atlas = load(UI + "battle/backgrounds/forest.png")
	crop.region = Rect2(40, 0, 200, 216)
	scenery.texture = crop
	scenery.scale = Vector2(0.5, 0.5)
	scenery.position = Vector2(6, 24)
	_canvas.add_child(scenery)
	_add_panel(UI + "summary/window_frame.png", Rect2(6, 24, 100, 108), 4)
	var shadow := TextureRect.new()
	shadow.texture = load(UI + "battle/shadows/shadow_3.png")
	shadow.scale = Vector2(0.5, 0.5)
	shadow.position = Vector2(20, 112)
	_canvas.add_child(shadow)
	_ball = TextureRect.new()
	_ball.texture = load("res://assets/sprites/items/pokeball.png")
	_ball.scale = Vector2(0.5, 0.5)
	_ball.position = Vector2(6, 136)
	_canvas.add_child(_ball)
	_name = _add_label("", Vector2(30, 136), &"SmallLabel")
	_name.size.x = 74
	_name.clip_text = true
	_gender = TextureRect.new()
	_canvas.add_child(_gender)
	_star = TextureRect.new()
	_star.texture = load(UI + "icons/shiny_star.png")
	_canvas.add_child(_star)
	_level = _add_label("", Vector2(52, 148), &"SmallLabel")
	_level.size.x = 52
	_level.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT


func _build_party_band() -> void:
	_add_panel(UI + "battle/panel_message.png", Rect2(0, 158, 256, 34), 3)
	for i: int in 6:
		var slot := _add_panel(UI + "battle/button_claro.png", Rect2(10 + i * 41, 162, 36, 27), 4)
		_slots.append(slot)
		var icon := TextureRect.new()
		icon.scale = Vector2(0.5, 0.5)
		icon.position = Vector2(2, -6)
		icon.mouse_filter = MOUSE_FILTER_IGNORE
		slot.add_child(icon)
		_icons.append(icon)


# --- Contenido ---

func _refresh() -> void:
	if party.is_empty():
		return
	var p := party[index]
	_name.text = p.display_name()
	_gender.texture = BattleDataBox.GENDER_ICONS.get(p.gender)
	_gender.position = Vector2(30, 148).round()
	_star.visible = p.shiny
	_star.position = Vector2(40, 148).round()
	_level.text = tr("Nv%d") % p.level
	var ball_path := "res://assets/sprites/items/%s.png" % p.ball
	_ball.texture = load(ball_path) if ResourceLoader.exists(ball_path) else load("res://assets/sprites/items/pokeball.png")
	_sprite.set_pokemon({"species": p.species_id, "shiny": p.shiny})
	for i: int in 6:
		_slots[i].visible = i < party.size()
		if i < party.size():
			_slots[i].texture = load(UI + ("battle/button_amarillo_foco.png" if i == index else "battle/button_claro.png"))
			_icons[i].texture = _icon_atlas(party[i])
	_refresh_page()


func _refresh_page() -> void:
	for i: int in _tabs.size():
		_tabs[i].texture = load(UI + ("battle/button_amarillo.png" if i == page else "battle/button_claro.png"))
		(_tabs[i].get_child(0) as TextureRect).modulate = Color.WHITE if i == page else Color(0.25, 0.25, 0.35)
	for child: Node in _page_root.get_children():
		child.queue_free()
	if party.is_empty():
		return
	match page:
		0: _page_info(party[index])
		1: _page_notes(party[index])
		2: _page_stats(party[index])


func _page_info(p: Pokemon) -> void:
	var s := p.species()
	_section(tr("Información"), 30)
	var rows: Array = [
		[tr("Nº"), "%03d" % s.num], [tr("Especie"), s.name], [tr("Tipo"), ""],
		[tr("EO"), p.original_trainer], [tr("Nº ID"), "%05d" % (p.trainer_id % 100000)],
		[tr("Exp."), str(p.exp)], [tr("Subir"), str(p.exp_to_next_level())],
	]
	_rows(rows, 44)
	var x := 182.0
	for type: StringName in p.types():
		var icon := TypeIcons.make_rect(type)
		icon.position = Vector2(x, 44 + 2 * 13 + 1)
		_page_root.add_child(icon)
		x += 33
	var bar := HpBar.new()
	bar.exp_mode = true
	bar.position = Vector2(136, 138)
	bar.size = Vector2(108, 3)
	_page_root.add_child(bar)
	var span := maxi(p.exp_at_next_level() - p.exp_at_level_start(), 1)
	bar.set_instant(float(p.exp - p.exp_at_level_start()) / span)


func _page_notes(p: Pokemon) -> void:
	_section(tr("Encuentro"), 30)
	var place := String(p.met_location).replace("_", " ").capitalize() if p.met_location != &"" else tr("Desconocido")
	_rows([[tr("Lugar"), place], [tr("Nivel"), str(maxi(p.met_level, 1))],
		[tr("Fecha"), p.met_date if p.met_date != "" else "--"]], 44)
	_section(tr("Carácter"), 86)
	var nature := DataDB.nature(p.nature)
	var ability := DataDB.ability(p.ability_id())
	_rows([[tr("Natural."), nature.name if nature else String(p.nature)],
		[tr("Carácter"), _trait(p)],
		[tr("Habilidad"), ability.name if ability else String(p.ability_id())],
		[tr("Objeto"), DataDB.item(p.held_item).name if p.held_item != &"" and DataDB.has_item(p.held_item) else tr("Ninguno")]], 100)


func _page_stats(p: Pokemon) -> void:
	_section(tr("Estadísticas"), 30)
	var nature := DataDB.nature(p.nature)
	for i: int in STATS.size():
		var stat := STATS[i]
		var y := 44 + (0 if i == 0 else 8 + i * 14)
		var key := _add_label(tr(STAT_NAMES[stat]), Vector2(136, y), &"KeyLabel", _page_root)
		if nature and stat == nature.plus:
			key.text += " +"
			key.add_theme_color_override(&"font_color", Color("be4844"))
		elif nature and stat == nature.minus:
			key.text += " -"
			key.add_theme_color_override(&"font_color", Color("2e68a6"))
		var value := "%d/%d" % [p.current_hp, p.max_hp()] if stat == &"hp" else str(p.stat(stat))
		var label := _add_label(value, Vector2(196, y), &"", _page_root)
		label.size.x = 50
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var frame := NinePatchRect.new()
	frame.texture = BattleDataBox.HP_FRAME
	for side: Side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		frame.set_patch_margin(side, 2)
	frame.position = Vector2(136, 58)
	frame.size = Vector2(110, 6)
	_page_root.add_child(frame)
	var hp := HpBar.new()
	hp.position = Vector2(137, 59)
	hp.size = Vector2(108, 4)
	_page_root.add_child(hp)
	hp.set_instant(float(p.current_hp) / maxi(p.max_hp(), 1))


## Filas de [clave, valor] en la columna derecha, desde `y`.
func _rows(rows: Array, y: float) -> void:
	for i: int in rows.size():
		var key := _add_label(rows[i][0], Vector2(134, y + i * 13), &"SmallLabel", _page_root)
		key.clip_text = true
		key.size.x = 52
		var value := _add_label(rows[i][1], Vector2(188, y + i * 13), &"SmallLabel", _page_root)
		value.clip_text = true
		value.size.x = 57


func _section(title: String, y: float) -> void:
	var header := _add_panel(UI + "summary/section.png", Rect2(132, y, 116, 13), 3, _page_root)
	var label := _add_label(title, Vector2(6, 0), &"SmallLabel", header)
	label.size.y = 13
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _trait(p: Pokemon) -> String:
	var best := &"hp"
	var best_value := -1
	for stat: StringName in STATS:
		var value := int(p.ivs.get(stat, 0))
		if value > best_value:
			best_value = value
			best = stat
	return tr(TRAITS[best])


func _icon_atlas(p: Pokemon) -> AtlasTexture:
	var folder := "icons_shiny" if p.shiny else "icons"
	var path := "res://assets/sprites/pokemon/%s/%s.png" % [folder, p.species_id]
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/pokemon/icons/%s.png" % p.species_id
	if not ResourceLoader.exists(path):
		return null
	var sheet: Texture2D = load(path)
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	var frame := sheet.get_height()
	atlas.region = Rect2(0, 0, frame, frame)
	return atlas


func _add_panel(path: String, rect: Rect2, margin: int, parent: Node = null) -> NinePatchRect:
	var panel := NinePatchRect.new()
	panel.texture = load(path)
	for side: Side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		panel.set_patch_margin(side, margin)
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = MOUSE_FILTER_IGNORE
	(parent if parent else _canvas).add_child(panel)
	return panel


func _add_label(text: String, at: Vector2, variation: StringName, parent: Node = null) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at
	label.mouse_filter = MOUSE_FILTER_IGNORE
	if variation != &"":
		label.theme_type_variation = variation
	(parent if parent else _canvas).add_child(label)
	return label


## Los valores abreviados de la tarjeta se pueden leer completos con C / Start.
func detail_choices(p: Pokemon) -> Dictionary:
	var labels := PackedStringArray(["Datos completos"])
	var nature := DataDB.nature(p.nature)
	var ability := DataDB.ability(p.ability_id())
	var item := DataDB.item(p.held_item) if DataDB.has_item(p.held_item) else null
	var notes := PackedStringArray(["%s\nEspecie: %s\nEO: %s\nLugar: %s\nFecha: %s\nNaturaleza: %s\nCarácter: %s\nHabilidad: %s\nObjeto: %s" % [p.display_name(), p.species().name, p.original_trainer, String(p.met_location).replace("_"," ").capitalize(), p.met_date, nature.name if nature else String(p.nature), _trait(p), ability.name if ability else String(p.ability_id()), item.name if item else "Ninguno"]])
	for move: MoveSlot in p.moves:
		labels.append(DataDB.move(move.id).name)
		notes.append(LearnMoveScreen.describe(move.id, move.pp, move.max_pp()))
	labels.append("Cintas")
	notes.append("Sin cintas." if p.ribbons.is_empty() else "\n".join(p.ribbons))
	return {"labels":labels,"notes":notes}

func _open_details() -> void:
	_detail_open = true
	var data := detail_choices(party[index])
	await ChoiceScreen.pick("Ficha / detalles", data.labels, data.notes)
	_detail_open = false
