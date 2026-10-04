class_name Party
extends RefCounted
## Equipo del jugador (máx. 6). Módulo de GameState (contratos.md §2 y §8.4).

const MAX_SIZE := 6

var members: Array[Pokemon] = []


func size() -> int:
	return members.size()


func is_empty() -> bool:
	return members.is_empty()


func is_full() -> bool:
	return members.size() >= MAX_SIZE


func get_at(index: int) -> Pokemon:
	return members[index] if index >= 0 and index < members.size() else null


func index_of(p: Pokemon) -> int:
	return members.find(p)


## Añade al final. Devuelve false si el equipo está lleno.
func add(p: Pokemon) -> bool:
	if is_full() or p == null:
		return false
	members.append(p)
	return true


func remove_at(index: int) -> Pokemon:
	var p := get_at(index)
	if p != null:
		members.remove_at(index)
	return p


func swap(i: int, j: int) -> void:
	if get_at(i) == null or get_at(j) == null:
		return
	var tmp := members[i]
	members[i] = members[j]
	members[j] = tmp


## Mueve el Pokémon de `from` a la posición `to` (reordenar).
func move(from: int, to: int) -> void:
	var p := remove_at(from)
	if p != null:
		members.insert(clampi(to, 0, members.size()), p)


func first_able() -> Pokemon:
	var i := first_able_index()
	return members[i] if i >= 0 else null


func first_able_index() -> int:
	for i: int in members.size():
		if not members[i].is_fainted():
			return i
	return -1


## Nivel del primer Pokémon no debilitado (para el Repelente); 0 si no hay ninguno.
func first_able_level() -> int:
	var p := first_able()
	return p.level if p else 0


func able_count() -> int:
	var n := 0
	for p: Pokemon in members:
		if not p.is_fainted():
			n += 1
	return n


## true si no queda ninguno que pueda luchar (también con el equipo vacío).
func is_all_fainted() -> bool:
	return first_able_index() == -1


func heal_all() -> void:
	for p: Pokemon in members:
		p.heal_full()


func has_species(species_id: StringName) -> bool:
	for p: Pokemon in members:
		if p.species_id == species_id:
			return true
	return false


func species_ids() -> Array[StringName]:
	var out: Array[StringName] = []
	for p: Pokemon in members:
		out.append(p.species_id)
	return out


func types() -> Array[StringName]:
	var out: Array[StringName] = []
	for p: Pokemon in members:
		for t: StringName in p.types():
			if t not in out:
				out.append(t)
	return out


func to_dict() -> Dictionary:
	return {"members": members.map(func(p: Pokemon) -> Dictionary: return p.to_dict())}


func from_dict(data: Dictionary) -> void:
	members.clear()
	for d: Dictionary in data.get("members", []):
		members.append(Pokemon.from_dict(d))
