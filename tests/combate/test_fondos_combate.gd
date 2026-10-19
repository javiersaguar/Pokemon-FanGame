extends GutTest
## Fondos de combate según el sitio y la hora (data/battle_backgrounds.json, BattleBackgrounds y
## BattleBackground). Recorre todos los mapas sin cargarlos: lee de cada escena su MapData (id,
## exterior y nombre).

const GYM_CITIES := ["madrid", "barcelona", "valencia", "sevilla", "playa_del_ingles", "bilbao", "valladolid", "malaga"]
const PERIODS: Array[StringName] = [&"morning", &"day", &"evening", &"night"]


## {map_id: {"outdoor": bool, "display_name": String}} de todos los mapas de maps/.
func _maps() -> Dictionary:
	var out := {}
	for map_id: StringName in MapRoot.list_all():
		var text := FileAccess.get_file_as_string(MapRoot.path_from_id(map_id))
		out[String(map_id)] = _map_data(text)
	return out


static func _map_data(text: String) -> Dictionary:
	var script_id := ""
	for line: String in text.split("\n"):
		if line.begins_with("[ext_resource") and line.contains("map_data.gd"):
			script_id = line.get_slice(" id=\"", 1).get_slice("\"", 0)
	var info := {"outdoor": true, "display_name": ""}
	var inside := false
	for line: String in text.split("\n"):
		if line.begins_with("["):
			if inside:
				break
			continue
		if line == "script = ExtResource(\"%s\")" % script_id:
			inside = true
		elif inside and line.begins_with("outdoor = "):
			info["outdoor"] = line.ends_with("true")
		elif inside and line.begins_with("display_name = "):
			info["display_name"] = line.trim_prefix("display_name = ").trim_prefix("\"").trim_suffix("\"")
	return info


func test_todos_los_mapas_tienen_un_fondo_con_sentido() -> void:
	var maps := _maps()
	assert_gt(maps.size(), 900, "se recorren todos los mapas")
	var by_default: PackedStringArray = []
	var missing: PackedStringArray = []
	var count := {}
	for map_id: String in maps:
		var m: Dictionary = maps[map_id]
		var info := BattleBackgrounds.for_map(map_id, m["outdoor"], m["display_name"])
		var id: StringName = info["escena"]
		if info["regla"] == "defecto":
			by_default.append("%s (%s)" % [map_id, m["display_name"]])
		if not BattleBackgrounds.has_scene(id):
			missing.append("%s → %s" % [map_id, id])
		count[id] = int(count.get(id, 0)) + 1
	assert_eq(by_default, PackedStringArray(), "ningún mapa se queda con el fondo genérico por descuido")
	assert_eq(missing, PackedStringArray(), "todas las escenas existen")
	gut.p("Fondos por escena: %s" % str(count))


func test_los_exteriores_estan_asignados_uno_a_uno() -> void:
	var maps := _maps()
	var outdoors: Dictionary = BattleBackgrounds.data()["exteriores"]
	for map_id: String in maps:
		if maps[map_id]["outdoor"]:
			var rule := String(BattleBackgrounds.for_map(map_id, true, maps[map_id]["display_name"])["regla"])
			assert_true(rule in ["exterior", "mapa", "gimnasio"], "%s: exterior con regla %s" % [map_id, rule])
	for map_id: String in outdoors:
		assert_true(maps.has(map_id), "el exterior %s existe" % map_id)


func test_cada_tipo_de_sala_personalizada_tiene_fondo() -> void:
	var types: Dictionary = BattleBackgrounds.data()["tipos_interior"]
	for file: String in DirAccess.get_files_at(BattleBackgrounds.INTERIORS_DIR):
		if not file.ends_with(".json") or file.begins_with("_"):
			continue
		var rooms: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BattleBackgrounds.INTERIORS_DIR + file))["interiores"]
		for map_id: String in rooms:
			var kind := String(rooms[map_id].get("tipo", ""))
			assert_true(types.has(kind), "%s: el tipo '%s' necesita su fondo en tipos_interior" % [map_id, kind])
			if types.has(kind):
				assert_true(BattleBackgrounds.has_scene(StringName(types[kind])), kind)


func test_cada_escena_tiene_sus_archivos() -> void:
	for id: StringName in BattleBackgrounds.scene_ids():
		for path: String in BattleBackgrounds.files(id):
			assert_true(ResourceLoader.exists(path), "%s: falta %s" % [id, path])
		assert_ne(String(BattleBackgrounds.scene(id).get("entorno", "")), "", "%s tiene entorno" % id)


func test_cada_gimnasio_y_la_liga_tienen_un_fondo_propio() -> void:
	var fronts := {}
	for city: String in GYM_CITIES:
		for room: String in ["gimnasio_1", "gimnasio_2", "gimnasio_3", "gimnasio_lider"]:
			var map_id := "%s/%s" % [city, room]
			assert_true(ResourceLoader.exists(MapRoot.path_from_id(StringName(map_id))), "existe %s" % map_id)
			var id: StringName = BattleBackgrounds.for_map(map_id, false)["escena"]
			assert_eq(id, StringName("gimnasio_" + city), map_id)
		var scene_id := StringName("gimnasio_" + city)
		var front := BattleBackgrounds.front_path(scene_id)
		assert_ne(front, "", "%s tiene frente propio" % scene_id)
		fronts[front] = scene_id
	for liga: String in ["liga_alonso", "liga_gasol", "liga_iniesta", "liga_nadal"]:
		assert_eq(BattleBackgrounds.for_map("madrid/" + liga, false)["escena"], &"liga", liga)
	assert_eq(BattleBackgrounds.for_map("madrid/liga_sanchez", false)["escena"], &"liga_campeon")
	fronts[BattleBackgrounds.front_path(&"liga")] = &"liga"
	fronts[BattleBackgrounds.front_path(&"liga_campeon")] = &"liga_campeon"
	assert_eq(fronts.size(), 10, "diez frentes distintos: ocho gimnasios, Alto Mando y campeón")
	assert_eq(BattleBackgrounds.for_map("madrid/atico_ayuso", true)["escena"], &"gimnasio_madrid", "Ayuso combate en su terraza")


func test_tipos_de_sitio() -> void:
	var cases := {
		"madrid/centro": [true, "Madrid · Sol y Gran Vía", &"ciudad"],
		"ruta_3/exterior": [true, "", &"nieve"],
		"ruta_2/exterior": [true, "", &"bosque"],
		"ruta_7/exterior": [true, "", &"desierto"],
		"valencia/malvarrosa": [true, "", &"playa"],
		"maritima_1/exterior": [true, "", &"agua"],
		"ruta_18/exterior": [true, "", &"montana"],
		"calle_victoria/tunel": [false, "Calle de la Victoria", &"cueva_oscura"],
		"ruta_18/covadonga_cueva": [false, "Cueva", &"cueva"],
		"pozuelo/casa_jugador": [false, "Tu casa", &"casa"],
		"madrid/hospital": [false, "Hospital · Madrid", &"edificio"],
		"madrid/mercadona": [false, "Mercadona · Madrid", &"edificio"],
		"transporte/ferry_valencia_ibiza": [false, "Ferry Ibiza", &"edificio"],
		"vigo/aeropuerto": [false, "Aeropuerto de Peinador", &"edificio"],
		"madrid/sala_retiro_20_58": [false, "Estación de Atocha", &"edificio"],
		"sevilla/sala_centro_23_37": [false, "Catedral de Sevilla, Sevilla", &"monumento"],
	}
	for map_id: String in cases:
		var c: Array = cases[map_id]
		assert_eq(BattleBackgrounds.for_map(map_id, c[0], c[1])["escena"], c[2], map_id)


func test_surf_y_pesca_van_al_agua() -> void:
	assert_eq(BattleBackgrounds.for_battle(null, {}, true), &"agua", "con Surf")
	assert_eq(BattleBackgrounds.for_battle(null, {"method": "oldrod"}), &"agua", "con la caña")
	assert_eq(BattleBackgrounds.for_battle(null, {}), &"hierba", "sin mapa, el de por defecto")


func test_los_ids_antiguos_siguen_valiendo() -> void:
	for old: String in ["grass", "field", "forest", "cave", "city", "water", "indoor", "snow", "sand"]:
		assert_true(BattleBackgrounds.has_scene(BattleBackgrounds.resolve_id(StringName(old))), old)
	assert_eq(BattleBackgrounds.resolve_id(&"cave"), &"cueva")


func test_exterior_cambia_con_la_hora_y_el_interior_no() -> void:
	var skies := {}
	for p: StringName in PERIODS:
		var bg := BattleBackground.new()
		add_child_autofree(bg)
		bg.set_environment(&"hierba", p)
		var sky: Sprite2D = bg.get_node("Escena/Cielo")
		skies[p] = sky.texture.resource_path
		var tone := bg.current_tone()
		if p == &"day":
			assert_eq(tone, Vector3.ZERO, "de día, sin tinte")
		else:
			assert_ne(tone, Vector3.ZERO, "%s tiñe el fondo" % p)
			assert_not_null(bg.get_node("Escena/Fondo").material, "%s: el fondo lleva el tinte" % p)
			assert_null(sky.material, "%s: el cielo no se tiñe" % p)
	assert_ne(skies[&"day"], skies[&"night"], "el cielo de noche es otro")
	var morning := BattleBackground.new()
	add_child_autofree(morning)
	morning.set_environment(&"hierba", &"morning")
	var evening := BattleBackground.new()
	add_child_autofree(evening)
	evening.set_environment(&"hierba", &"evening")
	assert_ne(morning.current_tone(), evening.current_tone(), "la mañana y la tarde se tiñen distinto")
	assert_lt(morning.get_node("Escena/Sol").position.x, evening.get_node("Escena/Sol").position.x, "el sol sale por un lado y se pone por el otro")
	var day := BattleBackground.new()
	add_child_autofree(day)
	day.set_environment(&"hierba", &"day")
	assert_false(day.has_node("Escena/Sol"), "de día el sol queda fuera del encuadre, como en EBDX")
	assert_ne(skies[&"day"], skies[&"evening"], "el cielo de la tarde es otro")
	assert_ne(skies[&"morning"], skies[&"evening"], "el de la mañana también")
	var night := BattleBackground.new()
	add_child_autofree(night)
	night.set_environment(&"hierba", &"night")
	assert_true(night.has_node("Escena/Estrella0"), "de noche hay estrellas")
	assert_false(night.has_node("Escena/Sol"), "de noche no hay sol")
	var inside := BattleBackground.new()
	add_child_autofree(inside)
	inside.set_environment(&"gimnasio_madrid", &"night")
	assert_eq(inside.current_tone(), Vector3.ZERO, "dentro no se tiñe de noche")
	assert_false(inside.has_node("Escena/Cielo"), "dentro no hay cielo")
	assert_true(inside.has_node("Escena/Frente"), "el gimnasio tiene su frente")


func test_todas_las_escenas_se_montan() -> void:
	for id: StringName in BattleBackgrounds.scene_ids():
		var bg := BattleBackground.new()
		add_child_autofree(bg)
		bg.set_environment(id, &"night")
		assert_eq(bg.environment, id)
		assert_true(bg.has_node("Escena/Fondo"), "%s tiene fondo" % id)
		assert_not_null(bg.base_texture(), "%s tiene base" % id)


func test_prepara_el_combate_con_el_fondo_y_la_hora() -> void:
	var setup := BattleSetup.new()
	setup.background = &"gimnasio_valencia"
	SceneManager._fill_battle_place(setup, {})
	assert_eq(setup.background, &"gimnasio_valencia", "lo que viene puesto se respeta")
	assert_ne(setup.time_period, &"", "se pone el momento del día")
	assert_eq(setup.environment, &"indoor", "y el entorno de la escena")
	var fishing := BattleSetup.new()
	SceneManager._fill_battle_place(fishing, {"method": "goodrod"})
	assert_eq(fishing.background, &"agua")
	assert_eq(fishing.environment, &"fishing", "la Cebo Ball sabe que se pesca")
