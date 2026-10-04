extends StoryEvent
## Evento de la sala de pruebas: salta una vez al pisar su disparador.


func run() -> void:
	await Cutscene.emote(player, "!")
	await Dialogue.say("Has pisado un disparador de prueba. Solo salta una vez.")
	var back: Array[Vector2i] = [Vector2i.DOWN]
	await Cutscene.walk(player, back)
