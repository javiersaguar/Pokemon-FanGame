extends StoryEvent
## Ayuso en el hospital Quirón (docs/DECISIONES_JAVIER_2026-10-13.md §3): hasta ganar a los tres
## enfermeros no te deja retarla; después te lleva a la terraza de su ático en Chamberí, donde se
## combate el gimnasio 1 (allí la coloca data/personajes_en_el_mapa.json con el flag de abajo).

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
	await Dialogue.say("Pero en un hospital no se combate. Ven a mi ático, que desde la terraza se ve todo Madrid. Y lo que ha hecho mal el Gobierno.", "Ayuso")
	GameState.set_flag(OPEN_FLAG)
	await Cutscene.teleport(&"madrid/atico_ayuso", &"default")
