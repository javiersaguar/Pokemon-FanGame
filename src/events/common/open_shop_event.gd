extends StoryEvent
## Dependiente de una tienda (Fase 8.5): abre la tienda de data/shops.json.
## params: shop_id (StringName, id de la tienda).


func run() -> void:
	var clerk := source_entity() as NPC
	var shop_id := StringName(param("shop_id", ""))
	await Dialogue.say("¡Hola! ¿En qué puedo ayudarte?", clerk)
	var screen := GlobalClasses.find(&"ShopScreen")
	if screen == null or not GlobalClasses.has_function(screen, &"open"):
		push_warning("open_shop_event: todavía no existe ShopScreen (Agente 3).")
		return
	if not DataDB.has_shop(shop_id):
		push_error("open_shop_event: no existe la tienda '%s'." % shop_id)
		return
	await screen.call(&"open", shop_id)
	await Dialogue.say("¡Vuelve cuando quieras!", clerk)
