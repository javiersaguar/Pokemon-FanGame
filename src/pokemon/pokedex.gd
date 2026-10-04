class_name Pokedex
extends RefCounted
## Pokédex del jugador (Fase 6.5). Módulo de GameState (contratos.md §2 y §8.4).
## Se apunta por especie base ("raichu"); las formas vistas ("raichualola") se guardan aparte.

var _seen: Dictionary[StringName, bool] = {}
var _caught: Dictionary[StringName, bool] = {}
var _shiny_seen: Dictionary[StringName, bool] = {}
var _forms_seen: Dictionary[StringName, Array] = {}


## Visto en combate (o en la Pokédex de un NPC...).
func mark_seen(species_id: StringName, shiny: bool = false) -> void:
	var root := _root(species_id)
	if root == &"":
		return
	_seen[root] = true
	if shiny:
		_shiny_seen[root] = true
	var forms: Array = _forms_seen.get(root, [])
	if species_id not in forms:
		forms.append(species_id)
		_forms_seen[root] = forms


## Capturado, evolucionado, recibido o eclosionado (también lo marca como visto).
func mark_caught(species_id: StringName) -> void:
	var root := _root(species_id)
	if root == &"":
		return
	mark_seen(species_id)
	_caught[root] = true


## Atajo para un Pokémon que pasa a ser del jugador.
func register(p: Pokemon) -> void:
	mark_seen(p.species_id, p.shiny)
	mark_caught(p.species_id)


func is_seen(species_id: StringName) -> bool:
	return _seen.has(_root(species_id))


func is_caught(species_id: StringName) -> bool:
	return _caught.has(_root(species_id))


func is_shiny_seen(species_id: StringName) -> bool:
	return _shiny_seen.has(_root(species_id))


func forms_seen(species_id: StringName) -> Array[StringName]:
	var out: Array[StringName] = []
	out.assign(_forms_seen.get(_root(species_id), []))
	return out


## Con `regional_only`, solo cuenta las especies de la Pokédex regional.
func seen_count(regional_only: bool = false) -> int:
	return _count(_seen, regional_only)


func caught_count(regional_only: bool = false) -> int:
	return _count(_caught, regional_only)


func caught_species() -> Array[StringName]:
	var out: Array[StringName] = []
	out.assign(_caught.keys())
	return out


func to_dict() -> Dictionary:
	var forms := {}
	for root: StringName in _forms_seen:
		forms[String(root)] = _forms_seen[root].map(func(f: StringName) -> String: return String(f))
	return {
		"seen": _keys(_seen),
		"caught": _keys(_caught),
		"shiny_seen": _keys(_shiny_seen),
		"forms_seen": forms,
	}


func from_dict(data: Dictionary) -> void:
	_seen = _set_from(data.get("seen", []))
	_caught = _set_from(data.get("caught", []))
	_shiny_seen = _set_from(data.get("shiny_seen", []))
	_forms_seen.clear()
	var forms: Dictionary = data.get("forms_seen", {})
	for root: String in forms:
		_forms_seen[StringName(root)] = DataUtil.names(forms[root])


func _root(species_id: StringName) -> StringName:
	if not DataDB.has_species(species_id):
		push_error("Pokedex: no existe la especie '%s'." % species_id)
		return &""
	return DataDB.species(species_id).root_species()


func _count(table: Dictionary[StringName, bool], regional_only: bool) -> int:
	if not regional_only:
		return table.size()
	var n := 0
	for id: StringName in table:
		if DataDB.regional_number(id) > 0:
			n += 1
	return n


func _keys(table: Dictionary[StringName, bool]) -> Array:
	return table.keys().map(func(k: StringName) -> String: return String(k))


func _set_from(values: Array) -> Dictionary[StringName, bool]:
	var out: Dictionary[StringName, bool] = {}
	for v: Variant in values:
		out[StringName(str(v))] = true
	return out
