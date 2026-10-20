extends RefCounted
## Ruta 2 · Sepúlveda (36×72). Del cañón del Duratón a la villa de Sepúlveda: el pinar cerrado a los
## lados del camino, la casa del guarda, el claro de hierba alta y la villa con sus calles empedradas al
## sur. Un paso obligado por hierba cierra el claro de pinar a pinar antes de entrar en la villa. Se
## conservan las casas, sus puertas, los carteles, los entrenadores, los vecinos y las conexiones.

var tree: SceneTree
var hierba_obligada := true


## Primera pasada (2026-10-19), ya aplicada: el paso de hierba.
func vestir_inicial(v: Vestidor) -> void:
	# Paso obligado por hierba en el claro del pinar, antes de la villa.
	v.grass_band(Rect2i(12, 28, 18, 2))
	v.item("SuperpocionPinar2", &"superpotion", Vector2i(13, 12), true)
	await v.refresh()


## Segunda pasada (2026-10-20): detalle completo, no solo el paso de hierba: el pinar de Tierra de Pinares cerrado en la hierba vacía, con matojos y flores en los claros. Lo que une
## puertas, carteles, personajes y bordes se queda libre (el relleno lo respeta).
func vestir(v: Vestidor) -> void:
	v.item("RevivirPinar", &"revive", Vector2i(3, 40), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": [1, 2], "arboles": [&"pino", &"arbol_doble", &"arbol_verde"], "hueco": 1, "adornos": 0.1})
