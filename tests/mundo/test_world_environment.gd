extends GutTest
class WaterMap extends MapRoot:
	var terrain := "water"
	func terrain_at(_tile: Vector2i) -> String:
		return terrain
class StaticHarness extends StaticEncounterEvent:
	var calls := 0
	var last_setup: BattleSetup
	var last_context: Dictionary
	var outcome := &"run"
	func battle(setup: BattleSetup, context: Dictionary) -> StringName:
		calls += 1
		last_setup = setup
		last_context = context
		return outcome
var original: Dictionary
var statics: Dictionary
var encounters: Dictionary
func before_each() -> void:
	original = GameState.world_config.duplicate(true)
	statics = DataDB._statics.duplicate(true)
	encounters = DataDB._encounters.duplicate(true)
	GameState.new_game()
	GameState.party.add(Pokemon.create(&"pidgey", 30))
	DataDB._statics = {"fixture_static": {"species": "snorlax", "level": 10}}
func after_each() -> void:
	DataDB.clear_patch()
	DataDB._statics = statics
	DataDB._encounters = encounters
	GameState.world_config = original
	GameState.reset()
func test_tinte_exterior_por_hora_y_interior_blanco() -> void:
	var data := MapData.new()
	assert_eq(WorldAtmosphere.tint_for(data, &"day"), Color.WHITE)
	assert_ne(WorldAtmosphere.tint_for(data, &"night"), Color.WHITE)
	assert_ne(WorldAtmosphere.tint_for(data, &"morning"), WorldAtmosphere.tint_for(data, &"evening"))
	data.outdoor = false
	assert_eq(WorldAtmosphere.tint_for(data, &"night"), Color.WHITE)
func test_clima_sin_recurso_no_genera_imagenes_y_reset() -> void:
	var map := MapRoot.new()
	map.data = MapData.new()
	map.data.weather = &"rain"
	add_child_autofree(map)
	var environment := WorldAtmosphere.new()
	add_child_autofree(environment)
	environment.apply_map(map)
	assert_false(environment.particles.emitting)
	environment.reset()
	assert_eq(environment.tint.color, Color.WHITE)
	assert_eq(AudioManager.current_ambient, &"")
func test_luz_requiere_textura_y_periodo() -> void:
	var light := NightLight.new()
	add_child_autofree(light)
	light._period_changed(&"night")
	assert_false(light.enabled)
	light.texture = Character.GROUND_SHADOW # Fixture real, no máscara creada por código.
	light._period_changed(&"night")
	assert_true(light.enabled)
	light._period_changed(&"day")
	assert_false(light.enabled)
func test_tres_canas_mochila_terreno_y_tabla_parcheada() -> void:
	DataDB._encounters = {"fixture": {"old_rod_rate": 100, "good_rod_rate": 100, "super_rod_rate": 100,
		"old_rod": [{"species": "magikarp", "level": 5}], "good_rod": [{"species": "magikarp", "level": 10}],
		"super_rod": [{"species": "magikarp", "level": 20}]}}
	var map := WaterMap.new()
	map.data = MapData.new()
	map.data.encounter_table = &"fixture"
	add_child_autofree(map)
	for item: StringName in [&"oldrod", &"goodrod", &"superrod"]:
		GameState.bag.add(item)
	for kind: StringName in FieldEncounters.FISHING:
		assert_eq(FieldEncounters.roll(map, kind, Vector2i.ZERO).species, &"magikarp")
	map.terrain = "path"
	assert_eq(FieldEncounters.roll(map, &"old_rod", Vector2i.ZERO), {})
	map.terrain = "water"
	assert_eq(DataDB.apply_patch({"encounters": {"fixture": {"old_rod_rate": 100, "old_rod": [{"species": "pikachu", "level": 5}]}}}), [] as Array[String])
	assert_eq(FieldEncounters.roll(map, &"old_rod", Vector2i.ZERO).species, &"pikachu", "R.2 consulta ROM")
func test_estatico_parcheado_resuelve_ko_captura_y_huida() -> void:
	assert_eq(DataDB.apply_patch({"statics": {"fixture_static": {"species": "pikachu", "level": 10}}}), [] as Array[String])
	var event := StaticHarness.new()
	await Cutscene.play(event, null, {"static_id": "fixture_static"})
	assert_eq(event.last_setup.foe_party[0].species_id, &"pikachu")
	assert_eq(event.last_context.source, "static")
	assert_false(GameState.flag(&"static_done:fixture_static"), "huir permite volver")
	event.outcome = &"caught"
	await Cutscene.play(event, null, {"static_id": "fixture_static"})
	assert_true(GameState.flag(&"static_done:fixture_static"))
	var calls := event.calls
	await Cutscene.play(event, null, {"static_id": "fixture_static"})
	assert_eq(event.calls, calls, "no se repite captura")
func test_errante_guarda_identidad_salud_estado_y_ubicacion() -> void:
	assert_true(WorldRoamers.release(&"fixture", &"fixture_static", ["test/test_room", "test/test_outdoor"]))
	assert_false(WorldRoamers.release(&"fixture", &"fixture_static", ["test/test_room"]))
	var record: Dictionary = GameState.roamers.fixture
	var pokemon := Pokemon.from_dict(record.pokemon)
	pokemon.current_hp = 7
	pokemon.status = &"paralysis"
	WorldRoamers.resolve(&"fixture", pokemon, &"run")
	var saved := GameState.to_dict()
	GameState.reset()
	GameState.from_dict(saved)
	assert_eq(GameState.roamers.fixture.pokemon.uid, pokemon.uid)
	assert_eq(GameState.roamers.fixture.pokemon.hp, 7)
	assert_eq(GameState.roamers.fixture.pokemon.status, "paralysis")
	var location: String = GameState.roamers.fixture.map
	WorldRoamers.move_on_transition(&"")
	assert_eq(GameState.roamers.fixture.map, location, "continuar no mueve el errante")
	WorldRoamers.resolve(&"fixture", pokemon, &"caught")
	assert_eq(GameState.roamers.fixture.state, "captured")
