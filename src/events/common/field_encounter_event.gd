class_name FieldEncounterEvent
extends StoryEvent
func run() -> void:
	if map == null or player == null:
		return
	var kind := StringName(param("method", "headbutt"))
	var tile := player.tile_position() + player.facing
	await FieldEncounters.start(map, kind, tile)
