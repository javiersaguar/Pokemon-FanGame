@tool
extends MapSign
## Expositor examinable: descripción y precio reales, compra en la caja.
@export var shop_id: StringName
func interact(player: Player) -> void:
	if player.facing != Vector2i.UP or player.tile_position() != tile_position()+Vector2i.DOWN: return
	var titles := PackedStringArray()
	var notes := PackedStringArray()
	for id: StringName in ShopTransactions.stock(shop_id):
		var item := DataDB.item(id)
		titles.append("%s / %d ₽" % [item.name,ShopTransactions.price(shop_id,id)])
		notes.append(item.description+"
Compra en la caja. C/Start desplaza la descripción.")
	if not titles.is_empty(): await ChoiceScreen.pick("Expositor / consulta",titles,notes)
