extends BattleEffect
## Lanzamiento: lanza su objeto. La potencia depende del objeto, que se pierde; algunos causan un
## estado (Llamasfera quema, Toxisfera envenena gravemente, Bola Luminosa paraliza, Flecha Venenosa
## envenena, Roca del Rey y Colmillo Agudo hacen retroceder) y las bayas se las come el objetivo.

const STATUS_ITEMS := {&"flameorb": &"brn", &"toxicorb": &"tox", &"lightball": &"par", &"poisonbarb": &"psn"}
const FLINCH_ITEMS: Array[StringName] = [&"kingsrock", &"razorfang"]


func on_try_move(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> bool:
	var item := user.pokemon.held_item
	if item == &"" or not DataDB.has_item(item) or int(DataDB.item(item).raw.get("fling_power", 0)) <= 0 or not engine.item_removable(user):
		engine.message(tr("¡Pero falló!"))
		return false
	user.set_meta(&"fling_item", item)
	return true


func base_power(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, _power: int) -> int:
	var item: StringName = user.get_meta(&"fling_item", &"")
	return int(DataDB.item(item).raw.get("fling_power", 10)) if DataDB.has_item(item) else 10


func on_prepare_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> void:
	var item: StringName = user.get_meta(&"fling_item", &"")
	if item != &"" and DataDB.has_item(item):
		engine.message(tr("¡%s ha lanzado su %s!") % [engine.name_of(user), DataDB.item(item).name])
		engine.consume_held_item(user)


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _damage: int) -> void:
	var item: StringName = user.get_meta(&"fling_item", &"")
	user.remove_meta(&"fling_item")
	if target.is_fainted() or item == &"":
		return
	if STATUS_ITEMS.has(item):
		engine.set_status(target, STATUS_ITEMS[item], user, false)
	elif item in FLINCH_ITEMS:
		target.volatiles[&"flinch"] = {}
	elif DataDB.has_item(item) and DataDB.item(item).pocket == &"berries":
		var berry := Effects.item(item)
		if berry == null:
			return
		var amount := berry.heal_amount(target)
		if amount > 0 and engine.heal(target, amount, &"item") > 0:
			engine.message(tr("¡%s ha recuperado PS!") % engine.name_of(target))
		if target.pokemon.status != &"" and berry.cures_status(target.pokemon.status):
			engine.cure_status(target)


func on_miss(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> void:
	user.remove_meta(&"fling_item")
