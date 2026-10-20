extends RefCounted
## Ruta 4 · Sierra de Guadarrama y el Pardo (52×46). De la sierra a Moncloa: el pinar cerrado de la
## bajada, la venta y las casas de la urbanización, el monte del Pardo con hierba alta y la carretera
## hacia Moncloa. Un paso obligado por hierba cierra la bajada del pinar al empezar la ruta. Se
## conservan las casas, sus puertas, los carteles, los entrenadores, los vecinos y las conexiones.

var tree: SceneTree
var hierba_obligada := true


## Primera pasada (2026-10-19), ya aplicada: el paso de hierba.
func vestir_inicial(v: Vestidor) -> void:
	# Paso obligado por hierba en la bajada del pinar.
	v.grass_band(Rect2i(8, 4, 20, 2))
	v.item("SuperpocionPardo", &"superpotion", Vector2i(3, 44), true)
	await v.refresh()


## Segunda pasada (2026-10-20): detalle completo, no solo el paso de hierba: pinares y encinas del Guadarrama en la hierba vacía, con matojos y flores. Lo que une
## puertas, carteles, personajes y bordes se queda libre (el relleno lo respeta).
func vestir(v: Vestidor) -> void:
	v.item("ParaliCuraEscorial", &"fullheal", Vector2i(6, 40), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": [1, 2], "arboles": [&"pino", &"arbol_verde", &"arbol_redondo"], "hueco": 1, "adornos": 0.1})
