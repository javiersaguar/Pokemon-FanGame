class_name FieldActions
extends RefCounted
## Objetos clave modernos; no exige una MO en el equipo ni consume el objeto.
## IDs/flags de historia sin decidir = acción deshabilitada, sin inventar objetos.
static func available(action: StringName, map: MapRoot = null) -> bool:
	var cfg: Dictionary = GameState.world_config.get("field", {}).get("actions", {}).get(String(action), {})
	var item := str(cfg.get("item", "")) if cfg.get("item") != null else ""
	if item.is_empty() or not (GameState.bag is Bag) or GameState.bag.count(StringName(item)) <= 0:
		return false
	var flag := StringName(cfg.get("required_flag", ""))
	if flag != &"" and not GameState.flag(flag):
		return false
	return action != &"bike" or map == null or map.data == null or map.data.can_bike

static func sheet_path(mode: StringName, gender: StringName) -> String:
	var value: Variant = GameState.world_config.get("field", {}).get("transport_sheets", {}).get(String(gender), {}).get(String(mode))
	return str(value) if value != null else ""

static func transport() -> StringName:
	return StringName(GameState.var_str(&"transport", "walk"))
