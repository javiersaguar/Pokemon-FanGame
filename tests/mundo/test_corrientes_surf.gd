extends GutTest
## Corrientes marinas de Surf (Ruta marítima 1): el rectángulo de cada SurfCurrent arrastra en su
## dirección. El arrastre lo hace Player._walk mientras el jugador hace Surf.


func test_la_corriente_arrastra_dentro_de_su_rectangulo() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var current := SurfCurrent.new()
	current.position = Grid.to_world(Vector2i(4, 2)) - Grid.HALF
	current.size_tiles = Vector2i(3, 5)
	current.direction = Vector2i.LEFT
	root.add_child(current)
	assert_eq(SurfCurrent.direction_at(root, Vector2i(5, 4)), Vector2i.LEFT, "dentro")
	assert_eq(SurfCurrent.direction_at(root, Vector2i(7, 4)), Vector2i.ZERO, "fuera")
	assert_eq(SurfCurrent.direction_at(null, Vector2i(5, 4)), Vector2i.ZERO)


func test_las_acciones_de_campo_dependen_de_los_datos() -> void:
	# Qué medalla u objeto desbloquea cada una es PENDIENTE JAVIER: los datos las dejan sin objeto.
	var actions: Dictionary = GameState.world_config.get("field", {}).get("actions", {})
	for id: String in ["cut", "rock_smash", "strength", "surf", "waterfall"]:
		assert_true(actions.has(id), id)
