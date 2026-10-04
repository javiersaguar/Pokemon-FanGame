class_name DataUtil
extends RefCounted
## Conversión de valores leídos de JSON (los números llegan como float y las claves como String).


static func names(values: Variant) -> Array[StringName]:
	var out: Array[StringName] = []
	if values is Array:
		for v: Variant in values:
			out.append(StringName(str(v)))
	return out


static func strings(values: Variant) -> Array[String]:
	var out: Array[String] = []
	if values is Array:
		for v: Variant in values:
			out.append(str(v))
	return out


static func ints(values: Variant) -> Array[int]:
	var out: Array[int] = []
	if values is Array:
		for v: Variant in values:
			out.append(int(v))
	return out


static func int_dict(values: Variant) -> Dictionary[StringName, int]:
	var out: Dictionary[StringName, int] = {}
	if values is Dictionary:
		for k: Variant in values:
			out[StringName(str(k))] = int(values[k])
	return out


static func bool_dict(values: Variant) -> Dictionary[StringName, bool]:
	var out: Dictionary[StringName, bool] = {}
	if values is Dictionary:
		for k: Variant in values:
			out[StringName(str(k))] = bool(values[k])
	return out


## Ordena alfabéticamente (en el sitio). Ojo: Array.sort() con StringName NO ordena por texto
## (compara punteros), así que el orden cambiaría entre ejecuciones.
static func sort_names(values: Array) -> void:
	values.sort_custom(func(a: Variant, b: Variant) -> bool: return String(a) < String(b))
