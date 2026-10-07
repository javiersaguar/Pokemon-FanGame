class_name Effects
extends RefCounted
## Registro de efectos con script (Fase 9.1). Cada efecto es un archivo con el id como nombre:
##   Effects.move(&"protect")      → src/battle/effects/moves/protect.gd
##   Effects.condition(&"reflect") → src/battle/effects/conditions/reflect.gd
##   Effects.ability(&"static")    → src/battle/effects/abilities/static.gd (o ability_catalog.gd)
##   Effects.item(&"lifeorb")      → src/battle/effects/items/lifeorb.gd (o item_catalog.gd)
## Devuelven null si no hay script (el motor usa entonces solo los datos de la Fase 7.6).

const MOVES_DIR := "res://src/battle/effects/moves/"
const CONDITIONS_DIR := "res://src/battle/effects/conditions/"
const ABILITIES_DIR := "res://src/battle/effects/abilities/"
const ITEMS_DIR := "res://src/battle/effects/items/"
const AbilityCatalog := preload("res://src/battle/effects/ability_catalog.gd")
const ItemCatalog := preload("res://src/battle/effects/item_catalog.gd")

static var _cache: Dictionary = {}


static func move(move_id: StringName) -> BattleEffect:
	return _load(MOVES_DIR, move_id)


static func condition(condition_id: StringName) -> BattleEffect:
	return _load(CONDITIONS_DIR, condition_id)


static func has_move(move_id: StringName) -> bool:
	return move(move_id) != null


static func ability(ability_id: StringName) -> BattleEffect:
	if ability_id == &"":
		return null
	var key := "ability:" + String(ability_id)
	if _cache.has(key):
		return _cache[key]
	var effect := _load(ABILITIES_DIR, ability_id)
	if effect == null:
		effect = AbilityCatalog.make(ability_id)
	if effect != null:
		effect.id = ability_id
	_cache[key] = effect
	return effect


static func item(item_id: StringName) -> BattleEffect:
	if item_id == &"":
		return null
	var key := "item:" + String(item_id)
	if _cache.has(key):
		return _cache[key]
	var effect := _load(ITEMS_DIR, item_id)
	if effect == null:
		effect = ItemCatalog.make(item_id)
	if effect != null:
		effect.id = item_id
	_cache[key] = effect
	return effect


static func _load(dir: String, effect_id: StringName) -> BattleEffect:
	var path := "%s%s.gd" % [dir, effect_id]
	if _cache.has(path):
		return _cache[path]
	var effect: BattleEffect = null
	if ResourceLoader.exists(path):
		var script: Script = load(path)
		effect = script.new()
		effect.id = effect_id
	_cache[path] = effect
	return effect
