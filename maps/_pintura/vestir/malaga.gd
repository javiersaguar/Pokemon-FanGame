extends RefCounted
## Málaga: manzanas con farolas y bancos en las aceras, árboles en alcorque y farolas en las plazas
## empedradas sin estrechar ningún paso, y arbolado y adornos en la hierba vacía lejos de calles y
## puertas (maps/_pintura/vestir/_ciudad.gd). Se conservan los edificios, los monumentos, sus puertas,
## los carteles, los vecinos y las conexiones.
## 2026-10-20: el mobiliario ya está puesto; esta pasada convierte la explanada empedrada en calles
## y manzanas (jardines con seto, árboles y flores) sin mover puertas (Ciudad.explanada).

const Ciudad := preload("res://maps/_pintura/vestir/_ciudad.gd")

var tree: SceneTree
var hierba_obligada := false


func vestir(v: Vestidor) -> void:
	await Ciudad.explanada(v, {"arboles": [&"palmera", &"arbol_redondo"]})
