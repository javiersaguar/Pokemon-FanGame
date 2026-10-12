extends GutTest
## La ventana de juego cabe a escala entera y la pantalla completa no cambia el modo de vídeo.


func test_la_escala_entera_cabe_en_el_monitor() -> void:
	var base := Vector2i(512, 384)
	assert_eq(UiPreferences.integer_scale(Vector2i(2560, 1600), base), 4)
	assert_eq(UiPreferences.fitted_window(Vector2i(2560, 1600), base), Vector2i(2048, 1536))
	assert_eq(UiPreferences.integer_scale(Vector2i(1920, 1080), base), 2)
	assert_eq(UiPreferences.fitted_window(Vector2i(1920, 1080), base), Vector2i(1024, 768))
	assert_eq(UiPreferences.integer_scale(Vector2i(1280, 720), base), 1)
	assert_eq(UiPreferences.integer_scale(Vector2i(0, 0), base), 1)
	assert_eq(UiPreferences.base_size(), base)


func test_aplicar_la_pantalla_en_headless_no_toca_el_modo() -> void:
	UiPreferences.initialize()
	UiPreferences.apply_display()
	var mode := DisplayServer.window_get_mode()
	assert_ne(mode, DisplayServer.WINDOW_MODE_FULLSCREEN)
	assert_ne(mode, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
