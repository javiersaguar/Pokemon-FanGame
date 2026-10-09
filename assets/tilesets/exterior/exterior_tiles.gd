class_name ExteriorTiles
extends RefCounted
## Catálogo del tileset de exteriores (exterior.tres): qué hay en cada casilla de
## cada atlas. Lo usan build_exterior.gd (para montar el TileSet) y los
## constructores de mapas. Fuentes y créditos en CREDITOS.md.

const TILESET := "res://assets/tilesets/exterior/exterior.tres"
## Objetos grandes (casas y árboles): lo escribe build_exterior.gd.
const OBJECTS_JSON := "res://assets/tilesets/exterior/objetos.json"

## Ids de las fuentes del TileSet.
const SRC_GEN4 := 0       ## gen4.png: 02_public_gen4_tileset (ya a ×2)
const SRC_AUTO := 1       ## autotiles.png: hierba alta y camino (02), compuestos
const SRC_ANIM := 2       ## animados.png: flores y brillos del agua (02)
const SRC_CASAS := 3      ## casas.png: 01_hgss_for_rmxp (×2)
const SRC_ARBOLES := 4    ## arboles.png: 03_big_tree_pack (×2)
const SRC_FLORA := 5      ## flora.png: 04_big_flora_pack (×2)
const SRC_CASAS_DPPT := 6 ## casas_dppt.png: casas de DPPt del pack 02 (×2 tal cual)
const SRC_VALLAS := 7     ## vallas.png: valla de madera del pack 01 (×2)
const SRC_EDIFICIOS := 8  ## edificios.png: edificios de ciudad del pack 01 (×2), docs/mundo/arte_ciudades.md
const SRC_ADORNOS := 9    ## adornos.png: farolas, fuentes, bancos... del pack 01 (UrbanRMXP, ×2)
## hecho_a_mano/*.png: monumentos dibujados a mano (assets/_fuentes/mundo/*.px2), uno por fuente desde aquí.
const SRC_HECHO_A_MANO := 20

## Conjunto de terrenos de Godot (pintar con autotile en el editor).
const TERRAIN_SET := 0
const TERRAIN_TALL_GRASS := 0
const TERRAIN_PATH := 1

# --- gen4.png (casillas del pack 02 copiadas por franjas) ---
const GRASS: Array[Vector2i] = [Vector2i(0, 0), Vector2i(6, 0), Vector2i(7, 1)]
const MUSHROOMS := Vector2i(1, 0)
const TUFT := Vector2i(0, 1)
const TUFT_TALL := Vector2i(0, 2)
const WHITE_FLOWERS := Vector2i(0, 3)
const SIGN := Vector2i(0, 4)
const PINK_FLOWERS := Vector2i(7, 2)
const STUMP := Vector2i(7, 3)
const STUMP_CUT := Vector2i(7, 4)
const LOG_LEFT: Array[Vector2i] = [Vector2i(0, 5), Vector2i(1, 5)]
const LOG_RIGHT: Array[Vector2i] = [Vector2i(6, 5), Vector2i(7, 5)]
## Bosque de pinos: columnas 1–5 (la 1 es lo que sobresale por la izquierda),
## filas 0–5 (0–1 copas de arriba, 2–3 se repiten, 4–5 troncos).
const FOREST_ORIGIN := Vector2i(1, 0)
## Nieve (Sierra de Guadarrama, Pirineos...): suelo con 2 variantes y bosque de pinos nevados con la
## misma forma que el de FOREST_ORIGIN (columna 0 = lo que sobresale por la izquierda).
const SNOW: Array[Vector2i] = [Vector2i(3, 32), Vector2i(4, 32)]
const SNOW_FOREST_ORIGIN := Vector2i(0, 33)
## Recuadros 3×3 (esquina superior izquierda).
const SAND_PATCH := Vector2i(0, 6)
const POND := Vector2i(5, 6)
## Bordillo (se salta hacia abajo): izquierda, centro (se repite) y derecha.
const LEDGE: Array[Vector2i] = [Vector2i(5, 9), Vector2i(6, 9), Vector2i(7, 9)]
## Vallas de madera: filas 10–13, columnas 0–2.
const FENCE_ORIGIN := Vector2i(0, 10)
const ROCK := Vector2i(1, 14)
const ROCK_BROWN := Vector2i(2, 14)
const ROUTE_SIGN: Array[Vector2i] = [Vector2i(7, 15), Vector2i(7, 16)]
## Adoquines claros (textura de 4×2) y rosados (4×2).
const COBBLE_LIGHT := Vector2i(0, 18)
const COBBLE_PINK := Vector2i(0, 20)
## Plaza de baldosas redondas: recuadro 3×3.
const PAVING := Vector2i(4, 18)
## Calle de baldosas grises en espiga: recuadro 3×3 con hierba en los bordes; el
## centro (1, 1) se repite sin que se note.
const PAVING_STONE := Vector2i(0, 27)
## Meseta: 3 columnas × 4 filas (2 de hierba arriba, 2 de pared de roca abajo).
const PLATEAU := Vector2i(0, 22)
## Escaleras de la meseta (las 2 filas de la pared).
const STAIRS: Array[Vector2i] = [Vector2i(3, 24), Vector2i(3, 25)]

# --- animados.png (cuadros en horizontal) ---
const FLOWERS_RED := Vector2i(0, 0)
const FLOWERS_WHITE := Vector2i(0, 1)
const WATER_SHINE := Vector2i(0, 2)


## {id: {source, coords, size, footprint: [Vector2i...] (relativas a la casilla
## de abajo a la izquierda), door?}} de casas y árboles.
static func objects() -> Dictionary:
	var raw := JsonFile.read_dict(OBJECTS_JSON)
	var out := {}
	for id: String in raw:
		var o: Dictionary = raw[id]
		var footprint: Array[Vector2i] = []
		for cell: Array in o.get("footprint", []):
			footprint.append(Vector2i(int(cell[0]), int(cell[1])))
		out[StringName(id)] = {
			"source": int(o["source"]),
			"coords": Vector2i(int(o["coords"][0]), int(o["coords"][1])),
			"size": Vector2i(int(o["size"][0]), int(o["size"][1])),
			"footprint": footprint,
			"door": Vector2i(int(o["door"][0]), int(o["door"][1])) if o.has("door") else Vector2i(-1, -1),
			"file": str(o.get("file", "")),
		}
	return out
