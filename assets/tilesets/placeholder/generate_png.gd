extends SceneTree
## Genera placeholder.png: tiles provisionales de 16×16 hasta que haya un tileset real.
## Uso (desde la raíz del repo):
##   godot --headless --path . -s res://assets/tilesets/placeholder/generate_png.gd
##   godot --headless --path . --import
##   godot --headless --path . -s res://assets/tilesets/placeholder/build_tileset.gd
## El orden de los tiles debe coincidir con TILES de build_tileset.gd.

const T := 16
const OUT := "res://assets/tilesets/placeholder/placeholder.png"
const COUNT := 16

const GRASS := Color8(106, 176, 76)
const GRASS_DARK := Color8(72, 136, 56)
const GRASS_LIGHT := Color8(140, 204, 100)
const PATH := Color8(217, 195, 140)
const PATH_DARK := Color8(186, 160, 108)
const WOOD := Color8(200, 149, 90)
const WOOD_DARK := Color8(160, 112, 64)
const BRICK := Color8(140, 140, 150)
const BRICK_DARK := Color8(96, 96, 108)
const WATER := Color8(72, 132, 220)
const WATER_LIGHT := Color8(132, 180, 240)
const TRUNK := Color8(110, 72, 40)
const LEAVES := Color8(40, 110, 48)
const LEAVES_LIGHT := Color8(64, 144, 64)
const ROOF := Color8(196, 64, 56)
const ROOF_DARK := Color8(150, 40, 40)
const HOUSE := Color8(236, 224, 196)
const WINDOW := Color8(120, 180, 220)
const OUTLINE := Color8(40, 32, 32)
const RUG := Color8(180, 48, 64)
const FLOWER_RED := Color8(232, 72, 72)
const FLOWER_YELLOW := Color8(248, 216, 64)
const WALL_IN := Color8(120, 96, 80)

var img: Image
var rng := RandomNumberGenerator.new()


func _init() -> void:
	rng.seed = 1234
	img = Image.create_empty(T * COUNT, T, false, Image.FORMAT_RGBA8)
	_grass(0)
	_tall_grass(1)
	_path(2)
	_floor(3)
	_wall(4)
	_water(5)
	_tree(6)
	_ledge(7)
	_door(8)
	_roof(9)
	_house_wall(10)
	_counter(11)
	_mat(12)
	_flowers(13)
	_indoor_wall(14)
	_rect(15, 0, 0, T, T, Color.BLACK)
	var err := img.save_png(ProjectSettings.globalize_path(OUT))
	print("placeholder.png: ", error_string(err))
	quit()


func _rect(i: int, x: int, y: int, w: int, h: int, c: Color) -> void:
	img.fill_rect(Rect2i(i * T + x, y, w, h), c)


func _px(i: int, x: int, y: int, c: Color) -> void:
	img.set_pixel(i * T + x, y, c)


func _specks(i: int, c: Color, n: int) -> void:
	for _k: int in n:
		_px(i, rng.randi_range(0, T - 1), rng.randi_range(0, T - 1), c)


func _grass(i: int) -> void:
	_rect(i, 0, 0, T, T, GRASS)
	_specks(i, GRASS_DARK, 10)
	_specks(i, GRASS_LIGHT, 6)


func _tall_grass(i: int) -> void:
	_rect(i, 0, 0, T, T, GRASS_DARK)
	for x: int in range(1, T, 4):
		for y: int in range(3, T, 5):
			_px(i, x, y, GRASS_LIGHT)
			_px(i, x + 1, y - 1, GRASS_LIGHT)
			_px(i, x + 2, y, GRASS_LIGHT)
			_px(i, x + 1, y + 1, LEAVES)


func _path(i: int) -> void:
	_rect(i, 0, 0, T, T, PATH)
	_specks(i, PATH_DARK, 12)


func _floor(i: int) -> void:
	_rect(i, 0, 0, T, T, WOOD)
	for y: int in [3, 7, 11, 15]:
		_rect(i, 0, y, T, 1, WOOD_DARK)
	_rect(i, 5, 0, 1, 3, WOOD_DARK)
	_rect(i, 11, 4, 1, 3, WOOD_DARK)
	_rect(i, 3, 8, 1, 3, WOOD_DARK)
	_rect(i, 9, 12, 1, 3, WOOD_DARK)


func _wall(i: int) -> void:
	_rect(i, 0, 0, T, T, BRICK)
	for y: int in [0, 4, 8, 12]:
		_rect(i, 0, y, T, 1, BRICK_DARK)
		var offset := 0 if y % 8 == 0 else 4
		for x: int in range(offset, T, 8):
			_rect(i, x, y, 1, 4, BRICK_DARK)


func _water(i: int) -> void:
	_rect(i, 0, 0, T, T, WATER)
	for y: int in [3, 9, 14]:
		var x0 := rng.randi_range(0, 8)
		_rect(i, x0, y, 5, 1, WATER_LIGHT)


func _tree(i: int) -> void:
	_grass(i)
	_rect(i, 6, 11, 4, 5, TRUNK)
	_rect(i, 2, 1, 12, 11, LEAVES)
	_rect(i, 1, 3, 14, 7, LEAVES)
	_rect(i, 4, 2, 4, 3, LEAVES_LIGHT)
	_rect(i, 2, 1, 12, 1, OUTLINE)


func _ledge(i: int) -> void:
	_grass(i)
	_rect(i, 0, 11, T, 2, GRASS_DARK)
	_rect(i, 0, 13, T, 3, OUTLINE)


func _door(i: int) -> void:
	_rect(i, 0, 0, T, T, HOUSE)
	_rect(i, 3, 2, 10, 14, WOOD_DARK)
	_rect(i, 4, 3, 8, 13, WOOD)
	_px(i, 10, 9, OUTLINE)


func _roof(i: int) -> void:
	_rect(i, 0, 0, T, T, ROOF)
	for y: int in [3, 7, 11, 15]:
		_rect(i, 0, y, T, 1, ROOF_DARK)


func _house_wall(i: int) -> void:
	_rect(i, 0, 0, T, T, HOUSE)
	_rect(i, 4, 4, 8, 7, OUTLINE)
	_rect(i, 5, 5, 6, 5, WINDOW)
	_rect(i, 0, 15, T, 1, OUTLINE)


func _counter(i: int) -> void:
	_floor(i)
	_rect(i, 0, 2, T, 12, WOOD_DARK)
	_rect(i, 0, 2, T, 3, WOOD)
	_rect(i, 0, 13, T, 1, OUTLINE)


func _mat(i: int) -> void:
	_floor(i)
	_rect(i, 1, 3, 14, 10, RUG)
	_rect(i, 2, 4, 12, 8, ROOF_DARK)


func _flowers(i: int) -> void:
	_grass(i)
	for p: Vector2i in [Vector2i(3, 3), Vector2i(11, 5), Vector2i(6, 11), Vector2i(13, 13)]:
		var c := FLOWER_RED if (p.x + p.y) % 2 == 0 else FLOWER_YELLOW
		_px(i, p.x, p.y, c)
		_px(i, p.x - 1, p.y, c)
		_px(i, p.x + 1, p.y, c)
		_px(i, p.x, p.y - 1, c)
		_px(i, p.x, p.y + 1, c)


func _indoor_wall(i: int) -> void:
	_rect(i, 0, 0, T, T, WALL_IN)
	_rect(i, 0, 12, T, 4, WOOD_DARK)
	_rect(i, 0, 12, T, 1, OUTLINE)
