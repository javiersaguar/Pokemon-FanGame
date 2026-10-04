class_name AbilityData
extends RefCounted
## Datos de una habilidad (data/generated/abilities.json). Su efecto en combate llega en la Fase 9.

var id: StringName
var num: int
var name: String
var name_en: String
var rating: float = 0.0
var needs_script: bool = true
var description: String
var raw: Dictionary = {}


static func from_dict(ability_id: StringName, d: Dictionary) -> AbilityData:
	var a := AbilityData.new()
	a.id = ability_id
	a.raw = d
	a.num = int(d.get("num", 0))
	a.name = str(d.get("name", ability_id))
	a.name_en = str(d.get("name_en", ""))
	a.rating = float(d.get("rating", 0.0))
	a.needs_script = bool(d.get("needs_script", true))
	a.description = str(d.get("description", ""))
	return a
