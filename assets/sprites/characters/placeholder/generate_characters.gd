extends SceneTree
## Genera los spritesheets provisionales del mapa hasta que haya arte real.
## Uso: godot --headless --path . -s res://assets/sprites/characters/placeholder/generate_characters.gd
##      godot --headless --path . --import
##
## Formato de un spritesheet de personaje (el mismo para el arte definitivo):
##   4 columnas (frames: quieto, paso A, quieto, paso B) × 4 filas (abajo,
##   izquierda, derecha, arriba). El tamaño de frame es libre (ancho/4 × alto/4);
##   los pies tocan el borde inferior del frame. Estos usan frames de 32×32.

const OUT_DIR := "res://assets/sprites/characters/placeholder/"
const FRAME := 32
const OFFSET := Vector2i(8, 12)

const OUTLINE := Color8(36, 30, 36)
const SKIN := Color8(248, 208, 168)

const DOWN := [
	"....OOOOOOOO....",
	"...OHHHHHHHHO...",
	"..OHHHHHHHHHHO..",
	"..OHHHHHHHHHHO..",
	"..OSSSSSSSSSSO..",
	"..OSSESSSSESSO..",
	"..OSSESSSSESSO..",
	"..OSSSSSSSSSSO..",
	"...OSSSSSSSSO...",
	"....OOOOOOOO....",
	"...OCCCCCCCCO...",
	"..OSCCCCCCCCSO..",
	"..OSCCCCCCCCSO..",
	"..OSCCCCCCCCSO..",
	"...OCCCCCCCCO...",
	"...OPPPPPPPPO...",
	"...OPPPOOPPPO...",
	"...OPPPOOPPPO...",
	"...OBBBOOBBBO...",
	"....OOO..OOO....",
]
const UP_HEAD := [
	"....OOOOOOOO....",
	"...OHHHHHHHHO...",
	"..OHHHHHHHHHHO..",
	"..OHHHHHHHHHHO..",
	"..OHHHHHHHHHHO..",
	"..OHHHHHHHHHHO..",
	"..OHHHHHHHHHHO..",
	"..OSHHHHHHHHSO..",
	"...OSSSSSSSSO...",
	"....OOOOOOOO....",
]
## Piernas del paso A mirando abajo o arriba (filas 15–19). El paso B es su espejo.
const LEGS_STEP := [
	"...OPPPPPPPPO...",
	"...OPPPOOPPPO...",
	"...OBBBOOPPPO...",
	"....OOO.OBBBO...",
	".........OOO....",
]
const LEFT := [
	"....OOOOOOOO....",
	"...OHHHHHHHHO...",
	"..OHHHHHHHHHHO..",
	"..OHHHHHHHHHHO..",
	"..OSSSSHHHHHHO..",
	"..OSESSSHHHHHO..",
	"..OSESSSSHHHHO..",
	"..OSSSSSSSHHHO..",
	"...OSSSSSSSSO...",
	"....OOOOOOOO....",
	"....OCCCCCCO....",
	"....OCCSSCCO....",
	"....OCCSSCCO....",
	"....OCCCCCCO....",
	"....OCCCCCCO....",
	"....OPPPPPPO....",
	"....OPPPPPPO....",
	"....OPPPPPPO....",
	"....OBBBBBBO....",
	".....OOOOOO.....",
]
const LEGS_SIDE_STEP := [
	"....OPPPPPPO....",
	"...OPPPOOPPPO...",
	"..OPPPO..OPPPO..",
	"..OBBBO..OBBBO..",
	"...OOO....OOO...",
]
## Pelo largo (se pinta encima; "." = no cambia).
const LONG_DOWN := {4: "..OH........HO..", 5: "..OH........HO..", 6: ".OHH........HHO.",
	7: ".OHH........HHO.", 8: ".OHHO......OHHO.", 9: ".OHHO......OHHO.", 10: "..OO........OO.."}
const LONG_UP := {7: "..OHHHHHHHHHHO..", 8: "..OHHHHHHHHHHO..", 9: "..OHHHHHHHHHHO..",
	10: "..OHHHHHHHHHHO..", 11: "...OHHHHHHHHO...", 12: "....OOOOOOOO...."}
const LONG_LEFT := {8: "...OSSSSSSHHHO..", 9: "....OOOOOOHHHO..", 10: "....OCCCCCOHHO..",
	11: "....OCCSSCCOO..."}

## id → [pelo, camiseta, pantalón, zapatos, pelo largo]
const CHARACTERS := {
	"player_male": [Color8(200, 40, 40), Color8(40, 90, 200), Color8(60, 60, 80), Color8(200, 40, 40), false],
	"player_female": [Color8(120, 70, 40), Color8(230, 100, 150), Color8(60, 80, 170), Color8(240, 240, 240), true],
	"rival": [Color8(150, 90, 40), Color8(50, 150, 90), Color8(90, 70, 50), Color8(40, 40, 40), false],
	"professor": [Color8(180, 180, 180), Color8(240, 240, 240), Color8(110, 80, 60), Color8(60, 40, 30), false],
	"mom": [Color8(170, 60, 40), Color8(240, 160, 60), Color8(180, 60, 60), Color8(90, 50, 40), true],
	"npc_man": [Color8(40, 40, 40), Color8(80, 160, 80), Color8(70, 70, 110), Color8(50, 40, 40), false],
	"npc_woman": [Color8(230, 200, 90), Color8(150, 90, 200), Color8(90, 60, 130), Color8(50, 40, 40), true],
	"npc_old": [Color8(230, 230, 230), Color8(150, 110, 70), Color8(90, 80, 70), Color8(50, 40, 40), false],
	"nurse": [Color8(240, 150, 180), Color8(250, 250, 250), Color8(250, 250, 250), Color8(240, 150, 180), true],
	"clerk": [Color8(70, 50, 40), Color8(60, 110, 200), Color8(40, 60, 120), Color8(30, 30, 30), false],
	"trainer": [Color8(60, 40, 30), Color8(240, 140, 40), Color8(60, 60, 60), Color8(30, 30, 30), false],
}


func _init() -> void:
	for id: String in CHARACTERS:
		var c: Array = CHARACTERS[id]
		var palette := {"O": OUTLINE, "E": OUTLINE, "S": SKIN, "H": c[0], "C": c[1], "P": c[2], "B": c[3]}
		_save(_character(palette, c[4]), id)
	_save(_item_ball(), "item_ball")
	_save(_sign(), "sign")
	quit()


func _save(img: Image, id: String) -> void:
	var err := img.save_png(ProjectSettings.globalize_path(OUT_DIR + id + ".png"))
	print("%s.png: %s" % [id, error_string(err)])


func _character(palette: Dictionary, long_hair: bool) -> Image:
	var img := Image.create_empty(FRAME * 4, FRAME * 4, false, Image.FORMAT_RGBA8)
	var down: Array = DOWN.duplicate()
	var up: Array = UP_HEAD + DOWN.slice(UP_HEAD.size())
	var left: Array = LEFT.duplicate()
	if long_hair:
		_overlay(down, LONG_DOWN)
		_overlay(up, LONG_UP)
		_overlay(left, LONG_LEFT)
	var rows := {0: down, 1: left, 3: up}
	for row: int in rows:
		var idle: Array = rows[row]
		var steps: Array = LEGS_SIDE_STEP if row == 1 else LEGS_STEP
		var step_a: Array = idle.slice(0, 15) + steps
		var step_b: Array = step_a if row == 1 else _mirror(step_a)
		for col: int in 4:
			var frame: Array = [idle, step_a, idle, step_b][col]
			_draw(img, col, row, frame, palette)
			if row == 1:
				_draw(img, col, 2, _mirror(frame), palette)
	return img


func _overlay(base: Array, extra: Dictionary) -> void:
	for y: int in extra:
		var line: String = base[y]
		var over: String = extra[y]
		for x: int in over.length():
			if over[x] != ".":
				line[x] = over[x]
		base[y] = line


func _mirror(template: Array) -> Array:
	return template.map(func(line: String) -> String: return line.reverse())


func _draw(img: Image, col: int, row: int, template: Array, palette: Dictionary) -> void:
	var origin := Vector2i(col * FRAME, row * FRAME) + OFFSET
	for y: int in template.size():
		var line: String = template[y]
		for x: int in line.length():
			if palette.has(line[x]):
				img.set_pixelv(origin + Vector2i(x, y), palette[line[x]])


func _item_ball() -> Image:
	var tpl := [
		"................",
		"................",
		"................",
		"......OOOO......",
		"....OORRRROO....",
		"...ORRRRRRWRO...",
		"...ORRRRRRRRO...",
		"..ORRRRRRRRRRO..",
		"..OOOOOWWOOOOO..",
		"..OWWWOWWOWWWO..",
		"...OWWWOOWWWO...",
		"...OWWWWWWWWO...",
		"....OOWWWWOO....",
		"......OOOO......",
		"................",
		"................",
	]
	return _object(tpl, {"O": OUTLINE, "R": Color8(220, 50, 50), "W": Color8(245, 245, 245)})


func _sign() -> Image:
	var tpl := [
		"................",
		"..OOOOOOOOOOOO..",
		"..OWWWWWWWWWWO..",
		"..OWDDDDDDDDWO..",
		"..OWWWWWWWWWWO..",
		"..OWDDDDDDWWWO..",
		"..OWWWWWWWWWWO..",
		"..OWDDDDDDDDWO..",
		"..OWWWWWWWWWWO..",
		"..OOOOOOOOOOOO..",
		"......OWWO......",
		"......OWWO......",
		"......OWWO......",
		"......OWWO......",
		".....OOOOOO.....",
		"................",
	]
	return _object(tpl, {"O": OUTLINE, "W": Color8(196, 150, 96), "D": Color8(120, 84, 48)})


func _object(template: Array, palette: Dictionary) -> Image:
	var img := Image.create_empty(16, 16, false, Image.FORMAT_RGBA8)
	for y: int in template.size():
		var line: String = template[y]
		for x: int in line.length():
			if palette.has(line[x]):
				img.set_pixel(x, y, palette[line[x]])
	return img
