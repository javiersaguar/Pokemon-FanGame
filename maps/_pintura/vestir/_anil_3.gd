extends RefCounted
## Receta común de la segunda pasada a nivel Añil (2026-10-20, no es de un mapa): llena los huecos de más
## de 5 casillas de lado y rompe los bordes rectos de bosque de más de 10. Se usa con
## vestir_exterior.gd -- <mapas> --receta=res://maps/_pintura/vestir/_anil_3.gd

const Ruta := preload("res://maps/_pintura/vestir/_ruta.gd")

var tree: SceneTree
var hierba_obligada := false


func vestir(v: Vestidor) -> void:
	hierba_obligada = v.mid.begins_with("ruta_")
	var edges := Ruta.romper_rectas(v)
	await v.refresh()
	var holes := Ruta.llenar_huecos(v)
	v.note("segunda pasada: %d árboles contra bordes rectos, %d huecos llenados" % [edges, holes])
	await v.refresh()
