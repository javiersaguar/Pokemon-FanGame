extends RefCounted
## Ruta 1 · Hoces del Duratón (36×64). De San Miguel de Bernuy a Sepúlveda por la ribera: el río al
## oeste con su cortado, el camino de la ribera, las mesetas de caliza con sus escaleras y la ermita en
## lo alto. Un paso obligado por hierba cierra la ribera entre el río y el cortado, a media bajada. Se
## conservan las mesetas, las puertas, los carteles, los entrenadores, los vecinos y las conexiones.

const Ruta := preload("res://maps/_pintura/vestir/_ruta.gd")

var tree: SceneTree
var hierba_obligada := true


## Primera pasada (2026-10-19), ya aplicada: el paso de hierba.
func vestir_inicial(v: Vestidor) -> void:
	# Paso obligado por hierba en la ribera, del río al pie del cortado.
	v.grass_band(Rect2i(10, 44, 8, 2))
	v.item("SuperpocionRibera", &"superpotion", Vector2i(11, 49), true)
	await v.refresh()


## Segunda pasada (2026-10-20): detalle completo, no solo el paso de hierba: pinos y encinas en la hierba vacía de la hoz y del páramo, matojos, setas y flores en los márgenes. Lo que une
## puertas, carteles, personajes y bordes se queda libre (el relleno lo respeta).
func vestir_segunda(v: Vestidor) -> void:
	v.item("PocionMaximaCortado", &"maxpotion", Vector2i(33, 14), true)
	v.item("PepitaRibera", &"nugget", Vector2i(11, 57), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": [1, 2], "arboles": [&"pino", &"arbol_verde", &"arbol_redondo"], "hueco": 1, "adornos": 0.1})


## Pasada del 2026-10-20 (rama feat/rutas-anil-3): obstáculos de campo (solo cierran objetos y zonas
## opcionales; las acciones siguen sin objeto, PENDIENTE JAVIER) y atajos que se abren desde un lado.
func vestir(v: Vestidor) -> void:
	Ruta.bolsa(v, "ArbolCorteRibera", "cut", Vector2i(34, 37), "CarameloRaroRibera", &"rarecandy")
	Ruta.atajo_primero(v, "CancelaPrado", [[Vector2i(17, 13), Vector2i.RIGHT, 1], [Vector2i(17, 18), Vector2i.RIGHT, 1],
			[Vector2i(17, 28), Vector2i.RIGHT, 1], [Vector2i(17, 32), Vector2i.RIGHT, 1], [Vector2i(17, 36), Vector2i.RIGHT, 1],
			[Vector2i(23, 14), Vector2i.RIGHT, 1], [Vector2i(23, 18), Vector2i.RIGHT, 1], [Vector2i(23, 24), Vector2i.RIGHT, 1]],
			"pueblo_inicial/exterior")
	await v.refresh()
