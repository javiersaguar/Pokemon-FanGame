class_name BattleBackground
extends Node2D
## Fondo del combate según el entorno del mapa (`battle_background`), con los
## fondos del pack 10_fondos_combate (assets/sprites/ui/battle/backgrounds/).
## Esos fondos son de Elite Battle: DX (384×308). Aquí se ven a ×2 exacto y se
## encuadra el horizonte (Javier, respuesta 14, hasta que llegue el pack completo).

const DIR := "res://assets/sprites/ui/battle/backgrounds/"
## Bases bajo los Pokémon. El Agente 4 deja aquí las de Elite Battle: DX
## (<entorno>.png, pies del Pokémon en el centro vertical). Mientras no esté
## la del entorno, se usa default.png (óvalo propio provisional).
const BASES := "res://assets/sprites/ui/battle/bases/"
const ZOOM := 2
## Desplazamiento del fondo ampliado para que el horizonte quede a la altura de Añil.
## Javier (respuesta 14) aceptó el ×2 exacto y este encuadre hasta que llegue EBDX.
const OFFSET := Vector2(-128, -40)
## Entorno → archivo del pack 10. La hierba usa el bosque: es el verde más
## cercano a Añil de los fondos que hay (ninguno trae árboles ni bases).
const FILES: Dictionary[StringName, String] = {
	&"grass": "forest", &"field": "field", &"forest": "forest", &"cave": "cave",
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


## Base del entorno, o la provisional. null si no hay ninguna.
static func load_base(id: StringName) -> Texture2D:
	for name: String in [String(id) if id != &"" else "default", "default"]:
		var path := BASES + name + ".png"
		if ResourceLoader.exists(path):
			return load(path)
	return null


func _draw() -> void:
	if _image:
		draw_texture_rect(_image, Rect2(OFFSET, _image.get_size() * ZOOM), false)
