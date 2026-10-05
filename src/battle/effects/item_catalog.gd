extends RefCounted
## Objetos equipados de combate de la fase 9.5: bayas, Restos, Banda Focus, Elección,
## Vidasfera, Chaleco Asalto y Casco Dentado.


static func make(id: StringName) -> BattleEffect:
	if id in CHOICE or id in HEAL_BERRIES or id in STATUS_BERRIES or id in RESIST_BERRIES \
			or id in [&"leftovers", &"focussash", &"lifeorb", &"assaultvest", &"rockyhelmet", &"lumberry"]:
		return ItemBehavior.new()
	return null


const CHOICE: Array[StringName] = [&"choiceband", &"choicespecs", &"choicescarf"]
const HEAL_BERRIES: Array[StringName] = [&"oranberry", &"sitrusberry", &"figyberry", &"wikiberry", &"magoberry", &"aguavberry", &"iapapaberry"]
const STATUS_BERRIES := {
	&"chestoberry": &"slp", &"pechaberry": &"psn", &"rawstberry": &"brn",
	&"aspearberry": &"frz", &"cheriberry": &"par",
}
const RESIST_BERRIES := {
	&"occaberry": &"fire", &"passhoberry": &"water", &"wacanberry": &"electric", &"rindoberry": &"grass",
	&"yacheberry": &"ice", &"chopleberry": &"fighting", &"kebiaberry": &"poison", &"shucaberry": &"ground",
	&"cobaberry": &"flying", &"payapaberry": &"psychic", &"tangaberry": &"bug", &"chartiberry": &"rock",
	&"kasibberry": &"ghost", &"habanberry": &"dragon", &"colburberry": &"dark", &"babiriberry": &"steel",
	&"chilanberry": &"normal",
}
const PINCH_FLAVOR := {
	&"figyberry": &"atk", &"wikiberry": &"spa", &"magoberry": &"spe", &"aguavberry": &"spd", &"iapapaberry": &"def",
}


class ItemBehavior extends BattleEffect:
	func stat_modifier(_engine: BattleEngine, _battler: Battler, stat: StringName) -> float:
		if id == &"choiceband" and stat == &"atk":
			return 1.5
		if id == &"choicespecs" and stat == &"spa":
			return 1.5
		if id == &"assaultvest" and stat == &"spd":
			return 1.5
		return 1.0


	func modify_speed(_engine: BattleEngine, _battler: Battler, speed: int) -> int:
		if id == &"choicescarf":
			return DamageCalc.modify(speed, 1.5)
		return speed


	func damage_modifier(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, _crit: bool) -> float:
		if id == &"lifeorb":
			return 1.3
		return 1.0


	func on_residual(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
		if id != &"leftovers":
			return
		var battler := holder as Battler
		if battler == null or battler.is_fainted() or battler.pokemon.current_hp >= battler.pokemon.max_hp():
			return
		if engine.heal(battler, maxi(1, battler.pokemon.max_hp() / 16), &"item") > 0:
			engine.message(tr("¡%s ha recuperado PS con Restos!") % engine.name_of(battler))


	func residual_order() -> int:
		return 5


	func on_damaged(engine: BattleEngine, battler: Battler, user: Battler, move: MoveData) -> void:
		if id != &"rockyhelmet" or user == null or user.is_fainted() or move == null or not move.has_flag(&"contact"):
			return
		engine.deal_damage(user, maxi(1, user.pokemon.max_hp() / 6), &"item")
		engine.message(tr("¡%s se ha hecho daño con el Casco Dentado!") % engine.name_of(user))


	## true si esta baya reduce el golpe supereficaz (o el de tipo Normal, la Chilan).
	func resists(move: MoveData, effectiveness: float) -> bool:
		var kind: StringName = RESIST_BERRIES.get(id, &"")
		if kind == &"":
			return false
		if kind == &"normal":
			return move.type == &"normal" and effectiveness > 0.0
		return move.type == kind and effectiveness > 1.0


	func cures_status(status: StringName) -> bool:
		if id == &"lumberry":
			return status != &""
		if id == &"pechaberry":
			return status == &"psn" or status == &"tox"
		return STATUS_BERRIES.get(id, &"") == status


	func cures_confusion() -> bool:
		return id == &"lumberry" or id == &"persimberry"


	func heal_amount(battler: Battler) -> int:
		match id:
			&"oranberry":
				return 10
			&"sitrusberry":
				return maxi(1, battler.pokemon.max_hp() / 4)
			&"figyberry", &"wikiberry", &"magoberry", &"aguavberry", &"iapapaberry":
				return maxi(1, battler.pokemon.max_hp() / 3)
		return 0


	func pinch_confuses(battler: Battler) -> bool:
		var flavor: StringName = PINCH_FLAVOR.get(id, &"")
		if flavor == &"" or battler.pokemon.nature == &"":
			return false
		var nature := DataDB.nature(battler.pokemon.nature)
		return nature.minus == flavor and nature.plus != flavor
