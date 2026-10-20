extends RefCounted
## Ruta 1 · Hoces del Duratón (36×64). De San Miguel de Bernuy a Sepúlveda por la ribera: el río al
## oeste con su cortado, el camino de la ribera, las mesetas de caliza con sus escaleras y la ermita en
## lo alto. Un paso obligado por hierba cierra la ribera entre el río y el cortado, a media bajada. Se
## conservan las mesetas, las puertas, los carteles, los entrenadores, los vecinos y las conexiones.

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
func vestir(v: Vestidor) -> void:
	v.item("PocionMaximaCortado", &"maxpotion", Vector2i(33, 14), true)
	v.item("PepitaRibera", &"nugget", Vector2i(11, 57), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": [1, 2], "arboles": [&"pino", &"arbol_verde", &"arbol_redondo"], "hueco": 1, "adornos": 0.1})
