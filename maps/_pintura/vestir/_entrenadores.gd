extends RefCounted
## Receta común (no es de un mapa): recoloca los entrenadores propios de una ruta en sus pasos estrechos
## (_ruta.gd → entrenadores_en_pasos). Se usa con vestir_exterior.gd -- <rutas> --receta=res://maps/_pintura/vestir/_entrenadores.gd

const Ruta := preload("res://maps/_pintura/vestir/_ruta.gd")

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	Ruta.entrenadores_en_pasos(v)
	await v.refresh()
