extends RefCounted
## Ruta 18 · Picos de Europa (72×40). De Galicia a Santander por Asturias: los Picos en su meseta con
## los lagos de Covadonga y sus escaleras, la aldea de casas de piedra al pie, la carretera de la
## costa, los prados con hierba alta, el bosque atlántico y el Cantábrico al sur. Un paso obligado por
## hierba corta la carretera del bosque del norte al del sur antes de Santander. Se conservan las
## casas, sus puertas, los carteles, los entrenadores, los vecinos y las conexiones.

const Ruta := preload("res://maps/_pintura/vestir/_ruta.gd")

var tree: SceneTree
var hierba_obligada := true


func vestir_inicial(v: Vestidor) -> void:
	# Paso obligado por hierba de bosque a bosque antes de Santander.
	v.grass_band(Rect2i(52, 18, 2, 14))
	v.hedge(2, 9, 13)
	v.flowers(Rect2i(4, 6, 4, 1), 0.4)
	v.flowers(Rect2i(62, 18, 4, 1), 0.4)
	v.item("HiperpocionCovadonga", &"hyperpotion", Vector2i(47, 1), true)
	v.item("UltraBallPrado18", &"ultraball", Vector2i(69, 25))
	v.item("RevivirAldea", &"revive", Vector2i(11, 25), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"arbol_verde", &"arbol_redondo"], "hueco": 2,
		"adornos": 0.06, "excluir": [Rect2i(20, 0, 30, 14)]})


## Pasada del 2026-10-20 (rama feat/rutas-anil-3): obstáculos de campo (solo cierran objetos y zonas
## opcionales; las acciones siguen sin objeto, PENDIENTE JAVIER) y atajos que se abren desde un lado.
func vestir(v: Vestidor) -> void:
	Ruta.atajo(v, "CancelaPicos", Vector2i(19, 8), Vector2i.RIGHT, 1, "santander/exterior")
	await v.refresh()
