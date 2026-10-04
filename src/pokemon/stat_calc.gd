class_name StatCalc
extends RefCounted
## Fórmulas de estadísticas (3.ª generación en adelante), con el mismo redondeo que Showdown.


## PS = floor((2·Base + IV + floor(EV/4)) · Nivel / 100) + Nivel + 10
@warning_ignore("integer_division")
static func hp(base: int, iv: int, ev: int, level: int) -> int:
	return (2 * base + iv + ev / 4) * level / 100 + level + 10


## Resto = floor((floor((2·Base + IV + floor(EV/4)) · Nivel / 100) + 5) · Naturaleza)
## `nature_percent` es 110, 100 o 90.
@warning_ignore("integer_division")
static func stat(base: int, iv: int, ev: int, level: int, nature_percent: int = 100) -> int:
	var value := (2 * base + iv + ev / 4) * level / 100 + 5
	return value * nature_percent / 100


## Aplica un nivel de característica (−6..+6): max(2, 2+n) / max(2, 2−n).
@warning_ignore("integer_division")
static func apply_stage(value: int, stage: int) -> int:
	stage = clampi(stage, -6, 6)
	if stage >= 0:
		return value * (2 + stage) / 2
	return value * 2 / (2 - stage)


## Precisión o evasión: max(3, 3+n) / max(3, 3−n).
@warning_ignore("integer_division")
static func apply_accuracy_stage(value: int, stage: int) -> int:
	stage = clampi(stage, -6, 6)
	if stage >= 0:
		return value * (3 + stage) / 3
	return value * 3 / (3 - stage)
