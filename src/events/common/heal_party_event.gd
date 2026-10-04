extends StoryEvent
## Enfermera del Centro Pokémon (Fase 8.5): cura al equipo y fija el punto de
## reaparición. Se pone como `event` del NPC de la enfermera.
## params: spawn (StringName, el spawn delante del mostrador; por defecto "default").


func run() -> void:
	var nurse := source_entity() as Character
	await Dialogue.say("¡Hola! Te damos la bienvenida al Centro Pokémon.", nurse)
	if not await Dialogue.ask_yes_no("¿Quieres que cure a tus Pokémon?", nurse):
		await Dialogue.say("¡Esperamos volver a verte!", nurse)
		return
	await Dialogue.say("Vale. Dame tus Pokémon un momento.", nurse)
	if nurse:
		nurse.face(Vector2i.UP)
	await Cutscene.wait(0.3)
	await Cutscene.jingle(&"heal")
	Cutscene.heal_party()
	GameState.set_healing_spot(SceneManager.current_map.get_map_id(), StringName(param("spawn", "default")))
	if nurse and is_instance_valid(player):
		nurse.face_towards(player)
	await Dialogue.say("¡Ya está! Tus Pokémon están en plena forma.", nurse)
	await Dialogue.say("¡Esperamos volver a verte!", nurse)
