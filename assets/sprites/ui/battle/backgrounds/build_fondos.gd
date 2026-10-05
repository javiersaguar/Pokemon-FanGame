extends SceneTree
@warning_ignore_start("integer_division")
## Compone los fondos de combate con entorno (Agente 4; respuesta 12 de Javier:
## "fondo con entorno y bases, como el bosque de Añil"). Solo copia y superpone
## arte de los packs, sin reescalar: el fondo del pack 10 (ORAS/XY para EBDX,
## 384×308) y, delante del horizonte, árboles y arbustos del pack 03 a ×1 (la
## misma escala del fondo, que BattleBackground enseña a ×2), con el retoque de
## verdes del tileset para que sean los mismos árboles que en el mapa.
##   godot --headless --path . -s res://assets/sprites/ui/battle/backgrounds/build_fondos.gd [-- --recursos=<ruta>]

const DEFAULT_RESOURCES := "/mnt/c/Users/Javier/Pokemon-Panchito-recursos"
const OUT := "res://assets/sprites/ui/battle/backgrounds/"
const BACKDROPS := "10_fondos_combate/Battlebacks/battlebg/"
const TREES := "03_big_tree_pack/alpatrees.png"
const ExteriorBuild := preload("res://assets/tilesets/exterior/build_exterior.gd")

## Árboles del pack 03 (×1), como en build_exterior.gd.
const TREE_AREAS := {
	"redondo": Rect2i(210, 0, 36, 48), "verde": Rect2i(114, 0, 34, 64), "doble": Rect2i(156, 0, 54, 64),
	"pino": Rect2i(68, 176, 34, 80), "manzano": Rect2i(320, 206, 48, 50), "arbustos": Rect2i(208, 158, 48, 30),
}
## Fondo → [fondo del pack 10, [árbol, x del centro, y de la base, espejo]...].
## Se pintan de atrás adelante (por la y de la base). Los pies del rival quedan en
## (256, 115), en la hierba, delante de los arbustos.
const SCENES := {
	"forest": ["Field.png", [
		["verde", 52, 94, false], ["pino", 84, 92, true], ["doble", 120, 94, false], ["pino", 150, 90, false],
		["verde", 178, 91, true], ["doble", 210, 92, false], ["pino", 238, 90, true], ["verde", 266, 92, false],
		["doble", 300, 94, true], ["pino", 330, 92, false],
		["redondo", 66, 104, true], ["manzano", 104, 106, false], ["redondo", 140, 102, false], ["redondo", 196, 101, true],
		["manzano", 246, 104, true], ["redondo", 286, 105, false], ["redondo", 322, 106, true],
		["arbustos", 44, 118, false], ["arbustos", 80, 119, true], ["arbustos", 120, 117, false], ["arbustos", 162, 116, true],
		["arbustos", 204, 116, false], ["arbustos", 246, 117, true], ["arbustos", 288, 119, false], ["arbustos", 330, 118, true],
		["arbustos", 360, 117, false]]],
}

var _resources := DEFAULT_RESOURCES


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--recursos="):
			_resources = arg.get_slice("=", 1)
	var trees := _load(TREES)
	ExteriorBuild._retouched(trees)
	for id: String in SCENES:
		var scene: Array = SCENES[id]
		var out := _load(BACKDROPS + str(scene[0]))
		var placement: Array = (scene[1] as Array).duplicate()
		placement.sort_custom(func(a: Array, b: Array) -> bool: return int(a[2]) < int(b[2]))
		for p: Array in placement:
			var tree := trees.get_region(TREE_AREAS[p[0]])
			if p[3]:
				tree.flip_x()
			out.blend_rect(tree, Rect2i(Vector2i.ZERO, tree.get_size()),
				Vector2i(int(p[1]) - tree.get_width() / 2, int(p[2]) - tree.get_height()))
		out.save_png(OUT + id + ".png")
		print("build_fondos: %s%s.png" % [OUT, id])
	quit()


func _load(relative: String) -> Image:
	var img := Image.load_from_file(_resources.path_join(relative))
	img.convert(Image.FORMAT_RGBA8)
	return img
