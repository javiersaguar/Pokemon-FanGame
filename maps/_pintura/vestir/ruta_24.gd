extends RefCounted
## Ruta 24 · La Mancha (48×64). De Getafe a Puertollano por la llanura: un paso obligado por hierba
## nada más salir de Getafe (de la loma de Consuegra al linde del este), el cerro de los molinos al
## noroeste con su escalera, olivares y encinas en lugar de bosque cerrado, campos vallados con sus
## surcos, tapias de piedra seca y flores de campo. Se conservan los molinos, las casas, sus puertas,
## los carteles, los entrenadores, los vecinos y las conexiones.

const Ruta := preload("res://maps/_pintura/vestir/_ruta.gd")

var tree: SceneTree
var hierba_obligada := true


## Primera pasada (2026-10-19), ya aplicada.
func vestir_inicial(v: Vestidor) -> void:
	# Paso obligado por hierba a la salida de Getafe: de la loma de los molinos (columna 20) al borde
	# del este, sobre el camino.
	v.grass_band(Rect2i(21, 6, 27, 2))
	# Campos vallados: los surcos del oeste y del sureste quedan dentro de su tapia.
	v.fence(2, 19, 31)
	v.fence(2, 19, 43)
	v.fence(32, 44, 42)
	v.fence(32, 44, 56)
	# Flores de campo y alguna encina suelta junto al camino.
	v.flowers(Rect2i(29, 26, 3, 2), 0.3)
	v.flowers(Rect2i(19, 44, 3, 1), 0.3)
	v.flowers(Rect2i(8, 52, 4, 1), 0.3)
	v.item("HiperpocionMolinos", &"hyperpotion", Vector2i(10, 15), true)
	v.item("UltraBallOlivar", &"ultraball", Vector2i(44, 21))
	v.item("MaxiRepelenteCampo", &"maxrepel", Vector2i(15, 48), true)
	await v.refresh()
	# Olivares y encinas en hileras (no bosque cerrado: es la llanura manchega).
	v.fill({"estilo": "hileras", "margen": [1, 1], "arboles": [&"arbol_redondo"], "hueco": 2, "adornos": 0.05,
		"excluir": [Rect2i(0, 0, 21, 22)]})


## Segunda pasada (2026-10-20): relieve y agua. Una laguna manchega al este que sale del mapa como
## arroyo, con juncos y nenúfares, y un cerro con escalera al sureste;
## a sus pies, una Pepita escondida.
func vestir_segunda(v: Vestidor) -> void:
	v.remove_objects([&"arbol_redondo"], Rect2i(30, 22, 18, 7))
	v.remove_objects([&"arbol_redondo"], Rect2i(36, 57, 12, 7))
	await v.refresh()
	v.pond(Rect2i(33, 23, 15, 3), [Vector2i(36, 24), Vector2i(40, 24), Vector2i(44, 24)])
	v.plateau(Rect2i(38, 57, 10, 5), [42])
	v.flowers(Rect2i(31, 22, 2, 1), 0.4)
	v.flowers(Rect2i(33, 27, 6, 1), 0.4, 0.5)
	v.item("PepitaCerro", &"nugget", Vector2i(36, 62), true)
	v.item("CaramelosLaguna", &"rarecandy", Vector2i(31, 26), true)
	await v.refresh()


## Pasada del 2026-10-20 (rama feat/rutas-anil-3): obstáculos de campo (solo cierran objetos y zonas
## opcionales; las acciones siguen sin objeto, PENDIENTE JAVIER) y atajos que se abren desde un lado.
func vestir(v: Vestidor) -> void:
	Ruta.atajo_primero(v, "CancelaLlanura", [[Vector2i(19, 1), Vector2i.RIGHT, 1], [Vector2i(19, 6), Vector2i.RIGHT, 1],
			[Vector2i(1, 19), Vector2i.DOWN, 2], [Vector2i(19, 13), Vector2i.RIGHT, 1], [Vector2i(6, 19), Vector2i.DOWN, 2]],
			"puertollano/exterior")
	await v.refresh()
