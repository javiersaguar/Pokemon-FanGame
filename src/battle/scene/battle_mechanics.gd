class_name BattleMechanics
extends RefCounted
const NAMES := {&"": "Atacar sin activar", &"mega":"Megaevolución", &"z":"Movimiento Z", &"dynamax":"Dinamax", &"tera":"Teracristalizar"}
static func available(request: Dictionary,move_slot: int) -> Array[StringName]:
	var result: Array[StringName] = [&""]
	if request.get("can_mega",false): result.append(&"mega")
	if move_slot in request.get("z_moves",[]): result.append(&"z")
	if request.get("can_dynamax",false): result.append(&"dynamax")
	if request.get("can_tera",false): result.append(&"tera")
	return result
static func action(move_slot: int,target_slot: int,mechanic: StringName) -> Dictionary:
	var result := {"type":&"fight","move_slot":move_slot,"target_slot":target_slot}
	if mechanic != &"" and NAMES.has(mechanic): result[String(mechanic)] = true
	return result
