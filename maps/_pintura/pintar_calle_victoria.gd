extends SceneTree
## Calle de la Victoria (docs/mundo/rutas.md y calle_victoria.md; DECISIONES_JAVIER_2026-10-13 §3: «larga»).
## Muy corta arriba (la calle junto a Sol) y larga bajo tierra: un andén abandonado del Metro, los túneles y
## las cloacas, en zigzag de sur a norte. Se baja por la boca de metro de Sol (madrid/centro) y se sale por la
## del Palacio Real (madrid/palacio_real). Entrenadores de data/trainers/calle_victoria.json (niveles 54–58).
## Arte: el tileset de interiores que ya existe (no hay pack de alcantarillas ni de Metro en los packs
## locales). PROVISIONAL; la elección del pack definitivo es PENDIENTE JAVIER.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_calle_victoria.gd

const INTERIOR := "res://assets/tilesets/interior/interior.tres"
const MAP_ID := "calle_victoria/tunel"
const SIZE := Vector2i(20, 62)
const FLOOR_TUNNEL := Vector2i(1, 33)   # suelo gris del andén y los túneles
const FLOOR_SEWER := Vector2i(2, 37)    # suelo de las cloacas
const WALL := 39                         # pared de ladrillo oscuro (fila del atlas de paredes)
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3
## Muros del zigzag: fila y hueco [desde, hasta) por el que se pasa.
const BARRIERS: Array = [[52, 15, 18], [42, 2, 5], [32, 15, 18], [22, 2, 5], [12, 15, 18]]


func _initialize() -> void:
	await process_frame
	var d := MapData.new()
	d.id = StringName(MAP_ID)
	d.display_name = "Calle de la Victoria · Metro y cloacas"
	d.zone_id = &"calle_victoria"
	d.outdoor = false
	d.fixed_camera = false
	d.can_bike = false
	d.can_fly_from = false
	d.battle_background = &"cave"
	d.bgm = &""
	var p := Pintor.new("CalleVictoria", SIZE, d)
	var tiles: TileSet = load(INTERIOR)
	for layer: TileMapLayer in [p.ground, p.decor, p.objects, p.above]:
		layer.tile_set = tiles
	for at: Vector2i in Pintor.cells(Rect2i(Vector2i.ZERO, SIZE)):
		p.ground.set_cell(at, 0, FLOOR_SEWER if at.y < 32 else FLOOR_TUNNEL)
	# Paredes de fuera.
	for x: int in SIZE.x:
		p.decor.set_cell(Vector2i(x, 0), 1, Vector2i(1, WALL - 1))
		p.decor.set_cell(Vector2i(x, 1), 1, Vector2i(1, WALL))
		p.decor.set_cell(Vector2i(x, SIZE.y - 1), 1, Vector2i(1, WALL))
	for y: int in range(2, SIZE.y - 1):
		for x: int in [0, SIZE.x - 1]:
			p.decor.set_cell(Vector2i(x, y), 1, Vector2i(1, WALL), TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	# Zigzag: cada muro deja un hueco a un lado.
	for b: Array in BARRIERS:
		for x: int in range(1, SIZE.x - 1):
			if x < int(b[1]) or x >= int(b[2]):
				p.decor.set_cell(Vector2i(x, int(b[0])), 1, Vector2i(1, WALL))
	# Bocas: abajo, la de Sol; arriba, la del Palacio Real.
	_door(p, "Sol", Vector2i(10, SIZE.y - 1), "madrid/centro", "from_calle_victoria", Warp.Facing.DOWN)
	p.spawn("default", Vector2i(10, SIZE.y - 2))
	_door(p, "Palacio", Vector2i(10, 1), "madrid/palacio_real", "from_calle_victoria", Warp.Facing.UP)
	p.spawn("from_palacio", Vector2i(10, 2))
	# Carteles.
	p.sign_text("CartelAnden", Vector2i(13, 58), PackedStringArray([
		"ANDÉN CERRADO. Estación fantasma de Sol, línea sin número.",
		"Por aquí se va por debajo de la Calle de la Victoria hasta el Palacio Real. Es larga. Muy larga."]))
	p.sign_text("CartelCloacas", Vector2i(3, 30), PackedStringArray([
		"CLOACAS DE MADRID. Prohibido el paso a toda persona ajena a las tuberías.",
		"Alguien ha escrito debajo: «la fontanera estuvo aquí»."]))
	p.sign_text("CartelPalacio", Vector2i(13, 3), PackedStringArray([
		"Salida: Palacio Real. Ahí arriba espera la Liga.",
		"Ocho medallas, dice el cartel. El cartel no comprueba nada; el guardia de arriba, a lo mejor."]))
	# Entrenadores (data/trainers/calle_victoria.json), uno por tramo, mirando al paso.
	p.trainer("Revisor", &"victoria_revisor", Vector2i(4, 48), RIGHT, 4)
	p.trainer("Perroflauta", &"victoria_perroflauta", Vector2i(16, 37), LEFT, 4)
	p.trainer("Mantero", &"victoria_mantero", Vector2i(4, 27), RIGHT, 4)
	p.trainer("Raver", &"victoria_raver", Vector2i(16, 17), LEFT, 4)
	p.npc("Vagabundo", "npc_old_man", Vector2i(2, 56), RIGHT, PackedStringArray([
		"Vivo aquí desde que cerraron el andén. Tengo vistas a la vía y el alquiler más barato de Sol.",
		"Si vas al Palacio, sigue el zigzag hacia arriba. Y no te pares en las cloacas: huelen."]))
	print("%s: %s" % [MAP_ID, error_string(p.save("res://maps/%s.tscn" % MAP_ID))])
	quit()


## Puerta en la pared de arriba (y = 1) o de abajo (última fila): quita la pared y pone el Warp.
func _door(p: Pintor, warp_name: String, cell: Vector2i, target: String, spawn: String, facing: Warp.Facing) -> void:
	p.decor.erase_cell(cell)
	if cell.y == 1:
		p.decor.erase_cell(cell + Vector2i.UP)
	p.warp(warp_name, cell, StringName(target), StringName(spawn))
	p.root.get_node("Warps/" + warp_name).arrival_facing = facing
