extends RefCounted
## Ruta 17 · Camino de Santiago gallego (64×40). De las Rías Baixas hacia el norte: el puente sobre el
## río, la aldea con su hórreo y sus casas al oeste, el castro en su meseta con escalera, la carretera
## que sube entre prados y la fraga cerrada al este. Un paso obligado por hierba corta la subida entre
## el castro y la fraga. Se conservan las casas, sus puertas, los carteles, los entrenadores, los
## peregrinos y las conexiones.

var tree: SceneTree
var hierba_obligada := true


func vestir(v: Vestidor) -> void:
	# Paso obligado por hierba en la subida, del muro del castro a la fraga.
	v.grass_band(Rect2i(40, 14, 8, 2))
	# Prados de la aldea con sus muros de piedra y flores.
	v.fence(2, 13, 15)
	v.flowers(Rect2i(8, 26, 4, 1), 0.4)
	v.flowers(Rect2i(48, 26, 4, 1), 0.4)
	v.item("HiperpocionCastro", &"hyperpotion", Vector2i(37, 3), true)
	v.item("UltraBallFraga", &"ultraball", Vector2i(58, 16))
	v.item("RevivirPrado", &"revive", Vector2i(3, 31), true)
	await v.refresh()
	v.fill({"estilo": "arboleda", "margen": [1, 1], "arboles": [&"arbol_verde", &"arbol_redondo", &"pino"],
		"hueco": 2, "adornos": 0.06, "excluir": [Rect2i(24, 2, 16, 14)]})
