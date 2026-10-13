class_name NewGameStory
extends RefCounted
## Consume la marca profesor de Moncloa sin editar la escena ni colocaciones ajenas.
static func apply(map: MapRoot) -> void:
	var cfg: Dictionary = JsonFile.read_dict("res://data/new_game_story.json").laboratory
	if String(map.get_map_id()) != str(cfg.map): return
	var marker := map.get_node_or_null("Spawns/" + str(cfg.professor_spawn)) as Node2D
	var entities := map.get_entities()
	if marker == null or entities == null or entities.has_node("ProfesorUnicoos"): return
	var professor := ProfessorNPC.new()
	professor.name = "ProfesorUnicoos"
	professor.position = marker.position
	entities.add_child(professor)
	professor.owner = map
