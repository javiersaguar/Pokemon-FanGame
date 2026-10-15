extends SceneTree
## Capturas reales a 512×384 del mapa del F9 (vista de España y recuadro de Madrid) y del mapa regional del
## juego, para docs/arte/comparativas/. Necesita ventana (no vale --headless).
## Uso: godot --path . -s res://tools/mundo/capturar_mapa_region.gd
## En un script suelto no existen los autoloads como nombres: se piden al árbol (root.get_node).

const OUT := "res://docs/arte/comparativas"


func _initialize() -> void:
	_run.call_deferred()


func _shot(file: String) -> void:
	for i: int in 6:
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	image.save_png("%s/%s.png" % [OUT, file])
	print("captura: %s/%s.png %s" % [OUT, file, image.get_size()])


func _run() -> void:
	await process_frame
	root.size = Vector2i(512, 384)
	var manager := root.get_node("SceneManager")
	var debug := root.get_node("Debug")
	var main: Node = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	root.add_child(main)
	manager.register_main(main)
	manager._fade.hide()
	var menu: Node = debug._preferred_panel
	await menu.session.begin(&"madrid/centro")
	for i: int in 30:
		await process_frame
	# F9 → Mundo → Mapa: vista de España con Madrid señalado.
	debug.open()
	menu._open_world_map()
	for i: int in 10:
		await process_frame
	var map: Node = manager.top_menu()
	map._show_zones("madrid")
	await _shot("a4_mapa_f9_espana")
	# Recuadro de Madrid y alrededores, con Moncloa (laboratorio y Quirón) a la derecha.
	map.set_view("madrid")
	map._show_zones("moncloa")
	await _shot("a4_mapa_f9_madrid")
	# Búsqueda sin tildes y filtro de gimnasios.
	map.set_view("spain")
	map.search.text = "atico ayuso"
	map.search.text_changed.emit(map.search.text)
	await _shot("a4_mapa_f9_busqueda")
	map.search.text = ""
	map.filter.select(3)
	map.filter.item_selected.emit(3)
	await _shot("a4_mapa_f9_gimnasios")
	map._complete("")
	for i: int in 10:
		await process_frame
	debug.close()
	# Mapa regional del juego: estás en Madrid · Sol; Pozuelo y Valencia visitados.
	var state := root.get_node("GameState")
	state.set_flag(&"visited_map:pozuelo/exterior")
	state.set_flag(&"visited_map:valencia/ciutat_vella")
	var screen: Control = load("res://src/ui/region_map/region_map_screen.gd").new()
	manager.push_menu(screen)
	for i: int in 10:
		await process_frame
	await _shot("a4_mapa_regional_madrid")
	for i: int in screen.places.size():
		if screen.places[i].id == "valencia":
			screen.selected = i
	screen._show()
	await _shot("a4_mapa_regional_valencia")
	for i: int in screen.places.size():
		if screen.places[i].id == "orcasitas":
			screen.selected = i
	screen._show()
	await _shot("a4_mapa_regional_orcasitas")
	manager.pop_menu(screen)
	await menu.session.finish()
	manager._leave_game()
	main.queue_free()
	for i: int in 4:
		await process_frame
	for node: Node in root.get_node("AudioManager").get_children():
		if node is AudioStreamPlayer:
			node.stop()
			node.stream = null
	await create_timer(0.1).timeout
	quit.call_deferred()
