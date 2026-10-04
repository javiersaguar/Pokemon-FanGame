class_name Effects
extends RefCounted
## Registro de efectos con script (Fase 9.1). Cada efecto es un archivo con el id como nombre:
##   Effects.move(&"protect")      → src/battle/effects/moves/protect.gd
##   Effects.condition(&"reflect") → src/battle/effects/conditions/reflect.gd
## Devuelven null si no hay script (el motor usa entonces solo los datos de la Fase 7.6).

const MOVES_DIR := "res://src/battle/effects/moves/"
const CONDITIONS_DIR := "res://src/battle/effects/conditions/"

static var _cache: Dictionary = {}


static func move(move_id: StringName) -> BattleEffect:
	return _load(MOVES_DIR, move_id)


static func condition(condition_id: StringName) -> BattleEffect:
	return _load(CONDITIONS_DIR, condition_id)


static func has_move(move_id: StringName) -> bool:
	return move(move_id) != null


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
