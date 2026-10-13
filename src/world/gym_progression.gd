class_name GymProgression
extends RefCounted
## Nivel del siguiente líder según las medallas reales de la partida.

const GYMS := "res://data/gimnasios.json"


static func next_ace_level(badges: Array[StringName]) -> int:
	var gyms: Dictionary = JsonFile.read_dict(GYMS).get("gimnasios", {})
	var ordered: Array = gyms.values()
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("orden", 0)) < int(b.get("orden", 0)))
	for gym: Dictionary in ordered:
		if StringName(str(gym.get("medalla", ""))) not in badges:
			return int(gym.get("nivel_tope", 0))
	return DataDB.MAX_LEVEL
