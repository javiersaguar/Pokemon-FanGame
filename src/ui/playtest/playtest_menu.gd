class_name PlaytestMenu
extends VBoxContainer
## Banco de pruebas jugable. Todo se aplica únicamente a PlaytestSession.
var session: PlaytestSession
var pages: TabContainer
var status: Label
var start_button: Button
var finish_button: Button
var actions: Array[Button] = []
var map_id: StringName = &"pueblo_inicial/exterior"
var map_button: Button
var spawn_pick: OptionButton
var side_pick: OptionButton
var member_pick: OptionButton
var species_button: Button
var item_button: Button
var move_buttons: Array[Button] = []
var level_pick: SpinBox
var shiny_pick: CheckBox
var team_line: Label
var spec: Dictionary = {}
var trainer_id: StringName = &""
var trainer_button: Button
var custom_pick: CheckBox
var double_pick: CheckBox
var environment_pick: OptionButton
var mechanic_checks: Dictionary = {}
var exp_pick: CheckBox
var heal_pick: CheckBox
var ai_pick: SpinBox
var badge: Label
var _last_ready := false
var _catalogues: Dictionary = {}

func _ready() -> void:
	theme = PlaytestPicker.menu_theme()
	add_theme_constant_override(&"separation", 4)
	var head := _row(self)
	start_button = _button(head,"Entrar",_begin,false)
	finish_button = _button(head,"Salir de pruebas",_finish,false)
	_button(head,"Volver / F9",Debug.close,false)
	status = _label(self,"Sesión temporal. Tu partida se restaura al salir.")
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.custom_minimum_size.y = 24
	pages = TabContainer.new()
	pages.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pages.add_theme_font_size_override(&"font_size",16)
	add_child(pages)
	_build_world(_page("Mundo"))
	_build_team(_page("Equipo"))
	_build_battle(_page("Combate"))
	_build_items(_page("Objetos"))
	_build_gallery(_page("Galería"))
	var layer := CanvasLayer.new()
	layer.layer = 90
	add_child(layer)
	badge = Label.new()
	badge.theme = theme
	badge.text = "PRUEBAS · F9"
	badge.position = Vector2(348,2)
	badge.add_theme_color_override(&"font_color",Color("fff4d8"))
	badge.add_theme_color_override(&"font_shadow_color",Color("303048"))
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(badge)
	session.changed.connect(func() -> void: _load_member(); refresh())
	Debug.opened.connect(refresh)
	_refresh_spawns()
	_load_member()
	refresh()

func _process(_delta: float) -> void:
	var ready := session.active and session.available()
	if ready != _last_ready:
		_last_ready = ready
		for button: Button in actions: button.disabled = not ready
	start_button.disabled = session.active or not session.available()
	finish_button.disabled = not ready
	badge.visible = session.active and not Debug.is_open and not SceneManager.is_menu_open() and not Dialogue.is_open

func refresh() -> void:
	if not is_node_ready(): return
	if session.active:
		status.text = "Pruebas · %s · F9: jugar/cambiar. Sin guardado." % (SceneManager.current_map.get_display_name() if SceneManager.current_map else "Preparando")
	else: status.text = "Sesión temporal. Tu partida se restaura al salir."
	_last_ready = not (session.active and session.available())

func _page(title: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = title
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	pages.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override(&"separation",6)
	scroll.add_child(box)
	return box

func _row(parent: Node) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation",8)
	parent.add_child(row)
	return row

func _label(parent: Node, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, callback: Callable, active_only := true) -> Button:
	var button := Button.new()
	button.text = text
	button.clip_text = true
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 32
	button.pressed.connect(callback)
	parent.add_child(button)
	if active_only:
		actions.append(button)
		button.disabled = not session.active
	return button

func _check(parent: Node, text: String, on := false) -> CheckBox:
	var check := CheckBox.new()
	check.text = text
	check.button_pressed = on
	parent.add_child(check)
	return check

func _spin(parent: Node, lo: int, hi: int, value: int) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = lo
	spin.max_value = hi
	spin.value = value
	spin.custom_minimum_size.x = 76
	parent.add_child(spin)
	return spin

func _message(error: Error, success: String) -> void:
	status.text = success if error == OK else "No se pudo completar: %s. Termina primero el diálogo o combate." % error_string(error)

func _begin() -> void:
	var spawn := _spawn()
	_message(await session.begin(map_id,spawn),"Sesión lista. F9 abre el menú; juega y cambia lo que quieras.")

func _finish() -> void:
	_message(await session.finish(),"Partida anterior restaurada.")

func _build_world(box: VBoxContainer) -> void:
	_label(box,"Todos los mapas disponibles, también los aún aislados.")
	map_button = _button(box,"San Miguel de Bernuy · elegir destino",_choose_map,false)
	var row := _row(box)
	var spawn_label := _label(row,"Llegada")
	spawn_label.custom_minimum_size.x = 70
	spawn_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	spawn_pick = OptionButton.new()
	spawn_pick.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spawn_pick)
	_button(row,"Viajar y jugar",_travel)
	var tools := _row(box)
	_button(tools,"Curar equipo",_heal)
	var encounters := _check(tools,"Encuentros")
	encounters.toggled.connect(func(on: bool) -> void:
		if session.active: Debug.encounters_disabled = not on)
	var clip := _check(tools,"Atravesar")
	clip.toggled.connect(func(on: bool) -> void:
		if session.active: Debug.noclip = on)
	var hour := _row(box)
	_label(hour,"Hora")
	for entry: Array in [["Día",12],["Noche",22]]:
		_button(hour,entry[0],func() -> void:
			Clock.set_debug_hour_offset(0)
			Clock.set_debug_hour_offset(int(entry[1])-Clock.hour()))
	_button(hour,"Hora real",func() -> void: Clock.set_debug_hour_offset(0))
	var screens := _row(box)
	_button(screens,"Mapa región",func() -> void: await _screen(&"region"))
	_button(screens,"Tarjeta",func() -> void: await _screen(&"card"))
	_button(screens,"Opciones",func() -> void: await _screen(&"options"))
	_label(box,"Camina, habla, compra y usa Surf o la bici de la sesión.")
	_label(box,"El arte de los mapas sigue pendiente de revisión de Javier.")

func _choose_map() -> void:
	Debug.close()
	if not _catalogues.has("maps"): _catalogues.maps = PlaytestSession.maps()
	var id := await PlaytestPicker.pick("Ciudades, rutas y salas",_catalogues.maps)
	if id != "":
		map_id = StringName(id)
		for entry: Dictionary in _catalogues.maps:
			if entry.id == id: map_button.text = str(entry.label)+" · elegir destino"
		_refresh_spawns()
	Debug.open()

func _refresh_spawns() -> void:
	spawn_pick.clear()
	for id: StringName in PlaytestSession.spawns(map_id):
		spawn_pick.add_item(String(id))
		if id == MapRoot.DEFAULT_SPAWN: spawn_pick.select(spawn_pick.item_count-1)

func _spawn() -> StringName:
	return StringName(spawn_pick.get_item_text(spawn_pick.selected)) if spawn_pick.item_count > 0 else MapRoot.DEFAULT_SPAWN

func _travel() -> void:
	if not session.active or not session.available(): return
	Debug.close()
	_message(await SceneManager.change_map(map_id,_spawn()),"Destino listo. Continúa jugando; F9 permite cambiar de mapa.")

func _heal() -> void:
	if session.active:
		GameState.party.heal_all()
		status.text = "Equipo curado: PS, PP y estados restaurados."

func _build_team(box: VBoxContainer) -> void:
	var row := _row(box)
	side_pick = OptionButton.new()
	side_pick.add_item("Jugador"); side_pick.add_item("Rival")
	side_pick.item_selected.connect(func(_i: int) -> void: _load_member())
	row.add_child(side_pick)
	member_pick = OptionButton.new()
	for i: int in 6: member_pick.add_item("Puesto %d" % (i+1))
	member_pick.item_selected.connect(func(_i: int) -> void: _load_member())
	row.add_child(member_pick)
	var level_label := _label(row,"Nv.")
	level_label.custom_minimum_size.x = 32
	level_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	level_pick = _spin(row,1,DataDB.MAX_LEVEL,50)
	level_pick.value_changed.connect(func(value: float) -> void: spec.level = int(value))
	shiny_pick = _check(row,"Shiny")
	shiny_pick.toggled.connect(func(on: bool) -> void: spec.shiny = on)
	var names := _row(box)
	species_button = _button(names,"Elegir Pokémon",_choose_species)
	item_button = _button(names,"Sin objeto",_choose_held)
	var grid := GridContainer.new()
	grid.columns = 2
	box.add_child(grid)
	for i: int in 4:
		var button := _button(grid,"Movimiento %d" % (i+1),_choose_move.bind(i))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		move_buttons.append(button)
	var controls := _row(box)
	_button(controls,"Aplicar / añadir",_apply_member)
	_button(controls,"Quitar puesto",_remove_member)
	_button(controls,"Ver equipo / ficha",func() -> void: await _screen(&"party"))
	team_line = _label(box,"")
	team_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var advanced := _row(box)
	_button(advanced,"Movimientos por nivel",func() -> void:
		spec.moves = DataDB.default_moves(StringName(spec.species),int(spec.level)).map(func(id: StringName) -> String: return String(id))
		_update_editor())
	_button(advanced,"Elegir teratipo",func() -> void:
		var id := await _pick("types","Teratipo")
		if id != "": spec.tera_type = "" if id == "-" else id)
	_label(box,"Hasta 6 por equipo. Los movimientos pueden ser cualquier set.")

func _load_member() -> void:
	if not species_button: return
	var members: Array[Pokemon] = GameState.party.members if session.active and side_pick.selected == 0 else session.foes
	var p: Pokemon = members[member_pick.selected] if member_pick.selected < members.size() else null
	spec = {"species":String(p.species_id) if p else "charizard", "level":p.level if p else 50,
		"item":String(p.held_item) if p else "", "shiny":p.shiny if p else false,
		"tera_type":String(p.tera_type) if p else "",
		"moves":p.moves.map(func(m: MoveSlot) -> String: return String(m.id)) if p else []}
	if spec.moves.is_empty(): spec.moves = DataDB.default_moves(StringName(spec.species),int(spec.level)).map(func(id: StringName) -> String: return String(id))
	_update_editor()
	if team_line:
		team_line.text = "Equipo: "+", ".join(members.map(func(member: Pokemon) -> String: return "%s Nv.%d" % [member.display_name(),member.level]))

func _update_editor() -> void:
	var species := DataDB.species(StringName(spec.species))
	species_button.text = _species_title(species)
	species_button.tooltip_text = species_button.text
	item_button.text = DataDB.item(StringName(spec.item)).name if spec.item != "" else "Sin objeto"
	level_pick.set_value_no_signal(int(spec.level))
	shiny_pick.set_pressed_no_signal(bool(spec.shiny))
	for i: int in 4:
		move_buttons[i].text = "%d · %s" % [i+1,DataDB.move(StringName(spec.moves[i])).name if i < spec.moves.size() else "Elegir movimiento"]

func _choose_species() -> void:
	var id := await _pick("species","Especie y forma")
	if id == "": return
	spec.species = id
	spec.moves = DataDB.default_moves(StringName(id),int(spec.level)).map(func(move: StringName) -> String: return String(move))
	_update_editor()

func _choose_move(index: int) -> void:
	var id := await _pick("moves","Movimiento %d" % (index+1))
	if id == "": return
	if index > spec.moves.size():
		status.text = "Elige los movimientos por orden, sin dejar huecos."
		return
	if index == spec.moves.size(): spec.moves.append(id)
	else: spec.moves[index] = id
	_update_editor()

func _choose_held() -> void:
	var id := await _pick("held","Objeto equipado")
	if id == "": return
	spec.item = "" if id == "-" else id
	_update_editor()

func _apply_member() -> void:
	var copy := spec.duplicate(true)
	var error := session.set_member(side_pick.selected,member_pick.selected,copy)
	_load_member()
	_message(error,"Pokémon aplicado; ya está listo para combatir.")

func _remove_member() -> void:
	var error := session.remove_member(side_pick.selected,member_pick.selected)
	_load_member()
	_message(error,"Puesto retirado.")

func _build_battle(box: VBoxContainer) -> void:
	var row := _row(box)
	trainer_button = _button(row,"Salvaje · elegir rival",_choose_trainer)
	custom_pick = _check(row,"Equipo editado",true)
	var rules := _row(box)
	double_pick = _check(rules,"Dobles")
	var ai_label := _label(rules,"IA")
	ai_label.custom_minimum_size.x = 24
	ai_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	ai_pick = _spin(rules,0,4,2)
	environment_pick = OptionButton.new()
	for id: StringName in BattleBackground.FILES:
		environment_pick.add_item({"grass":"Bosque","field":"Pradera","forest":"Bosque","cave":"Cueva","city":"Ciudad","water":"Agua","indoor":"Interior","snow":"Nieve","sand":"Arena"}[String(id)])
		environment_pick.set_item_metadata(environment_pick.item_count-1,id)
	rules.add_child(environment_pick)
	var mechanics := _row(box)
	for entry: Array in [["mega","Mega"],["z","Z"],["dynamax","Dinamax"],["tera","Tera"]]:
		mechanic_checks[entry[0]] = _check(mechanics,entry[1])
	var extras := _row(box)
	exp_pick = _check(extras,"Experiencia",true)
	heal_pick = _check(extras,"Curar antes",true)
	_button(extras,"Iniciar combate",_battle)
	var stats := _row(box)
	_button(stats,"Probar subidas",_stat_preset.bind(true))
	_button(stats,"Probar bajadas",_stat_preset.bind(false))
	_label(box,"El salvaje usa 1 rival (2 en dobles); entrenador, su equipo entero.")
	_label(box,"Mega y Z requieren objeto equipado; Tera usa el teratipo del Pokémon.")

func _choose_trainer() -> void:
	var id := await _pick("trainers","Entrenador o combate salvaje")
	if id == "": return
	trainer_id = &"" if id == "-" else StringName(id)
	trainer_button.text = "Salvaje · elegir rival" if trainer_id == &"" else BattleSetup.trainer_info(trainer_id,GameState.player_name).display_name
	custom_pick.button_pressed = trainer_id == &""

func _battle() -> void:
	if not session.active or not session.available(): return
	if heal_pick.button_pressed: GameState.party.heal_all()
	var options := {"double":double_pick.button_pressed,"environment":environment_pick.get_selected_metadata(),
		"background":environment_pick.get_selected_metadata(),"ai_level":int(ai_pick.value),"exp_enabled":exp_pick.button_pressed}
	for key: String in mechanic_checks: options[key] = mechanic_checks[key].button_pressed
	var setup := session.battle_setup(trainer_id,custom_pick.button_pressed,options)
	if setup == null:
		status.text = "Revisa los equipos: dobles necesita 2 Pokémon capaces de combatir."
		return
	Debug.close()
	var outcome := await SceneManager.start_battle(setup)
	session.changed.emit()
	_message(OK,"Combate terminado (%s). Sigue explorando o abre F9." % outcome)

func _stat_preset(up: bool) -> void:
	if not session.active or not session.available(): return
	var moves: Array = ["swordsdance","agility","amnesia","doubleteam"] if up else ["growl","tailwhip","scaryface","screech"]
	_message(session.set_member(0,0,{"species":"charizard","level":50,"moves":moves}),"Set preparado en el primer Pokémon. Elige Luchar para probarlo.")
	session.foes = [Pokemon.from_spec({"species":"magikarp","level":50,"moves":["splash"]}),Pokemon.from_spec({"species":"magikarp","level":50,"moves":["splash"]})]
	session.changed.emit()
	trainer_id = &""
	double_pick.button_pressed = false
	for check: CheckBox in mechanic_checks.values(): check.button_pressed = false
	await _battle()

func _build_items(box: VBoxContainer) -> void:
	_label(box,"Añade objetos del catálogo y úsalos en el juego o en combate.")
	_button(box,"Elegir objeto y cantidad",_give_item)
	var row := _row(box)
	_button(row,"Abrir mochila",func() -> void: await _screen(&"bag"))
	_button(row,"Abrir PC",func() -> void: await _screen(&"pc"))
	_button(row,"Tienda",_shop)
	_label(box,"Para equiparlos, usa la pestaña Equipo o la mochila.")

func _give_item() -> void:
	var id := await _pick("items","Añadir a la mochila")
	if id == "": return
	Debug.close()
	var amount := await ChoiceScreen.pick("Cantidad",["1","10","99","999"])
	if amount >= 0 and session.active:
		var added: int = GameState.bag.add(StringName(id),[1,10,99,999][amount])
		status.text = "+%d %s en la mochila de pruebas." % [added,DataDB.item(StringName(id)).name]
	Debug.open()

func _shop() -> void:
	var id := await _pick("shops","Tienda disponible")
	if id == "": return
	Debug.close()
	await ShopScreen.open(StringName(id))
	Debug.open()

func _build_gallery(box: VBoxContainer) -> void:
	var row := _row(box)
	_button(row,"Pokédex / gritos",func() -> void: await _screen(&"dex"))
	_button(row,"Monumentos",_monument)
	_button(row,"Música y sonidos",_audio)
	_button(box,"RandomLocke: ajustes, ROM y resumen",_rom)
	_label(box,"Los Pokémon del catálogo incluyen formas y shinies oficiales.")
	_label(box,"Elige movimientos en Equipo para ver sus animaciones en combate.")
	_label(box,"Los entrenadores muestran sus sprites o fotos al iniciar el combate.")

func _screen(kind: StringName) -> void:
	if not session.active or not session.available(): return
	Debug.close()
	match kind:
		&"party": await PartyScreen.open()
		&"bag": await BagScreen.open()
		&"pc": await PCScreen.open()
		&"dex": await PokedexScreen.open()
		&"region": await RegionMapScreen.open()
		&"card": await TrainerCardScreen.open()
		&"options":
			var screen := OptionsScreen.new()
			SceneManager.push_menu(screen)
			await screen.closed
			SceneManager.pop_menu(screen)
	Debug.open()

func _rom() -> void:
	if not session.active or not session.available(): return
	Debug.close()
	var settings := await RandomlockeSettingsScreen.edit(RandomizerSettings.from_preset("clasico"))
	if settings != null:
		var rom := await RandomlockeGeneratingScreen.generate(settings.to_dict(),SeedCode.random_seed())
		if rom != null and rom.is_valid() and await RandomlockeSummaryScreen.confirm(rom):
			await SceneManager.start_randomlocke(rom,0,true)
			session.changed.emit()
	Debug.open()

func _pick(kind: String, title: String) -> String:
	if not session.available(): return ""
	Debug.close()
	if not _catalogues.has(kind): _catalogues[kind] = _catalogue(kind)
	var id := await PlaytestPicker.pick(title,_catalogues[kind])
	Debug.open()
	return id

static func _species_title(species: SpeciesData) -> String:
	var form := species.form_name
	if form == "" and species.forme != &"":
		form = "Gigamax" if species.forme == &"gmax" else String(species.forme).capitalize()
	return species.name+(" · "+form if form != "" else "")

func _catalogue(kind: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var ids: Array[StringName] = []
	match kind:
		"species": ids = DataDB.species_ids()
		"moves": ids = DataDB.move_ids()
		"items","held": ids = DataDB.item_ids()
		"trainers": ids = DataDB.trainer_ids()
		"shops": ids = DataDB.shop_ids()
		"types": ids = DataDB.type_ids()
	for id: StringName in ids:
		var title := String(id)
		var note := String(id)
		match kind:
			"species":
				var species := DataDB.species(id)
				title = _species_title(species)
			"types": title = DataDB.type_name(id)
			"moves":
				title = DataDB.move(id).name
				note += " · "+DataDB.type_name(DataDB.move(id).type)
				note += " · Efecto general" if BattleMoveAnimation.sequence(id).is_empty() else " · Secuencia propia"
			"items","held": title = DataDB.item(id).name
			"trainers": title = BattleSetup.trainer_info(id,GameState.player_name).display_name
			"shops": title = str(DataDB.shop(id).get("name",String(id)))
		out.append({"id":String(id),"label":title,"note":note})
	out.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return str(a.label)+str(a.id) < str(b.label)+str(b.id))
	if kind in ["trainers","held","types"]:
		out.push_front({"id":"-","label":"Combate salvaje" if kind == "trainers" else ("Tipo natural" if kind == "types" else "Sin objeto"),"note":""})
	return out

func _monument() -> void:
	if not session.available(): return
	var out: Array[Dictionary] = []
	var pieces: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/tilesets/exterior/hecho_a_mano/piezas.json"))
	for key: String in pieces:
		if pieces[key] is Dictionary: out.append({"id":key,"label":key.replace("_"," ").capitalize(),"note":"Arte provisional, pendiente Javier"})
	out.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return str(a.label) < str(b.label))
	Debug.close()
	var id := await PlaytestPicker.pick("Piezas del mundo",out)
	if id != "":
		var preview := PlaytestArtPreview.new()
		preview.asset_path = "res://assets/tilesets/exterior/hecho_a_mano/%s.png" % id
		preview.caption = id.replace("_"," ").capitalize()
		SceneManager.push_menu(preview)
		await preview.closed
		SceneManager.pop_menu(preview)
	Debug.open()

func _audio() -> void:
	if not session.available(): return
	var out: Array[Dictionary] = []
	for folder: String in ["bgm","se","me","ambient"]:
		for file: String in DirAccess.get_files_at("res://assets/audio/"+folder):
			if file.get_extension() in AudioManager.EXTENSIONS:
				out.append({"id":folder+"/"+file.get_basename(),"label":folder.to_upper()+" · "+file.get_basename(),"note":"Escuchar original"})
	var previous := AudioManager.current_bgm
	var previous_ambient := AudioManager.current_ambient
	Debug.close()
	while session.active:
		var id := await PlaytestPicker.pick("Música y sonidos · Volver restaura la música",out)
		if id == "": break
		var bits := id.split("/")
		match bits[0]:
			"bgm": AudioManager.play_bgm(StringName(bits[1]),0)
			"se": AudioManager.play_se(StringName(bits[1]))
			"me": await AudioManager.play_me(StringName(bits[1]))
			"ambient": AudioManager.play_ambient(StringName(bits[1]))
	AudioManager.play_bgm(previous)
	AudioManager.play_ambient(previous_ambient)
	Debug.open()
