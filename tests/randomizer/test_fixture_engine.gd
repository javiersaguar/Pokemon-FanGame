extends GutTest

const FIXTURE := "res://tests/randomizer/fixtures/mini_game.json"
const GOLDEN := "res://tests/randomizer/fixtures/golden_v2.json"
var _input: RandomizerInput

func before_all() -> void:
	_input = RandomizerInput.from_dict(JsonFile.read_dict(FIXTURE))

func _settings() -> RandomizerSettings:
	return RandomizerSettings.from_preset("clasico")

func test_entrada_40_especies_sin_dependencias_y_sin_mutacion() -> void:
	assert_eq(_input.species_ids().size(), 40)
	var before := JSON.stringify(_input.to_dict(), "", true)
	var rom := Randomizer.generate(_input, _settings(), 321)
	assert_true(rom.is_valid(), str(rom.errors))
	assert_eq(JSON.stringify(_input.to_dict(), "", true), before)
	assert_eq(rom.data.input_hash, _input.fingerprint)

func test_parche_dorado_fixture_no_se_omite_si_cambia() -> void:
	var rom := Randomizer.generate(_input, _settings(), 20261004)
	assert_true(rom.is_valid(), str(rom.errors))
	assert_true(FileAccess.file_exists(GOLDEN))
	if FileAccess.file_exists(GOLDEN):
		assert_eq(rom.to_json() + "\n", FileAccess.get_file_as_string(GOLDEN))

func test_200_semillas_y_1000_en_modo_lento() -> void:
	var count := 1000 if OS.get_environment("PANCHITO_LONG_TESTS") == "1" else 200
	var failures: Array[String] = []
	for seed_number: int in count:
		for preset_id: String in ["clasico", "solo_aleatorio", "caos"]:
			var rom := Randomizer.generate(_input, RandomizerSettings.from_preset(preset_id), seed_number * 7919)
			if not rom.is_valid() or not RomValidator.validate(_input, rom).is_empty():
				failures.append("%s/%d: %s" % [preset_id, seed_number, str(rom.errors)])
				if failures.size() >= 5:
					break
		if failures.size() >= 5:
			break
	assert_eq(failures, [] as Array[String], "%d semillas por preset" % count)

func test_aislamiento_modulos_y_orden_de_diccionario() -> void:
	var a := Randomizer.generate(_input, _settings(), 25)
	var settings := _settings()
	settings.items = false
	var b := Randomizer.generate(_input, settings, 25)
	for section: String in ["starters", "encounters", "trainers", "learnsets", "abilities", "gifts", "statics", "trades"]:
		assert_eq(a.section(section), b.section(section), section)
	var reversed: Dictionary = _input.to_dict()
	for table: String in RandomizerInput.TABLES:
		var reordered: Dictionary = {}
		var keys: Array = reversed[table].keys()
		keys.reverse()
		for key: Variant in keys:
			reordered[key] = reversed[table][key]
		reversed[table] = reordered
	var c := Randomizer.generate(RandomizerInput.from_dict(reversed), _settings(), 25)
	assert_eq(a.to_json(), c.to_json())

func test_todos_los_modulos_protegen_randomize_false() -> void:
	var settings := RandomizerSettings.from_preset("caos")
	settings.tm_content = true
	settings.tm_compat = true
	settings.tutor_content = true
	settings.tutor_compat = true
	var rom := Randomizer.generate(_input, settings, 33)
	assert_true(rom.is_valid(), str(rom.errors))
	for section: String in ["species", "learnsets", "abilities", "tm_compat", "tutor_compat"]:
		assert_false(rom.section(section).has("panchito"), section)
	assert_false(rom.section("encounters").has("reserva"))
	assert_false(rom.section("trainers").has("guion"))
	assert_false(rom.section("statics").has("guion"))
	assert_false(rom.section("items").has("pueblo/bici"))
	assert_false(rom.section("tm_moves").has("tm_field"))
	assert_eq(rom.section("encounters")["ruta_1"].land.night[1], _input.data.encounters.ruta_1.land.night[1])

func test_mapeo_global_inyectivo_y_por_zone_id() -> void:
	var settings := _settings()
	settings.wild = "global"
	var rom := Randomizer.generate(_input, settings, 12)
	assert_true(rom.is_valid(), str(rom.errors))
	var values: Array = rom.section("species_map").values()
	var unique: Dictionary = {}
	for id: Variant in values:
		unique[id] = true
	assert_eq(unique.size(), values.size())
	for table_id: String in rom.section("encounters"):
		var before: Array[Dictionary] = RomValidator._entries(_input.data.encounters[table_id])
		var after: Array[Dictionary] = RomValidator._entries(rom.section("encounters")[table_id])
		for i: int in before.size():
			if before[i].get("randomize", true) and _input.mutable_species(StringName(before[i].species)):
				assert_eq(after[i].species, rom.section("species_map")[before[i].species])

func test_mt_tutores_y_tiendas_porcentaje_extremos() -> void:
	var settings := _settings()
	settings.tm_compat = true
	settings.tutor_compat = true
	settings.tm_content = true
	settings.tutor_content = true
	settings.tm_percent = 0
	settings.tutor_percent = 100
	settings.shops = true
	var rom := Randomizer.generate(_input, settings, 80)
	assert_true(rom.is_valid(), str(rom.errors))
	for id: String in rom.section("tm_compat"):
		assert_eq(rom.section("tm_compat")[id], [])
		assert_eq(rom.section("tutor_compat")[id].size(), _input.data.tutor_moves.size())
	var stock: Array = rom.section("shops").tienda.stock[0].items
	assert_has(stock, "pokeball")
	assert_has(stock, "potion")
	assert_false(rom.section("species").is_empty(), "objetos equipados de salvajes")

func test_parche_y_seed_code_roundtrip_todos_ajustes() -> void:
	var settings := _settings()
	settings.shiny_denominator = 100
	settings.battle_items = "limited"
	settings.battle_item_limit = 2
	settings.tm_percent = 73
	settings.gifts = false
	settings.level_cap = true
	settings.preset = "personalizado"
	var code := SeedCode.encode(4294967295, settings)
	var decoded := SeedCode.decode(code)
	assert_true(decoded.ok, str(decoded.get("error", "")))
	assert_eq(decoded.settings.to_dict(), settings.to_dict())
	var rom := Randomizer.generate(_input, settings, decoded.seed)
	assert_true(rom.is_valid(), str(rom.errors))
	var loaded := RomPatch.from_dict(JSON.parse_string(rom.to_json()))
	assert_eq(loaded.to_json(), rom.to_json())
	assert_eq(RomValidator.validate(_input, loaded), [] as Array[String])
	var bad := SeedCode.encode(1, _settings()) + "-" + settings.payload()
	assert_false(SeedCode.decode(bad).ok)

func test_validacion_rechaza_parche_corrupto_y_progreso_perdido() -> void:
	var rom := Randomizer.generate(_input, _settings(), 92)
	rom.data.items["pueblo/bici"] = "potion"
	rom.data.encounters["ruta_1"].land.day[0].species = "no_existe"
	rom.data.abilities["mon00_0"] = {"0": "wonderguard"}
	assert_gt(RomValidator.validate(_input, rom).size(), 2)
	var source := _input.to_dict()
	source.required_moves = ["no_existe"]
	var failed := Randomizer.generate(RandomizerInput.from_dict(source), _settings(), 10)
	assert_false(failed.is_valid())
	assert_eq(failed.seed_code(), SeedCode.encode(10, _settings()), "reintentos sin cambiar código")

func test_aprendizaje_stab_preferencia_y_potencia() -> void:
	var rom := Randomizer.generate(_input, _settings(), 88)
	assert_true(rom.is_valid(), str(rom.errors))
	for id: String in rom.section("learnsets"):
		var types: Array[StringName] = _input.species(StringName(id)).types
		var first := RomValidator.default_moves(rom, StringName(id), 1)
		assert_true(first.any(func(m: StringName) -> bool: return RomValidator.is_damaging(m, _input) and _input.move(m).type in types), id)
		var stab_count := 0
		for entry: Array in rom.section("learnsets")[id]:
			var move := _input.move(StringName(entry[1]))
			if move.type in types:
				stab_count += 1
			var cap := 9999
			for row: Array in _input.data.config.power_caps:
				if int(entry[0]) <= int(row[0]):
					cap = int(row[1])
					break
			assert_lte(move.power, cap)
		assert_gte(stab_count, ceili(rom.section("learnsets")[id].size() / 2.0), id)

func test_evoluciones_rival_as_y_estadisticas() -> void:
	var settings := _settings()
	settings.base_stats = true
	var rom := Randomizer.generate(_input, settings, 103)
	assert_true(rom.is_valid(), str(rom.errors))
	var rival_root: String = rom.section("starters").starter_2
	assert_eq(rom.section("trainers").get("rival_1", _input.data.trainers.rival_1).party[0].species, rival_root)
	for id: String in rom.section("species"):
		if rom.section("species")[id].has("base_stats"):
			assert_eq(RomValidator._bst(rom.section("species")[id].base_stats), RomValidator._bst(_input.species(StringName(id)).base_stats))

func test_diccionario_y_settings_producen_mismos_bytes() -> void:
	var settings := _settings()
	var a := Randomizer.generate(_input, settings, 56)
	var b := Randomizer.generate(_input, settings.to_dict(), 56)
	assert_eq(a.to_json(), b.to_json())
	assert_eq(SeedCode.encode(56, settings), SeedCode.encode(56, settings.to_dict()))
	var decoded := SeedCode.decode(b.seed_code())
	assert_true(decoded.ok)
	assert_eq(Randomizer.generate(_input, decoded.settings, decoded.seed).to_json(), a.to_json())

func test_reglas_progreso_preservan_objeto_y_mt_accesible() -> void:
	var source := _input.to_dict()
	source.required_items = ["bicycle", "oranberry"]
	source.required_moves = ["normal_hit0"]
	source.tm_compat["mon00_0"] = ["tm_1", "tm_field"]
	var input := RandomizerInput.from_dict(source)
	var settings := _settings()
	settings.tm_compat = true
	settings.tm_content = true
	settings.tm_percent = 0
	settings.shops = true
	var rom := Randomizer.generate(input, settings, 28)
	assert_true(rom.is_valid(), str(rom.errors))
	assert_false(rom.section("items").has("ruta_1/suelo"))
	assert_has(rom.section("tm_compat")["mon00_0"], "tm_field")
	assert_eq(RomValidator.validate(input, rom), [] as Array[String])

func test_configuracion_invalida_y_semilla_version_1() -> void:
	assert_false(RandomizerSettings.errors({"starters": "inventado"}).is_empty())
	assert_false(RandomizerSettings.errors({"strength_tolerance": 101}).is_empty())
	assert_false(RandomizerSettings.errors({"shiny_denominator": 10}).is_empty())
	var settings := _settings()
	settings.strength_tolerance = 101
	assert_false(Randomizer.generate(_input, settings, 1).is_valid())
	# Código v1 real del dorado heredado, también reconoce personalizados de longitud antigua.
	var legacy: Dictionary = JsonFile.read_dict("res://tests/randomizer/golden_clasico.json")
	var result := SeedCode.decode(str(legacy.get("rom", {}).get("seed_code", "PANCHITO-1000-0000-00")))
	assert_false(result.ok)
	assert_string_contains(str(result.error), "otra versión")

func test_familias_parcheadas_para_duplicados() -> void:
	var families := _input.families()
	assert_eq(families.mon00_0, families.mon00_2)
	assert_ne(families.mon00_0, families.mon01_0)
	var rom := Randomizer.generate(_input, RandomizerSettings.from_preset("caos"), 4)
	assert_true(rom.is_valid(), str(rom.errors))
	var randomized_families := _input.families(rom)
	for id: String in rom.section("species"):
		for edge: Dictionary in rom.section("species")[id].get("evolutions", []):
			assert_eq(randomized_families[id], randomized_families[edge.to])

func test_validador_rechaza_ciclos_y_registros_malformados() -> void:
	var rom := Randomizer.generate(_input, _settings(), 2)
	rom.data.species["mon00_0"] = {"evolutions": [{"to": "mon00_0", "method": "level", "level": 16}]}
	assert_false(RomValidator.validate(_input, rom).is_empty())
	rom = Randomizer.generate(_input, _settings(), 2)
	rom.data.learnsets["mon00_0"] = [["mal"]]
	assert_false(RomValidator.validate(_input, rom).is_empty())
	assert_false(Randomizer.generate(_input, {"strength_tolerance": -1}, 2).is_valid())
	assert_eq(SeedCode.encode(2, {"strength_tolerance": -1}), "")
