class_name ItemData
extends RefCounted
## Datos de un objeto: data/generated/items.json (estándar) o data/items_panchito.json (Panchito).
## Contrato: docs/contratos.md (sección DataDB).

## Valores de field_use / battle_use.
const USE_NONE := &""
const USE_ON_POKEMON := &"on_pokemon"
const USE_ON_ACTIVE := &"on_active"
const USE_NO_TARGET := &"no_target"

var id: StringName
var name: String
var name_plural: String
var name_en: String
## items, medicine, pokeballs, machines, berries, mail, battle, key (y los que añada el Agente 3).
var pocket: StringName = &"items"
var category: StringName
var price: int = 0
var fling_power: int = 0
var flags: Array[StringName] = []
var description: String
var field_use: StringName = USE_NONE
var battle_use: StringName = USE_NONE
## heal_hp, cure_status, heal_and_cure, revive, restore_pp, boost_stat, crit_boost, ball, flee,
## repel, escape, evolution, add_evs, level_up, pp_up... (ver contrato).
var effect: StringName
var effect_params: Dictionary = {}
var is_berry: bool = false
var is_pokeball: bool = false
## true si al llevarlo equipado necesita código propio (Fase 9.5).
var held_needs_script: bool = false
## true si viene de data/items_panchito.json.
var is_panchito: bool = false
var nonstandard: StringName
var raw: Dictionary = {}


static func from_dict(item_id: StringName, d: Dictionary, panchito: bool = false) -> ItemData:
	var it := ItemData.new()
	it.id = item_id
	it.raw = d
	it.name = str(d.get("name", item_id))
	it.name_plural = str(d.get("name_plural", it.name))
	it.name_en = str(d.get("name_en", ""))
	it.pocket = StringName(d.get("pocket", "items"))
	it.category = StringName(d.get("category", ""))
	it.price = int(d.get("price", 0))
	it.fling_power = int(d.get("fling_power", 0))
	it.flags = DataUtil.names(d.get("flags", []))
	it.description = str(d.get("description", ""))
	it.field_use = StringName(d.get("field_use", ""))
	it.battle_use = StringName(d.get("battle_use", ""))
	it.effect = StringName(d.get("effect", ""))
	it.effect_params = d.get("effect_params", {})
	it.is_berry = bool(d.get("is_berry", false))
	it.is_pokeball = bool(d.get("is_pokeball", false)) or it.effect == &"ball"
	it.held_needs_script = bool(d.get("held_needs_script", false))
	it.is_panchito = panchito
	it.nonstandard = StringName(d.get("nonstandard", ""))
	return it


## Precio de venta (la mitad, como en los juegos oficiales).
@warning_ignore("integer_division")
func sell_price() -> int:
	return price / 2


func has_flag(flag: StringName) -> bool:
	return flag in flags


func is_ball() -> bool:
	return is_pokeball


func is_key_item() -> bool:
	return pocket == &"key"


func is_z_crystal() -> bool:
	var value: Variant = raw.get("z_move", false)
	if value is bool:
		return value
	return value is String and str(value) != ""


func z_move_type() -> StringName:
	return StringName(str(raw.get("z_move_type", "")))


## Movimiento Z concreto (Pikastal Z...). Vacío en los cristales de tipo.
func z_move_id() -> StringName:
	var value: Variant = raw.get("z_move", "")
	return StringName(str(value)) if value is String else &""


func z_move_from() -> StringName:
	return StringName(str(raw.get("z_move_from", "")))


## Forma mega que otorga esta Megapiedra a esa especie. Vacío si no es su piedra.
func mega_species(for_species: StringName) -> StringName:
	var map: Variant = raw.get("mega_stone", {})
	if map is Dictionary and map.has(String(for_species)):
		return StringName(str(map[String(for_species)]))
	return &""


func usable_in_field() -> bool:
	return field_use != USE_NONE


func usable_in_battle() -> bool:
	return battle_use != USE_NONE


func param(key: String, default: Variant = null) -> Variant:
	return effect_params.get(key, default)
