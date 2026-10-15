extends SceneTree
## Capturas reales a 512×384 de la Calle de la Victoria (túnel y bocas) para docs/arte/comparativas/.
## Necesita ventana (no vale --headless). Uso: godot --path . -s res://tools/mundo/capturar_calle_victoria.gd
## En un script suelto no existen los autoloads como nombres: se piden al árbol (root.get_node).

const OUT := "res://docs/arte/comparativas"
## [archivo, mapa, aparición o casilla].
const SHOTS: Array = [
	["a4_calle_victoria_boca_sol", "madrid/centro", "from_calle_victoria"],
	["a4_calle_victoria_anden", "calle_victoria/tunel", "default"],
	["a4_calle_victoria_cloacas", "calle_victoria/tunel", Vector2i(9, 27)],
	["a4_calle_victoria_boca_palacio", "madrid/palacio_real", "from_calle_victoria"],
]
## Con «-- falcon»: el Falcon aparcado junto a las dos terminales.
const FALCON: Array = [
	["a4_falcon_playa_del_ingles", "playa_del_ingles/exterior", Vector2i(8, 11)],
	["a4_falcon_vigo", "vigo/exterior", Vector2i(52, 35)],
]


func _initialize() -> void:
	_run.call_deferred()


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
	debug.close()
	# De día (las 12) para que se vean los colores sin el tinte de la noche; se deja como estaba al final.
	var clock := root.get_node("Clock")
	var offset: int = clock.debug_hour_offset
	clock.set_debug_hour_offset(offset + 12 - int(Time.get_datetime_dict_from_system()["hour"]))
	for shot: Array in (FALCON if "falcon" in OS.get_cmdline_user_args() else SHOTS):
		if shot[2] is Vector2i:
			await manager.change_map_at(StringName(shot[1]), shot[2], Vector2i.UP, false)
		else:
			await manager.change_map(StringName(shot[1]), StringName(shot[2]), Vector2i.UP, false)
		for i: int in 30:
			await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		image.save_png("%s/%s.png" % [OUT, shot[0]])
		print("captura: %s %s" % [shot[0], image.get_size()])
	clock.set_debug_hour_offset(offset)
	await menu.session.finish()
	manager._leave_game()
	main.queue_free()
	for i: int in 4:
		await process_frame
	await create_timer(0.1).timeout
	quit.call_deferred()
