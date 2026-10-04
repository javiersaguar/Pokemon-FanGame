class_name CatchCalc
extends RefCounted
## Captura (fórmula moderna, guía 7.7):
##   a = ((3·PSmáx − 2·PS) · ratio · ball / (3·PSmáx)) · estado
##   b = 65536 / (255 / a)^0,1875 y 4 comprobaciones random(0..65535) < b.
##   Captura crítica según las especies capturadas: una sola comprobación.
## Los multiplicadores de cada Ball están en los datos (items.json → effect_params).

const SHAKE_CHECKS := 4
const STATUS_BONUS: Dictionary[StringName, float] = {
	&"slp": 2.5, &"frz": 2.5, &"par": 1.5, &"brn": 1.5, &"psn": 1.5, &"tox": 1.5,
}
## [especies capturadas mínimas (exclusivo), multiplicador] para la captura crítica.
const CRIT_TABLE: Array[Array] = [[600, 2.5], [450, 2.0], [300, 1.5], [150, 1.0], [30, 0.5]]
## Multiplicador con el que una Ball "guaranteed" (Master Ball) supera siempre el umbral.
const GUARANTEED := 1000000.0


static func catch_value(max_hp: int, hp: int, catch_rate: int, ball_multiplier: float, status: StringName) -> float:
	var hp_factor := float(3 * max_hp - 2 * hp) / float(3 * max_hp)
	return hp_factor * catch_rate * ball_multiplier * STATUS_BONUS.get(status, 1.0)


static func shake_threshold(a: float) -> int:
	if a >= 255.0:
		return 65536
	if a <= 0.0:
		return 0
	return int(65536.0 / pow(255.0 / a, 0.1875))


## Umbral (0-255) de captura crítica según cuántas especies se han capturado.
static func critical_threshold(a: float, dex_caught: int) -> int:
	for row: Array in CRIT_TABLE:
		if dex_caught > int(row[0]):
			return int(minf(a, 255.0) * float(row[1]) / 6.0)
	return 0


## Tira la captura: {caught, shakes (0-3), critical}.
static func attempt(rng: RandomNumberGenerator, a: float, dex_caught: int) -> Dictionary:
	if a >= 255.0:
		return {"caught": true, "shakes": 3, "critical": false}
	var critical := rng.randi_range(0, 255) < critical_threshold(a, dex_caught)
	var checks := 1 if critical else SHAKE_CHECKS
	var b := shake_threshold(a)
	var passed := 0
	while passed < checks and rng.randi_range(0, 65535) < b:
		passed += 1
	var caught := passed == checks
	var shakes := 1 if critical else mini(passed, 3)
	return {"caught": caught, "shakes": shakes, "critical": critical}


## Multiplicador de la Ball `ball` contra `target`. `context`: {turn, environment, time_period,
## caught_species: Dictionary, user: Battler}. Las condiciones que no se cumplen dejan ×1.
static func ball_multiplier(ball: ItemData, target: Battler, context: Dictionary = {}) -> float:
	var params := ball.effect_params
	if bool(params.get("guaranteed", false)):
		return GUARANTEED
	var species := target.pokemon.species()
	match str(params.get("formula", "")):
		"nest":
			return maxf(1.0, (41.0 - target.pokemon.level) / 10.0) if target.pokemon.level < 30 else 1.0
		"timer":
			return minf(4.0, 1.0 + int(context.get("turn", 1)) * 1229.0 / 4096.0)
		"level":
			var user: Battler = context.get("user")
			if user == null:
				return 1.0
			var lv := user.pokemon.level
			var foe := target.pokemon.level
			return 8.0 if lv >= 4 * foe else (4.0 if lv >= 2 * foe else (2.0 if lv > foe else 1.0))
		"heavy":
			return 1.0
	if params.has("ultra_beast_multiplier"):
		return float(params["ultra_beast_multiplier"]) if &"ultra_beast" in species.tags else float(params.get("multiplier", 1.0))
	var multiplier := float(params.get("multiplier", 1.0))
	var ok := true
	if params.has("if_types"):
		ok = false
		for t: Variant in params["if_types"]:
			ok = ok or target.has_type(StringName(str(t)))
	if params.has("if_environment"):
		ok = ok and str(context.get("environment", "")) in params["if_environment"]
	if bool(params.get("if_first_turn", false)):
		ok = ok and int(context.get("turn", 1)) <= 1
	if bool(params.get("if_already_caught", false)):
		ok = ok and (context.get("caught_species", {}) as Dictionary).has(species.root_species())
	if bool(params.get("if_asleep", false)):
		ok = ok and target.pokemon.status == &"slp"
	if bool(params.get("if_night_or_cave", false)):
		ok = ok and (StringName(context.get("time_period", &"")) == &"night" or StringName(context.get("environment", &"")) == &"cave")
	if bool(params.get("if_fishing", false)):
		ok = ok and StringName(context.get("environment", &"")) == &"fishing"
	if params.has("if_base_speed_at_least"):
		ok = ok and species.base_stat(&"spe") >= int(params["if_base_speed_at_least"])
	if bool(params.get("if_opposite_gender_same_species", false)):
		var user: Battler = context.get("user")
		ok = ok and user != null and user.pokemon.species().root_species() == species.root_species() \
			and user.pokemon.gender != Pokemon.GENDERLESS and target.pokemon.gender != Pokemon.GENDERLESS \
			and user.pokemon.gender != target.pokemon.gender
	if params.has("if_evolves_with_item"):
		var needed := StringName(str(params["if_evolves_with_item"]))
		var found := false
		for evo: Dictionary in species.evolutions:
			found = found or StringName(evo.get("item", "")) == needed
		ok = ok and found
	return multiplier if ok else 1.0
