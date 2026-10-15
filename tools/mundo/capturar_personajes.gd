extends SceneTree
## Capturas reales del juego (512×384) de los personajes colocados el 2026-10-15: la entrada al combate con su
## retrato y varios personajes en su sitio, con las colocaciones de data/personajes_en_el_mapa.json. La escena de
## la detención se monta con los mismos sprites que usa el evento (coche y agentes). Necesita ventana.
##   godot --path . --rendering-driver opengl3 -s res://tools/mundo/capturar_personajes.gd
## Salida: docs/arte/comparativas/personajes_2026-10-15/

const OUT := "res://docs/arte/comparativas/personajes_2026-10-15/"
const SIZE := Vector2i(512, 384)
## Entrada al combate: nombre del archivo y entrenadores.
const ENTRIES := [
	["entrada_zapatero_maduro", ["zapatero", "maduro"]],
	["entrada_trump", ["trump"]],
	["entrada_rufian", ["rufian"]],
	["entrada_javier", ["javier"]],
	["entrada_abalos_koldo_soto", ["abalos_soto", "koldo_soto"]],
	["entrada_zona_gemelos", ["zona_gemelos_carlos", "zona_gemelos_dani"]],
	["entrada_omar_montes", ["omar_montes"]],
	["entrada_paache", ["paache"]],
]
## En el mapa: nombre, mapa, casilla del centro, medallas y flags.
const SHOTS := [
	["mapa_rufian_salon", "barcelona/casa_rufian", Vector2i(8, 6), 0, []],
	["mapa_rufian_habitacion_vito", "barcelona/habitacion_rufian", Vector2i(8, 6), 0, []],
	["mapa_soto_exterior", "soto_del_real/exterior", Vector2i(17, 15), 0, []],
	["mapa_soto_carcel", "soto_del_real/carcel", Vector2i(8, 6), 6, ["detenido:abalos_albufera"]],
	["mapa_zapatero_maduro", "las_palmas/canteras", Vector2i(41, 36), 0, []],
	["mapa_trump_aeropuerto", "playa_del_ingles/exterior", Vector2i(16, 9), 0, ["trainer_defeated:maduro"]],
	["mapa_zona_gemelos", "getafe/exterior", Vector2i(37, 50), 0, []],
	["mapa_montepinar", "mostoles/exterior", Vector2i(34, 44), 0, []],
	["mapa_lamine_familia", "rocafonda/exterior", Vector2i(31, 15), 0, []],
	["mapa_cucurella", "rocafonda/exterior", Vector2i(27, 31), 0, []],
	["mapa_javier_san_miguel", "pueblo_inicial/exterior", Vector2i(38, 40), 7, []],
	["mapa_puigdemont", "barcelona/ciutat_vella", Vector2i(18, 48), 0, []],
]
## La detención en la Albufera: los dos del Clan, el coche y un agente al lado de cada uno.
const ARREST := ["mapa_detencion_albufera", "ruta_9/exterior", Vector2i(18, 27), 3]

var _manager: Node
var _state: Node


func _initialize() -> void:
	await process_frame
	root.size = SIZE
	var main: Node = load("res://src/main/main.tscn").instantiate()
	main.set_script(null)
	root.add_child(main)
	_manager = root.get_node("SceneManager")
	_manager.register_main(main)
	_manager._fade.hide()
	_state = root.get_node("GameState")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	for entry: Array in ENTRIES:
		await _entry(entry[0], entry[1])
	for shot: Array in SHOTS:
		await _map(shot[0], shot[1], shot[2], shot[3], shot[4], false)
	await _map(ARREST[0], ARREST[1], ARREST[2], ARREST[3], [], true)
	_manager._leave_game()
	main.queue_free()
	await process_frame
	quit()


func _viewport() -> SubViewport:
	var viewport := SubViewport.new()
	viewport.size = SIZE
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(viewport)
	return viewport


func _save(viewport: SubViewport, file: String) -> void:
	for i: int in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	var path := OUT + file + ".png"
	print("%s: %s" % [path, error_string(viewport.get_texture().get_image().save_png(path))])
	viewport.free()


func _entry(file: String, ids: Array) -> void:
	var setup: GDScript = load("res://src/battle/engine/battle_setup.gd")
	var trainers: Array = []
	for id: String in ids:
		trainers.append(setup.trainer_info(StringName(id)))
	var screen: Control = load("res://src/battle/scene/battle_entry_transition.gd").new()
	screen.kind = &"trainer"
	screen.info = {"trainers": trainers}
	var viewport := _viewport()
	viewport.add_child(screen)
	screen.set_progress(0.4)
	await _save(viewport, file)


func _map(file: String, map_id: String, center: Vector2i, medals: int, flags: Array, arrest: bool) -> void:
	_state.reset()
	var badges: Array[StringName] = []
	for i: int in medals:
		badges.append(StringName("medalla_%d" % i))
	_state.badges.assign(badges)
	for flag: String in flags:
		_state.set_flag(StringName(flag))
	var loader: GDScript = load("res://src/util/map_loader.gd")
	var prepared: Dictionary = loader.prepare(StringName(map_id))
	if prepared.error != OK:
		push_error("No se puede preparar %s" % map_id)
		return
	var map: Node2D = prepared.map
	var viewport := _viewport()
	map.position = Vector2(256, 192) - Vector2(center * 32) - Vector2(16, 16)
	viewport.add_child(map)
	if arrest:
		_police(map)
	await _save(viewport, file)
	loader.call(&"clear")


## Los mismos sprites del evento de la detención (src/events/personajes/personaje_event.gd).
func _police(map: Node2D) -> void:
	var entities := map.get_node(^"Entities")
	var group: Array[Node2D] = []
	for name: String in ["Personaje_abalos_albufera", "Personaje_koldo_albufera"]:
		var t := entities.get_node_or_null(NodePath(name)) as Node2D
		if t != null:
			group.append(t)
	if group.is_empty():
		return
	var center := Vector2.ZERO
	for t: Node2D in group:
		center += t.position
	center /= group.size()
	var car := Sprite2D.new()
	car.texture = load("res://assets/sprites/characters/coche_policia.png")
	car.position = Vector2(roundf(center.x + 96.0), roundf(center.y + 32.0))
	entities.add_child(car)
	for t: Node2D in group:
		var officer: Node2D = (load("res://src/overworld/npc/npc.tscn") as PackedScene).instantiate()
		officer.set(&"sprite_sheet", load("res://assets/sprites/characters/policia.png"))
		officer.set(&"initial_facing", 1)
		officer.position = t.position + Vector2(32, 0)
		entities.add_child(officer)
