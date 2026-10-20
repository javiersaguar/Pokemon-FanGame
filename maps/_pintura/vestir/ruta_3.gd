extends RefCounted
## Ruta 3 · Puerto de Navacerrada. El paso de hierba ya exigía 26 casillas y no se toca. 2026-10-20:
## objetos repartidos como en Añil, uno a la vista en el claro del pinar y otro escondido junto al
## camino de subida.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	v.item("PocionMaximaPuerto", &"maxpotion", Vector2i(14, 28))
	v.item("RevivirNevero", &"revive", Vector2i(30, 29), true)
	await v.refresh()
