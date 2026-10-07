extends RefCounted
## Habilidades de las especies en uso (species_in_use.json), incluidas las ocultas.
## El motor llama los hooks; aquí solo está el comportamiento.


static func make(id: StringName) -> BattleEffect:
	if id in [
		&"aromaveil", &"bigpecks", &"blaze", &"chlorophyll", &"compoundeyes", &"frisk", &"guts",
		&"hustle", &"infiltrator", &"insomnia", &"intimidate", &"keeneye", &"leafguard", &"moxie",
		&"overgrow", &"raindish", &"rattled", &"runaway", &"shedskin", &"shielddust", &"sniper",
		&"solarpower", &"swarm", &"sweetveil", &"swiftswim", &"tangledfeet", &"tintedlens",
		&"torrent", &"unburden",
	]:
		return AbilityBehavior.new()
	return null


class AbilityBehavior extends BattleEffect:
	const PINCH := {
		&"blaze": &"fire", &"overgrow": &"grass", &"torrent": &"water", &"swarm": &"bug",
	}


	## Mar Llamas, Espesura, Torrente y Enjambre: ×1,5 al Ataque o Ataque Especial con un tercio de
	## los PS o menos (5.ª generación en adelante; antes era la potencia).
	func move_stat_modifier(_engine: BattleEngine, user: Battler, move: MoveData) -> float:
		var element: StringName = PINCH.get(id, &"")
		if element == &"" or move.type != element or user.pokemon.current_hp * 3 > user.pokemon.max_hp():
			return 1.0
		return 1.5


	func stat_modifier(engine: BattleEngine, battler: Battler, stat: StringName) -> float:
		match id:
			&"guts":
				if stat == &"atk" and battler.pokemon.status != &"":
					return 1.5
			&"hustle":
				if stat == &"atk":
					return 1.5
			&"solarpower":
				if stat == &"spa" and engine.weather() == &"sunnyday":
					return 1.5
		return 1.0


	func modify_speed(engine: BattleEngine, battler: Battler, speed: int) -> int:
		if id == &"chlorophyll" and engine.weather() == &"sunnyday":
			return speed * 2
		if id == &"swiftswim" and engine.weather() == &"raindance":
			return speed * 2
		if id == &"unburden" and battler.unburdened:
			return speed * 2
		return speed


	func damage_modifier(_engine: BattleEngine, _user: Battler, target: Battler, move: MoveData, crit: bool) -> float:
		if id == &"sniper" and crit:
			return 1.5
		if id == &"tintedlens":
			var effect := DataDB.type_effectiveness(move.type, target.types())
			if effect > 0.0 and effect < 1.0:
				return 2.0
		return 1.0


	func modify_accuracy(_engine: BattleEngine, _user: Battler, _target: Battler, move: MoveData, accuracy: int) -> int:
		if id == &"compoundeyes":
			return DamageCalc.modify(accuracy, 1.3)
		if id == &"hustle" and move.is_physical():
			return DamageCalc.modify(accuracy, 0.8)
		return accuracy


	func modify_incoming_accuracy(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, accuracy: int) -> int:
		if id == &"tangledfeet" and target.has_volatile(&"confusion"):
			return maxi(1, accuracy / 2)
		return accuracy


	func prevents_drop(stat: StringName) -> bool:
		return (id == &"keeneye" and stat == &"accuracy") or (id == &"bigpecks" and stat == &"def")


	func blocks_secondary() -> bool:
		return id == &"shielddust"


	func allows_volatile(volatile_id: StringName) -> bool:
		return not (id == &"aromaveil" and volatile_id == &"attract")


	func guarantees_escape() -> bool:
		return id == &"runaway"


	func on_switch_in(engine: BattleEngine, battler: Battler, _state: Dictionary) -> void:
		var foe := engine.foe_of(battler)
		if foe == null or foe.is_fainted():
			return
		if id == &"intimidate":
			engine.message(tr("¡%s intimida a %s!") % [engine.name_of(battler), engine.name_of(foe)])
			engine.boost(foe, {&"atk": -1}, false)
			# Nerviosismo: desde la 8.ª generación, la Intimidación le sube la Velocidad.
			if foe.ability == &"rattled" and not foe.is_fainted():
				engine.boost(foe, {&"spe": 1}, true)
		elif id == &"frisk" and foe.pokemon.held_item != &"" and DataDB.has_item(foe.pokemon.held_item):
			engine.message(tr("¡%s ha cacheado a %s y ha encontrado %s!") % [engine.name_of(battler), engine.name_of(foe), DataDB.item(foe.pokemon.held_item).name])


	func on_set_status(engine: BattleEngine, target: Battler, status: StringName, _source: Battler, announce: bool) -> bool:
		var blocked := false
		if id == &"insomnia" or id == &"sweetveil":
			blocked = status == &"slp"
		elif id == &"leafguard":
			blocked = engine.weather() == &"sunnyday"
		if not blocked:
			return true
		if announce:
			engine.message(tr("¡%s se protege con su habilidad!") % engine.name_of(target))
		return false


	func on_residual(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
		var battler := holder as Battler
		if battler == null or battler.is_fainted():
			return
		match id:
			&"raindish":
				if engine.weather() == &"raindance" and engine.heal(battler, maxi(1, battler.pokemon.max_hp() / 16), &"ability") > 0:
					engine.message(tr("¡%s ha recuperado PS con Cura Lluvia!") % engine.name_of(battler))
			&"solarpower":
				if engine.weather() == &"sunnyday":
					engine.deal_damage(battler, maxi(1, battler.pokemon.max_hp() / 8), &"ability")
					engine.message(tr("¡%s se resiente por Poder Solar!") % engine.name_of(battler))
			&"shedskin":
				if battler.pokemon.status != &"" and engine.rand_chance(&"shedskin", 33, 100):
					engine.cure_status(battler)
					engine.message(tr("¡%s se ha liberado de su problema con Mudar!") % engine.name_of(battler))


	func residual_order() -> int:
		return 8 if id == &"solarpower" else 5


	func on_damaged(engine: BattleEngine, battler: Battler, _user: Battler, move: MoveData) -> void:
		if id != &"rattled" or move == null or battler.is_fainted():
			return
		if move.type in [&"bug", &"ghost", &"dark"]:
			engine.boost(battler, {&"spe": 1}, true)


	func on_foe_fainted(engine: BattleEngine, user: Battler) -> void:
		if id == &"moxie" and not user.is_fainted():
			engine.message(tr("¡La Autoestima de %s sube su Ataque!") % engine.name_of(user))
			engine.boost(user, {&"atk": 1}, true)
