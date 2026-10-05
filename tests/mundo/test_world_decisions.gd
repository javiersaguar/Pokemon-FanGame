extends GutTest

var original: Dictionary
func before_each() -> void:
	original = GameState.world_config.duplicate(true)
func after_each() -> void:
	GameState.world_config = original
	GameState.reset()

func test_decisiones_de_javier_en_los_datos_reales() -> void:
	assert_eq(GameState.world_config.mvp_story.reward.quantity, 5.0)
	assert_eq(GameState.world_config.clock.mode, "real")
	GameState.new_game()
	assert_eq(GameState.money, 3000)

func test_nombres_en_un_solo_sitio_sin_inventarlos() -> void:
	for key: String in ["town", "city_2", "professor", "rival", "region"]:
		assert_eq(WorldNames.value(StringName(key)), "POR DEFINIR")
	GameState.world_config.names.professor = "Profesor de prueba"
	GameState.world_config.names.town = "Pueblo de prueba"
	assert_eq(WorldNames.resolve("{world:professor} vive en {world:town}."),
		"Profesor de prueba vive en Pueblo de prueba.")
	assert_eq(WorldNames.resolve("{player} y {starter:starter_1}"), "{player} y {starter:starter_1}",
		"los marcadores de partida y R.2 siguen disponibles para Dialogue/DataDB")

func test_nombre_de_mapa_resuelve_el_marcador() -> void:
	var map := MapRoot.new()
	map.data = MapData.new()
	map.data.display_name = "{world:city_2}"
	GameState.world_config.names.city_2 = "Ciudad de prueba"
	assert_eq(map.get_display_name(), "Ciudad de prueba")
	map.free()
