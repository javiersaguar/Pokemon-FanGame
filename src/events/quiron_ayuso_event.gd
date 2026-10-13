extends StoryEvent
## Ayuso en el hospital Quirón (docs/DECISIONES_JAVIER_2026-10-13.md §3): hasta ganar a los tres
## enfermeros no te da paso; después abre el gimnasio 1, la Real Casa de Correos (flag de abajo). Al
## fondo de sus salas te sube a la terraza de su ático (src/events/gym1_ayuso_event.gd), donde la
## coloca data/personajes_en_el_mapa.json.

const NURSES: Array[StringName] = [&"quiron_enfermera_1", &"quiron_enfermero_2", &"quiron_enfermera_3"]
const OPEN_FLAG := &"quiron_superado"


func run() -> void:
	if GameState.has_badge(&"medalla_libertad"):
		await Dialogue.say("¡Ya tienes mi medalla! La libertad no se regala, pero a ti te la he dado. Vuelve cuando quieras a tomar una caña.", "Ayuso")
		return
	for nurse: StringName in NURSES:
		if not GameState.flag(StringName(TrainerNPC.DEFEATED_FLAG % nurse)):
			await Dialogue.say("Estoy de visita en el Quirón: la sanidad madrileña es la mejor del mundo. Si quieres retarme, gana antes a mis enfermeros. Todos.", "Ayuso")
			return
	await Dialogue.say("Has ganado a todos mis enfermeros. Eso aquí se llama colaboración público-privada.", "Ayuso")
	await Dialogue.say("Pero en un hospital no se combate. Te espero en la Real Casa de Correos, en la Puerta del Sol: ya he avisado de que te dejen pasar.", "Ayuso")
	await Dialogue.say("Si llegas hasta mi despacho, subimos a mi ático. Antes tendrás que saludar a unos compañeros de partido.", "Ayuso")
	GameState.set_flag(OPEN_FLAG)
