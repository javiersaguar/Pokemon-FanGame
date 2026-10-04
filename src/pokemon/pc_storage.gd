class_name PCStorage
extends RefCounted
## Cajas del PC. Módulo de GameState (contratos.md §2 y §8.4).
## Número de cajas y huecos: data/world.json → pokemon.pc_boxes / pc_box_size.

const NO_SLOT := Vector2i(-1, -1)

var current_box: int = 0
## Cada caja: Array de `box_size()` huecos (Pokemon o null).
var _boxes: Array[Array] = []
var _names: Array[String] = []
var _wallpapers: Array[StringName] = []


func _init() -> void:
	var count := int(DataDB.rule(&"pc_boxes", 32))
	for i: int in count:
		_add_box(i)


func box_count() -> int:
	return _boxes.size()


func box_size() -> int:
	return int(DataDB.rule(&"pc_box_size", 30))


func box_name(box: int) -> String:
	return _names[box] if _valid_box(box) else ""


func rename_box(box: int, new_name: String) -> void:
	if _valid_box(box):
		_names[box] = new_name


func box_wallpaper(box: int) -> StringName:
	return _wallpapers[box] if _valid_box(box) else &""


func set_box_wallpaper(box: int, wallpaper: StringName) -> void:
	if _valid_box(box):
		_wallpapers[box] = wallpaper


func get_pokemon(box: int, slot: int) -> Pokemon:
	return _boxes[box][slot] if _valid(box, slot) else null


## Pone `p` en el hueco (sustituye lo que hubiera; `null` lo vacía).
func set_pokemon(box: int, slot: int, p: Pokemon) -> void:
	if _valid(box, slot):
		_boxes[box][slot] = p


## Saca el Pokémon del hueco y lo devuelve (null si estaba vacío).
func take(box: int, slot: int) -> Pokemon:
	var p := get_pokemon(box, slot)
	set_pokemon(box, slot, null)
	return p


## Deja `p` en el primer hueco libre, empezando por la caja actual. Devuelve (caja, hueco) o NO_SLOT.
func deposit(p: Pokemon) -> Vector2i:
	for offset: int in box_count():
		var box := (current_box + offset) % box_count()
		for slot: int in box_size():
			if _boxes[box][slot] == null:
				_boxes[box][slot] = p
				return Vector2i(box, slot)
	return NO_SLOT


## Intercambia dos huecos (cualquiera de los dos puede estar vacío).
func move(from_box: int, from_slot: int, to_box: int, to_slot: int) -> void:
	if not _valid(from_box, from_slot) or not _valid(to_box, to_slot):
		return
	var tmp: Pokemon = _boxes[to_box][to_slot]
	_boxes[to_box][to_slot] = _boxes[from_box][from_slot]
	_boxes[from_box][from_slot] = tmp


## Libera al Pokémon (la confirmación la pide la interfaz).
func release(box: int, slot: int) -> void:
	set_pokemon(box, slot, null)


func count() -> int:
	var n := 0
	for box: Array in _boxes:
		for p: Variant in box:
			if p != null:
				n += 1
	return n


func is_full() -> bool:
	return count() >= box_count() * box_size()


func find_uid(uid: String) -> Vector2i:
	for box: int in box_count():
		for slot: int in box_size():
			var p: Pokemon = _boxes[box][slot]
			if p != null and p.uid == uid:
				return Vector2i(box, slot)
	return NO_SLOT


func to_dict() -> Dictionary:
	var boxes := []
	for i: int in box_count():
		var slots := []
		for p: Variant in _boxes[i]:
			slots.append(null if p == null else (p as Pokemon).to_dict())
		boxes.append({"name": _names[i], "wallpaper": String(_wallpapers[i]), "slots": slots})
	return {"current_box": current_box, "boxes": boxes}


func from_dict(data: Dictionary) -> void:
	var saved: Array = data.get("boxes", [])
	_boxes.clear()
	_names.clear()
	_wallpapers.clear()
	for i: int in maxi(saved.size(), int(DataDB.rule(&"pc_boxes", 32))):
		_add_box(i)
		if i >= saved.size():
			continue
		var box: Dictionary = saved[i]
		_names[i] = str(box.get("name", _names[i]))
		_wallpapers[i] = StringName(box.get("wallpaper", ""))
		var slots: Array = box.get("slots", [])
		for slot: int in mini(slots.size(), box_size()):
			if slots[slot] is Dictionary:
				_boxes[i][slot] = Pokemon.from_dict(slots[slot])
	current_box = clampi(int(data.get("current_box", 0)), 0, box_count() - 1)


func _add_box(index: int) -> void:
	var slots: Array = []
	slots.resize(box_size())
	_boxes.append(slots)
	_names.append(tr("Caja %d") % (index + 1))
	_wallpapers.append(&"")


func _valid_box(box: int) -> bool:
	return box >= 0 and box < _boxes.size()


func _valid(box: int, slot: int) -> bool:
	return _valid_box(box) and slot >= 0 and slot < box_size()
