class_name EvolutionRules
extends RefCounted
## ¿Evoluciona este Pokémon? Lee SpeciesData.evolutions (ver contratos.md §8.3).
## `context` (todo opcional): {time: Clock.period(), party_species: Array[StringName],
## party_types: Array[StringName], weather: StringName, location: StringName}.

## Periodos de Clock (data/world.json → clock.periods) en los que vale cada `time` de evolución.
const TIME_PERIODS: Dictionary[String, Array] = {
	"day": [&"morning", &"day"],
	"night": [&"night"],
	"dusk": [&"evening"],
}
const LEVEL_UP_METHODS: Array[String] = ["level", "friendship", "level_hold", "level_move", "level_extra"]
## Confites con los que Milcery evoluciona al girar. El sabor de Alcremie (una sola especie en los datos) queda PENDIENTE JAVIER.
const SWEETS: Array[StringName] = [
	&"strawberrysweet", &"lovesweet", &"berrysweet", &"cloversweet",
	&"flowersweet", &"starsweet", &"ribbonsweet",
]


## Especie a la que evoluciona al subir de nivel (o al acabar un combate tras subir); &"" si no.
static func level_up_target(p: Pokemon, context: Dictionary = {}) -> StringName:
	var evo := level_up_evolution(p, context)
	return StringName(evo.get("to", ""))


## Igual que level_up_target, pero devuelve la entrada completa ({} si no evoluciona).
static func level_up_evolution(p: Pokemon, context: Dictionary = {}) -> Dictionary:
	for evo: Dictionary in p.species().evolutions:
		if str(evo.get("method", "")) in LEVEL_UP_METHODS and matches(p, evo, context):
			return evo
	return {}


## Especie a la que evoluciona al usar `item_id` (piedras...); &"" si no.
static func item_target(p: Pokemon, item_id: StringName, context: Dictionary = {}) -> StringName:
	for evo: Dictionary in p.species().evolutions:
		if evo.get("method", "") == "item" and StringName(evo.get("item", "")) == item_id and matches(p, evo, context):
			return StringName(evo["to"])
	return &""


## Milcery y otras de método `other` que el motor reconoce. `context.spin` lo pone quien gira al Pokémon.
static func special_target(p: Pokemon, context: Dictionary = {}) -> StringName:
	for evo: Dictionary in p.species().evolutions:
		if evo.get("method", "") == "other" and matches(p, evo, context):
			return StringName(evo["to"])
	return &""


## Evolución por intercambio ya sustituida, o la que sigue pidiendo el método `trade` en los datos.
static func trade_target(p: Pokemon, context: Dictionary = {}) -> StringName:
	for evo: Dictionary in p.species().evolutions:
		if evo.get("method", "") == "trade" and matches(p, evo, context):
			return StringName(evo["to"])
	return &""


## ¿El motor entiende esta entrada? Las de `other` solo si la condición está reconocida.
static func implemented(evo: Dictionary) -> bool:
	var method := str(evo.get("method", ""))
	if method in LEVEL_UP_METHODS or method in ["item", "shed", "trade"]:
		return true
	if method == "other":
		return _spin_sweet(evo)
	return false


## Shedinja: especie extra que aparece al evolucionar `from` (Nincada) a `to`; &"" si ninguna.
static func shed_species(from_species: StringName, to_species: StringName) -> StringName:
	var s := DataDB.species(from_species)
	if s == null:
		return &""
	var leveled := false
	var shed := &""
	for evo: Dictionary in s.evolutions:
		if evo.get("method", "") == "shed":
			shed = StringName(evo["to"])
		elif StringName(evo.get("to", "")) == to_species:
			leveled = true
	return shed if leveled else &""


## ¿Cumple `p` todas las condiciones de la entrada `evo`?
static func matches(p: Pokemon, evo: Dictionary, context: Dictionary = {}) -> bool:
	if not DataDB.has_species(StringName(evo.get("to", ""))):
		return false
	if evo.has("region") and str(evo["region"]) != str(context.get("region", "")):
		return false
	var method := str(evo.get("method", ""))
	if evo.has("level") and p.level < int(evo["level"]):
		return false
	match method:
		"friendship":
			if p.friendship < int(evo.get("min_friendship", 160)):
				return false
		"level_hold":
			if p.held_item != StringName(evo.get("item", "")):
				return false
		"level_move":
			if not p.has_move(StringName(evo.get("move", ""))):
				return false
		"level", "level_extra", "item":
			pass
		"trade":
			var needed := StringName(evo.get("item", ""))
			if needed != &"" and p.held_item != needed:
				return false
		"other":
			if not _spin_sweet(evo):
				return false
			if not bool(context.get("spin", false)) or p.held_item not in SWEETS:
				return false
		_:
			return false
	if evo.has("time"):
		var period := StringName(context.get("time", &""))
		if period not in TIME_PERIODS.get(str(evo["time"]), []):
			return false
	if evo.has("gender") and p.gender != StringName(evo["gender"]):
		return false
	if evo.has("stat_relation"):
		var atk := p.stat(&"atk")
		var def := p.stat(&"def")
		match str(evo["stat_relation"]):
			"atk_gt_def":
				if atk <= def:
					return false
			"atk_lt_def":
				if atk >= def:
					return false
			"atk_eq_def":
				if atk != def:
					return false
	if evo.has("party_species") and StringName(evo["party_species"]) not in context.get("party_species", []):
		return false
	if evo.has("party_type") and StringName(evo["party_type"]) not in context.get("party_types", []):
		return false
	if evo.has("weather") and StringName(evo["weather"]) != StringName(context.get("weather", &"")):
		return false
	if evo.has("location") and StringName(evo["location"]) != StringName(context.get("location", &"")):
		return false
	if evo.has("known_move_type"):
		var found := false
		for move_id: StringName in p.move_ids():
			var m := DataDB.move(move_id)
			found = found or (m != null and m.type == StringName(evo["known_move_type"]))
		if not found:
			return false
	if evo.has("upside_down") or evo.has("min_affection"):
		return false
	if method == "level_extra" and not _has_structured_condition(evo):
		return false
	return true


static func _spin_sweet(evo: Dictionary) -> bool:
	var condition := str(evo.get("condition", "")).to_lower()
	return "spin" in condition and "sweet" in condition


## level_extra sin ninguna condición entendida (solo texto en "condition") no se aplica nunca.
static func _has_structured_condition(evo: Dictionary) -> bool:
	for key: String in ["level", "time", "gender", "stat_relation", "party_species", "party_type", "weather", "location", "known_move_type"]:
		if evo.has(key):
			return true
	return false


## Aplica la evolución: cambia de especie y gasta el objeto equipado si hacía falta.
static func evolve(p: Pokemon, evo: Dictionary) -> void:
	if evo.get("method", "") == "level_hold":
		p.held_item = &""
	p.evolve_to(StringName(evo["to"]))
