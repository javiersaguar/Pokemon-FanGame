extends RefCounted
## Valladolid: manzanas con farolas y bancos en las aceras, árboles en alcorque y farolas en las plazas
## empedradas sin estrechar ningún paso, y arbolado y adornos en la hierba vacía lejos de calles y
## puertas (maps/_pintura/vestir/_ciudad.gd). Se conservan los edificios, los monumentos, sus puertas,
## los carteles, los vecinos y las conexiones.

const Ciudad := preload("res://maps/_pintura/vestir/_ciudad.gd")

var tree: SceneTree
var hierba_obligada := false


func vestir(v: Vestidor) -> void:
	await Ciudad.manzanas(v, {"arboles": [&"arbol_redondo", &"arbol_verde"], "arbol_plaza": &"arbol_redondo"})
