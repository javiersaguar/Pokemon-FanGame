extends RefCounted
## Ruta 9 · La Albufera y la huerta (48×76). Del Turia hacia el sur entre la Albufera al oeste, la huerta
## con sus barracas, la avenida que cruza los arrozales, la playa del Saler al este y el pueblo del sur.
## Un paso obligado por hierba cierra de lado a lado la huerta entre la Albufera y la playa (la avenida
## se corta por las obras del carril bici). Se conservan las barracas, las casas, sus puertas, los
## carteles, los entrenadores, los vecinos y las conexiones.

const Ruta := preload("res://maps/_pintura/vestir/_ruta.gd")

var tree: SceneTree
var hierba_obligada := true


## Primera pasada (2026-10-19), ya aplicada.
func vestir_inicial(v: Vestidor) -> void:
	# Paso obligado por hierba de la orilla de la Albufera a la arena del Saler.
	v.grass_band(Rect2i(14, 36, 29, 2))
	v.sign("CartelObrasCarril", Vector2i(24, 39), PackedStringArray(["OBRAS DEL CARRIL BICI.",
		"Paso provisional por la huerta. Se ruega no pisar las alcachofas."]))
	# Juncos en la orilla de la Albufera y barcas.
	v.tall_grass(Vestidor.rects.call([Rect2i(14, 16, 2, 3), Rect2i(14, 39, 1, 2)]))
	v.object(&"barca_albufera", Vector2i(3, 24), true)
	v.object(&"barca_albufera", Vector2i(9, 34), true)
	v.flowers(Rect2i(30, 39, 3, 1), 0.4)
	v.item("HiperpocionHuerta", &"hyperpotion", Vector2i(36, 18), true)
	v.item("UltraBallSaler", &"ultraball", Vector2i(40, 44))
	v.item("RevivirMarjal", &"revive", Vector2i(3, 47), true)
	await v.refresh()
	# Pinada del Saler y arboleda en lo que queda de hierba lejos de la avenida.
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"pino", &"arbol_redondo"], "hueco": 2,
		"adornos": 0.05, "excluir": [Rect2i(0, 57, 48, 19)]})

## Segunda pasada (2026-10-20): la avenida empedrada recta de cuatro casillas pasa a ser un camino de
## tierra que va de un lado a otro entre la pinada; el resto, hierba con pinos y flores. Las dos
## casillas que rodeaban el paso de hierba de la fila 36 pasan a hierba alta.
func vestir_segunda(v: Vestidor) -> void:
	await Ruta.romper_avenida(v, Rect2i(25, 2, 4, 55), 9)
	v.tall_grass([Vector2i(24, 36), Vector2i(25, 36)])
	v.flowers(Rect2i(25, 12, 2, 1), 0.3)
	v.flowers(Rect2i(27, 44, 2, 1), 0.3)
	v.item("PerlaPinada", &"bigpearl", Vector2i(28, 28), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "zona": Rect2i(24, 2, 6, 55), "margen": [1, 1], "arboles": [&"pino", &"arbol_verde"], "hueco": 2, "adornos": 0.08})


## Pasada del 2026-10-20 (rama feat/rutas-anil-3): obstáculos de campo (solo cierran objetos y zonas
## opcionales; las acciones siguen sin objeto, PENDIENTE JAVIER) y atajos que se abren desde un lado.
func vestir(v: Vestidor) -> void:
	Ruta.bolsa(v, "ArbolCorteHuerta", "cut", Vector2i(13, 42), "PepitaHuerta", &"nugget")
	Ruta.atajo(v, "CancelaHuerta", Vector2i(14, 45), Vector2i.RIGHT, 1, "ruta_10/exterior")
	await v.refresh()
