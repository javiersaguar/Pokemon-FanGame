extends GutTest
## Región de Pokémon Spain (data/region.json) y personajes (data/trainers/liga.json y famosos.json):
## que todo encaje con los datos del juego (docs/mundo/).

const REGION := "res://data/region.json"


func _json(path: String) -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return data if data is Dictionary else {}


func test_la_region_tiene_las_ciudades_de_javier_con_sus_gimnasios_en_orden() -> void:
	var region := _json(REGION)
	var locations: Dictionary = region.get("locations", {})
	var leaders := {}
	for id: String in locations:
		var gym: Variant = locations[id].get("gym")
		if gym is Dictionary:
			leaders[int(gym["order"])] = id
	assert_eq(leaders, {1: "madrid", 2: "barcelona", 3: "valencia", 4: "sevilla", 5: "las_palmas",
		6: "bilbao", 7: "valladolid", 8: "malaga"})
	assert_eq(str(locations["madrid"].get("league", {}).get("place", "")), "Palacio Real")
	for id: String in ["zaragoza", "murcia", "palma", "alicante", "vigo", "sur_de_madrid", "pamplona",
			"puertollano", "san_miguel_de_bernuy", "santander", "ibiza"]:
		assert_true(locations.has(id), "falta %s" % id)


func test_las_casillas_estan_dentro_del_mapa_y_las_rutas_unen_cosas_que_existen() -> void:
	var region := _json(REGION)
	var size: Array = region["size"]
	var locations: Dictionary = region["locations"]
	var routes: Dictionary = region["routes"]
	for id: String in locations:
		var cell: Array = locations[id]["cell"]
		assert_true(int(cell[0]) >= 0 and int(cell[0]) < int(size[0]) and int(cell[1]) >= 0 and int(cell[1]) < int(size[1]), id)
	var places := {}
	for id: String in locations:
		places[id] = true
	for id: String in routes:
		places[id] = true
	for id: String in region.get("landmarks", {}):
		places[id] = true
	for id: String in routes:
		var route: Dictionary = routes[id]
		assert_true(places.has(str(route["from"])), "%s: origen %s" % [id, route["from"]])
		assert_true(places.has(str(route["to"])), "%s: destino %s" % [id, route["to"]])
		for cell: Array in route["cells"]:
			assert_true(int(cell[0]) >= 0 and int(cell[0]) < int(size[0]) and int(cell[1]) >= 0 and int(cell[1]) < int(size[1]), "%s fuera del mapa" % id)
	# Ibiza se alcanza con Surf desde Palma (decisión de Javier).
	assert_eq(str(routes["maritima_1"]["kind"]), "surf")
	assert_eq([str(routes["maritima_1"]["from"]), str(routes["maritima_1"]["to"])], ["palma", "ibiza"])


func test_cada_personaje_tiene_clase_sprites_y_un_equipo_valido() -> void:
	for file: String in ["res://data/trainers/liga.json", "res://data/trainers/famosos.json"]:
		var trainers := _json(file)
		assert_false(trainers.is_empty(), file)
		for id: String in trainers:
			var trainer := TrainerData.get_trainer(StringName(id))
			assert_false(trainer.is_empty(), id)
			assert_false(str(trainer.get("class_name", "")).is_empty(), "%s sin título" % id)
			assert_true(ResourceLoader.exists(str(trainer["battle_sprite"])), "%s sin sprite de combate" % id)
			assert_true(ResourceLoader.exists(str(trainer["overworld_sprite"])), "%s sin sprite del mapa" % id)
			var party: Array = trainers[id]["party"]
			assert_between(party.size(), 1, 6, id)
			for member: Dictionary in party:
				assert_true(DataDB.has_species(StringName(str(member["species"]))), "%s: %s" % [id, member["species"]])


func test_los_lideres_el_alto_mando_y_el_lider_supremo_son_los_de_javier() -> void:
	var expected := {"ayuso": "Líder", "laporta": "Líder", "labrador": "Líder", "joaquin": "Líder", "quevedo": "Líder",
		"aupa_athletic": "Líder", "latasa": "Líder", "banderas": "Líder", "iniesta": "Alto Mando", "nadal": "Alto Mando",
		"gasol": "Alto Mando", "alonso": "Alto Mando", "pedro_sanchez": "Líder Supremo"}
	for id: String in expected:
		assert_eq(str(TrainerData.get_trainer(StringName(id)).get("class_name", "")), expected[id], id)
