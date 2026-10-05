extends GutTest
## Interacción por física real: caras, aproximaciones, mostrador y paseo.

class TalkNPC extends NPC:
	signal released
	var calls := 0
	var hold := false
	var dialogue_facing := Vector2i.ZERO
	func _on_interact(_player: Player) -> void:
		calls += 1
		dialogue_facing = facing
		if hold:
			await released

class TalkTrainer extends TrainerNPC:
	var challenges := 0
	var spotted := true
	func challenge(value: bool) -> void:
		challenges += 1
		spotted = value

class CounterMap extends MapRoot:
	var counter := Vector2i(-100, -100)
	func terrain_at(tile: Vector2i) -> String:
		return "counter" if tile == counter else ""

var _player: Player
var _npc: TalkNPC
var _map: CounterMap

func before_each() -> void:
	GameState.new_game()
	_map = CounterMap.new()
	add_child_autofree(_map)
	SceneManager.current_map = _map
	_player = load("res://src/overworld/player/player.tscn").instantiate()
	_map.add_child(_player)
	_player.set_process(false)
	var actor = load("res://src/overworld/npc/npc.tscn").instantiate()
	actor.set_script(TalkNPC)
	_npc = actor
	_map.add_child(_npc)
	_npc.place_at(Vector2i(5, 5))

func after_each() -> void:
	SceneManager.current_map = null
	GameState.reset()

func test_dieciséis_caras_y_acercamientos() -> void:
	for original: Vector2i in Character.DIRECTIONS:
		for side: Vector2i in Character.DIRECTIONS:
			_npc.face(original)
			_player.place_at(Vector2i(5, 5) + side, -side)
			await get_tree().physics_frame
			await get_tree().physics_frame
			var calls := _npc.calls
			await _player._interact()
			assert_eq(_npc.calls, calls + 1, "cara %s, lado %s" % [original, side])
			assert_eq(_npc.dialogue_facing, side, "se gira ANTES de hablar")
			assert_false(GameState.input_locked)

func test_no_se_gira_si_el_evento_lo_impide() -> void:
	_npc.turn_on_interact = false
	_npc.face(Vector2i.UP)
	_player.place_at(Vector2i(6, 5), Vector2i.LEFT)
	await get_tree().physics_frame
	await get_tree().physics_frame
	await _player._interact()
	assert_eq(_npc.dialogue_facing, Vector2i.UP)
	_npc.turn_to_player = true
	assert_true(_npc.turn_on_interact, "propiedad de escenas antiguas compatible")

func test_mostrador_por_los_cuatro_lados() -> void:
	for side: Vector2i in Character.DIRECTIONS:
		_map.counter = Vector2i(5, 5) + side
		_player.place_at(Vector2i(5, 5) + side * 2, -side)
		await get_tree().physics_frame
		await get_tree().physics_frame
		var calls := _npc.calls
		await _player._interact()
		assert_eq(_npc.calls, calls + 1)
		assert_eq(_npc.dialogue_facing, side)

func test_paseante_termina_paso_y_permanece_quieto() -> void:
	_npc.wander = true
	_npc.wander_interval = Vector2(0.01, 0.01)
	_npc.hold = true
	_npc.step(Vector2i.RIGHT, 0.1)
	_player.place_at(Vector2i(6, 6), Vector2i.UP)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_player._interact()
	assert_true(_npc.talking)
	assert_eq(_npc.calls, 0, "no habla a mitad del paso")
	await get_tree().create_timer(0.15).timeout
	assert_eq(_npc.tile_position(), Vector2i(6, 5))
	assert_eq(_npc.calls, 1)
	assert_eq(_npc.dialogue_facing, Vector2i.DOWN)
	await get_tree().create_timer(0.12).timeout
	assert_eq(_npc.tile_position(), Vector2i(6, 5), "sin paseo durante diálogo")
	_npc.wander = false
	_npc.released.emit()
	assert_false(_npc.talking)
	assert_false(GameState.input_locked)

func test_entrenador_por_detras_y_lados_desafia() -> void:
	_npc.queue_free()
	var trainer = load("res://src/overworld/npc/npc.tscn").instantiate()
	trainer.set_script(TalkTrainer)
	trainer.trainer_id = &"rival_lab_1"
	trainer.sight_range = 0
	_map.add_child(trainer)
	trainer.place_at(Vector2i(5, 5))
	for side: Vector2i in Character.DIRECTIONS:
		trainer.face(Vector2i.UP)
		_player.place_at(Vector2i(5, 5) + side, -side)
		await get_tree().physics_frame
		await get_tree().physics_frame
		var calls: int = trainer.challenges
		await _player._interact()
		assert_eq(trainer.challenges, calls + 1)
		assert_false(trainer.spotted, "hablar no equivale a verlo")
		assert_eq(trainer.facing, side)

func test_cartel_solo_desde_abajo() -> void:
	var sign_node: MapSign = load("res://src/overworld/sign/sign.tscn").instantiate()
	_map.add_child(sign_node)
	sign_node.position = Grid.to_world(Vector2i(8, 8))
	sign_node.lines = ["Cartel de prueba"]
	for side: Vector2i in [Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
		_player.place_at(Vector2i(8, 8) + side, Vector2i.UP)
		await sign_node.interact(_player)
		assert_false(Dialogue.is_open, "rechaza posición %s incluso mirando arriba" % side)
