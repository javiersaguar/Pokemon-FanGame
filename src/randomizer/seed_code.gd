class_name SeedCode
extends RefCounted
## Códigos de semilla para compartir (Fase R.5): PANCHITO-XXXX-XXXX-XX codifica la versión del
## generador, el preset y la semilla (con una suma de control). Con ajustes personalizados se añade
## un grupo más con los ajustes: PANCHITO-XXXX-XXXX-XX-XXXXXX.
## Alfabeto Crockford base 32 (sin I, L, O ni U para no confundirlos).

const PREFIX := "PANCHITO"
const ALPHABET := "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
const VERSION_BITS := 5
const PRESET_BITS := 3
const SEED_BITS := 32
const CHECK_BITS := 10
const CUSTOM_PRESET := 7


## Código para `seed_value` (0..2³²−1) y `settings`.
static func encode(seed_value: int, settings: RandomizerSettings, version: int = Randomizer.GENERATOR_VERSION) -> String:
	var preset_index := RandomizerSettings.PRESETS.find(settings.preset) if settings.matches_preset() else CUSTOM_PRESET
	var setting_bits := settings.to_bits() if preset_index == CUSTOM_PRESET else 0
	var seed32 := seed_value & 0xFFFFFFFF
	var check := _checksum(version, preset_index, seed32, setting_bits)
	var main := (version & 0x1F)
	main = (main << PRESET_BITS) | preset_index
	main = (main << SEED_BITS) | seed32
	main = (main << CHECK_BITS) | check
	var chars := _to_base32(main, 10)
	var code := "%s-%s-%s-%s" % [PREFIX, chars.substr(0, 4), chars.substr(4, 4), chars.substr(8, 2)]
	if preset_index == CUSTOM_PRESET:
		code += "-" + _to_base32(setting_bits, _custom_chars())
	return code


## {ok, seed, settings, version, error}. `error` explica por qué no vale (texto para el jugador).
static func decode(code: String) -> Dictionary:
	var clean := code.strip_edges().to_upper().replace(" ", "")
	var fail := func(message: String) -> Dictionary:
		return {"ok": false, "error": message}
	if not clean.begins_with(PREFIX + "-"):
		return fail.call("El código debe empezar por %s-." % PREFIX)
	var body := clean.substr(PREFIX.length() + 1).replace("-", "")
	body = body.replace("O", "0").replace("I", "1").replace("L", "1")
	if body.length() != 10 and body.length() != 10 + _custom_chars():
		return fail.call("El código no tiene la longitud correcta.")
	for c: String in body:
		if ALPHABET.find(c) < 0:
			return fail.call("El código tiene caracteres que no valen (%s)." % c)
	var main := _from_base32(body.substr(0, 10))
	var check := main & ((1 << CHECK_BITS) - 1)
	main >>= CHECK_BITS
	var seed32 := main & 0xFFFFFFFF
	main >>= SEED_BITS
	var preset_index := main & ((1 << PRESET_BITS) - 1)
	var version := main >> PRESET_BITS
	var setting_bits := _from_base32(body.substr(10)) if body.length() > 10 else 0
	if _checksum(version, preset_index, seed32, setting_bits) != check:
		return fail.call("El código no es válido (¿hay alguna letra mal copiada?).")
	if version != Randomizer.GENERATOR_VERSION:
		return {"ok": false, "version": version,
			"error": "Este código es de otra versión de Pokémon Panchito (generador %d; esta es la %d)." % [version, Randomizer.GENERATOR_VERSION]}
	var settings: RandomizerSettings
	if preset_index == CUSTOM_PRESET:
		if body.length() == 10:
			return fail.call("Faltan los ajustes personalizados al final del código.")
		settings = RandomizerSettings.from_bits(setting_bits)
	elif preset_index < RandomizerSettings.PRESETS.size():
		settings = RandomizerSettings.from_preset(RandomizerSettings.PRESETS[preset_index])
	else:
		return fail.call("El código usa un preset que no existe.")
	return {"ok": true, "seed": seed32, "settings": settings, "version": version, "error": ""}


## Semilla nueva al azar (para "🎲 Aleatoria").
static func random_seed() -> int:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return int(rng.randi())


static func _custom_chars() -> int:
	return ceili(RandomizerSettings.total_bits() / 5.0)


static func _checksum(version: int, preset_index: int, seed32: int, setting_bits: int) -> int:
	var text := "%d|%d|%d|%d" % [version, preset_index, seed32, setting_bits]
	var h := 0
	for i: int in text.length():
		h = (h * 31 + text.unicode_at(i)) & 0xFFFFFF
	return h & ((1 << CHECK_BITS) - 1)


static func _to_base32(value: int, length: int) -> String:
	var out := ""
	for i: int in length:
		out = ALPHABET[value & 31] + out
		value >>= 5
	return out


static func _from_base32(text: String) -> int:
	var value := 0
	for c: String in text:
		value = (value << 5) | ALPHABET.find(c)
	return value
