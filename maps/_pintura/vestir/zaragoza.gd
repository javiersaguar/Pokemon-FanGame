extends RefCounted
## Zaragoza: farolas y bancos en las aceras, arbolado en los huecos de hierba vacíos y flores. Se
## conservan los edificios, el Pilar, sus puertas, los carteles, los vecinos y las conexiones.

const Ciudad := preload("res://maps/_pintura/vestir/_ciudad.gd")

var tree: SceneTree
var hierba_obligada := false


func vestir(v: Vestidor) -> void:
	await Ciudad.manzanas(v, {"arboles": [&"arbol_redondo", &"arbol_verde"]})
