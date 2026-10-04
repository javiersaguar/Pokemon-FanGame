class_name TypeIcons
extends RefCounted
## Iconos de tipo en español de Loaky (assets/sprites/ui/icons/types_spanish.png):
## una tira vertical de 64×28 por tipo, ya a la escala de 512×384. Dentro de un
## UiCanvas (×2) se dibujan con escala 0,5 para verlos a 1:1.

const SHEET := preload("res://assets/sprites/ui/icons/types_spanish.png")
const ICON_SIZE := Vector2(64, 28)
## Orden de la tira (el de Pokémon Essentials).
const ORDER: Array[StringName] = [
	&"normal", &"fighting", &"flying", &"poison", &"ground", &"rock", &"bug", &"ghost", &"steel",
	&"unknown", &"fire", &"water", &"grass", &"electric", &"psychic", &"ice", &"dragon", &"dark", &"fairy",
]

static var _cache: Dictionary[StringName, AtlasTexture] = {}


static func texture(type: StringName) -> AtlasTexture:
	var key := type if type in ORDER else &"unknown"
	if not _cache.has(key):
		var atlas := AtlasTexture.new()
		atlas.atlas = SHEET
		atlas.region = Rect2(Vector2(0, ORDER.find(key) * ICON_SIZE.y), ICON_SIZE)
		_cache[key] = atlas
	return _cache[key]


## TextureRect con el icono, listo para meterlo en un UiCanvas (se ve a 1:1).
static func make_rect(type: StringName) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = texture(type)
	rect.scale = Vector2(0.5, 0.5)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect
