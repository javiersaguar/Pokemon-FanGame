extends StoryEvent
## Ayuso al fondo de la Real Casa de Correos (docs/DECISIONES_JAVIER_2026-10-13.md §3 y
## DECISIONES_JAVIER_2026-10-14.md): cuando llegas a su despacho, tras ganar a los concejales, a Almeida,
## a Rajoy y a Casado, te sube a la terraza de su ático de Chamberí, donde se combate por la medalla.


func run() -> void:
	if GameState.has_badge(&"medalla_libertad"):
		await Dialogue.say("¡Ya tienes mi medalla! Vuelve cuando quieras a tomar una caña. Invitas tú, que eso también es libertad.", "Ayuso")
		return
	await Dialogue.say("Has pasado por mis concejales, por el alcalde, por Mariano y por Pablo. Eso en mi partido se llama hacer carrera.", "Ayuso")
	await Dialogue.say("Pero aquí no combato: hay cámaras. Sube conmigo a mi ático de Chamberí, que desde la terraza se ve todo Madrid.", "Ayuso")
	await Cutscene.teleport(&"madrid/atico_ayuso", &"default")
