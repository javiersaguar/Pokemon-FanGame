class_name Bag
extends RefCounted
## Mochila (Fase 11.1): cuántos hay de cada objeto, en el orden en que se consiguieron.
## Módulo de GameState (contratos.md §2 y §9.5): GameState la crea y la guarda sola.

## Máximo de unidades de un mismo objeto (Fase 11.1).
const MAX_COUNT := 999

var _counts: Dictionary[StringName, int] = {}
var _order: Array[StringName] = []


## Añade `amount` unidades. Devuelve cuántas se han añadido de verdad (tope MAX_COUNT).
func add(item_id: StringName, amount: int = 1) -> int:
	if amount <= 0:
		return 0
	if not DataDB.has_item(item_id):
		push_error("Bag.add: no existe el objeto '%s'." % item_id)
		return 0
	var before: int = _counts.get(item_id, 0)
	var after := mini(before + amount, MAX_COUNT)
	_counts[item_id] = after
	if item_id not in _order:
		_order.append(item_id)
	return after - before


## Quita `amount` unidades. false (sin quitar nada) si no hay suficientes.
func remove(item_id: StringName, amount: int = 1) -> bool:
	if amount <= 0 or count(item_id) < amount:
		return false
	_counts[item_id] -= amount
	if _counts[item_id] == 0:
		_counts.erase(item_id)
		_order.erase(item_id)
	return true


func count(item_id: StringName) -> int:
	return _counts.get(item_id, 0)


func has(item_id: StringName, amount: int = 1) -> bool:
	return count(item_id) >= amount


func is_empty() -> bool:
	return _order.is_empty()


## Todos los objetos, en el orden en que se consiguieron.
func all_items() -> Array[StringName]:
	return _order.duplicate()


## Objetos de un bolsillo (campo `pocket` de ItemData: items, medicine, pokeballs...).
func items_in_pocket(pocket: StringName) -> Array[StringName]:
	return _order.filter(func(id: StringName) -> bool: return DataDB.item(id).pocket == pocket)


## Objetos que se pueden usar en combate (campo `battle_use`).
func battle_items() -> Array[StringName]:
	return _order.filter(func(id: StringName) -> bool: return DataDB.item(id).usable_in_battle())


func to_dict() -> Dictionary:
	var items: Array = []
	for id: StringName in _order:
		items.append([String(id), _counts[id]])
	return {"items": items}


func from_dict(data: Dictionary) -> void:
	_counts.clear()
	_order.clear()
	for entry: Variant in data.get("items", []):
		if entry is Array and entry.size() == 2 and DataDB.has_item(StringName(entry[0])):
			var id := StringName(entry[0])
			_counts[id] = clampi(int(entry[1]), 1, MAX_COUNT)
			_order.append(id)
