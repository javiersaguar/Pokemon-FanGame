class_name ExpCalc
extends RefCounted
## Experiencia ganada en combate: fórmula escalada de la 7.ª generación en adelante (decisión de Javier).
##   Exp = (floor(b · L / 5 · 1/s · ((2L + 10) / (L + Lp + 10))^2,5) + 1) · bonus
## b = experiencia base del derrotado, L = su nivel, Lp = nivel del que la recibe,
## s = 1 si participó y 2 si la recibe con Repartir Experiencia sin participar.
## bonus = producto de: intercambiado ×1,5, Huevo Suerte ×1,5, nivel de evolución pasado ×1,2.
## Sin bonus por combatir contra un entrenador (desde la 7.ª generación).

const TRADED_BONUS := 1.5
const PAST_EVOLUTION_BONUS := 1.2


static func battle_exp(base_exp: int, foe_level: int, own_level: int, participated: bool, bonus: float = 1.0) -> int:
	var base := float(base_exp) * foe_level / 5.0
	if not participated:
		base /= 2.0
	var scale := pow(float(2 * foe_level + 10) / float(foe_level + own_level + 10), 2.5)
	return int(floor((floor(base * scale) + 1.0) * bonus))


## Bonus de `pkmn` cuando su entrenador actual tiene el id `owner_trainer_id`.
static func bonus_for(pkmn: Pokemon, owner_trainer_id: int) -> float:
	var bonus := 1.0
	if pkmn.trainer_id != owner_trainer_id:
		bonus *= TRADED_BONUS
	if pkmn.held_item != &"" and DataDB.has_item(pkmn.held_item):
		var it := DataDB.item(pkmn.held_item)
		if it.effect == &"exp_boost":
			bonus *= float(it.param("multiplier", 1.0))
	if pkmn.is_past_evolution_level():
		bonus *= PAST_EVOLUTION_BONUS
	return bonus
