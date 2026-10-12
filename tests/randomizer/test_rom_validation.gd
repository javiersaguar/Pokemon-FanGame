extends GutTest

const FIXTURE := "res://tests/randomizer/fixtures/mini_game.json"
var _input: RandomizerInput
var _base: Dictionary

func before_all() -> void:
	_input = RandomizerInput.from_dict(JsonFile.read_dict(FIXTURE))
	_base = Randomizer.generate(_input,RandomizerSettings.from_preset("clasico"),123).to_dict()

func _rom() -> RomPatch:
	return RomPatch.from_dict(_base)

func test_metadatos_de_semilla_y_ajustes_no_pueden_contradecir_el_codigo() -> void:
	for field: String in ["seed","seed_code","generator_version"]:
		var rom := _rom()
		rom.data[field] = {"seed":124,"seed_code":SeedCode.encode(124,rom.settings()),"generator_version":0}[field]
		assert_false(RomValidator.validate(_input,rom).is_empty(),field)
	var rom := _rom()
	rom.data.settings.nickname_required = not rom.data.settings.nickname_required
	assert_false(RomValidator.validate(_input,rom).is_empty(),"Ajustes distintos del código compartido")

func test_rom_incompleta_no_se_repara_al_validarla() -> void:
	var rom := _rom()
	rom.data.erase("shops")
	var before := rom.to_json()
	assert_false(RomValidator.validate(_input,rom).is_empty())
	assert_eq(rom.to_json(),before,"Validar no crea la tabla que falta")

func test_niveles_fraccionarios_fuera_de_rango_y_movimientos_no_textuales() -> void:
	for level: Variant in [1.5,-1,101]:
		var rom := _rom()
		rom.data.learnsets.mon00_0[0][0] = level
		assert_false(RomValidator.validate(_input,rom).is_empty(),str(level))
	var rom := _rom()
	rom.data.learnsets.mon00_0[0][1] = {"move":"normal_hit0"}
	assert_false(RomValidator.validate(_input,rom).is_empty())

func test_errores_guardados_no_se_ignoran_si_cambia_el_diccionario() -> void:
	var rom := _rom()
	rom.data.errors = ["ROM incompleta"]
	assert_false(rom.is_valid())
	assert_false(RomValidator.validate(_input,rom).is_empty())

func test_metadatos_malformados_no_se_truncan_y_el_validador_no_muta() -> void:
	for change: Dictionary in [{"seed":-1},{"seed":4294967296},{"seed":1.5},{"seed":"123"},{"generator_version":2.5},{"subseed":-1},{"subseed":25},{"subseed":.5},{"input_hash":"otra_base"}]:
		var rom := _rom()
		rom.data.merge(change,true)
		var before := rom.to_json()
		assert_false(RomValidator.validate(_input,rom).is_empty(),str(change))
		assert_eq(rom.to_json(),before)

func test_estructuras_anidadas_invalidas_devuelven_errores_sin_excepciones() -> void:
	for value: Variant in ["no_es_equipo",["no_es_miembro"],[{"species":"mon00_0","level":1.5}]]:
		var rom := _rom()
		rom.data.trainers.rival_1.party = value
		assert_false(RomValidator.validate(_input,rom).is_empty())
	for value: Variant in ["no_es_stock",["no_es_tramo"],[{"items":"no_es_lista"}]]:
		var rom := _rom()
		rom.data.shops.tienda = {"stock":value}
		assert_false(RomValidator.validate(_input,rom).is_empty())
	for kind: String in ["tm_compat","tutor_compat"]:
		var rom := _rom()
		rom.data[kind].mon00_0 = "no_es_lista"
		assert_false(RomValidator.validate(_input,rom).is_empty())
	for value: Variant in ["no_es_lista",[12]]:
		var rom := _rom()
		rom.data.species.mon00_0 = {"held_items":value}
		assert_false(RomValidator.validate(_input,rom).is_empty())

func test_rom_valida_con_preset_personalizado_y_json_conserva_sus_bytes() -> void:
	for preset: String in ["clasico","solo_aleatorio","caos"]:
		var settings := RandomizerSettings.from_preset(preset)
		settings.nickname_required = not settings.nickname_required
		var rom := Randomizer.generate(_input,settings,0xFFFFFFFF)
		assert_true(rom.is_valid(),str(rom.errors))
		var loaded := RomPatch.from_dict(JSON.parse_string(rom.to_json()))
		var before := loaded.to_json()
		assert_eq(RomValidator.validate(_input,loaded),[] as Array[String])
		assert_eq(loaded.to_json(),before)
	assert_false(RomPatch.from_dict({"input_hash":""}).is_valid())
	assert_eq(RomValidator.validate(null),["Falta la ROM que se quiere validar."] as Array[String])

func test_errores_serializados_malformados_se_recuperan_sin_excepciones() -> void:
	for value: Variant in ["no_es_lista",[12],[],["falló la generación"]]:
		var data := _base.duplicate(true)
		data.errors = value
		var rom := RomPatch.from_dict(data)
		assert_false(rom.is_valid())
		assert_false(RomValidator.validate(_input,rom).is_empty())

func test_validacion_pura_en_hilo_no_depende_del_catalogo_global_de_presets() -> void:
	var saved := RandomizerSettings._preset_catalog.duplicate(true)
	RandomizerSettings._preset_catalog = {"clasico":{"settings":{"wild":"off"}}}
	var rom := _rom()
	var before := rom.to_json()
	var thread := Thread.new()
	assert_eq(thread.start(func() -> Array[String]: return RomValidator.validate(_input,rom)),OK)
	var problems: Array[String] = thread.wait_to_finish()
	RandomizerSettings._preset_catalog = saved
	assert_eq(problems,[] as Array[String])
	assert_eq(rom.to_json(),before)

func test_valores_no_finitos_y_entrada_ausente_se_rechazan() -> void:
	for value: float in [NAN,INF,-INF]:
		var rom := _rom()
		rom.data.seed = value
		assert_false(RomValidator.validate(_input,rom).is_empty())
		rom = _rom()
		rom.data.learnsets.mon00_0[0][0] = value
		assert_false(RomValidator.validate(_input,rom).is_empty())
	assert_false(RomValidator.validate(null,_rom()).is_empty())
	assert_false(RomValidator.validate("no_es_una_rom").is_empty())
