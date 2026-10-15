extends StoryEvent
## Vuelo libre (docs/mundo/region.md: «Las Palmas → Vigo, y luego vuelo libre»). El mostrador de vuelos
## nacionales de las terminales (playa_del_ingles/aeropuerto y vigo/aeropuerto, pintadas por
## maps/_pintura/pintar_transportes.gd): después del primer vuelo (flag "vuelo_libre", que pone el viaje
## del avión al aterrizar) lleva a cualquier ciudad o pueblo ya visitado de data/world.json →
## field.flight_destinations (los lugares de data/region.json) y aterriza en su llegada (aparición).
## No hace falta la herramienta de Vuelo: es un avión de línea. Parámetros: ciudad (id del destino donde
## está la terminal, para no ofrecerlo) y hablante. PENDIENTE JAVIER: precio y qué ciudades tienen aeropuerto.


func run() -> void:
	var speaker := str(param("hablante", "Vuelos nacionales"))
	if not GameState.flag(&"vuelo_libre"):
		await Dialogue.say("Vuelos nacionales. Hoy solo sale el vuelo de la puerta de embarque, por la izquierda y pasando el control.", speaker)
		await Dialogue.say("Cuando hayas volado una vez, te llevo a cualquier ciudad en la que ya hayas estado.", speaker)
		return
	var here := str(param("ciudad", ""))
	var options: Array[Dictionary] = []
	for destination: Dictionary in WorldTravel.destinations():
		if str(destination.get("id", "")) != here:
			options.append(destination)
	if options.is_empty():
		await Dialogue.say("No has estado en ninguna otra ciudad. Viaja un poco y vuelve, que aquí no vendemos vuelos a ciegas.", speaker)
		return
	var labels := PackedStringArray()
	for destination: Dictionary in options:
		labels.append(str(destination.get("name", destination.get("id", ""))))
	var index := await ChoiceScreen.pick("Vuelos nacionales", labels)
	if index < 0 or index >= options.size():
		await Dialogue.say("Vuelva cuando quiera. El Falcon no espera a nadie; nosotros, sí.", speaker)
		return
	var target: Dictionary = options[index]
	if not await Dialogue.ask_yes_no("¿Volar a %s?" % str(target.get("name", target.get("id", ""))), speaker):
		return
	await Dialogue.say("Embarque inmediato. No se preocupe por el control: al vuelo nacional se pasa con una sonrisa.", speaker)
	await Cutscene.teleport(StringName(str(target.get("map", ""))), StringName(str(target.get("spawn", "default"))))
	await Dialogue.say("Bienvenido a %s. Hora local: la misma. Retraso: el de siempre." % str(target.get("name", "")), "Comandante")
