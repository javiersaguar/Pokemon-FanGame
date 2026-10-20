extends RefCounted
## Ruta 1 · Hoces del Duratón (36×64). De San Miguel de Bernuy a Sepúlveda por la ribera: el río al
## oeste con su cortado, el camino de la ribera, las mesetas de caliza con sus escaleras y la ermita en
## lo alto. Un paso obligado por hierba cierra la ribera entre el río y el cortado, a media bajada. Se
## conservan las mesetas, las puertas, los carteles, los entrenadores, los vecinos y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# Paso obligado por hierba en la ribera, del río al pie del cortado.
	v.grass_band(Rect2i(10, 44, 8, 2))
	v.item("SuperpocionRibera", &"superpotion", Vector2i(11, 49), true)
	await v.refresh()
