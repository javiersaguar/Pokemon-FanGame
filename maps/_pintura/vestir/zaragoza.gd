extends RefCounted
## Zaragoza: la explanada empedrada pasa a ser calles y manzanas (jardines con seto, árboles y flores
## entre la red de calles que une puertas, apariciones y bordes); luego farolas y bancos en las aceras
## y arbolado en la hierba vacía. Se conservan los edificios, el Pilar, sus puertas, los carteles, los
## vecinos y las conexiones.
## 2026-10-20: el mobiliario ya está puesto; esta pasada convierte la explanada empedrada en calles
## y manzanas (jardines con seto, árboles y flores) sin mover puertas (Ciudad.explanada).

const Ciudad := preload("res://maps/_pintura/vestir/_ciudad.gd")

var tree: SceneTree
var hierba_obligada := false


func vestir(v: Vestidor) -> void:
	await Ciudad.explanada(v, {"arboles": [&"arbol_redondo", &"arbol_verde"]})
