class_name MoveSlot
extends RefCounted
## Un movimiento que conoce un Pokémon: id, PP actuales y Más PP usados (0-3).

var id: StringName
var pp: int = 0
var pp_ups: int = 0


static func create(move_id: StringName, ups: int = 0) -> MoveSlot:
	var slot := MoveSlot.new()
	slot.id = move_id
	slot.pp_ups = clampi(ups, 0, 3)
	slot.pp = slot.max_pp()
	return slot


func data() -> MoveData:
	return DataDB.move(id)


func max_pp() -> int:
	var m := DataDB.move(id)
	return m.max_pp(pp_ups) if m else 0


func restore(amount: int = -1) -> int:
	var before := pp
	pp = max_pp() if amount < 0 else mini(pp + amount, max_pp())
	return pp - before


func to_dict() -> Dictionary:
	return {"id": String(id), "pp": pp, "pp_ups": pp_ups}


static func from_dict(d: Dictionary) -> MoveSlot:
	var slot := MoveSlot.new()
	slot.id = StringName(d.get("id", ""))
	slot.pp_ups = int(d.get("pp_ups", 0))
	slot.pp = int(d.get("pp", slot.max_pp()))
	return slot
