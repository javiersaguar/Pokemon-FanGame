class_name UiColors
extends RefCounted
## Colores de la interfaz que se dibujan por código (rellenos de barras y tipos).
## Salen de la paleta maestra (assets/arte/paleta.json), salvo los tipos.

const TYPE_COLORS_PATH := "res://src/ui/theme/type_colors.json"

## Barras de PS: [base, luz] (hierba_4/5, acento_amarillo + tierra_6, teja_4/6).
const HP_GREEN: Array[Color] = [Color("5aa148"), Color("8cc65a")]
const HP_YELLOW: Array[Color] = [Color("f0b030"), Color("ead098")]
const HP_RED: Array[Color] = [Color("be4844"), Color("e07258")]
const HP_GHOST := Color("f4a884")
const EXP := Color("4592ca")
const EXP_LIGHT := Color("7cc0e2")

## Abreviatura de cada estado principal (sobre su icono de assets/sprites/ui/icons/status/).
const STATUS_LABELS: Dictionary[StringName, String] = {
	&"par": "PAR", &"brn": "QUE", &"psn": "ENV", &"tox": "ENV", &"slp": "DOR", &"frz": "CON",
}

static var _type_colors: Dictionary = {}


static func type_color(type: StringName) -> Color:
	if _type_colors.is_empty():
		var raw := JsonFile.read_dict(TYPE_COLORS_PATH)
		for key: String in raw:
			if not key.begins_with("_"):
				_type_colors[StringName(key)] = Color(str(raw[key]))
	return _type_colors.get(type, _type_colors.get(&"unknown", Color.GRAY))


## [base, luz] de la barra de PS según lo que le queda (como en los juegos oficiales).
static func hp_tones(ratio: float) -> Array[Color]:
	if ratio > 0.5:
		return HP_GREEN
	if ratio > 0.2:
		return HP_YELLOW
	return HP_RED
