extends SceneTree
## Capturas de pantallas reales, sin modificar sprites ni datos persistentes.
var screen: Control
var runtime: Control
var main: Node
var case_name := "options"

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	await process_frame
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--screen="):
			case_name = arg.trim_prefix("--screen=")
	root.size = Vector2i(512, 384)
	if case_name in ["locke_cemetery","locke_game_over","locke_zone"]:
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
			if case_name.begins_with("title_"):
				screen.logo_variant = int(case_name.trim_prefix("title_"))
		root.add_child(screen)
		if case_name == "credits":
			screen.show_subscreen(load("res://src/ui/title/credits_screen.gd").new())
		if case_name in ["splash", "notice", "intro", "main_menu"]:
			screen.set_stage(&"menu" if case_name == "main_menu" else StringName(case_name))
		await create_timer(0.35).timeout
	elif case_name in ["dex", "dex_entry", "learn_move", "evolution", "professor_intro"]:
		var manager = root.get_node("SceneManager")
		var state = root.get_node("GameState")
		main = load("res://src/main/main.tscn").instantiate()
		main.set_script(null)
		root.add_child(main)
		manager.register_main(main)
		await manager.start_new_game(&"", &"", {"slot": 1})
		var pokemon = load("res://src/pokemon/pokemon.gd").create(&"charmander", 16)
		state.party.add(pokemon)
		state.pokedex.register(pokemon)
		var paths = {"dex": "pokedex/pokedex_screen", "dex_entry": "pokedex/pokedex_entry", "learn_move": "learn_move/learn_move_screen", "evolution": "evolution/evolution_screen", "professor_intro": "intro/professor_intro"}
		screen = load("res://src/ui/%s.gd" % paths[case_name]).new()
		if case_name == "dex_entry": screen.species_id = &"charmander"
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
		runtime = load("res://src/ui/ui_runtime.gd").new()
		root.add_child(runtime)
		if case_name == "run_notice":
			runtime._run_changed(true)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var path := "res://docs/arte/comparativas/a3_%s.png" % case_name
	image.save_png(path)
	print("Captura: ", path)
	screen.queue_free()
	if runtime:
		runtime.queue_free()
	if main:
		root.get_node("SceneManager")._leave_game()
		main.queue_free()
	await process_frame
	quit.call_deferred()
