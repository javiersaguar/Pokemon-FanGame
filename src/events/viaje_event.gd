extends StoryEvent
## El viaje en ferry o en avión (docs/mundo/region.md, «Transportes»). Salta al entrar en el barco o en
## el avión (Trigger ON_ENTER de maps/transporte/*): aviso de salida, el trayecto (fundido, y
## turbulencias si es avión) y aviso de llegada. Después se baja por la puerta del mapa, que lleva al
## destino. Lo pinta maps/_pintura/pintar_transportes.gd con estos parámetros:
##   hablante: quién da los avisos ("Megafonía", "Comandante"...)
##   salida, llegada: avisos antes y después del trayecto
##   trayecto: lo que se ve mientras dura (fundido en negro)
##   turbulencias: si tiembla la pantalla a mitad de viaje


func run() -> void:
	var speaker := str(param("hablante", "Megafonía"))
	for line: Variant in param("salida", []):
		await Dialogue.say(str(line), speaker)
	await Cutscene.fade_out(0.6)
	await Cutscene.wait(0.8)
	await Cutscene.fade_in(0.6)
	if bool(param("turbulencias", false)):
		await Cutscene.shake(4.0, 0.6)
	for line: Variant in param("trayecto", []):
		await Dialogue.say(str(line))
	for line: Variant in param("llegada", []):
		await Dialogue.say(str(line), speaker)
