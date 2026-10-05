extends GutTest
var original: Dictionary
func before_each() -> void:
	original = GameState.world_config.duplicate(true)
func after_each() -> void:
	GameState.world_config = original
	GameState.reset()
func test_todos_los_roles_de_prueba_existen() -> void:
	assert_eq(MvpLocations.validate("test"), PackedStringArray())
	assert_eq(MvpLocations.target(&"bedroom").spawn, "bedroom")
	assert_eq(MvpLocations.target(&"laboratory").spawn, "laboratory")
func test_no_activa_perfil_incompleto() -> void:
	assert_false(MvpLocations.activate("desconocido").is_empty())
	assert_eq(GameState.world_config.mvp_locations.profile, "test")
func test_traslado_sin_cambiar_eventos() -> void:
	GameState.world_config.mvp_locations.profiles["copia"] = {
		"start": {"map": "test/test_outdoor", "spawn": "from_room"},
		"bedroom": {"map": "test/test_room", "spawn": "bedroom"},
		"laboratory": {"map": "test/test_room", "spawn": "laboratory"},
		"healing": {"map": "test/test_room", "spawn": "laboratory"}}
	assert_eq(MvpLocations.activate("copia"), PackedStringArray())
	GameState.new_game()
	assert_eq(GameState.map_id, &"test/test_outdoor")
	assert_eq(GameState.healing_spawn, &"laboratory")
	assert_eq(MvpLocations.new_game_config().spawn, "from_room")
	assert_eq(GameState.money, 3000)
func test_detecta_spawn_ausente_sin_fallback_silencioso() -> void:
	GameState.world_config.mvp_locations.profiles["mal"] = {"start": {"map": "test/test_room", "spawn": "ausente"}}
	assert_eq(MvpLocations.validate("mal").size(), 1)
	assert_false(MvpLocations.activate("mal").is_empty())
	assert_eq(GameState.world_config.mvp_locations.profile, "test")
