extends RefCounted
## Receta común: solo llena los huecos de más de 5 casillas de lado (segunda vuelta de _anil_3.gd, sin
## volver a poner árboles contra los bordes rectos).

const Ruta := preload("res://maps/_pintura/vestir/_ruta.gd")

var tree: SceneTree
var hierba_obligada := false


func vestir(v: Vestidor) -> void:
	hierba_obligada = v.mid.begins_with("ruta_")
	v.note("huecos llenados: %d" % Ruta.llenar_huecos(v))
	await v.refresh()
