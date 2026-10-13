extends SceneTree
## Pinta Orcasitas (maps/orcasitas/exterior.tscn), pueblo inicial de cani y choni (docs/DECISIONES_JAVIER_
## 2026-10-13.md §2 y §7): barrio de bloques de Usera con el piso del jugador y el del rival, la plaza
## con bancos, el descampado con su sofá y la calle que sale al norte hacia Madrid Río.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_orcasitas.gd -- --force

const OUT := "res://maps/orcasitas/exterior.tscn"
const SIZE := Vector2i(44, 36)


func _initialize() -> void:
	await process_frame
	if FileAccess.file_exists(OUT) and not "--force" in OS.get_cmdline_user_args():
		push_error("pintar_orcasitas: '%s' ya existe; usa -- --force (se pierden las puertas enlazadas)." % OUT)
		quit(1)
		return
	var painter: GDScript = load("res://maps/_pintura/pintor.gd")
	print("%s: %s" % [OUT, error_string(_paint(painter).save(OUT))])
	quit()


func _paint(painter: GDScript) -> RefCounted:
	var data := MapData.new()
	data.id = &"orcasitas/exterior"
	data.display_name = "Orcasitas"
	data.zone_id = &"orcasitas"
	data.region_map_position = Vector2i(14, 12)
	var p: RefCounted = painter.new("Orcasitas", SIZE, data, 1984)
	p.fill_grass(0.1)
	p.connect_edge("north", &"madrid_rio/exterior", 0, Vector2i(18, 24))
	# Calles entre bloques; el norte sale a Madrid Río.
	p.paving(Rect2i(0, 0, 44, 22))
	p.build_paving()
	for r: Rect2i in [Rect2i(0, 0, 18, 2), Rect2i(24, 0, 20, 2), Rect2i(0, 2, 2, 34), Rect2i(42, 2, 2, 34), Rect2i(2, 34, 40, 2)]:
		p.forest(r)
	p.build_forest()
	# Bloques: el del jugador (el primero) y el del rival (el verde), y los demás.
	for b: Array in [[&"bloque_pisos", Vector2i(3, 12)], [&"bloque_verde", Vector2i(10, 12)], [&"bloque_pisos", Vector2i(26, 12)],
			[&"bloque_verde_2", Vector2i(33, 9)], [&"bloque_pisos", Vector2i(3, 32)], [&"tienda_morada", Vector2i(26, 20)]]:
		p.object(b[0], b[1])
	_door(p, &"bloque_pisos", Vector2i(3, 12), &"orcasitas/casa_jugador", "CasaJugador", "from_casa_jugador")
	_door(p, &"bloque_verde", Vector2i(10, 12), &"orcasitas/casa_rival", "CasaRival", "from_casa_rival")
	# La plaza con bancos y el descampado.
	for cell: Vector2i in [Vector2i(32, 17), Vector2i(37, 17)]:
		p.object(&"banco", cell)
	p.object(&"farola_roja", Vector2i(25, 15))
	p.soil(Rect2i(12, 24, 26, 9))
	for cell: Vector2i in [Vector2i(15, 27), Vector2i(22, 30), Vector2i(31, 26), Vector2i(35, 31), Vector2i(19, 25)]:
		p.deco(cell, ExteriorTiles.ROCK if cell.x % 2 == 0 else ExteriorTiles.ROCK_BROWN)
	p.sprinkle(Rect2i(12, 24, 26, 9), 0.12, [ExteriorTiles.TUFT, ExteriorTiles.TUFT_TALL])

	p.deco(Vector2i(24, 3), ExteriorTiles.SIGN)
	p.sign_text("CartelBarrio", Vector2i(24, 3), PackedStringArray(["ORCASITAS (USERA, MADRID).",
		"Barrio de bloques, de bares y de chándal. ↑ Madrid Río y Atocha."]))
	p.deco(Vector2i(9, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelCasa", Vector2i(9, 13), PackedStringArray(["TU BLOQUE.", "Cuarto sin ascensor. Tu madre te espera arriba con el táper."]))
	p.deco(Vector2i(17, 13), ExteriorTiles.SIGN)
	p.sign_text("CartelRival", Vector2i(17, 13), PackedStringArray(["BLOQUE DE TU RIVAL.", "Su moto lleva más luces que la Gran Vía en Navidad."]))
	p.deco(Vector2i(24, 24), ExteriorTiles.SIGN)
	p.sign_text("CartelDescampado", Vector2i(24, 24), PackedStringArray(["DESCAMPADO.",
		"Prohibido tirar escombros. Firmado: el Ayuntamiento. Debajo, alguien ha dejado un sofá."]))
	p.spawn("default", Vector2i(5, 14))
	p.spawn("from_madrid_rio", Vector2i(20, 0))
	p.npc("Abuela", "npc_old_woman", Vector2i(34, 20), 0, PackedStringArray([
		"Hijo, ¿te vas a Madrid? Esto también es Madrid. Pero no se lo digas a los de Pozuelo, que no se lo creen.",
		"Por Madrid Río se llega a Atocha. Ten cuidado con El Jincho, que va por ahí cantando."]))
	p.npc("Chaval", "npc_youngster", Vector2i(20, 28), 1, PackedStringArray([
		"Este descampado es nuestro estadio. La portería es el sofá."]))
	return p

## Puerta de `id` (colocado en `anchor`) enlazada con su interior, y la aparición de vuelta debajo.
func _door(p: RefCounted, id: StringName, anchor: Vector2i, interior: StringName, warp_name: String, spawn: String) -> void:
	var door: Vector2i = anchor + Vector2i(ExteriorTiles.objects()[id]["door"])
	p.warp(warp_name, door, interior, &"default")
	p.root.get_node("Warps/" + warp_name).arrival_facing = Warp.Facing.UP
	p.spawn(spawn, door + Vector2i.DOWN)
