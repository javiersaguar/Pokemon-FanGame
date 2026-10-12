class_name ShopScreen
extends MenuScreen
var shop_id: StringName
var _money: Label

static func open(id: StringName) -> void:
	if not DataDB.has_shop(id): return
	var screen := ShopScreen.new()
	screen.shop_id = id
	SceneManager.push_menu(screen)
	await screen.closed
	SceneManager.pop_menu(screen)

func _ready() -> void:
	heading.text = "Tienda"
	panel(Rect2(14, 35, 228, 27))
	_money = label("", Rect2(24, 40, 208, 18), Color("382a38"))
	menu = make_menu(["Comprar", "Vender", "Salir"], Rect2(40, 78, 176, 75))
	_update_money()
	run.call_deferred()

func _update_money() -> void:
	_money.text = "Dinero: %d ₽" % GameState.money

func run() -> void:
	while is_inside_tree():
		var action := await menu.choose()
		if action < 0 or action == 2:
			closed.emit()
			return
		while true:
			var ids: Array[StringName] = []
			var title := "Comprar"
			if action == 0:
				ids = ShopTransactions.stock(shop_id)
			else:
				var pockets := PackedStringArray()
				var pocket_ids: Array[StringName] = []
				for i: int in BagScreen.POCKETS.size():
					var pocket: StringName = BagScreen.POCKETS[i]
					var any := false
					for id: StringName in GameState.bag.all_items():
						if DataDB.item(id).pocket == pocket and ShopTransactions.sale_price(id) > 0:
							any = true
							break
					if any:
						pockets.append(BagScreen.NAMES[i])
						pocket_ids.append(pocket)
				if pockets.is_empty():
					await Dialogue.say("No tienes nada que vender.")
					break
				pockets.append("Volver")
				var pocket_pick := await ChoiceScreen.pick("Vender", pockets)
				if pocket_pick < 0 or pocket_pick >= pocket_ids.size():
					break
				for id: StringName in GameState.bag.all_items():
					if DataDB.item(id).pocket == pocket_ids[pocket_pick] and ShopTransactions.sale_price(id) > 0:
						ids.append(id)
				title = "Vender / %s" % pockets[pocket_pick]
			var item := await BagScreen.choose_from(ids, title, action == 0, shop_id)
			if item == &"": break
			var unit := ShopTransactions.price(shop_id, item) if action == 0 else ShopTransactions.sale_price(item)
			var limit := mini(Bag.MAX_COUNT - GameState.bag.count(item), GameState.money / unit) if action == 0 else mini(GameState.bag.count(item), (GameState.max_money() - GameState.money) / unit)
			if limit < 1:
				await Dialogue.say("No puedes comprar más." if action == 0 else "No puedes vender más.")
				continue
			var count := await QuantityPicker.pick(DataDB.item(item).name, limit, unit)
			if count > 0 and await Dialogue.ask_yes_no("¿%s %d unidades por %d ₽?" % ["Comprar" if action == 0 else "Vender", count, count * unit]):
				var error := ShopTransactions.buy(shop_id, item, count) if action == 0 else ShopTransactions.sell(item, count)
				await Dialogue.say("Gracias. ¡Vuelve cuando quieras!" if error == OK else "No se pudo completar la operación.")
			_update_money()
