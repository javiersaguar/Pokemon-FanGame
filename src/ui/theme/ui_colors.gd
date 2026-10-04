class_name UiColors
extends RefCounted
## Colores de la interfaz que no están en el Theme: tipos, barras de PS y estados.

const TYPE_COLORS_PATH := "res://src/ui/theme/type_colors.json"

const HP_GREEN := Color("58d080")
const HP_YELLOW := Color("f8c838")
const HP_RED := Color("f85838")
const EXP_BLUE := Color("40a0f8")
const BAR_BACK := Color("505860")
const BAR_EMPTY := Color("e8e8d8")

## Abreviatura y color de cada estado principal (en las cajas de datos).
const STATUS_LABELS: Dictionary[StringName, String] = {
	&"par": "PAR", &"brn": "QUE", &"psn": "ENV", &"tox": "ENV", &"slp": "DOR", &"frz": "CON",
}
const STATUS_COLORS: Dictionary[StringName, Color] = {
	&"par": Color("b8b818"), &"brn": Color("e07038"), &"psn": Color("a040a0"),
	&"tox": Color("8030a0"), &"slp": Color("8c8c8c"), &"frz": Color("58b8d8"),
}

static var _type_colors: Dictionary = {}


static func type_color(type: StringName) -> Color:
	if _type_colors.is_empty():
		var raw := JsonFile.read_dict(TYPE_COLORS_PATH)
		for key: String in raw:
			if not key.begins_with("_"):
				_type_colors[StringName(key)] = Color(str(raw[key]))
	return _type_colors.get(type, _type_colors.get(&"unknown", Color.GRAY))


## Color de la barra de PS según lo que le queda (como en los juegos oficiales).
static func hp_color(ratio: float) -> Color:
	if ratio > 0.5:
		return HP_GREEN
	if ratio > 0.2:
		return HP_YELLOW
	return HP_RED
