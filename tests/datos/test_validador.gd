extends GutTest
## Validador de datos (Fase 4.6): sin errores en los datos del juego.


func test_datos_sin_errores() -> void:
	var v := DataValidator.run()
	gut.p(v.report())
	assert_eq(v.errors, PackedStringArray(), "errores del validador (ver arriba)")
