class_name NatureData
extends RefCounted
## Naturaleza (data/generated/natures.json): +10 % a `plus` y −10 % a `minus` (vacíos si es neutra).

var id: StringName
var name: String
var plus: StringName
var minus: StringName


static func from_dict(nature_id: StringName, d: Dictionary) -> NatureData:
	var n := NatureData.new()
	n.id = nature_id
	n.name = str(d.get("name", nature_id))
	n.plus = StringName(d.get("plus", ""))
	n.minus = StringName(d.get("minus", ""))
	return n


func is_neutral() -> bool:
	return plus == minus


## Modificador en tanto por ciento para `stat`: 110, 90 o 100.
func percent(stat: StringName) -> int:
	if is_neutral():
		return 100
	if stat == plus:
		return 110
	if stat == minus:
		return 90
	return 100
