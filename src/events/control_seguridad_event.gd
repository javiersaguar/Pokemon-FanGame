extends StoryEvent
## El control de seguridad del aeropuerto (docs/mundo/region.md: «chiste con los líquidos»). Salta al
## pasar por el arco (Trigger STEP de playa_del_ingles/aeropuerto y vigo/aeropuerto). La primera vez,
## la escena entera; después, solo un aviso. Parámetros: flag (la de «ya pasaste»), guardia (quién habla).


func run() -> void:
	var guard := str(param("guardia", "Guardia Civil"))
	var seen := StringName(str(param("flag", "control_seguridad_visto")))
	if GameState.flag(seen):
		await Dialogue.say("Bandeja, cinturón, móvil y Poké Balls. Que pase el siguiente.", guard)
		return
	await Dialogue.say("Alto. Control de seguridad. Deje las Poké Balls en la bandeja, el cinturón también y el móvil aparte.", guard)
	if await Dialogue.ask_yes_no("¿Lleva líquidos de más de cien mililitros?", guard):
		await Dialogue.say("Pues o se los bebe aquí delante o se quedan en España. Bueno, en el otro trozo de España.", guard)
	else:
		await Dialogue.say("¿Y esas Pociones de la mochila? Son líquidos. Esto va a la papelera con el champú de los guiris.", guard)
		await Dialogue.say("...Que es broma. Son medicinas. Pero la próxima vez, en bolsita transparente.", guard)
	await Cutscene.shake(2.0, 0.2)
	await Dialogue.say("¡PIIIIP! Ha pitado el arco.")
	await Dialogue.say("Será la hebilla. O el Pokémon de acero. Pase, pase, que hay cola hasta la Guardia Civil de Tráfico.", guard)
	GameState.set_flag(seen)
