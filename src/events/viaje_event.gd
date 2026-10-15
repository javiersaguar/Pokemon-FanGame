extends StoryEvent
## El viaje en ferry, en avión o en AVE (docs/mundo/region.md, «Transportes»). Salta al entrar en el barco,
## el avión o el vagón (Trigger ON_ENTER de maps/transporte/*): aviso de salida, el trayecto (fundido, y
## turbulencias si es avión) y aviso de llegada. Después se baja por la puerta del mapa, que lleva al
## destino. Lo pinta maps/_pintura/pintar_transportes.gd con estos parámetros:
##   hablante: quién da los avisos ("Megafonía", "Comandante"...)
##   salida, llegada: avisos antes y después del trayecto
##   trayecto: lo que se ve mientras dura (fundido en negro)
##   turbulencias: si tiembla la pantalla a mitad de viaje
##   billete: objeto clave que pide el sobrecargo (el del ferry: "Ticket Barco", vale para todos los ferris);
##     si no lo tienes, te lo vende por `precio`, y si no lo compras vuelves a `vuelta` ([mapa, aparición]).
##   marca: flag que se activa al terminar el viaje (el primer vuelo abre el vuelo libre de los aeropuertos).
## PENDIENTE JAVIER: quién da el billete y su precio (propuesta: se compra al embarcar).


func run() -> void:
	var speaker := str(param("hablante", "Megafonía"))
	if not await _ticket():
		var back: Array = param("vuelta", [])
		if back.size() == 2:
			await Cutscene.teleport(StringName(str(back[0])), StringName(str(back[1])))
		return
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
	var mark := str(param("marca", ""))
	if mark != "":
		GameState.set_flag(StringName(mark))


## El sobrecargo pide el billete. Devuelve si se puede viajar.
func _ticket() -> bool:
	var ticket := StringName(str(param("billete", "")))
	if ticket == &"" or not DataDB.has_item(ticket):
		return true
	var crew := "Sobrecargo"
	var item_name := DataDB.item(ticket).name
	if GameState.bag.count(ticket) > 0:
		await Dialogue.say("%s, por favor... Correcto. Bienvenido a bordo." % item_name, crew)
		return true
	var price := int(param("precio", 0))
	await Dialogue.say("Alto ahí. Sin %s no se sube a ningún ferry, ni aunque seas de la tripulación del Falcon." % item_name, crew)
	if not await Dialogue.ask_yes_no("Te lo vendo aquí mismo por %d ₽ y te vale para todos los ferris. ¿Lo quieres?" % price, crew):
		await Dialogue.say("Pues a tierra. El mar no se va a ir a ningún sitio.", crew)
		return false
	if GameState.money < price:
		await Dialogue.say("No te llega. Esto no es el Cercanías: aquí se paga.", crew)
		return false
	GameState.money -= price
	await Cutscene.give_item(ticket, 1, true)
	await Dialogue.say("Guárdalo bien: es un objeto clave. Ahora sí, bienvenido a bordo.", crew)
	return true
