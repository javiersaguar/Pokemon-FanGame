extends SceneTree
## Interiores a medida de las piezas nuevas (Guggenheim, Botín, hórreo, Covadonga,
## Café Iruña y las ruinas de Rocafonda). Cada edificio tiene su planta; los grandes,
## más de una sala. Textos y muebles provisionales hasta que los apruebe Javier.
const TILESET := "res://assets/tilesets/interior/interior.tres"


func _initialize() -> void:
	await process_frame
	_guggenheim()
	_botin()
	_horreo()
	_covadonga()
	_cafe()
	_ruinas("rocafonda/ruinas", "Ruinas · Rocafonda", &"rocafonda", "rocafonda/exterior", "from_ruinas")
	_ruinas("rocafonda/ruinas_2", "Otra ruina · Rocafonda", &"rocafonda", "rocafonda/exterior", "from_ruinas_2")
	quit()


func _guggenheim() -> void:
	var atrio := _room("bilbao/guggenheim", "Guggenheim · Bilbao", &"bilbao", Vector2i(16, 12), Vector2i(1, 49), 9)
	_exit(atrio, "bilbao/exterior", "from_guggenheim")
	_link(atrio, "Sala", Vector2i(8, 0), "bilbao/guggenheim_sala", "default")
	_npc(atrio, "Guia", "npc_woman", Vector2i(4, 6), PackedStringArray([
		"El titanio de fuera cambia de color con la nube. Aquí dentro no: aquí es el suelo.",
		"La sala de al fondo es la de las piezas grandes. El perro de flores se queda en la calle.",
	]), "Guía")
	_spawn(atrio, "desde_sala", Vector2i(8, 2))
	_save(atrio, "bilbao/guggenheim")
	var sala := _room("bilbao/guggenheim_sala", "Sala grande · Guggenheim", &"bilbao", Vector2i(16, 12), Vector2i(2, 45), 14)
	_link(sala, "Atrio", Vector2i(8, 11), "bilbao/guggenheim", "desde_sala")
	_link(sala, "Rampa", Vector2i(8, 0), "bilbao/guggenheim_rampa", "default")
	_npc(sala, "Vigilante", "npc_man", Vector2i(12, 6), PackedStringArray([
		"No se toca. Si es muy grande, se rodea.",
		"La rampa de arriba baja a la otra crujía.",
	]), "Vigilante")
	_spawn(sala, "desde_rampa", Vector2i(8, 2))
	_save(sala, "bilbao/guggenheim_sala")
	var rampa := _room("bilbao/guggenheim_rampa", "Rampa · Guggenheim", &"bilbao", Vector2i(16, 12), Vector2i(1, 41), 4)
	_link(rampa, "Volver", Vector2i(8, 11), "bilbao/guggenheim_sala", "desde_rampa")
	_npc(rampa, "Ordenanza", "npc_old_man", Vector2i(5, 6), PackedStringArray([
		"Esta crujía es más baja. El río queda al otro lado del muro.",
	]), "Ordenanza")
	_save(rampa, "bilbao/guggenheim_rampa")


func _botin() -> void:
	var hall := _room("santander/botin", "Centro Botín · Santander", &"santander", Vector2i(16, 12), Vector2i(2, 53), 34)
	_exit(hall, "santander/exterior", "from_botin")
	_link(hall, "Sala", Vector2i(8, 0), "santander/botin_sala", "default")
	_npc(hall, "Taquilla", "clerk", Vector2i(4, 6), PackedStringArray([
		"Los dos cuerpos de fuera vuelan sobre el muelle. Esta planta es la de entrada.",
		"La sala de arriba es la de las exposiciones. Hoy no se cobra.",
	]), "Taquilla")
	_spawn(hall, "desde_sala", Vector2i(8, 2))
	_save(hall, "santander/botin")
	var sala := _room("santander/botin_sala", "Exposición · Botín", &"santander", Vector2i(16, 12), Vector2i(1, 33), 39)
	_link(sala, "Bajar", Vector2i(8, 11), "santander/botin", "desde_sala")
	_npc(sala, "Mediadora", "npc_lass", Vector2i(11, 6), PackedStringArray([
		"La bahía se vería por el cristal si el muro no fuera el del juego.",
		"Para salir a la calle, baja y toma el hueco del sur.",
	]), "Mediadora")
	_save(sala, "santander/botin_sala")


func _horreo() -> void:
	var p := _room("ruta_17/horreo", "Hórreo · Ruta 17", &"ruta_17", Vector2i(12, 8), Vector2i(1, 25), 24)
	_exit(p, "ruta_17/exterior", "from_horreo")
	_npc(p, "Labradora", "npc_old_woman", Vector2i(3, 4), PackedStringArray([
		"El maíz va aquí arriba para que no suban los ratones.",
		"Los pilares de fuera son la puerta. Agáchate, que el cajón es bajo.",
	]), "Labradora")
	_save(p, "ruta_17/horreo")


func _covadonga() -> void:
	var nave := _room("ruta_18/covadonga", "Basílica · Covadonga", &"ruta_18", Vector2i(16, 12), Vector2i(1, 21), 4)
	_exit(nave, "ruta_18/exterior", "from_covadonga")
	_link(nave, "Cueva", Vector2i(8, 0), "ruta_18/covadonga_cueva", "default")
	_npc(nave, "Custodio", "npc_old_man", Vector2i(4, 6), PackedStringArray([
		"La basílica está en el peñasco. La cueva, al fondo de esta nave.",
		"Baja la voz. Fuera se oye el río.",
	]), "Custodio")
	_spawn(nave, "desde_cueva", Vector2i(8, 2))
	_save(nave, "ruta_18/covadonga")
	var cueva := _room("ruta_18/covadonga_cueva", "Cueva · Covadonga", &"ruta_18", Vector2i(16, 12), Vector2i(2, 13), 4)
	_link(cueva, "Nave", Vector2i(8, 11), "ruta_18/covadonga", "desde_cueva")
	_npc(cueva, "Visitante", "npc_woman", Vector2i(11, 6), PackedStringArray([
		"Aquí la piedra está húmeda. La imagen queda en la hornacina del fondo.",
		"Para la calle, vuelve a la nave y sal por el sur.",
	]), "Visitante")
	_save(cueva, "ruta_18/covadonga_cueva")


func _cafe() -> void:
	var barra := _room("pamplona/cafe_iruna", "Café Iruña · Pamplona", &"pamplona", Vector2i(16, 12), Vector2i(1, 17), 24)
	_exit(barra, "pamplona/exterior", "from_cafe_iruna")
	_link(barra, "Comedor", Vector2i(8, 0), "pamplona/cafe_comedor", "default")
	_npc(barra, "Camarero", "npc_man", Vector2i(4, 6), PackedStringArray([
		"El local es de 1888. El toldo rojo de fuera es el de siempre.",
		"El comedor está al fondo. En la barra se está de pie.",
	]), "Camarero")
	_spawn(barra, "desde_comedor", Vector2i(8, 2))
	_save(barra, "pamplona/cafe_iruna")
	var comedor := _room("pamplona/cafe_comedor", "Comedor · Café Iruña", &"pamplona", Vector2i(16, 12), Vector2i(2, 29), 24)
	_link(comedor, "Barra", Vector2i(8, 11), "pamplona/cafe_iruna", "desde_comedor")
	_npc(comedor, "Cliente", "npc_lass", Vector2i(12, 6), PackedStringArray([
		"Desde aquí se oye la plaza. El chupinazo, no: eso es en julio y en el balcón del Ayuntamiento.",
	]), "Cliente")
	_save(comedor, "pamplona/cafe_comedor")


func _ruinas(id: String, title: String, zone: StringName, back: String, spawn_name: String) -> void:
	var p := _room(id, title, zone, Vector2i(14, 10), Vector2i(2, 5), 9)
	_exit(p, back, spawn_name)
	_npc(p, "Vecino", "npc_old_man", Vector2i(4, 5), PackedStringArray([
		"Se cayó el tejado hace años. La puerta, no.",
		"No hay otra sala: lo que queda es esto.",
	]), "Vecino")
	_save(p, id)


func _room(id: String, title: String, zone: StringName, size: Vector2i, floor: Vector2i, wall: int) -> Pintor:
	var d := MapData.new()
	d.id = StringName(id)
	d.display_name = title
	d.zone_id = zone
	d.outdoor = false
	d.fixed_camera = true
	d.can_bike = false
	d.can_run = false
	d.can_fly_from = false
	d.followers_allowed = false
	d.battle_background = &"indoor"
	var p := Pintor.new("Sala", size, d, 1)
	var tiles: TileSet = load(TILESET)
	for layer: TileMapLayer in [p.ground, p.decor, p.objects, p.above]:
		layer.tile_set = tiles
	for at: Vector2i in Pintor.cells(Rect2i(Vector2i.ZERO, size)):
		p.ground.set_cell(at, 0, floor)
	for x: int in size.x:
		p.decor.set_cell(Vector2i(x, 0), 1, Vector2i(1, wall - 1))
		p.decor.set_cell(Vector2i(x, 1), 1, Vector2i(1, wall))
		if x != 8 and x < size.x:
			p.decor.set_cell(Vector2i(x, size.y - 1), 1, Vector2i(1, wall))
	for y: int in range(2, size.y - 1):
		p.decor.set_cell(Vector2i(0, y), 1, Vector2i(1, wall), TileSetAtlasSource.TRANSFORM_TRANSPOSE)
		p.decor.set_cell(Vector2i(size.x - 1, y), 1, Vector2i(1, wall), TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	# Muebles a los lados, el pasillo del centro libre.
	if size.x >= 14 and size.y >= 10:
		_piece(p, Vector2i(1, 3), Rect2i(5, 3, 3, 3))
		_piece(p, Vector2i(size.x - 5, 3), Rect2i(0, 40, 2, 2))
		_piece(p, Vector2i(2, size.y - 4), Rect2i(3, 59, 3, 2))
	p.spawn("default", Vector2i(8, size.y - 2))
	var label := Label.new()
	label.name = "Rotulo"
	label.position = Vector2(16, 4)
	label.size = Vector2(480, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = title.to_upper()
	label.add_theme_font_override("font", load("res://assets/fonts/truth_and_ideals/TruthAndIdeals-Normal.ttf"))
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("303048"))
	p.root.add_child(label)
	return p


func _piece(p: Pintor, at: Vector2i, rect: Rect2i) -> void:
	for y: int in rect.size.y:
		for x: int in rect.size.x:
			p.decor.set_cell(at + Vector2i(x, y), 2, rect.position + Vector2i(x, y))


func _exit(p: Pintor, exterior: String, spawn_name: String) -> void:
	var door := Vector2i(8, p.size.y - 1)
	p.decor.erase_cell(door)
	p.warp("Salida", door, StringName(exterior), StringName(spawn_name))
	p.root.get_node(^"Warps/Salida").arrival_facing = Warp.Facing.DOWN


func _link(p: Pintor, warp_name: String, cell: Vector2i, target: String, spawn_name: String) -> void:
	p.decor.erase_cell(cell)
	if cell.y == 0:
		p.decor.erase_cell(cell + Vector2i.DOWN)
	p.warp(warp_name, cell, StringName(target), StringName(spawn_name))
	p.root.get_node(NodePath("Warps/" + warp_name)).arrival_facing = Warp.Facing.UP if cell.y == 0 else Warp.Facing.DOWN


func _spawn(p: Pintor, spawn_name: String, cell: Vector2i) -> void:
	p.spawn(spawn_name, cell)


func _npc(p: Pintor, node_name: String, sheet: String, cell: Vector2i, lines: PackedStringArray, display: String) -> void:
	p.npc(node_name, sheet, cell, 0, lines, {"display_name": display})


func _save(p: Pintor, id: String) -> void:
	print(id, " ", error_string(p.save("res://maps/%s.tscn" % id)))
