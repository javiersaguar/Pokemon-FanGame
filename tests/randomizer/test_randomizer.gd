extends GutTest
## Motor de RandomLocke (Fase R.6): códigos de semilla, determinismo, robustez, reglas y rendimiento.
## Integración con datos reales; cobertura de 200/1000 semillas por preset en test_fixture_engine.gd.
## Con PANCHITO_UPDATE_GOLDEN=1 se rehace el parche dorado.

const GOLDEN_PATH := "res://tests/randomizer/golden_clasico_v2.json"
const GOLDEN_SEED := 20261004

var _saved: Dictionary


func before_all() -> void:
	_saved = {"starters": DataDB._starters, "gifts": DataDB._gifts, "statics": DataDB._statics}
	if DataDB._starters.is_empty():
		DataDB._starters = {"starter_1": {"species": "bulbasaur", "level": 5}, "starter_2": {"species": "charmander", "level": 5}, "starter_3": {"species": "squirtle", "level": 5}}
	if DataDB._gifts.is_empty():
		DataDB._gifts = {"gift_prueba": {"species": "eevee", "level": 10}}
	if DataDB._statics.is_empty():
		DataDB._statics = {"static_prueba": {"species": "snorlax", "level": 30, "randomize": false}}


func after_all() -> void:
	DataDB.clear_patch()
	DataDB._starters = _saved["starters"]
	DataDB._gifts = _saved["gifts"]
	DataDB._statics = _saved["statics"]


func _clasico() -> RandomizerSettings:
	return RandomizerSettings.from_preset("clasico")


# --- Códigos de semilla (R.5) ---

func test_codigo_de_semilla_de_un_preset() -> void:
	var code := SeedCode.encode(123456789, _clasico())
	assert_true(code.begins_with("PANCHITO-"))
	assert_eq(code.length(), "PANCHITO-XXXX-XXXX-XX".length())
	var decoded := SeedCode.decode(code)
	assert_true(decoded["ok"], str(decoded.get("error")))
	assert_eq(decoded["seed"], 123456789)
	assert_eq((decoded["settings"] as RandomizerSettings).to_dict(), _clasico().to_dict())
	assert_true(SeedCode.decode(code.to_lower())["ok"], "no distingue mayúsculas")


func test_codigo_con_ajustes_personalizados() -> void:
	var s := _clasico()
	s.wild = "chaos"
	s.strength_tolerance = 42
	s.preset = RandomizerSettings.CUSTOM
	var code := SeedCode.encode(4294967295, s)
	var decoded := SeedCode.decode(code)
	assert_true(decoded["ok"], str(decoded.get("error")))
	assert_eq(decoded["seed"], 4294967295)
	var back: RandomizerSettings = decoded["settings"]
	assert_eq(back.wild, "chaos")
	assert_eq(back.strength_tolerance, 42)
	assert_eq(back.to_bits(), s.to_bits())


func test_codigos_no_validos() -> void:
	var code := SeedCode.encode(1, _clasico())
	var broken := code.substr(0, code.length() - 1) + ("A" if code.ends_with("B") else "B")
	assert_false(SeedCode.decode(broken)["ok"], "suma de control")
	assert_false(SeedCode.decode("HOLA-1234")["ok"])
	var other_version := SeedCode.encode(1, _clasico(), Randomizer.GENERATOR_VERSION + 1)
	var result := SeedCode.decode(other_version)
	assert_false(result["ok"])
	assert_string_contains(str(result["error"]), "otra versión")


# --- Determinismo (R.6) ---

func test_misma_semilla_misma_rom() -> void:
	var a := Randomizer.generate(777, _clasico())
	var b := Randomizer.generate(777, _clasico())
	assert_eq(a.to_json(), b.to_json())
	assert_ne(a.to_json(), Randomizer.generate(778, _clasico()).to_json())
	assert_eq(a.seed_code(), SeedCode.encode(777, _clasico()))


func test_parche_dorado() -> void:
	var rom := Randomizer.generate(GOLDEN_SEED, _clasico())
	var fingerprint := _data_fingerprint()
	if OS.get_environment("PANCHITO_UPDATE_GOLDEN") == "1" or not FileAccess.file_exists(GOLDEN_PATH):
		var f := FileAccess.open(GOLDEN_PATH, FileAccess.WRITE)
		f.store_string(JSON.stringify({"fingerprint": fingerprint, "rom": rom.data}, "\t", true) + "\n")
		f.close()
		pass_test("Parche dorado regenerado.")
		return
	var golden := JsonFile.read_dict(GOLDEN_PATH)
	if golden.get("fingerprint") != fingerprint:
		pending("Los datos de entrada han cambiado: rehaz el parche dorado (PANCHITO_UPDATE_GOLDEN=1).")
		return
	var expected := JSON.stringify(golden["rom"], "\t", true)
	var actual := JSON.stringify(JSON.parse_string(rom.to_json()), "\t", true)
	assert_eq(actual, expected, "mismos datos y misma semilla → mismo parche, byte a byte")


## Huella de todo lo que lee el generador: si cambia, el parche dorado deja de valer.
func _data_fingerprint() -> String:
	var inputs := {
		"version": Randomizer.GENERATOR_VERSION,
		"meta": DataDB.meta().get("sources", {}),
		"config": JsonFile.read_dict(Randomizer.CONFIG_PATH),
		"encounters": _all(DataDB.encounter_ids(), func(id: StringName) -> Dictionary: return DataDB.encounter_table(id)),
		"trainers": _all(DataDB.trainer_ids(), func(id: StringName) -> Dictionary: return DataDB.trainer(id)),
		"starters": DataDB._starters, "gifts": DataDB._gifts, "statics": DataDB._statics, "trades": DataDB._trades,
		"items": DataDB.item_placements(), "regional": DataDB.regional_dex(),
	}
	return JSON.stringify(inputs, "", true).sha256_text()


func _all(ids: Array[StringName], getter: Callable) -> Dictionary:
	var out := {}
	for id: StringName in ids:
		out[String(id)] = getter.call(id)
	return out


# --- Robustez y reglas (R.4) ---

func test_muchas_semillas_pasan_la_validacion() -> void:
	var count := 20
	var failed: PackedStringArray = []
	for i: int in count:
		var seed_value := i * 7919 + 1
		for preset: String in ["clasico", "caos"] if i % 10 == 0 else ["clasico"]:
			var r := Randomizer.new()
			r.seed_value = seed_value
			r.settings = RandomizerSettings.from_preset(preset)
			r.run()
			if not r.problems.is_empty():
				failed.append("%s/%d: %s" % [preset, seed_value, r.problems[0]])
	assert_eq(failed, PackedStringArray(), "%d semillas" % count)


func test_reglas_de_equilibrio() -> void:
	var rom := Randomizer.generate(99, _clasico())
	var starters: Array = rom.section("starters").values()
	assert_eq(starters.size(), 3)
	var s1 := DataDB.species(StringName(starters[0])).types[0]
	var s2 := DataDB.species(StringName(starters[1])).types[0]
	var s3 := DataDB.species(StringName(starters[2])).types[0]
	assert_gt(DataDB.type_effectiveness(s2, [s1]), 1.0, "starter_2 gana a starter_1")
	assert_gt(DataDB.type_effectiveness(s3, [s2]), 1.0, "starter_3 gana a starter_2")
	assert_gt(DataDB.type_effectiveness(s1, [s3]), 1.0, "starter_1 gana a starter_3")
	for id: Variant in starters:
		var s := DataDB.species(StringName(id))
		assert_eq(s.prevo, &"", "%s es la primera etapa" % id)
		assert_false(s.is_legendary or s.is_mythical, "%s no es legendario" % id)
	for table_id: String in rom.section("encounters"):
		for species: StringName in RomValidator.wild_species(rom):
			var s := DataDB.species(species)
			assert_false(s.is_legendary or s.is_mythical, "sin legendarios en las rutas iniciales (%s)" % species)
	# El rival lleva la línea del inicial con ventaja: rival_lab_1 (Charmander) → la línea de starter_2.
	var rival: Dictionary = rom.section("trainers").get("rival_lab_1", {})
	if not rival.is_empty():
		assert_eq(rival["party"][0]["species"], starters[1])
	assert_eq(rom.section("statics").size(), 0, "los que tienen randomize: false no cambian")


func test_cada_especie_tiene_ataque_con_stab_al_nivel_1() -> void:
	var rom := Randomizer.generate(5, _clasico())
	for id: StringName in RomValidator.species_in_play(rom):
		var moves := RomValidator.default_moves(rom, id, 1)
		if moves.is_empty():
			continue
		var stab := false
		for m: StringName in moves:
			stab = stab or (RomValidator.is_damaging(m) and DataDB.move(m).type in DataDB.species(id).types)
		assert_true(stab, "%s tiene un ataque con STAB al nivel 1 (%s)" % [id, moves])


func test_la_rom_se_aplica_a_datadb() -> void:
	var rom := Randomizer.generate(31337, _clasico())
	var new_species: String = rom.section("encounters")["ruta_1"]["land"]["day"][0]["species"]
	rom.apply()
	assert_eq(DataDB.encounter_table(&"ruta_1")["land"]["day"][0]["species"], new_species)
	assert_eq(String(DataDB.starter(&"starter_1")), str(rom.section("starters")["starter_1"]))
	DataDB.clear_patch()
	assert_eq(DataDB.encounter_table(&"ruta_1")["land"]["day"][0]["species"], "pidgey")


func test_se_genera_rapido() -> void:
	if not FileAccess.file_exists("res://data/generated/species.json"):
		pending("Rendimiento omitido: todavía no existen datos reales.")
		return
	var t0 := Time.get_ticks_msec()
	var caos := Randomizer.generate(1, RandomizerSettings.from_preset("caos"))
	var elapsed := Time.get_ticks_msec() - t0
	gut.p("ROM 'caos' generada en %d ms" % elapsed)
	assert_not_null(caos)
	assert_lt(elapsed, 3000, "menos de 3 s (R.4)")


func test_registro_de_spoilers() -> void:
	var rom := Randomizer.generate(8, _clasico())
	var text := rom.spoiler_text()
	assert_string_contains(text, rom.seed_code())
	assert_string_contains(text, "Iniciales:")
	assert_string_contains(text, DataDB.species(StringName(rom.section("starters")["starter_1"])).name)
