class_name BattleBackground
extends Node2D
## Fondo del combate según el entorno del mapa (`battle_background`), con los
## fondos del pack 10_fondos_combate (assets/sprites/ui/battle/backgrounds/).
## Esos fondos son de Elite Battle: DX (384×308) y allí se ven ampliados con la
## cámara (ROOM_SCALE 2,25). Aquí se ven a ×2 exacto y se encuadra la parte del
## horizonte. PENDIENTE JAVIER: confirmar este encuadre (pregunta en docs/ESTADO.md).

const DIR := "res://assets/sprites/ui/battle/backgrounds/"
const ZOOM := 2
## Desplazamiento del fondo ampliado para que el horizonte quede a la altura de Añil.
const OFFSET := Vector2(-128, -40)
## Entorno → archivo del pack.
const FILES: Dictionary[StringName, String] = {
	&"grass": "field", &"field": "field", &"forest": "forest", &"cave": "cave",
	&"city": "city", &"water": "water", &"indoor": "indoor_a", &"snow": "snow", &"sand": "sand",
}

var environment: StringName = &"grass"
var _image: Texture2D


func set_environment(id: StringName) -> void:
	environment = id if id != &"" else &"grass"
	var file: String = FILES.get(environment, "field")
	_image = PlaceholderArt.load_texture(DIR + file + ".png")
	if _image == null:
		_image = PlaceholderArt.load_texture(DIR + "field.png")
	queue_redraw()


func _draw() -> void:
	if _image:
		draw_texture_rect(_image, Rect2(OFFSET, _image.get_size() * ZOOM), false)
