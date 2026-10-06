class_name ShopTransactions
extends RefCounted

static func stock(shop_id: StringName) -> Array[StringName]:
	var out: Array[StringName] = []
	if not DataDB.has_shop(shop_id): return out
	for tier: Dictionary in DataDB.shop(shop_id).get("stock", []):
		if int(tier.get("badges", 0)) <= GameState.badges.size():
			for item: String in tier.get("items", []):
				if DataDB.has_item(StringName(item)) and StringName(item) not in out: out.append(StringName(item))
	return out

static func price(shop_id: StringName, item: StringName) -> int:
	if not DataDB.has_shop(shop_id) or not DataDB.has_item(item): return 0
	return maxi(0, int(DataDB.shop(shop_id).get("prices", {}).get(String(item), DataDB.item(item).price)))

static func sale_price(item: StringName) -> int:
	if not DataDB.has_item(item) or DataDB.item(item).is_key_item(): return 0
	return maxi(0, floori(DataDB.item(item).price * DataDB.shop_sell_ratio()))

static func buy(shop_id: StringName, item: StringName, quantity: int) -> Error:
	if quantity <= 0 or quantity > Bag.MAX_COUNT or item not in stock(shop_id): return ERR_INVALID_PARAMETER
	var unit := price(shop_id, item)
	if unit <= 0: return ERR_UNAVAILABLE
	var bag := GameState.bag as Bag
	if bag == null or bag.count(item) + quantity > Bag.MAX_COUNT: return ERR_OUT_OF_MEMORY
	var cost := unit * quantity
	if GameState.money < cost: return ERR_UNAVAILABLE
	if not GameState.spend_money(cost): return ERR_UNAVAILABLE
	bag.add(item, quantity)
	return OK

static func sell(item: StringName, quantity: int) -> Error:
	var bag := GameState.bag as Bag
	if quantity <= 0 or bag == null or not bag.has(item, quantity): return ERR_INVALID_PARAMETER
	var unit := sale_price(item)
	if unit <= 0 or GameState.money + unit * quantity > GameState.max_money(): return ERR_UNAVAILABLE
	bag.remove(item, quantity)
	GameState.add_money(unit * quantity)
	return OK
