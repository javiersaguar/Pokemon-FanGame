extends RefCounted
## Ruta 11 · Palmeral de Elche (76×34). De Alicante a Murcia por la carretera de Elche: el palmeral al
## norte, los huertos vallados al este con su balsa de riego, el casco de Elche al sur y un paso
## obligado por hierba donde la carretera cruza el huerto (cerrado al norte por la tapia del huerto y
## al sur por la balsa). Palmeras en lugar de bosque. Se conservan las casas, sus puertas, los
## carteles, Carmen, Sergio, Pencho, la aparadora, el palmerero, la huertana y las conexiones.

var tree: SceneTree
var hierba_obligada := true


## Primera pasada (2026-10-19), ya aplicada.
func vestir_inicial(v: Vestidor) -> void:
	# El camino del huerto cruza la carretera: la hierba crece de lado a lado.
	v.grass_band(Rect2i(62, 15, 4, 7))
	# Tapias del huerto al norte y al sur de la balsa: no se rodea el paso de hierba.
	v.fence_v(64, 0, 14)
	v.fence_v(64, 22, 22)
	v.fence_v(64, 31, 33)
	# Huertos vallados del norte, con su palmera de linde.
	v.fence(0, 7, 2)
	v.fence(59, 72, 2)
	v.flowers(Rect2i(72, 31, 3, 2), 0.4)
	v.item("HiperpocionPalmeral", &"hyperpotion", Vector2i(41, 11), true)
	v.item("UltraBallHuerto", &"ultraball", Vector2i(70, 6))
	v.item("RevivirBalsa", &"revive", Vector2i(73, 27), true)
	await v.refresh()
	# Palmeras sueltas en lo que queda de hierba, lejos de la carretera.
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"palmera"], "hueco": 2, "adornos": 0.05,
		"excluir": [Rect2i(8, 20, 50, 12)]})


## Segunda pasada (2026-10-20): fuera la carretera de cuatro carriles de lado a lado. Queda un camino
## de tierra de dos casillas que serpentea entre huertos (tres curvas) y el resto del asfalto pasa a
## hierba con palmeras y flores. La plaza de Elche, delante de las casas, se queda como estaba.
const CAMINO := [
	Rect2i(0, 16, 14, 2), Rect2i(12, 16, 2, 4), Rect2i(12, 18, 19, 2), Rect2i(29, 16, 2, 4),
	Rect2i(29, 16, 18, 2), Rect2i(45, 16, 2, 4), Rect2i(45, 18, 17, 2),
]


func vestir(v: Vestidor) -> void:
	var road: Array[Vector2i] = []
	for at: Vector2i in Pintor.cells(Rect2i(0, 16, 62, 4)):
		if v.paving.has(at):
			road.append(at)
	v.clear_cells(road)
	for at: Vector2i in road:
		for d: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			v._paving_dirty[at + d] = true
	v.path(Vestidor.rects(CAMINO))
	v.build()
	await v.refresh()
	v.flowers(Rect2i(16, 16, 10, 1), 0.3, 0.5)
	v.flowers(Rect2i(33, 18, 10, 1), 0.3, 0.5)
	v.item("PerlaHuerto", &"pearl", Vector2i(24, 16), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "zona": Rect2i(0, 15, 62, 6), "margen": [1, 1], "arboles": [&"palmera"], "hueco": 3, "adornos": 0.06})
