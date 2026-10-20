extends RefCounted
## Habilidades de las especies en uso, por familias (segunda parte de la fase 9.5). Mecánicas de la
## 9.ª generación contrastadas con Showdown y Bulbapedia. El motor llama los ganchos de BattleEffect
## (docs/contratos.md §8); lo que depende de reglas generales (Rompemoldes, Gas Reactivo, Nube Nueve,
## Indefenso, Encadenado, Experto, Potencia Bruta, Dicha...) está en el motor.

const IDS: Array[StringName] = [
	# Inmunidades y absorción.
	&"voltabsorb", &"waterabsorb", &"dryskin", &"eartheater", &"flashfire", &"lightningrod", &"stormdrain",
	&"motordrive", &"sapsipper", &"windrider", &"levitate", &"soundproof", &"bulletproof", &"overcoat",
	&"goodasgold", &"queenlymajesty", &"telepathy", &"damp", &"sturdy",
	# Estados y volátiles.
	&"limber", &"immunity", &"waterveil", &"magmaarmor", &"vitalspirit", &"thermalexchange", &"flowerveil",
	&"owntempo", &"oblivious", &"innerfocus", &"purifyingsalt", &"waterbubble",
	# Características.
	&"hugepower", &"purepower", &"marvelscale", &"grasspelt", &"flowergift", &"plus", &"minus",
	&"quickfeet", &"sandrush", &"slushrush", &"protosynthesis", &"quarkdrive", &"thickfat", &"heatproof",
	&"furcoat",
	# Potencia y daño.
	&"technician", &"ironfist", &"reckless", &"sheerforce", &"strongjaw", &"megalauncher", &"toughclaws",
	&"punkrock", &"sandforce", &"analytic", &"rivalry", &"stakeout", &"supremeoverlord", &"transistor",
	&"steelyspirit", &"rockypayload", &"pixilate", &"liquidvoice", &"adaptability", &"multiscale",
	&"fluffy", &"icescales", &"magicguard", &"rockhead", &"poisonheal", &"disguise", &"iceface",
	# Contacto y golpes recibidos.
	&"static", &"flamebody", &"poisonpoint", &"effectspore", &"cutecharm", &"roughskin", &"ironbarbs",
	&"gooey", &"lingeringaroma", &"pickpocket", &"aftermath", &"weakarmor", &"stamina", &"justified",
	&"steamengine", &"watercompaction", &"angerpoint", &"cursedbody", &"sandspit", &"windpower",
	&"innardsout", &"emergencyexit", &"gulpmissile", &"poisontouch", &"stench", &"magician",
	# Entrada al combate.
	&"drizzle", &"drought", &"sandstream", &"snowwarning", &"psychicsurge", &"grassysurge", &"pressure",
	&"moldbreaker", &"unnerve", &"anticipation", &"forewarn", &"download", &"trace", &"intrepidsword",
	&"costar", &"cloudnine", &"neutralizinggas", &"illusion", &"zerotohero", &"guarddog", &"schooling",
	&"stancechange", &"protean", &"libero",
	# Final del turno.
	&"speedboost", &"moody", &"icebody", &"hydration", &"harvest", &"healer", &"cudchew", &"pickup",
	&"naturalcure", &"regenerator", &"truant",
	# Prioridad, críticos, precisión y niveles.
	&"prankster", &"galewings", &"triage", &"stall", &"battlearmor", &"shellarmor", &"superluck",
	&"merciless", &"sandveil", &"snowcloak", &"illuminate", &"hypercutter", &"clearbody", &"whitesmoke",
	&"mirrorarmor", &"contrary", &"simple", &"defiant", &"competitive", &"unaware", &"noguard",
	&"scrappy", &"skilllink", &"serenegrace", &"steadfast", &"earlybird", &"synchronize",
	# Objetos, peso, atrapar, dobles y el resto.
	&"klutz", &"stickyhold", &"gluttony", &"cheekpouch", &"symbiosis", &"liquidooze", &"suctioncups",
	&"heavymetal", &"lightmetal", &"arenatrap", &"shadowtag", &"magnetpull", &"magicbounce", &"dancer",
	&"friendguard", &"propellertail",
]


static func make(id: StringName) -> BattleEffect:
	return Family.new() if id in IDS else null


class Family extends BattleEffect:
	## Absorbe un tipo: [tipo, qué hace]. «heal» cura 1/4; «flashfire» potencia el fuego; si no, sube esa característica.
	const ABSORB := {
		&"voltabsorb": [&"electric", &"heal"], &"waterabsorb": [&"water", &"heal"], &"dryskin": [&"water", &"heal"],
		&"eartheater": [&"ground", &"heal"], &"flashfire": [&"fire", &"flashfire"], &"lightningrod": [&"electric", &"spa"],
		&"stormdrain": [&"water", &"spa"], &"motordrive": [&"electric", &"spe"], &"sapsipper": [&"grass", &"atk"],
		&"windrider": [&"wind", &"atk"],
	}
	const STATUS_GUARD := {
		&"limber": [&"par"], &"immunity": [&"psn", &"tox"], &"waterveil": [&"brn"], &"waterbubble": [&"brn"],
		&"thermalexchange": [&"brn"], &"magmaarmor": [&"frz"], &"vitalspirit": [&"slp"],
		&"purifyingsalt": [&"par", &"psn", &"tox", &"brn", &"frz", &"slp"],
	}
	const EXPLOSIONS: Array[StringName] = [&"explosion", &"selfdestruct", &"mistyexplosion", &"mindblown"]
	const WEATHER_SETTERS := {&"drizzle": &"raindance", &"drought": &"sunnyday", &"sandstream": &"sandstorm", &"snowwarning": &"snow"}
	const TERRAIN_SETTERS := {&"psychicsurge": &"psychicterrain", &"grassysurge": &"grassyterrain"}
	const UNTRACEABLE: Array[StringName] = [&"trace", &"illusion", &"imposter", &"multitype", &"stancechange",
		&"schooling", &"disguise", &"zerotohero", &"neutralizinggas", &"powerofalchemy", &"receiver", &"flowergift",
		&"iceface", &"gulpmissile", &"commander", &"protosynthesis", &"quarkdrive"]
	static var _bouncing := false


	func _say(engine: BattleEngine, b: Battler, text: String) -> void:
		engine.message(tr(text) % engine.name_of(b))


	func _ability_name() -> String:
		return DataDB.ability(id).name if DataDB.has_ability(id) else String(id)


	# --- Inmunidades y absorción ---

	func immune_to(engine: BattleEngine, target: Battler, _state: Dictionary, move: MoveData) -> bool:
		var user: Battler = engine._move_user
		if ABSORB.has(id):
			var kind: StringName = ABSORB[id][0]
			return move.has_flag(&"wind") if kind == &"wind" else move.type == kind
		match id:
			&"levitate":
				return move.type == &"ground" and not move.is_status() and not engine.is_grounded(target) and move.id != &"thousandarrows"
			&"soundproof":
				return move.has_flag(&"sound")
			&"bulletproof":
				return move.has_flag(&"bullet")
			&"overcoat":
				return move.has_flag(&"powder")
			&"goodasgold":
				return move.is_status() and user != null and user != target and move.target not in MoveData.FIELD_TARGETS
			&"queenlymajesty":
				return user != null and user.side != target.side and engine.move_priority(user, move) > 0
			&"telepathy":
				return user != null and user != target and user.side == target.side and not move.is_status()
			&"damp":
				return move.id in EXPLOSIONS
			&"sturdy":
				return move.ohko != &""
		return false


	func absorbs_move(engine: BattleEngine, target: Battler, _user: Battler, move: MoveData) -> bool:
		if not ABSORB.has(id) or not immune_to(engine, target, {}, move):
			return false
		var effect: StringName = ABSORB[id][1]
		engine.message(tr("¡%s se beneficia de %s!") % [engine.name_of(target), _ability_name()])
		match effect:
			&"heal":
				if engine.heal(target, maxi(1, target.pokemon.max_hp() / 4), &"ability") <= 0:
					engine.message(tr("No afecta %s...") % engine.inner_name_of(target))
			&"flashfire":
				engine.add_volatile(target, &"flashfire")
			_:
				engine.boost(target, {effect: 1}, true)
		return true


	func on_set_status(engine: BattleEngine, target: Battler, status: StringName, _source: Battler, announce: bool) -> bool:
		var blocked: bool = STATUS_GUARD.has(id) and status in STATUS_GUARD[id]
		if id == &"flowerveil" and target.has_type(&"grass") and engine._move_user != null and engine._move_user.side != target.side:
			blocked = true
		if blocked and announce:
			engine.message(tr("¡%s se protege con %s!") % [engine.name_of(target), _ability_name()])
		return not blocked


	func on_try_confuse(engine: BattleEngine, target: Battler, _source: Battler, announce: bool) -> bool:
		if id != &"owntempo":
			return true
		if announce:
			engine.message(tr("¡%s se protege con %s!") % [engine.name_of(target), _ability_name()])
		return false


	func allows_volatile(volatile_id: StringName) -> bool:
		if id == &"oblivious":
			return volatile_id not in [&"attract", &"taunt"]
		if id == &"innerfocus":
			return volatile_id != &"flinch"
		return true


	## Intimidación (8.ª generación en adelante): no afecta a Foco Interno, Despiste, Ritmo Propio ni
	## Intrépido; Guardián la vuelve contra quien la usa (sube su Ataque).
	func blocks_intimidate() -> bool:
		return id in [&"innerfocus", &"oblivious", &"owntempo", &"scrappy", &"guarddog"]


	# --- Características ---

	func _best_stat(battler: Battler) -> StringName:
		var best := &"atk"
		var value := -1
		for stat: StringName in [&"atk", &"def", &"spa", &"spd", &"spe"]:
			var v := battler.boosted_stat(stat)
			if v > value:
				value = v
				best = stat
		return best


	func _paradox_active(engine: BattleEngine, battler: Battler) -> bool:
		if battler.has_volatile(&"boosterenergy"):
			return true
		if id == &"protosynthesis":
			return engine.weather() == &"sunnyday"
		return id == &"quarkdrive" and engine.terrain() == &"electricterrain"


	func stat_modifier(engine: BattleEngine, battler: Battler, stat: StringName) -> float:
		match id:
			&"hugepower", &"purepower":
				return 2.0 if stat == &"atk" else 1.0
			&"furcoat":
				return 2.0 if stat == &"def" else 1.0
			&"marvelscale":
				return 1.5 if stat == &"def" and battler.pokemon.status != &"" else 1.0
			&"grasspelt":
				return 1.5 if stat == &"def" and engine.terrain() == &"grassyterrain" else 1.0
			&"flowergift":
				return 1.5 if stat in [&"atk", &"spd"] and engine.weather() == &"sunnyday" else 1.0
			&"plus", &"minus":
				var ally := engine.ally_of(battler)
				return 1.5 if stat == &"spa" and ally != null and ally.ability in [&"plus", &"minus"] else 1.0
			&"protosynthesis", &"quarkdrive":
				if stat != &"spe" and _paradox_active(engine, battler) and _best_stat(battler) == stat:
					return 1.3
		return 1.0


	func modify_speed(engine: BattleEngine, battler: Battler, speed: int) -> int:
		match id:
			&"quickfeet":
				if battler.pokemon.status != &"":
					return DamageCalc.modify(speed, 1.5)
			&"sandrush":
				if engine.weather() == &"sandstorm":
					return speed * 2
			&"slushrush":
				if engine.weather() == &"snow":
					return speed * 2
			&"protosynthesis", &"quarkdrive":
				if _paradox_active(engine, battler) and _best_stat(battler) == &"spe":
					return DamageCalc.modify(speed, 1.5)
		return speed


	func incoming_atk_modifier(_engine: BattleEngine, _user: Battler, _target: Battler, move: MoveData) -> float:
		match id:
			&"thickfat":
				return 0.5 if move.type in [&"fire", &"ice"] else 1.0
			&"heatproof", &"waterbubble":
				return 0.5 if move.type == &"fire" else 1.0
			&"purifyingsalt":
				return 0.5 if move.type == &"ghost" else 1.0
		return 1.0


	func move_stat_modifier(_engine: BattleEngine, user: Battler, move: MoveData) -> float:
		match id:
			&"flashfire":
				return 1.5 if move.type == &"fire" and user.has_volatile(&"flashfire") else 1.0
			&"transistor":
				return 1.3 if move.type == &"electric" else 1.0
			&"steelyspirit", &"rockypayload":
				return 1.5 if move.type == (&"steel" if id == &"steelyspirit" else &"rock") else 1.0
			&"waterbubble":
				return 2.0 if move.type == &"water" else 1.0
			&"stakeout":
				return 2.0 if _stakeout_target != null and _stakeout_target.entered_turn == _engine_turn and _engine_turn > 0 else 1.0
		return 1.0


	var _stakeout_target: Battler = null
	var _engine_turn := 0


	# --- Potencia y daño ---

	func modify_base_power(engine: BattleEngine, user: Battler, target: Battler, move: MoveData, power: int) -> int:
		_stakeout_target = target
		_engine_turn = engine.turn
		match id:
			&"technician":
				if power <= 60:
					return DamageCalc.modify(power, 6144, 4096)
			&"ironfist":
				if move.has_flag(&"punch"):
					return DamageCalc.modify(power, 4915, 4096)
			&"reckless":
				if not move.recoil.is_empty() or move.id in [&"highjumpkick", &"jumpkick", &"axekick", &"supercellslam"]:
					return DamageCalc.modify(power, 4915, 4096)
			&"sheerforce":
				if not move.secondaries.is_empty():
					return DamageCalc.modify(power, 5325, 4096)
			&"strongjaw":
				if move.has_flag(&"bite"):
					return DamageCalc.modify(power, 6144, 4096)
			&"megalauncher":
				if move.has_flag(&"pulse"):
					return DamageCalc.modify(power, 6144, 4096)
			&"toughclaws":
				if move.has_flag(&"contact"):
					return DamageCalc.modify(power, 5325, 4096)
			&"punkrock":
				if move.has_flag(&"sound"):
					return DamageCalc.modify(power, 5325, 4096)
			&"sandforce":
				if engine.weather() == &"sandstorm" and move.type in [&"rock", &"ground", &"steel"]:
					return DamageCalc.modify(power, 5325, 4096)
			&"analytic":
				if target != null and target.moved_this_turn:
					return DamageCalc.modify(power, 5325, 4096)
			&"rivalry":
				var a := user.pokemon.gender
				var b := target.pokemon.gender if target != null else &""
				if a != Pokemon.GENDERLESS and b != Pokemon.GENDERLESS:
					return DamageCalc.modify(power, 5120 if a == b else 3072, 4096)
			&"supremeoverlord":
				var fallen := mini(5, engine.fainted_indices(user.side).size())
				if fallen > 0:
					return DamageCalc.modify(power, 4096 + 410 * fallen, 4096)
		return power


	func modify_own_move(_engine: BattleEngine, user: Battler, _state: Dictionary, move: MoveData) -> MoveData:
		match id:
			&"pixilate":
				if move.type == &"normal" and not move.is_status():
					var copy := MoveData.from_dict(move.id, move.raw)
					copy.type = &"fairy"
					copy.power = DamageCalc.modify(move.power, 4915, 4096)
					return copy
			&"liquidvoice":
				if move.has_flag(&"sound"):
					var copy := MoveData.from_dict(move.id, move.raw)
					copy.type = &"water"
					return copy
			&"stancechange":
				if user.pokemon.species_id == &"aegislash" and not move.is_status():
					_engine.change_forme(user, &"aegislashblade")
				elif user.pokemon.species_id == &"aegislashblade" and move.id == &"kingsshield":
					_engine.change_forme(user, &"aegislash")
			&"protean", &"libero":
				# 9.ª generación: una vez por cada entrada al combate.
				if not user.has_volatile(&"protean") and move.id != &"struggle" and user.types() != [move.type]:
					user.type_override = [move.type] as Array[StringName]
					_engine.add_volatile(user, &"protean")
					_engine.message(tr("¡%s ahora es de tipo %s!") % [_engine.name_of(user), DataDB.type_name(move.type)])
		return move


	func stab_modifier(_user: Battler) -> float:
		return 2.0 if id == &"adaptability" else 0.0


	func incoming_damage_modifier(_engine: BattleEngine, _user: Battler, target: Battler, move: MoveData, _crit: bool) -> float:
		var effectiveness := DamageCalc.effectiveness(move, target)
		match id:
			&"multiscale":
				return 0.5 if target.pokemon.current_hp == target.pokemon.max_hp() else 1.0
			&"fluffy":
				var m := 1.0
				if move.has_flag(&"contact"):
					m *= 0.5
				if move.type == &"fire":
					m *= 2.0
				return m
			&"icescales":
				return 0.5 if not move.is_physical() and not move.is_status() else 1.0
			&"punkrock":
				return 0.5 if move.has_flag(&"sound") else 1.0
			&"dryskin":
				return 1.25 if move.type == &"fire" else 1.0
		if effectiveness > 1.0 and id in [&"filter", &"solidrock", &"prismarmor"]:
			return 0.75
		return 1.0


	func modify_damage_taken(engine: BattleEngine, b: Battler, amount: int, source: StringName, move: MoveData) -> int:
		var hp := b.pokemon.current_hp
		match id:
			&"sturdy":
				if source == &"move" and hp == b.pokemon.max_hp() and amount >= hp and hp > 1:
					engine.message(tr("¡%s ha aguantado el golpe gracias a Robustez!") % engine.name_of(b))
					return hp - 1
			&"magicguard":
				if source not in [&"move", &"confusion"]:
					return 0
			&"rockhead":
				if source == &"recoil":
					return 0
			&"poisonheal":
				if source in [&"psn", &"tox"]:
					if engine.heal(b, maxi(1, b.pokemon.max_hp() / 8), &"ability") > 0:
						engine.message(tr("¡%s se cura con Antídoto!") % engine.name_of(b))
					return 0
			&"heatproof":
				if source == &"brn":
					return amount / 2
			&"disguise":
				if source == &"move" and b.pokemon.species_id == &"mimikyu" and move != null and not move.is_status():
					engine.message(tr("¡El disfraz de %s ha recibido el golpe!") % engine.inner_name_of(b))
					engine.change_forme(b, &"mimikyubusted", true)
					return maxi(1, b.pokemon.max_hp() / 8)
			&"iceface":
				if source == &"move" and b.pokemon.species_id == &"eiscue" and move != null and move.is_physical():
					engine.message(tr("¡La cara de hielo de %s se ha roto!") % engine.inner_name_of(b))
					engine.change_forme(b, &"eiscuenoice", true)
					return 0
		return amount


	# --- Contacto y golpes recibidos ---

	func on_damaged(engine: BattleEngine, battler: Battler, user: Battler, move: MoveData) -> void:
		if move == null:
			return
		var contact := user != null and user != battler and not user.is_fainted() and engine.makes_contact(user, move)
		if contact:
			_on_contact(engine, battler, user, move)
		if contact and id == &"aftermath" and battler.is_fainted():
			engine.deal_damage(user, maxi(1, user.pokemon.max_hp() / 4), &"ability")
			engine.message(tr("¡%s ha sufrido daños por Detonación!") % engine.name_of(user))
		var lost := int(battler.hurt_by.get("amount", 0))
		if battler.is_fainted():
			if id == &"innardsout" and user != null and not user.is_fainted() and lost > 0:
				engine.deal_damage(user, lost, &"ability")
				engine.message(tr("¡%s ha sufrido daños por Revés!") % engine.name_of(user))
			return
		match id:
			&"weakarmor":
				if move.is_physical():
					engine.boost(battler, {&"def": -1, &"spe": 2}, true)
			&"stamina":
				engine.boost(battler, {&"def": 1}, true)
			&"justified":
				if move.type == &"dark":
					engine.boost(battler, {&"atk": 1}, true)
			&"steamengine":
				if move.type in [&"fire", &"water"]:
					engine.boost(battler, {&"spe": 6}, true)
			&"watercompaction":
				if move.type == &"water":
					engine.boost(battler, {&"def": 2}, true)
			&"thermalexchange":
				if move.type == &"fire":
					engine.boost(battler, {&"atk": 1}, true)
			&"angerpoint":
				if engine.last_hit_crit and battler.boosts[&"atk"] < 6:
					battler.boosts[&"atk"] = 6
					engine.message(tr("¡%s ha subido su Ataque al máximo!") % engine.name_of(battler))
			&"cursedbody":
				if user != null and user != battler and not user.is_fainted() and engine.rand_chance(&"ability", 3, 10):
					engine.add_volatile(user, &"disable", battler, {"move": String(move.id), "turns": 4})
			&"sandspit":
				engine.set_weather(&"sandstorm", battler)
			&"windpower":
				if move.has_flag(&"wind"):
					engine.add_volatile(battler, &"charge", battler)
			&"emergencyexit":
				var hp := battler.pokemon.current_hp
				if (hp + lost) * 2 > battler.pokemon.max_hp() and hp * 2 <= battler.pokemon.max_hp():
					engine.message(tr("¡%s huye con Retirada!") % engine.name_of(battler))
					engine.request_switch(battler, &"emergencyexit")
			&"gulpmissile":
				if user != null and not user.is_fainted() and battler.pokemon.species_id in [&"cramorantgulping", &"cramorantgorging"]:
					engine.deal_damage(user, maxi(1, user.pokemon.max_hp() / 4), &"ability")
					if battler.pokemon.species_id == &"cramorantgulping":
						engine.boost(user, {&"def": -1}, true)
					else:
						engine.set_status(user, &"par", battler)
					engine.change_forme(battler, &"cramorant", true)


	func _on_contact(engine: BattleEngine, battler: Battler, user: Battler, move: MoveData) -> void:
		match id:
			&"static", &"flamebody", &"poisonpoint":
				if engine.rand_chance(&"ability", 3, 10):
					engine.set_status(user, {&"static": &"par", &"flamebody": &"brn", &"poisonpoint": &"psn"}[id], battler, false)
			&"effectspore":
				if not user.has_type(&"grass") and user.ability != &"overcoat" and engine.rand_chance(&"ability", 3, 10):
					engine.set_status(user, [&"slp", &"psn", &"par"][engine.rand_int(&"ability", 0, 2)], battler, false)
			&"cutecharm":
				var a := battler.pokemon.gender
				var b := user.pokemon.gender
				if a != Pokemon.GENDERLESS and b != Pokemon.GENDERLESS and a != b and engine.rand_chance(&"ability", 3, 10):
					engine.add_volatile(user, &"attract", battler)
			&"roughskin", &"ironbarbs":
				engine.deal_damage(user, maxi(1, user.pokemon.max_hp() / 8), &"ability")
				engine.message(tr("¡%s se ha hecho daño con %s!") % [engine.name_of(user), _ability_name()])
			&"gooey":
				engine.boost(user, {&"spe": -1}, true)
			&"lingeringaroma":
				if user.ability not in [&"lingeringaroma", &"mummy"] + UNTRACEABLE:
					user.ability = &"lingeringaroma"
					engine.message(tr("¡%s ahora tiene Olor Persistente!") % engine.name_of(user))
			&"pickpocket":
				if battler.pokemon.held_item == &"" and engine.item_removable(user) and user.ability != &"stickyhold":
					var item := user.pokemon.held_item
					engine.set_held_item(user, &"")
					engine.set_held_item(battler, item)
					engine.message(tr("¡%s ha robado %s!") % [engine.name_of(battler), DataDB.item(item).name])
		var _unused := move


	## Lo que hace la habilidad del atacante con cada golpe que hace daño.
	func on_dealt_damage(engine: BattleEngine, user: Battler, target: Battler, move: MoveData, _damage: int) -> void:
		if target.is_fainted():
			return
		match id:
			&"poisontouch":
				if engine.makes_contact(user, move) and engine.rand_chance(&"ability", 3, 10):
					engine.set_status(target, &"psn", user, false)
			&"stench":
				if not target.moved_this_turn and engine.rand_chance(&"ability", 1, 10):
					engine.add_volatile(target, &"flinch", user)
			&"magician":
				if user.pokemon.held_item == &"" and engine.item_removable(target) and target.ability != &"stickyhold":
					var item := target.pokemon.held_item
					engine.set_held_item(target, &"")
					engine.set_held_item(user, item)
					engine.message(tr("¡%s ha robado %s!") % [engine.name_of(user), DataDB.item(item).name])


	func on_after_move(engine: BattleEngine, user: Battler, move: MoveData, _hit: bool) -> void:
		if id == &"gulpmissile" and user.pokemon.species_id == &"cramorant" and move.id in [&"surf", &"dive"]:
			var gorging := user.pokemon.current_hp * 2 <= user.pokemon.max_hp()
			engine.change_forme(user, &"cramorantgorging" if gorging else &"cramorantgulping", true)


	# --- Entrada y salida ---

	func on_switch_in(engine: BattleEngine, battler: Battler, _state: Dictionary) -> void:
		var foe := engine.foe_of(battler)
		battler.volatiles.erase(&"protean")
		if WEATHER_SETTERS.has(id):
			engine.set_weather(WEATHER_SETTERS[id], battler)
			return
		if TERRAIN_SETTERS.has(id):
			engine.set_terrain(TERRAIN_SETTERS[id], battler)
			return
		match id:
			&"pressure":
				_say(engine, battler, "¡%s ejerce su Presión!")
			&"moldbreaker":
				_say(engine, battler, "¡%s rompe moldes!")
			&"unnerve":
				engine.message(tr("¡El equipo rival está tan nervioso que no puede comer bayas!"))
			&"cloudnine":
				engine.message(tr("Los efectos del tiempo atmosférico han desaparecido."))
			&"neutralizinggas":
				engine.message(tr("¡Un gas reactivo se propaga por toda la zona!"))
			&"intrepidsword":
				engine.boost(battler, {&"atk": 1}, true)
			&"costar":
				var ally := engine.ally_of(battler)
				if ally != null:
					battler.boosts.assign(ally.boosts)
					engine.message(tr("¡%s ha copiado los cambios de %s!") % [engine.name_of(battler), engine.name_of(ally)])
			&"download":
				if foe != null and not foe.is_fainted():
					engine.boost(battler, {&"atk" if foe.boosted_stat(&"def") < foe.boosted_stat(&"spd") else &"spa": 1}, true)
			&"anticipation":
				if foe != null and _foe_has_danger(foe, battler):
					_say(engine, battler, "¡%s se ha estremecido!")
			&"forewarn":
				if foe != null:
					var best: MoveData = null
					for slot: MoveSlot in foe.pokemon.moves:
						var m := DataDB.move(slot.id)
						if best == null or m.power > best.power:
							best = m
					if best != null:
						engine.message(tr("¡Alerta ha detectado %s de %s!") % [best.name, engine.inner_name_of(foe)])
			&"trace":
				if foe != null and foe.ability not in UNTRACEABLE and foe.ability != &"":
					battler.ability = foe.ability
					engine.message(tr("¡%s ha copiado %s de %s!") % [engine.name_of(battler), DataDB.ability(foe.ability).name, engine.inner_name_of(foe)])
					var copied := Effects.ability(battler.ability)
					if copied != null:
						copied.on_switch_in(engine, battler, {})
			&"zerotohero":
				if battler.pokemon.species_id == &"palafinhero":
					_say(engine, battler, "¡%s se ha convertido en un héroe!")
			&"schooling":
				_school(engine, battler)
			&"truant":
				battler.volatiles.erase(&"truant")


	func _foe_has_danger(foe: Battler, me: Battler) -> bool:
		for slot: MoveSlot in foe.pokemon.moves:
			var m := DataDB.move(slot.id)
			if m.ohko != &"" or (not m.is_status() and DataDB.type_effectiveness(m.type, me.types()) > 1.0):
				return true
		return false


	func _school(engine: BattleEngine, b: Battler) -> void:
		if b.pokemon.level < 20 or not String(b.pokemon.species_id).begins_with("wishiwashi"):
			return
		var school := b.pokemon.current_hp * 4 > b.pokemon.max_hp()
		var want := &"wishiwashischool" if school else &"wishiwashi"
		if b.pokemon.species_id != want:
			engine.change_forme(b, want, true)
			engine.message(tr("¡%s ha formado un banco!") % engine.name_of(b) if school else tr("¡El banco de %s se ha dispersado!") % engine.name_of(b))


	func on_switch_out(engine: BattleEngine, b: Battler) -> void:
		match id:
			&"naturalcure":
				if b.pokemon.status != &"":
					b.pokemon.status = &""
			&"regenerator":
				if not b.is_fainted():
					b.pokemon.current_hp = mini(b.pokemon.max_hp(), b.pokemon.current_hp + b.pokemon.max_hp() / 3)
			&"zerotohero":
				if b.pokemon.species_id == &"palafin":
					engine.change_forme(b, &"palafinhero", true)


	# --- Final del turno ---

	func on_residual(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
		var b := holder as Battler
		if b == null or b.is_fainted():
			return
		var max_hp := b.pokemon.max_hp()
		match id:
			&"speedboost":
				if b.entered_turn < engine.turn:
					engine.boost(b, {&"spe": 1}, true)
			&"moody":
				var up: Array[StringName] = []
				for stat: StringName in [&"atk", &"def", &"spa", &"spd", &"spe"]:
					if b.boosts[stat] < 6:
						up.append(stat)
				var raised := &""
				if not up.is_empty():
					raised = up[engine.rand_int(&"ability", 0, up.size() - 1)]
					engine.boost(b, {raised: 2}, true)
				var down: Array[StringName] = []
				for stat: StringName in [&"atk", &"def", &"spa", &"spd", &"spe"]:
					if stat != raised and b.boosts[stat] > -6:
						down.append(stat)
				if not down.is_empty():
					engine.boost(b, {down[engine.rand_int(&"ability", 0, down.size() - 1)]: -1}, true)
			&"icebody":
				if engine.weather() == &"snow" and engine.heal(b, maxi(1, max_hp / 16), &"ability") > 0:
					_say(engine, b, "¡%s ha recuperado PS con Gélido!")
			&"dryskin":
				if engine.weather() == &"raindance" and engine.heal(b, maxi(1, max_hp / 8), &"ability") > 0:
					_say(engine, b, "¡%s ha recuperado PS con Piel Seca!")
				elif engine.weather() == &"sunnyday":
					engine.deal_damage(b, maxi(1, max_hp / 8), &"ability")
					_say(engine, b, "¡%s se resiente por Piel Seca!")
			&"hydration":
				if engine.weather() == &"raindance" and b.pokemon.status != &"":
					engine.cure_status(b)
					_say(engine, b, "¡%s se ha curado con Hidratación!")
			&"harvest":
				if b.pokemon.held_item == &"" and b.consumed_item != &"" and DataDB.has_item(b.consumed_item) \
						and DataDB.item(b.consumed_item).pocket == &"berries" \
						and (engine.weather() == &"sunnyday" or engine.rand_chance(&"ability", 1, 2)):
					b.pokemon.held_item = b.consumed_item
					b.consumed_item = &""
					engine.message(tr("¡%s ha cosechado una baya!") % engine.name_of(b))
			&"cudchew":
				var pending := int(_state.get("cudchew", -1))
				if b.ate_berry and b.pokemon.held_item == &"" and b.consumed_item != &"" and not b.has_volatile(&"cudchew"):
					engine.add_volatile(b, &"cudchew", b, {"item": String(b.consumed_item), "turn": engine.turn})
				elif b.has_volatile(&"cudchew") and int(b.volatiles[&"cudchew"].get("turn", 0)) < engine.turn:
					var berry := StringName(str(b.volatiles[&"cudchew"].get("item", "")))
					b.volatiles.erase(&"cudchew")
					engine.message(tr("¡%s rumia la baya otra vez!") % engine.name_of(b))
					engine.eat_berry(b, berry)
				var _p := pending
			&"healer":
				var ally := engine.ally_of(b)
				if ally != null and ally.pokemon.status != &"" and engine.rand_chance(&"ability", 3, 10):
					engine.cure_status(ally)
			&"pickup":
				var foe := engine.foe_of(b)
				if b.pokemon.held_item == &"" and foe != null and foe.consumed_item != &"" and DataDB.has_item(foe.consumed_item):
					b.pokemon.held_item = foe.consumed_item
					foe.consumed_item = &""
					engine.message(tr("¡%s ha recogido %s!") % [engine.name_of(b), DataDB.item(b.pokemon.held_item).name])
			&"schooling":
				_school(engine, b)
			&"iceface":
				if b.pokemon.species_id == &"eiscuenoice" and engine.weather() == &"snow":
					engine.change_forme(b, &"eiscue", true)


	func can_act(engine: BattleEngine, user: Battler, _move: MoveData) -> bool:
		if id != &"truant":
			return true
		if user.has_volatile(&"truant"):
			user.volatiles.erase(&"truant")
			engine.message(tr("¡%s está holgazaneando!") % engine.name_of(user))
			return false
		user.volatiles[&"truant"] = {}
		return true


	# --- Prioridad, críticos, precisión y niveles ---

	func modify_priority(_engine: BattleEngine, user: Battler, move: MoveData, priority: int) -> int:
		match id:
			&"prankster":
				if move.is_status():
					return priority + 1
			&"galewings":
				if move.type == &"flying" and user.pokemon.current_hp == user.pokemon.max_hp():
					return priority + 1
			&"triage":
				if move.has_flag(&"heal") or not move.drain.is_empty():
					return priority + 3
		return priority


	## Retraso: actúa el último de su prioridad (como Showdown, onFractionalPriority −0,1).
	func moves_last() -> bool:
		return id == &"stall"


	func blocks_crit() -> bool:
		return id in [&"battlearmor", &"shellarmor"]


	func crit_bonus(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
		if id == &"superluck":
			return 1
		if id == &"merciless" and target != null and target.pokemon.status in [&"psn", &"tox"]:
			return 5
		return 0


	func modify_incoming_accuracy(engine: BattleEngine, _user: Battler, _target: Battler, _move: MoveData, accuracy: int) -> int:
		if (id == &"sandveil" and engine.weather() == &"sandstorm") or (id == &"snowcloak" and engine.weather() == &"snow"):
			return DamageCalc.modify(accuracy, 3277, 4096)
		return accuracy


	func prevents_drop(stat: StringName) -> bool:
		return (id == &"illuminate" and stat == &"accuracy") or (id == &"hypercutter" and stat == &"atk")


	func prevents_foe_drop() -> bool:
		return id in [&"clearbody", &"whitesmoke", &"mirrorarmor"]


	func modify_boost(amount: int) -> int:
		if id == &"contrary":
			return -amount
		if id == &"simple":
			return amount * 2
		return amount


	func on_stat_lowered(engine: BattleEngine, b: Battler) -> void:
		if id == &"defiant":
			engine.boost(b, {&"atk": 2}, true)
		elif id == &"competitive":
			engine.boost(b, {&"spa": 2}, true)


	func ignores_boosts() -> bool:
		return id == &"unaware"


	func on_try_hit(engine: BattleEngine, target: Battler, _state: Dictionary, user: Battler, move: MoveData) -> bool:
		if id != &"magicbounce" or _bouncing or user == target or not move.has_flag(&"reflectable"):
			return true
		_bouncing = true
		engine.message(tr("¡%s ha devuelto %s!") % [engine.name_of(target), move.name])
		engine.use_move(target, move)
		_bouncing = false
		return false


	func traps_foe(engine: BattleEngine, _holder: Battler, b: Battler) -> bool:
		match id:
			&"arenatrap":
				return engine.is_grounded(b)
			&"shadowtag":
				return b.ability != &"shadowtag"
			&"magnetpull":
				return b.has_type(&"steel")
		return false
