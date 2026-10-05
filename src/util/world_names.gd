class_name WorldNames
extends RefCounted
## Identidades de diseño provisionales: un solo origen, sin fijarlas en el guion.
## {world:town}, {world:city_2}, {world:professor}, {world:rival}, {world:region}.
## {player}/{rival} siguen siendo las identidades elegidas y guardadas en la partida.
static func value(key: StringName) -> String:
	return str(GameState.world_config.get("names", {}).get(String(key), "POR DEFINIR"))

static func resolve(text: String) -> String:
	var names: Dictionary = GameState.world_config.get("names", {})
	for key: String in names:
		text = text.replace("{world:%s}" % key, str(names[key]))
	return text
