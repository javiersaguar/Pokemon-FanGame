class_name BreakProtect
extends RefCounted
## Romper protecciones (Cerco Dimensión, Golpe Umbrío, Amago): quita Protección y compañía al objetivo.


const IDS: Array[StringName] = [&"protect", &"banefulbunker", &"spikyshield", &"kingsshield", &"silktrap",
	&"burningbulwark", &"obstruct", &"maxguard"]


static func apply(engine: BattleEngine, target: Battler) -> void:
	var broke := false
	for id: StringName in IDS:
		if target.has_volatile(id):
			engine.remove_volatile(target, id)
			broke = true
	for id: StringName in [&"wideguard", &"quickguard", &"craftyshield", &"matblock"]:
		if engine.has_side_condition(target.side, id):
			engine.remove_side_condition(target.side, id)
			broke = true
	if broke:
		engine.message(engine.tr("¡%s ha roto la protección!") % engine.name_of(target))
