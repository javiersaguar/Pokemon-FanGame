class_name DamageCalc
extends RefCounted
## Fórmula de daño (5.ª generación en adelante) con el mismo redondeo que Showdown
## (sim/battle-actions.ts: getDamage y modifyDamage; los modificadores van en base 4096).
##   base = floor(floor(floor(2·Nivel/5 + 2) · Potencia · A / D) / 50) + 2
##   × objetivos × clima × crítico (1,5) × aleatorio (85..100) × STAB × tipo × quemadura × otros

const STAB := 1.5
const CRIT_MULTIPLIER := 1.5
const BURN_MULTIPLIER := 0.5
const SPREAD_MULTIPLIER := 0.75
const CONFUSION_POWER := 40
## La tirada aleatoria de Showdown es random(16): factor (100 − tirada) / 100.
const ROLLS := 16


## battle.modify() de Showdown: multiplica con un modificador en base 4096 y redondea "hacia abajo en el .5".
@warning_ignore("integer_division")
static func modify(value: int, numerator: float, denominator: float = 1.0) -> int:
	var modifier := int(numerator * 4096.0 / denominator)
	return (value * modifier + 2047) / 4096


@warning_ignore("integer_division")
static func base_damage(level: int, power: int, attack: int, defense: int) -> int:
	var level_factor := 2 * level / 5 + 2
	return level_factor * power * attack / maxi(defense, 1) / 50


## Del daño base (sin el +2) al daño final. `effectiveness` > 0 (las inmunidades se miran antes).
@warning_ignore("integer_division")
static func modify_damage(base: int, roll: int, crit: bool, stab: bool, effectiveness: float,
		burned_physical: bool, spread: bool = false, other: float = 1.0, weather: float = 1.0,
		stab_mod: float = 0.0) -> int:
	var damage := base + 2
	if spread:
		damage = modify(damage, SPREAD_MULTIPLIER)
	if weather != 1.0:
		damage = modify(damage, weather)
	if crit:
		damage = int(damage * CRIT_MULTIPLIER)
	damage = damage * (100 - clampi(roll, 0, ROLLS - 1)) / 100
	if stab_mod > 1.0:
		damage = modify(damage, stab_mod)
	elif stab:
		damage = modify(damage, STAB)
	var exponent := roundi(log(effectiveness) / log(2.0)) if effectiveness > 0.0 else 0
	for i: int in absi(exponent):
		damage = damage * 2 if exponent > 0 else damage / 2
	if burned_physical:
		damage = modify(damage, BURN_MULTIPLIER)
	if other != 1.0:
		damage = modify(damage, other)
	if damage == 0:
		return 1
	return damage % 65536


## Encadena modificadores como Showdown (chainModify, en base 4096) y devuelve el total.
@warning_ignore("integer_division")
static func chain(modifiers: Array) -> float:
	var total := 4096
	for m: Variant in modifiers:
		total = (total * int(float(m) * 4096.0) + 2048) >> 12
	return total / 4096.0


## Daño de `move` de `attacker` contra `defender` con una tirada concreta (0..15). No mira inmunidades.
## `opts` (todo opcional, lo pone el motor con los efectos de la Fase 9): power (potencia base),
## weather (multiplicador del clima), final (Array de multiplicadores finales: Reflejo...),
## atk_mod / def_mod (multiplicadores de las estadísticas: Tormenta Arena, Nieve...).
static func calculate(attacker: Battler, defender: Battler, move: MoveData, crit: bool, roll: int, opts: Dictionary = {}) -> int:
	var physical := move.is_physical()
	var atk_stat := &"atk" if physical else &"spa"
	var def_stat := &"def" if physical else &"spd"
	var atk_stage: int = attacker.boosts[atk_stat]
	var def_stage: int = defender.boosts[def_stat]
	if crit:
		atk_stage = maxi(atk_stage, 0)
		def_stage = mini(def_stage, 0)
	if move.ignore_defensive:
		def_stage = 0
	var attack := attacker.boosted_stat(atk_stat, atk_stage)
	var defense := defender.boosted_stat(def_stat, def_stage)
	if float(opts.get("atk_mod", 1.0)) != 1.0:
		attack = modify(attack, float(opts["atk_mod"]))
	if float(opts.get("def_mod", 1.0)) != 1.0:
		defense = modify(defense, float(opts["def_mod"]))
	var base := base_damage(attacker.pokemon.level, int(opts.get("power", move.power)), attack, defense)
	var typeless := is_typeless(move)
	var effectiveness := 1.0 if typeless else DataDB.type_effectiveness(move.type, defender.types())
	var stab := not typeless and attacker.has_type(move.type)
	var stab_mod := _tera_stab(attacker, move) if not typeless else 0.0
	if stab_mod > 1.0:
		stab = false
	var burned := physical and attacker.pokemon.status == &"brn" and move.id != &"facade" and not bool(opts.get("ignore_burn", false))
	var final_mod := chain(opts.get("final", []))
	return modify_damage(base, roll, crit, stab, effectiveness, burned, bool(opts.get("spread", false)), final_mod, float(opts.get("weather", 1.0)), stab_mod)


## STAB del Teratipo: 2 si el tipo ya lo tenía, 1,5 si es nuevo o si el golpe es de un tipo original. 0 = sin Teratipo.
static func _tera_stab(attacker: Battler, move: MoveData) -> float:
	if attacker.tera_active == &"":
		return 0.0
	var original := attacker.pokemon.types()
	if move.type == attacker.tera_active:
		return 2.0 if move.type in original else 1.5
	if move.type in original:
		return 1.5
	return 0.0


## Las 16 cantidades posibles, de menor a mayor (como la calculadora de Showdown).
static func damage_range(attacker: Battler, defender: Battler, move: MoveData, crit: bool = false) -> Array[int]:
	var out: Array[int] = []
	for roll: int in range(ROLLS - 1, -1, -1):
		out.append(calculate(attacker, defender, move, crit, roll))
	return out


## Golpe por confusión: 40 de potencia, físico, sin tipo ni STAB ni crítico.
@warning_ignore("integer_division")
static func confusion_damage(b: Battler, roll: int) -> int:
	var base := base_damage(b.pokemon.level, CONFUSION_POWER, b.boosted_stat(&"atk"), b.boosted_stat(&"def")) + 2
	return maxi(1, (base % 65536) * (100 - clampi(roll, 0, ROLLS - 1)) / 100)


## Forcejeo no tiene tipo (no hay STAB ni efectividad).
static func is_typeless(move: MoveData) -> bool:
	return move.id == &"struggle"


## Multiplicador de tipo de `move` contra `defender` (1.0 si no tiene tipo).
static func effectiveness(move: MoveData, defender: Battler) -> float:
	if is_typeless(move):
		return 1.0
	return DataDB.type_effectiveness(move.type, defender.types())
