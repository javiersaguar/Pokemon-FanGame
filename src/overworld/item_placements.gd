class_name ItemPlacements
extends RefCounted
## Lista de objetos colocados en los mapas (regla R.2): {placement_id: item_id},
## con placement_id = "<map_id>/<nodo>" (ItemBall.placement_id()). La usa el
## randomizer (DataDB.item_placements()). Se regenera con
## maps/_tools/build_item_placements.gd y un test comprueba que está al día.

const OUTPUT := "res://data/item_placements.json"


## Recorre todos los mapas y devuelve {placement_id: item_id}, ordenado.
static func scan() -> Dictionary:
	var out := {}
	var rewards := JsonFile.read_dict("res://data/npc_rewards.json")
	for map_id: StringName in MapRoot.list_all():
		var scene := load(MapRoot.path_from_id(map_id)) as PackedScene
		if scene == null:
			continue
		var root := scene.instantiate()
		for node: Node in _descendants(root):
			if node is ItemBall:
				var ball := node as ItemBall
				out["%s/%s" % [map_id, ball.name]] = String(ball.item_id)
			elif node is NPC and node.event != null and node.event.resource_path == "res://src/events/common/npc_reward_event.gd":
				var cfg: Dictionary = rewards.get(str(node.event_params.get("reward_id","")),{})
				var placement := "%s/%s" % [map_id,node.name]
				var item := StringName(cfg.get("item",""))
				if str(cfg.get("placement","")) != placement or not DataDB.has_item(item):
					push_error("Recompensa de NPC inválida: %s." % placement)
					continue
				out[placement] = String(item)
		root.free()
	var keys := out.keys()
	keys.sort()
	var sorted := {}
	for key: String in keys:
		sorted[key] = out[key]
	return sorted


static func to_json(placements: Dictionary) -> String:
	return JSON.stringify(placements, "\t", true) + "\n"


static func _descendants(node: Node) -> Array[Node]:
	var out: Array[Node] = []
	for child: Node in node.get_children():
		out.append(child)
		out.append_array(_descendants(child))
	return out
