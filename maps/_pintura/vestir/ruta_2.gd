extends RefCounted
## Ruta 2 · Sepúlveda (36×72). Del cañón del Duratón a la villa de Sepúlveda: el pinar cerrado a los
## lados del camino, la casa del guarda, el claro de hierba alta y la villa con sus calles empedradas al
## sur. Un paso obligado por hierba cierra el claro de pinar a pinar antes de entrar en la villa. Se
## conservan las casas, sus puertas, los carteles, los entrenadores, los vecinos y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# Paso obligado por hierba en el claro del pinar, antes de la villa.
	v.grass_band(Rect2i(12, 28, 18, 2))
	v.item("SuperpocionPinar2", &"superpotion", Vector2i(13, 12), true)
	await v.refresh()
