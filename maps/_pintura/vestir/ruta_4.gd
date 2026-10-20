extends RefCounted
## Ruta 4 · Sierra de Guadarrama y el Pardo (52×46). De la sierra a Moncloa: el pinar cerrado de la
## bajada, la venta y las casas de la urbanización, el monte del Pardo con hierba alta y la carretera
## hacia Moncloa. Un paso obligado por hierba cierra la bajada del pinar al empezar la ruta. Se
## conservan las casas, sus puertas, los carteles, los entrenadores, los vecinos y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# Paso obligado por hierba en la bajada del pinar.
	v.grass_band(Rect2i(8, 4, 20, 2))
	v.item("SuperpocionPardo", &"superpotion", Vector2i(3, 44), true)
	await v.refresh()
