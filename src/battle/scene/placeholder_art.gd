class_name PlaceholderArt
extends RefCounted
## Gráficos provisionales generados al vuelo mientras no haya arte: Pokémon
## (una "gota" del color de su tipo), entrenadores (silueta) y Poké Ball.

const OUTLINE := Color("303040")

static var _cache: Dictionary[String, Texture2D] = {}


## Textura del archivo si existe; si no, null.
static func load_texture(path: String) -> Texture2D:
	if path != "" and ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


static func pokemon(types: Array, back: bool) -> Texture2D:
	var main_type := StringName(types[0]) if not types.is_empty() else &"normal"
	var second_type := StringName(types[1]) if types.size() > 1 else main_type
	var key := "pkmn:%s:%s:%s" % [main_type, second_type, back]
	if _cache.has(key):
		return _cache[key]
	var img := Image.create_empty(64, 64, false, Image.FORMAT_RGBA8)
	var body := UiColors.type_color(main_type)
	var belly := UiColors.type_color(second_type).lightened(0.25)
	var center := Vector2(32, 40)
	var radius := Vector2(25, 21) if back else Vector2(23, 20)
	for y: int in 64:
		for x: int in 64:
			var d := ((Vector2(x, y) - center) / radius).length()
			if d > 1.0:
				continue
			var color := body
			if d > 0.9:
				color = OUTLINE
			elif not back and y > 44 and absf(x - center.x) < 11:
				color = belly
			elif y < 30 and x < 26:
				color = body.lightened(0.2)
			img.set_pixel(x, y, color)
	if not back:
		for eye_x: int in [24, 37]:
			img.fill_rect(Rect2i(eye_x, 33, 3, 5), OUTLINE)
			img.set_pixel(eye_x + 1, 34, Color.WHITE)
	var texture := ImageTexture.create_from_image(img)
	_cache[key] = texture
	return texture


static func trainer(back: bool) -> Texture2D:
	var key := "trainer:%s" % back
	if _cache.has(key):
		return _cache[key]
	var img := Image.create_empty(48, 64, false, Image.FORMAT_RGBA8)
	var skin := Color("f0c8a0")
	var cloth := Color("586898") if back else Color("985858")
	_disc(img, Vector2(24, 14), 9.0, OUTLINE)
	_disc(img, Vector2(24, 14), 8.0, skin)
	for y: int in range(24, 64):
		var half := 10 + (y - 24) / 4
		for x: int in range(24 - half, 24 + half):
			if x >= 0 and x < 48:
				var edge := x == 24 - half or x == 24 + half - 1
				img.set_pixel(x, y, OUTLINE if edge else cloth)
	var texture := ImageTexture.create_from_image(img)
	_cache[key] = texture
	return texture


static func ball() -> Texture2D:
	if _cache.has("ball"):
		return _cache["ball"]
	var img := Image.create_empty(10, 10, false, Image.FORMAT_RGBA8)
	for y: int in 10:
		for x: int in 10:
			var d := Vector2(x - 4.5, y - 4.5).length()
			if d > 5.0:
				continue
			var color := Color("e83838") if y < 5 else Color.WHITE
			if d > 4.0 or y == 5:
				color = OUTLINE
			img.set_pixel(x, y, color)
	img.fill_rect(Rect2i(4, 4, 2, 2), Color.WHITE)
	var texture := ImageTexture.create_from_image(img)
	_cache["ball"] = texture
	return texture


static func _disc(img: Image, center: Vector2, radius: float, color: Color) -> void:
	for y: int in img.get_height():
		for x: int in img.get_width():
			if Vector2(x, y).distance_to(center) <= radius:
				img.set_pixel(x, y, color)
