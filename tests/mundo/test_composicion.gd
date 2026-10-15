extends GutTest

func test_paso_cerrado_de_hierba_cuenta_las_casillas_del_recorrido() -> void:
	var audit = load("res://tools/mundo/auditar_composicion.gd")
	var free := {Vector2i(0,0):true,Vector2i(1,0):true,Vector2i(2,0):true,Vector2i(3,0):true}
	var grass := {Vector2i(1,0):true,Vector2i(2,0):true}
	var starts: Array[Vector2i] = [Vector2i(0,0)]
	var costs: Dictionary = audit.minimum_encounters(free,grass,starts)
	assert_eq(costs[Vector2i(3,0)],2)
	assert_false(costs.has(Vector2i(4,0)),"la búsqueda no sale de las casillas libres")

func test_rodeo_seguro_detecta_que_la_hierba_se_puede_evitar() -> void:
	var audit = load("res://tools/mundo/auditar_composicion.gd")
	var free := {}
	for y: int in 2:
		for x: int in 3:
			free[Vector2i(x,y)] = true
	var starts: Array[Vector2i] = [Vector2i(0,0)]
	var costs: Dictionary = audit.minimum_encounters(free,{Vector2i(1,0):true},starts)
	assert_eq(costs[Vector2i(2,0)],0,"se evalúa el recorrido completo, no solo la línea recta")

func test_arranque_sobre_hierba_y_varios_accesos() -> void:
	var audit = load("res://tools/mundo/auditar_composicion.gd")
	var free := {Vector2i(0,0):true,Vector2i(1,0):true,Vector2i(2,0):true,Vector2i(8,0):true}
	var starts: Array[Vector2i] = [Vector2i(0,0),Vector2i(2,0)]
	var costs: Dictionary = audit.minimum_encounters(free,{Vector2i(0,0):true},starts)
	assert_eq(costs[Vector2i(0,0)],1)
	assert_eq(costs[Vector2i(1,0)],0)
	assert_false(costs.has(Vector2i(8,0)),"una isla desconectada no es un destino alcanzable")
