extends RefCounted
## Ruta 3 · Puerto de Navacerrada. El paso de hierba ya exigía 26 casillas y no se toca. 2026-10-20:
## objetos repartidos como en Añil, uno a la vista en el claro del pinar y otro escondido junto al
## camino de subida.

const Ruta := preload("res://maps/_pintura/vestir/_ruta.gd")

var tree: SceneTree
var hierba_obligada := true


func vestir_inicial(v: Vestidor) -> void:
	v.item("PocionMaximaPuerto", &"maxpotion", Vector2i(14, 28))
	v.item("RevivirNevero", &"revive", Vector2i(30, 29), true)
	await v.refresh()


## Pasada del 2026-10-20 (rama feat/rutas-anil-3): obstáculos de campo (solo cierran objetos y zonas
## opcionales; las acciones siguen sin objeto, PENDIENTE JAVIER) y atajos que se abren desde un lado.
func vestir(v: Vestidor) -> void:
	Ruta.atajo(v, "TroncoPinar", Vector2i(30, 25), Vector2i.DOWN, 2, "ruta_2/exterior")
	await v.refresh()
