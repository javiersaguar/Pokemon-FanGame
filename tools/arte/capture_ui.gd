extends SceneTree
## Capturas de pantallas reales, sin modificar sprites ni datos persistentes.
var screen: Control
var runtime: Control
var main: Node
var case_name := "options"
var output_dir := "res://docs/arte/comparativas"

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	await process_frame
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--screen="):
			case_name = arg.trim_prefix("--screen=")
		if arg.begins_with("--output-dir="): output_dir = arg.trim_prefix("--output-dir=")
	root.size = Vector2i(512, 384)
	if case_name == "locke_game_over":
		main = load("res://src/main/main.tscn").instantiate()
		main.set_script(null)
		root.add_child(main)
		root.get_node("SceneManager").register_main(main)
		root.get_node("SceneManager")._fade.hide()
	if case_name.begins_with("playtest_"):
		main = load("res://src/main/main.tscn").instantiate()
		main.set_script(null)
		root.add_child(main)
		var manager = root.get_node("SceneManager")
		manager.register_main(main)
		screen = root.get_node("Debug")._preferred_panel
		await screen.session.begin(&"getafe/exterior")
		root.get_node("Debug").open()
		screen.pages.current_tab = {"playtest_world":0,"playtest_team":1,"playtest_battle":2,"playtest_items":3,"playtest_gallery":4}.get(case_name,0)
		if case_name == "playtest_before":
			root.get_node("Debug").unregister_panel(screen)
			await process_frame
			root.get_node("Debug")._panel.theme = null
			root.get_node("Debug")._tabs.remove_theme_font_size_override(&"font_size")
			root.get_node("Debug")._tabs.current_tab = 0
			screen = Control.new()
			root.add_child(screen)
		elif case_name == "playtest_picker":
			root.get_node("Debug").close()
			var menu := screen
			screen = load("res://src/ui/playtest/playtest_picker.gd").new()
			screen.caption = "Especies y formas"
			screen.entries = menu._catalogue("species")
			manager.push_menu(screen)
			screen.search.text = "char"
			screen._filter("char")

	elif case_name in ["stat_before","stat_up","stat_down","stat_reduced"]:
		screen = load("res://src/battle/scene/battle_scene.tscn").instantiate()
		root.add_child(screen)
		screen._background.set_environment(&"grass")
		screen._apply_bases()
		screen.get_node("Canvas/Curtain").hide()
		screen._player_sprite.set_pokemon({"species":&"charizard"})
		screen._foe_sprite.set_pokemon({"species":&"magikarp"})
		screen._player_box.show_pokemon({"name":"Charizard","level":50,"hp":150,"max_hp":150})
		screen._foe_box.show_pokemon({"name":"Magikarp","level":50,"hp":100,"max_hp":100})
		screen._player_box.show()
		screen._foe_box.show()
		if case_name == "stat_before":
			var fx = load("res://src/battle/scene/battle_fx.gd").create(screen._fx,2,screen._player_sprite.center(),screen._player_sprite.center(),{"asset":"eb519_2","frame":[]},Color("f87858"))
			fx.progress = 0.45
		else:
			var down := case_name == "stat_down"
			var fx = load("res://src/battle/scene/battle_stat_change.gd").create(screen._fx,screen._foe_sprite.center() if down else screen._player_sprite.center(),"def" if down else "atk",-1 if down else 2,case_name == "stat_reduced")
			fx.progress = 0.45
	elif case_name in ["dialogue","choice","volume"]:
		if case_name == "volume":
			screen = load("res://src/ui/widgets/choice_screen.gd").new()
			screen.caption = "Volumen / Música"
			for value: int in range(0,101,10): screen.choices.append("%d %%" % value)
			root.add_child(screen)
		else:
			screen = Control.new(); root.add_child(screen)
			var dialogue = root.get_node("Dialogue")
			dialogue.text_speed = 0; dialogue._box.text_speed = 0
			if case_name == "dialogue": dialogue.say("¡Hola, Javier! Pokémon Panchito te espera.")
			else: dialogue.ask_yes_no("¿Quieres continuar?")
	elif case_name in ["recordador","tutor"]:
		screen = load("res://src/ui/learn_move/move_lesson_screen.gd").new()
		var p = load("res://src/pokemon/pokemon.gd").create(&"charmander",30)
		var lessons = load("res://src/pokemon/move_lessons.gd")
		screen.caption = "Recordar movimiento" if case_name == "recordador" else "Tutor de movimientos"
		screen.move_ids = lessons.relearnable(p) if case_name == "recordador" else lessons.tutor_moves(p.species_id)
		root.add_child(screen)
	elif case_name in ["controls","controls_names"]:
		screen = load("res://src/ui/options/controls_screen.gd").new()
		root.add_child(screen)
		if case_name == "controls_names": screen.page = 1; screen._refresh(); screen.menu.select(4)
	elif case_name in ["locke_cemetery","locke_game_over","locke_zone"]:
		if case_name == "locke_zone":
			screen = Control.new()
			root.add_child(screen)
			var ui = load("res://src/ui/widgets/ui_canvas.gd").new()
			ui.theme = load("res://src/ui/theme/main_theme.tres")
			screen.add_child(ui)
			var bg := ColorRect.new()
			bg.size = Vector2(256,192)
			bg.color = Color("4592ca")
			ui.add_child(bg)
			var zone = load("res://src/ui/randomlocke/locke_zone_indicator.gd").new()
			ui.add_child(zone)
			zone.set_zone("Ruta 1","available",true)
			zone.show()
		else:
			var poke = load("res://src/pokemon/pokemon.gd").create(&"charmander",12)
			var grave: Dictionary = poke.to_dict()
			grave.nickname = "Chispa"
			grave.zone_id = "ruta_1"
			grave.opponent = "Vendedor de Chupachups Manolo"
			grave.epitaph = "Aquí yace Chispa: el crítico no venía en el contrato."
			screen = load("res://src/ui/randomlocke/"+("cemetery_screen" if case_name == "locke_cemetery" else "locke_game_over_screen")+".gd").new()
			screen.snapshot = {"cemetery":[grave],"captures":5,"death_count":1}
			root.add_child(screen)
	elif case_name in ["locke_mode","locke_settings","locke_generating","locke_summary"]:
		if case_name == "locke_mode":
			screen = load("res://src/ui/widgets/choice_screen.gd").new()
			screen.caption = "Modo de partida"
			screen.choices = ["Normal","RandomLocke"]
			screen.notes = ["Aventura con los datos originales del juego.","Una ROM por semilla y reglas configurables."]
		elif case_name == "locke_settings": screen = load("res://src/ui/randomlocke/randomlocke_settings_screen.gd").new()
		elif case_name == "locke_generating": screen = load("res://src/ui/randomlocke/randomlocke_generating_screen.gd").new()
		else:
			screen = load("res://src/ui/randomlocke/randomlocke_summary_screen.gd").new()
			var patch_class = load("res://src/randomizer/randomizer.gd")
			var settings_class = load("res://src/randomizer/randomizer_settings.gd")
			screen.rom = patch_class.generate(713,settings_class.from_preset("clasico"))
		root.add_child(screen)
	elif case_name.begins_with("summary_"):
		screen = load("res://src/ui/summary/summary_screen.gd").new()
		root.add_child(screen)
		var p = load("res://src/pokemon/pokemon.gd").create(&"charmander",16)
		p.nature = &"adamant"
		p.nickname = "ABCDEFGHIJKL" if case_name == "summary_long" else "Panchito"
		screen.party.assign([p,load("res://src/pokemon/pokemon.gd").create(&"pidgey",7)])
		screen._refresh()
		screen.show_page({"summary_data":0,"summary_notes":1,"summary_stats":2}.get(case_name,0))
		if case_name == "summary_moves":
			var card = screen
			screen = load("res://src/ui/widgets/choice_screen.gd").new()
			var details = card.detail_choices(p)
			screen.caption = "Ficha / detalles"
			screen.choices = details.labels; screen.notes = details.notes
			root.add_child(screen)
			screen.menu.select(1)
			card.queue_free()
	elif case_name in ["daycare","hatching_egg","hatching_born"]:
		var p = load("res://src/pokemon/pokemon.gd").create(&"charmander",1)
		if case_name == "daycare":
			screen = load("res://src/ui/daycare/daycare_screen.gd").new()
			screen.service = load("res://src/pokemon/daycare.gd").new(8)
			screen.service.deposit(p)
			screen.service.deposit(load("res://src/pokemon/pokemon.gd").create(&"ditto",5))
			screen.service.egg_ready = true
		else:
			screen = load("res://src/ui/hatching/hatching_screen.gd").new()
			screen.pokemon = p
			screen.preview = true
		root.add_child(screen)
		if case_name == "hatching_born": screen.show_baby()
	elif case_name in ["mechanics_menu","mega","zmove","dynamax","tera"]:
		screen = load("res://src/battle/scene/battle_scene.tscn").instantiate()
		screen.fast = true
		root.add_child(screen)
		screen._box.text_speed = 0
		screen._background.set_environment(&"grass")
		screen._apply_bases()
		screen.get_node("Canvas/Curtain").hide()
		screen._driver = load("res://src/battle/scene/dev/fake_battle.gd").new({},7)
		await screen._play_event({"type":&"switch_in","side":0,"slot":0,"data":{"species":&"charmander","name":"Chispa","hp":30,"max_hp":36,"level":12}})
		screen._foe_sprite.set_pokemon({"species":&"bulbasaur"})
		screen._foe_box.show_pokemon({"name":"Bulbasaur","level":12,"hp":30,"max_hp":36})
		screen._foe_box.show()
		if case_name == "mechanics_menu": screen._choose_mechanic({"can_mega":true,"z_moves":[0],"can_dynamax":true,"can_tera":true},0)
		else:
			var data := {"species":&"charizardmegax","hp":60,"max_hp":72,"type":&"water"}
			await screen._play_event({"type":StringName(case_name),"side":0,"slot":0,"data":data})
			screen._box.play({"mega":"Megaevolución / Chispa","zmove":"Movimiento Z","dynamax":"Dinamax / PS al doble","tera":"Teratipo Agua"}[case_name],"",false)
	elif case_name in ["battle_double","double_target","battle_long"]:
		screen = load("res://src/battle/scene/battle_scene.tscn").instantiate()
		screen.fast = true
		root.add_child(screen)
		screen._info = {"format":&"double"}
		screen._configure_field()
		screen._background.set_environment(&"grass")
		screen._apply_bases()
		screen.get_node("Canvas/Curtain").hide()
		var ids := [[&"charmander",&"bulbasaur"],[&"pidgey",&"rattata"]]
		for side: int in 2:
			for slot: int in 2:
				var id: StringName = ids[side][slot]
				var data = root.get_node("DataDB").species(id)
				screen._sprite(side,slot).set_pokemon({"species":id})
				screen._data_box(side,slot).show_pokemon({"name":"ABCDEFGHIJKL" if case_name == "battle_long" else data.name,"gender":&"female","shiny":case_name == "battle_long","level":100 if case_name == "battle_long" else 12,"hp":30,"max_hp":36})
				screen._data_box(side,slot).show()
		screen._box.text_speed = 0
		if case_name == "double_target":
			var disabled: Array[bool] = []
			screen._list("Elige el objetivo.",PackedStringArray(["Pidgey / puesto 1","Rattata / puesto 2"]),disabled,true)
		else: screen._box.set_text_width(112); screen._box.play("¿Qué debería hacer Bulbasaur?","",false); screen._command_panel.show()
	elif case_name.begins_with("motion_"):
		screen = load("res://src/battle/scene/battle_scene.tscn").instantiate()
		root.add_child(screen)
		screen._background.set_environment(&"grass")
		screen._apply_bases()
		screen.get_node("Canvas/Curtain").hide()
		screen._player_sprite.set_pokemon({"species": &"charmander"})
		screen._foe_sprite.set_pokemon({"species": &"bulbasaur"})
		var fx_class = load("res://src/battle/scene/battle_fx.gd")
		var kind = fx_class.Kind.ORB if case_name == "motion_special" else (fx_class.Kind.SPARKLE if case_name == "motion_status" else fx_class.Kind.BURST)
		var spec = fx_class.type_profile(&"fire" if kind == fx_class.Kind.ORB else &"normal")
		if case_name in ["motion_scratch","motion_stringshot","motion_vinewhip"]:
			spec = load("res://src/battle/scene/battle_move_animation.gd").sequence(StringName(case_name.trim_prefix("motion_")))
			kind = fx_class.Kind.ORB if spec.kind == "orb" else fx_class.Kind.BURST
		var fx = fx_class.create(screen._fx, kind, screen._player_sprite.center(), screen._foe_sprite.center(), spec, Color(0.7,1,0.5))
		fx.progress = 0.45
	elif case_name.begins_with("transition_"):
		if case_name == "transition_before":
			screen = load("res://src/battle/scene/battle_scene.tscn").instantiate()
			root.add_child(screen)
			screen._background.set_environment(&"grass")
			screen._open_curtain(false)
			await create_timer(0.15).timeout
		else:
			screen = load("res://src/battle/scene/battle_entry_transition.gd").new()
			screen.kind = StringName(case_name.trim_prefix("transition_"))
			screen.info = {"transition": screen.kind}
			root.add_child(screen)
			screen.set_progress(0.5)
	elif case_name in ["shift", "forced"]:
		screen = load("res://src/battle/scene/battle_scene.tscn").instantiate()
		screen.fast = true
		root.add_child(screen)
		screen._box.text_speed = 0
		screen._driver = load("res://src/battle/scene/dev/fake_battle.gd").new({}, 7)
		screen._background.set_environment(&"grass")
		screen.get_node("Canvas/Curtain").hide()
		screen._ask_player({"kind": &"switch", "reason": &"shift" if case_name == "shift" else &"faint"})
	elif case_name.begins_with("title") or case_name in ["splash", "notice", "intro", "main_menu", "credits"]:
		if case_name == "credits":
			screen = load("res://src/ui/title/title_screen.gd").new()
			screen.skip_sequence = true
		else:
			screen = load("res://src/ui/title/title_screen.gd").new()
			screen.skip_sequence = true
			if case_name == "title_reduced": load("res://src/ui/options/ui_preferences.gd").set_value("reduce_animations",true,false)
			elif case_name.begins_with("title_"):
				screen.logo_variant = int(case_name.trim_prefix("title_"))
		root.add_child(screen)
		if case_name == "credits":
			screen.show_subscreen(load("res://src/ui/title/credits_screen.gd").new())
		if case_name in ["splash", "notice", "intro", "main_menu"]:
			screen.set_stage(&"menu" if case_name == "main_menu" else StringName(case_name))
		await create_timer(0.35).timeout
	elif case_name in ["dex", "dex_entry", "dex_area", "dex_shiny", "dex_forms", "pc", "trainer_card", "region_map", "learn_move", "evolution", "professor_intro"]:
		var manager = root.get_node("SceneManager")
		var state = root.get_node("GameState")
		main = load("res://src/main/main.tscn").instantiate()
		main.set_script(null)
		root.add_child(main)
		manager.register_main(main)
		await manager.start_new_game(&"", &"", {"slot": 1})
		var pokemon = load("res://src/pokemon/pokemon.gd").create(&"charmander", 16)
		state.player_name = "Javier"
		state.party.add(pokemon)
		state.pokedex.register(pokemon)
		var paths = {"dex": "pokedex/pokedex_screen", "dex_entry": "pokedex/pokedex_entry", "learn_move": "learn_move/learn_move_screen", "evolution": "evolution/evolution_screen", "professor_intro": "intro/professor_intro", "dex_area":"pokedex/pokedex_entry", "dex_shiny":"pokedex/pokedex_entry", "dex_forms":"pokedex/pokedex_entry", "pc":"pc/pc_screen", "trainer_card":"trainer_card/trainer_card_screen", "region_map":"region_map/region_map_screen"}
		screen = load("res://src/ui/%s.gd" % paths[case_name]).new()
		if case_name in ["dex_entry","dex_area","dex_shiny"]:
			screen.species_id = &"charmander"
			if case_name == "dex_area": screen.species_id = &"pidgey"; state.pokedex.mark_seen(&"pidgey")
			screen.show_area = case_name == "dex_area"
			screen.shiny = case_name == "dex_shiny"
		if case_name == "dex_forms":
			state.pokedex.mark_seen(&"raichualola",true)
			screen.species_id = &"raichualola"
		if case_name == "pc":
			state.pc.set_pokemon(0,0,pokemon)
			state.pc.set_pokemon(0,4,load("res://src/pokemon/pokemon.gd").create(&"pidgey",7))
		if case_name == "learn_move":
			screen.request = {"move_id": &"flamethrower", "move_name": "Lanzallamas", "moves": load("res://src/battle/scene/engine_driver.gd")._moves_of(pokemon)}
		if case_name == "evolution":
			screen.pokemon = pokemon
			screen.evolution = {"to": "charmeleon", "method": "level"}
		manager.push_menu(screen)
		if case_name == "evolution": await create_timer(0.1).timeout
	elif case_name in ["party", "bag", "bag_items", "shop", "quantity"]:
		var manager = root.get_node("SceneManager")
		var state = root.get_node("GameState")
		main = load("res://src/main/main.tscn").instantiate()
		main.set_script(null)
		root.add_child(main)
		manager.register_main(main)
		await manager.start_new_game(&"", &"", {"slot": 1})
		state.player_name = "Javier"
		state.party.add(load("res://src/pokemon/pokemon.gd").create(&"charmander", 5))
		state.party.add(load("res://src/pokemon/pokemon.gd").create(&"pidgey", 7))
		state.bag.add(&"potion", 5)
		state.bag.add(&"antidote", 2)
		state.bag.add(&"pokeball", 10)
		state.bag.add(&"repel", 3)
		var paths = {"party": "party/party_screen", "bag": "bag/bag_screen", "bag_items": "widgets/choice_screen", "shop": "shop/shop_screen", "quantity": "widgets/quantity_picker"}
		screen = load("res://src/ui/%s.gd" % paths[case_name]).new()
		if case_name == "bag_items":
			screen.caption = "Medicinas"
			screen.choices = ["Poción / 5", "Antídoto / 2"]
			screen.notes = [root.get_node("DataDB").item(&"potion").description, root.get_node("DataDB").item(&"antidote").description]
			screen.images.append(load("res://assets/sprites/items/potion.png"))
			screen.images.append(load("res://assets/sprites/items/antidote.png"))
		if case_name == "shop": screen.shop_id = &"tienda_ciudad2"
		if case_name == "quantity":
			screen.caption = "Poción"
			screen.maximum = 15
			screen.unit_price = 200
			screen.quantity = 3
		manager.push_menu(screen)
	elif case_name in ["slots", "pause"]:
		var manager = root.get_node("SceneManager")
		var state = root.get_node("GameState")
		var saves = root.get_node("SaveManager")
		main = load("res://src/main/main.tscn").instantiate()
		main.set_script(null)
		root.add_child(main)
		manager.register_main(main)
		await manager.start_new_game(&"", &"", {"slot": 1})
		state.player_name = "Javier"
		await RenderingServer.frame_post_draw
		manager.world_snapshot = manager.capture_screen()
		saves.save_game(1)
		var settings = load("res://src/randomizer/randomizer_settings.gd").from_preset("clasico")
		var rom = load("res://src/randomizer/randomizer.gd").generate(42, settings)
		await manager.start_randomlocke(rom, 2, false)
		state.player_name = "Javi"
		await RenderingServer.frame_post_draw
		manager.world_snapshot = manager.capture_screen()
		saves.save_game(2)
		screen = load("res://src/ui/saves/save_slots_screen.gd" if case_name == "slots" else "res://src/ui/pause_menu/pause_menu.gd").new()
		manager.push_menu(screen)
	elif case_name == "name":
		screen = load("res://src/ui/name/name_keyboard.gd").new()
		screen.kind = &"player"
		screen.initial = "Javier"
		root.add_child(screen)
	else:
		screen = load("res://src/ui/options/options_screen.gd").new()
		root.add_child(screen)
		if case_name in ["options_yellow","options_green"]:
			load("res://src/ui/options/ui_preferences.gd").set_value("frame",1 if case_name == "options_yellow" else 2,false)
		if case_name in ["options_volumes","options_return"]:
			screen.page = 2 if case_name == "options_return" else 1
			screen._refresh()
		runtime = load("res://src/ui/ui_runtime.gd").new()
		root.add_child(runtime)
		if case_name == "run_notice":
			load("res://src/ui/options/ui_preferences.gd").set_value("always_run",true,false)
			root.get_node("GameState").set_always_run(true)
			screen.build_choices(); screen._refresh()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var path := "%s/a3_%s.png" % [output_dir,case_name]
	image.save_png(path)
	var bounds: Array = []
	_label_bounds(root,bounds)
	print("UI_BOUNDS ",JSON.stringify(bounds))
	print("Captura: ", path)
	screen.queue_free()
	if runtime:
		runtime.queue_free()
	if main:
		root.get_node("SceneManager")._leave_game()
		main.queue_free()
	await process_frame
	await process_frame
	for node: Node in root.get_node("AudioManager").get_children():
		if node is AudioStreamPlayer: node.stop(); node.stream = null
	await process_frame
	await process_frame
	await create_timer(0.1).timeout
	quit.call_deferred()


func _label_bounds(node: Node, records: Array) -> void:
	if node is Label and node.is_visible_in_tree():
		var rect: Rect2 = node.get_global_rect()
		var ancestor := node.get_parent()
		var scroll_clips := false
		while ancestor != null:
			if ancestor is ScrollContainer or (ancestor is Control and ancestor.clip_contents): scroll_clips = true
			ancestor = ancestor.get_parent()
		records.append({"text":node.text,"x":rect.position.x,"y":rect.position.y,"w":rect.size.x,"h":rect.size.y,"clip":node.clip_text,"wrap":node.autowrap_mode,"ancestor_clip":scroll_clips})
	for child: Node in node.get_children(): _label_bounds(child,records)
