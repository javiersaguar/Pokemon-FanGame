extends RefCounted
## Objetos equipados de combate, segunda parte de la fase 9.5 (los de la primera siguen en
## item_catalog.gd). Valores de la 9.ª generación, como en Showdown.

const TYPE_BOOST := {
	&"charcoal": &"fire", &"mysticwater": &"water", &"miracleseed": &"grass", &"magnet": &"electric",
	&"nevermeltice": &"ice", &"blackbelt": &"fighting", &"poisonbarb": &"poison", &"softsand": &"ground",
	&"sharpbeak": &"flying", &"twistedspoon": &"psychic", &"silverpowder": &"bug", &"hardstone": &"rock",
	&"spelltag": &"ghost", &"dragonfang": &"dragon", &"blackglasses": &"dark", &"metalcoat": &"steel",
	&"silkscarf": &"normal", &"fairyfeather": &"fairy", &"flameplate": &"fire", &"splashplate": &"water",
	&"meadowplate": &"grass", &"zapplate": &"electric", &"icicleplate": &"ice", &"fistplate": &"fighting",
	&"toxicplate": &"poison", &"earthplate": &"ground", &"skyplate": &"flying", &"mindplate": &"psychic",
	&"insectplate": &"bug", &"stoneplate": &"rock", &"spookyplate": &"ghost", &"dracoplate": &"dragon",
	&"dreadplate": &"dark", &"ironplate": &"steel", &"pixieplate": &"fairy", &"seaincense": &"water",
	&"waveincense": &"water", &"oddincense": &"psychic", &"rockincense": &"rock", &"roseincense": &"grass",
}
## Bayas de apuro que suben una característica (a 1/4 de los PS; con Gula, a la mitad).
const PINCH_STAT := {&"liechiberry": &"atk", &"ganlonberry": &"def", &"salacberry": &"spe", &"petayaberry": &"spa", &"apicotberry": &"spd"}
## Un golpe de ese tipo sube esa característica y se gasta.
const HIT_BOOST := {&"absorbbulb": [&"water", &"spa"], &"cellbattery": [&"electric", &"atk"], &"snowball": [&"ice", &"atk"], &"luminousmoss": [&"water", &"spd"]}
const SEEDS := {&"electricseed": [&"electricterrain", &"def"], &"grassyseed": [&"grassyterrain", &"def"], &"mistyseed": [&"mistyterrain", &"spd"], &"psychicseed": [&"psychicterrain", &"spd"]}
const OTHERS: Array[StringName] = [
	&"muscleband", &"wiseglasses", &"punchingglove", &"expertbelt", &"metronome", &"eviolite", &"ironball",
	&"widelens", &"zoomlens", &"brightpowder", &"scopelens", &"razorclaw", &"leek", &"luckypunch", &"quickclaw",
	&"laggingtail", &"fullincense", &"kingsrock", &"razorfang", &"shellbell", &"weaknesspolicy", &"redcard",
	&"ejectbutton", &"airballoon", &"keeberry", &"marangaberry", &"jabocaberry", &"rowapberry", &"enigmaberry",
	&"stickybarb", &"safetygoggles", &"heavydutyboots", &"focusband", &"blacksludge", &"toxicorb", &"flameorb",
	&"whiteherb", &"mentalherb", &"ejectpack", &"throatspray", &"blunderpolicy", &"roomservice", &"covertcloak",
	&"clearamulet", &"boosterenergy", &"starfberry", &"lansatberry", &"micleberry", &"custapberry", &"leppaberry",
	&"lightclay", &"heatrock", &"damprock", &"smoothrock", &"icyrock", &"terrainextender", &"powerherb",
	&"bigroot", &"loadeddice", &"shedshell", &"protectivepads", &"utilityumbrella", &"bindingband", &"gripclaw",
	&"adrenalineorb", &"mirrorherb", &"abilityshield",
]


static func make(id: StringName) -> BattleEffect:
	if TYPE_BOOST.has(id) or PINCH_STAT.has(id) or HIT_BOOST.has(id) or SEEDS.has(id) or id in OTHERS:
		return HeldItem.new()
	return null


class HeldItem extends BattleEffect:
	func _name() -> String:
		return DataDB.item(id).name if DataDB.has_item(id) else String(id)


	func _use(engine: BattleEngine, b: Battler, text: String = "") -> void:
		if text != "":
			engine.message(tr(text) % [engine.name_of(b), _name()])
		engine.consume_held_item(b)


	func modify_base_power(_engine: BattleEngine, _user: Battler, _target: Battler, move: MoveData, power: int) -> int:
		if TYPE_BOOST.get(id, &"") == move.type:
			return DamageCalc.modify(power, 4915, 4096)
		match id:
			&"muscleband":
				if move.is_physical():
					return DamageCalc.modify(power, 4505, 4096)
			&"wiseglasses":
				if not move.is_physical() and not move.is_status():
					return DamageCalc.modify(power, 4505, 4096)
			&"punchingglove":
				if move.has_flag(&"punch"):
					return DamageCalc.modify(power, 4506, 4096)
		return power


	func damage_modifier(_engine: BattleEngine, user: Battler, target: Battler, move: MoveData, _crit: bool) -> float:
		if id == &"expertbelt" and DamageCalc.effectiveness(move, target) > 1.0:
			return 4915.0 / 4096.0
		if id == &"metronome":
			var state: Dictionary = user.volatiles.get(&"metronomeitem", {})
			if StringName(str(state.get("move", ""))) == move.id:
				return minf(2.0, 1.0 + 0.2 * int(state.get("count", 0)))
		return 1.0


	func stat_modifier(_engine: BattleEngine, battler: Battler, stat: StringName) -> float:
		if id == &"eviolite" and stat in [&"def", &"spd"] and not battler.pokemon.species().evolutions.is_empty():
			return 1.5
		return 1.0


	func modify_speed(_engine: BattleEngine, _battler: Battler, speed: int) -> int:
		return speed / 2 if id == &"ironball" else speed


	func modify_accuracy(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, accuracy: int) -> int:
		if id == &"widelens":
			return DamageCalc.modify(accuracy, 4505, 4096)
		if id == &"zoomlens" and target != null and target.moved_this_turn:
			return DamageCalc.modify(accuracy, 4915, 4096)
		if id == &"micleberry":
			return accuracy
		return accuracy


	func modify_incoming_accuracy(_engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, accuracy: int) -> int:
		return DamageCalc.modify(accuracy, 3686, 4096) if id == &"brightpowder" else accuracy


	func crit_bonus(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
		match id:
			&"scopelens", &"razorclaw":
				return 1
			&"leek":
				return 2 if String(user.pokemon.species_id).begins_with("farfetchd") or user.pokemon.species_id == &"sirfetchd" else 0
			&"luckypunch":
				return 2 if user.pokemon.species_id == &"chansey" else 0
		return 0


	## Garra Rápida (20 %) y baya Chiri (a 1/4 de los PS): actúa primero dentro de su prioridad.
	func moves_first(engine: BattleEngine, b: Battler) -> bool:
		if id == &"quickclaw" and engine.rand_chance(&"quickclaw", 1, 5):
			engine.message(tr("¡%s actúa primero gracias a la Garra Rápida!") % engine.name_of(b))
			return true
		if id == &"custapberry" and _pinch(b):
			_use(engine, b, "¡%s actúa primero gracias a su %s!")
			return true
		return false


	func moves_last() -> bool:
		return id in [&"laggingtail", &"fullincense"]


	func _pinch(b: Battler) -> bool:
		var hp := b.pokemon.current_hp
		return hp > 0 and hp * (2 if b.ability == &"gluttony" else 4) <= b.pokemon.max_hp()


	func on_dealt_damage(engine: BattleEngine, user: Battler, target: Battler, move: MoveData, damage: int) -> void:
		match id:
			&"kingsrock", &"razorfang":
				var flinches := move.secondaries.any(func(s: Dictionary) -> bool: return str(s.get("volatile_status", "")) == "flinch")
				if not flinches and not target.is_fainted() and not target.moved_this_turn and engine.rand_chance(&"item", 1, 10):
					engine.add_volatile(target, &"flinch", user)
			&"shellbell":
				if not user.is_fainted() and engine.heal(user, maxi(1, damage / 8), &"item") > 0:
					engine.message(tr("¡%s ha recuperado PS con el Cascabel Concha!") % engine.name_of(user))


	func on_damaged(engine: BattleEngine, battler: Battler, user: Battler, move: MoveData) -> void:
		if move == null:
			return
		if id == &"airballoon":
			_use(engine, battler, "¡El %2$s de %1$s ha explotado!")
			return
		if battler.is_fainted():
			return
		var effectiveness := DamageCalc.effectiveness(move, battler)
		match id:
			&"weaknesspolicy":
				if effectiveness > 1.0:
					_use(engine, battler, "¡%s usa su %s!")
					engine.boost(battler, {&"atk": 2, &"spa": 2}, true)
			&"keeberry", &"marangaberry":
				if (id == &"keeberry") == move.is_physical():
					_use(engine, battler, "¡%s se come su %s!")
					engine.boost(battler, {&"def" if id == &"keeberry" else &"spd": 1}, true)
			&"jabocaberry", &"rowapberry":
				if user != null and not user.is_fainted() and (id == &"jabocaberry") == move.is_physical():
					_use(engine, battler, "¡%s se come su %s!")
					engine.deal_damage(user, maxi(1, user.pokemon.max_hp() / 8), &"item")
			&"enigmaberry":
				if effectiveness > 1.0:
					_use(engine, battler, "¡%s se come su %s!")
					engine.heal(battler, maxi(1, battler.pokemon.max_hp() / 4), &"item")
			&"redcard":
				if user != null and not user.is_fainted() and user.side != battler.side:
					_use(engine, battler, "¡%s muestra su %s!")
					engine.force_switch(user)
			&"ejectbutton":
				_use(engine, battler, "¡%s sale gracias a su %s!")
				engine.request_switch(battler, &"ejectbutton")
			&"stickybarb":
				if user != null and not user.is_fainted() and user.pokemon.held_item == &"" and engine.makes_contact(user, move):
					engine.set_held_item(battler, &"")
					engine.set_held_item(user, &"stickybarb")
		if HIT_BOOST.has(id) and move.type == HIT_BOOST[id][0]:
			_use(engine, battler, "¡%s usa su %s!")
			engine.boost(battler, {HIT_BOOST[id][1]: 1}, true)


	func immune_to(engine: BattleEngine, target: Battler, _state: Dictionary, move: MoveData) -> bool:
		if id == &"airballoon":
			return move.type == &"ground" and not move.is_status() and not engine.is_grounded(target) and move.id != &"thousandarrows"
		if id == &"safetygoggles":
			return move.has_flag(&"powder")
		return false


	func modify_damage_taken(engine: BattleEngine, b: Battler, amount: int, source: StringName, _move: MoveData) -> int:
		match id:
			&"focusband":
				if source == &"move" and amount >= b.pokemon.current_hp and b.pokemon.current_hp > 0 and engine.rand_chance(&"item", 1, 10):
					engine.message(tr("¡%s ha aguantado gracias a la Cinta Focus!") % engine.name_of(b))
					return b.pokemon.current_hp - 1
			&"safetygoggles":
				if source in [&"sandstorm", &"hail"]:
					return 0
			&"heavydutyboots":
				if source in [&"stealthrock", &"spikes"]:
					return 0
		return amount


	func on_residual(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
		var b := holder as Battler
		if b == null or b.is_fainted():
			return
		var max_hp := b.pokemon.max_hp()
		match id:
			&"blacksludge":
				if b.has_type(&"poison"):
					if engine.heal(b, maxi(1, max_hp / 16), &"item") > 0:
						engine.message(tr("¡%s ha recuperado PS con el Lodo Negro!") % engine.name_of(b))
				else:
					engine.deal_damage(b, maxi(1, max_hp / 8), &"item")
					engine.message(tr("¡%s se ha hecho daño con el Lodo Negro!") % engine.name_of(b))
			&"toxicorb", &"flameorb":
				if b.pokemon.status == &"":
					engine.set_status(b, &"tox" if id == &"toxicorb" else &"brn", b)
			&"stickybarb":
				engine.deal_damage(b, maxi(1, max_hp / 8), &"item")
			&"mentalherb":
				for v: StringName in [&"attract", &"taunt", &"encore", &"torment", &"disable", &"healblock"]:
					if b.has_volatile(v):
						engine.remove_volatile(b, v)
						if b.pokemon.held_item == id:
							_use(engine, b, "¡%s se ha curado con su %s!")
			_:
				pass


	## Semillas al empezar su campo y Servicio Habitación al empezar el Espacio Raro (y al entrar con ellos).
	func on_field_change(engine: BattleEngine, b: Battler) -> void:
		if b.pokemon.held_item != id:
			return
		if SEEDS.has(id) and engine.terrain() == SEEDS[id][0]:
			_use(engine, b, "¡%s usa su %s!")
			engine.boost(b, {SEEDS[id][1]: 1}, true)
		elif id == &"roomservice" and engine.trick_room():
			_use(engine, b, "¡%s usa su %s!")
			engine.boost(b, {&"spe": -1}, true)


	func on_switch_in(engine: BattleEngine, battler: Battler, _state: Dictionary) -> void:
		if SEEDS.has(id) or id == &"roomservice":
			on_field_change(engine, battler)
		elif id == &"boosterenergy" and battler.ability in [&"protosynthesis", &"quarkdrive"] \
				and not (battler.ability == &"protosynthesis" and engine.weather() == &"sunnyday") \
				and not (battler.ability == &"quarkdrive" and engine.terrain() == &"electricterrain"):
			engine.add_volatile(battler, &"boosterenergy")
			_use(engine, battler, "¡%s usa su %s!")
		elif id == &"airballoon":
			engine.message(tr("¡%s flota en el aire con su Globo Helio!") % engine.name_of(battler))


	## Hierba Blanca y Mochila Escape: alguna característica ha bajado (por lo que sea).
	func after_stat_drop(engine: BattleEngine, b: Battler) -> void:
		if id == &"whiteherb":
			for stat: StringName in b.boosts:
				if b.boosts[stat] < 0:
					b.boosts[stat] = 0
			_use(engine, b, "¡%s ha restaurado sus características con su %s!")
		elif id == &"ejectpack" and engine.request_switch(b, &"ejectpack"):
			_use(engine, b, "¡%s sale gracias a su %s!")


	func on_after_move(engine: BattleEngine, user: Battler, move: MoveData, hit: bool) -> void:
		match id:
			&"metronome":
				var state: Dictionary = user.volatiles.get(&"metronomeitem", {})
				var same := StringName(str(state.get("move", ""))) == move.id and hit
				user.volatiles[&"metronomeitem"] = {"move": String(move.id), "count": int(state.get("count", 0)) + 1 if same else (1 if hit else 0)}
			&"throatspray":
				if hit and move.has_flag(&"sound"):
					_use(engine, user, "¡%s usa su %s!")
					engine.boost(user, {&"spa": 1}, true)
			&"blunderpolicy":
				if not hit and move.accuracy > 0 and move.ohko == &"":
					_use(engine, user, "¡%s usa su %s!")
					engine.boost(user, {&"spe": 2}, true)
			&"leppaberry":
				for slot: MoveSlot in user.pokemon.moves:
					if slot.pp == 0:
						slot.pp = mini(slot.max_pp(), 10)
						_use(engine, user, "¡%s ha recuperado PP con su %s!")
						break


	## Bayas de apuro que no curan (Lichi, Gonlan, Aslac, Yapati, Albaricoque, Arabol, Zonlan, Lagro).
	func on_pinch(engine: BattleEngine, b: Battler) -> bool:
		if not _pinch(b):
			return false
		return on_eat(engine, b)


	func on_eat(engine: BattleEngine, b: Battler) -> bool:
		if PINCH_STAT.has(id):
			engine.message(tr("¡%s se come su %s!") % [engine.name_of(b), _name()])
			engine.boost(b, {PINCH_STAT[id]: 1}, true)
			return true
		match id:
			&"starfberry":
				var stats: Array[StringName] = []
				for stat: StringName in [&"atk", &"def", &"spa", &"spd", &"spe"]:
					if b.boosts[stat] < 6:
						stats.append(stat)
				if stats.is_empty():
					return false
				engine.message(tr("¡%s se come su %s!") % [engine.name_of(b), _name()])
				engine.boost(b, {stats[engine.rand_int(&"item", 0, stats.size() - 1)]: 2}, true)
				return true
			&"lansatberry":
				engine.message(tr("¡%s se come su %s y se concentra!") % [engine.name_of(b), _name()])
				b.crit_stage += 2
				return true
			&"micleberry":
				engine.message(tr("¡%s se come su %s!") % [engine.name_of(b), _name()])
				engine.add_volatile(b, &"micleberry")
				return true
		return false


	func eats_at(battler: Battler) -> bool:
		return (PINCH_STAT.has(id) or id in [&"starfberry", &"lansatberry", &"micleberry"]) and _pinch(battler)


	func blocks_secondary() -> bool:
		return id == &"covertcloak"


	func prevents_foe_drop() -> bool:
		return id == &"clearamulet"


	## Duración de lo que pone quien lo lleva (Refleluz, rocas del tiempo, Cubrecampos).
	func extends_condition(condition_id: StringName) -> bool:
		match id:
			&"lightclay":
				return condition_id in [&"reflect", &"lightscreen", &"auroraveil"]
			&"heatrock":
				return condition_id == &"sunnyday"
			&"damprock":
				return condition_id == &"raindance"
			&"smoothrock":
				return condition_id == &"sandstorm"
			&"icyrock":
				return condition_id == &"snow"
			&"terrainextender":
				return condition_id in [&"electricterrain", &"grassyterrain", &"mistyterrain", &"psychicterrain"]
		return false
