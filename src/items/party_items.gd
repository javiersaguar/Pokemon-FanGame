class_name PartyItems
extends RefCounted
## Intercambio atómico entre mochila y objeto equipado.
static func equip(p: Pokemon, item: StringName) -> Error:
	if p == null or not DataDB.has_item(item) or DataDB.item(item).is_key_item(): return ERR_INVALID_PARAMETER
	if p.held_item == item: return OK
	var bag := GameState.bag as Bag
	if bag == null or not bag.has(item): return ERR_DOES_NOT_EXIST
	if p.held_item != &"" and bag.count(p.held_item) >= Bag.MAX_COUNT: return ERR_OUT_OF_MEMORY
	bag.remove(item)
	if p.held_item != &"": bag.add(p.held_item)
	p.held_item = item
	return OK

static func take(p: Pokemon) -> Error:
	var bag := GameState.bag as Bag
	if p == null or p.held_item == &"" or bag == null: return ERR_INVALID_PARAMETER
	if bag.count(p.held_item) >= Bag.MAX_COUNT: return ERR_OUT_OF_MEMORY
	if bag.add(p.held_item) != 1: return ERR_UNAVAILABLE
	p.held_item = &""
	return OK
