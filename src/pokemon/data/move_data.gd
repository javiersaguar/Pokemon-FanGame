class_name MoveData
extends RefCounted
## Datos de un movimiento (data/generated/moves.json). Contrato: docs/contratos.md (sección DataDB).

enum Category { PHYSICAL, SPECIAL, STATUS }

const CATEGORY_IDS: Dictionary[StringName, Category] = {
	&"physical": Category.PHYSICAL,
	&"special": Category.SPECIAL,
	&"status": Category.STATUS,
}
## Objetivos que, en un combate individual, apuntan al propio usuario o a su bando.
const SELF_TARGETS: Array[StringName] = [
	&"self", &"adjacent_ally_or_self", &"ally_side", &"ally_team", &"allies", &"adjacent_ally",
]
## Objetivos que no son un Pokémon (todo el campo o un bando): necesitan script.
const FIELD_TARGETS: Array[StringName] = [&"all", &"foe_side", &"ally_side"]

var id: StringName
var num: int
var name: String
var name_en: String
var type: StringName
var category: Category = Category.PHYSICAL
var power: int = 0
## 0 = no falla nunca.
var accuracy: int = 0
var pp: int = 0
var priority: int = 0
## Objetivo de Showdown en snake_case: "normal", "self", "all_adjacent_foes"...
var target: StringName = &"normal"
var flags: Dictionary[StringName, bool] = {}
## Efectos secundarios: {chance, status?, volatile_status?, boosts?, self_boosts?}.
var secondaries: Array[Dictionary] = []
## Cambios de características en el objetivo (o en el usuario si el objetivo es "self").
var boosts: Dictionary[StringName, int] = {}
## Cambios de características en el usuario tras usar el movimiento (A Bocajarro, Sofoco...).
var self_boosts: Dictionary[StringName, int] = {}
## Estado principal que causa (movimientos de estado): "par", "slp"...
var status: StringName
## Estado volátil que causa: "confusion" (el resto necesita script).
var volatile_status: StringName
## Fracciones [numerador, denominador]; vacías si no aplican.
var drain: Array[int] = []
var recoil: Array[int] = []
var heal: Array[int] = []
var multihit_min: int = 1
var multihit_max: int = 1
var crit_ratio: int = 1
var will_crit: bool = false
## "" = no es fulminante; "any" = cualquiera; un tipo ("ice") = falla contra ese tipo.
var ohko: StringName
## Daño fijo (Bomba Sónica = 20). 0 = no.
var fixed_damage: int = 0
## Daño igual al nivel del usuario (Sísmico, Tinieblas).
var level_damage: bool = false
## "", "always" o "if_hit".
var selfdestruct: StringName
var struggle_recoil: bool = false
var thaws_target: bool = false
## null = valor por defecto (los de estado ignoran inmunidades de tipo); bool; o lista de tipos.
var ignore_immunity: Variant = null
var ignore_defensive: bool = false
var ignore_evasion: bool = false
var breaks_protect: bool = false
var sleep_usable: bool = false
var no_pp_boosts: bool = false
var nonstandard: StringName
## true si necesita código propio (Fase 9.2); false = funciona solo con sus datos (Fase 7.6).
var needs_script: bool = false
var script_hooks: Array[String] = []
var description: String
var raw: Dictionary = {}


static func from_dict(move_id: StringName, d: Dictionary) -> MoveData:
	var m := MoveData.new()
	m.id = move_id
	m.raw = d
	m.num = int(d.get("num", 0))
	m.name = str(d.get("name", move_id))
	m.name_en = str(d.get("name_en", ""))
	m.type = StringName(d.get("type", "normal"))
	m.category = CATEGORY_IDS.get(StringName(d.get("category", "physical")), Category.PHYSICAL)
	m.power = int(d.get("power", 0))
	m.accuracy = int(d.get("accuracy", 0))
	m.pp = int(d.get("pp", 0))
	m.priority = int(d.get("priority", 0))
	m.target = StringName(d.get("target", "normal"))
	m.flags = DataUtil.bool_dict(d.get("flags", {}))
	for sec: Dictionary in d.get("secondaries", []):
		m.secondaries.append(sec)
	m.boosts = DataUtil.int_dict(d.get("boosts", {}))
	m.self_boosts = DataUtil.int_dict(d.get("self_boosts", {}))
	m.status = StringName(d.get("status", ""))
	m.volatile_status = StringName(d.get("volatile_status", ""))
	m.drain = DataUtil.ints(d.get("drain", []))
	m.recoil = DataUtil.ints(d.get("recoil", []))
	m.heal = DataUtil.ints(d.get("heal", []))
	var hits: Variant = d.get("multihit", 1)
	if hits is Array:
		m.multihit_min = int(hits[0])
		m.multihit_max = int(hits[1])
	else:
		m.multihit_min = int(hits)
		m.multihit_max = int(hits)
	m.crit_ratio = int(d.get("crit_ratio", 1))
	m.will_crit = bool(d.get("will_crit", false))
	m.ohko = StringName(d.get("ohko", ""))
	var damage: Variant = d.get("damage", 0)
	m.level_damage = damage is String and damage == "level"
	m.fixed_damage = 0 if damage is String else int(damage)
	m.selfdestruct = StringName(d.get("selfdestruct", ""))
	m.struggle_recoil = bool(d.get("struggle_recoil", false))
	m.thaws_target = bool(d.get("thaws_target", false))
	m.ignore_immunity = d.get("ignore_immunity", null)
	m.ignore_defensive = bool(d.get("ignore_defensive", false))
	m.ignore_evasion = bool(d.get("ignore_evasion", false))
	m.breaks_protect = bool(d.get("breaks_protect", false))
	m.sleep_usable = bool(d.get("sleep_usable", false))
	m.no_pp_boosts = bool(d.get("no_pp_boosts", false))
	m.nonstandard = StringName(d.get("nonstandard", ""))
	m.needs_script = bool(d.get("needs_script", false))
	m.script_hooks = DataUtil.strings(d.get("script_hooks", []))
	m.description = str(d.get("description", ""))
	return m


func has_flag(flag: StringName) -> bool:
	return flags.get(flag, false)


func is_status() -> bool:
	return category == Category.STATUS


func is_physical() -> bool:
	return category == Category.PHYSICAL


func is_damaging() -> bool:
	return category != Category.STATUS


func is_multihit() -> bool:
	return multihit_max > 1


func targets_user() -> bool:
	return target in SELF_TARGETS


## PP máximos con `pp_ups` Más PP (0-3).
@warning_ignore("integer_division")
func max_pp(pp_ups: int = 0) -> int:
	if no_pp_boosts:
		return pp
	return pp * (5 + clampi(pp_ups, 0, 3)) / 5


## ¿Ignora las inmunidades de tipo de `def_type`? (por defecto, los de estado sí).
func ignores_immunity_of(def_type: StringName) -> bool:
	if ignore_immunity == null:
		return is_status()
	if ignore_immunity is bool:
		return ignore_immunity
	return String(def_type) in ignore_immunity
