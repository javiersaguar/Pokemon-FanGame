extends GutTest
## TrainerNPC (Fase 10.4, contratos.md §9.8): línea de visión, desafío, pareja y derrotado.
## El combate es falso (gana al momento) para no depender de la BattleScene.

const TRAINER_SCENE := preload("res://src/overworld/trainers/trainer_npc.tscn")
const PLAYER_SCENE := preload("res://src/overworld/player/player.tscn")
const TRAINER_ID := &"ruta1_manolo"
const PARTNER_ID := &"rival_lab_1"


class FakeChallenge extends "res://src/overworld/trainers/trainer_challenge_event.gd":
	static var fought: Array[StringName] = []
	static var group_formats: Array[int] = []

	func battle(t: TrainerNPC) -> StringName:
		fought.append(t.trainer_id)
		GameState.set_flag(StringName(TrainerNPC.DEFEATED_FLAG % t.trainer_id))
		return SceneManager.OUTCOME_WIN

	func battle_group(group: Array[TrainerNPC]) -> StringName:
		group_formats.append(group_setup(group).format)
		for t: TrainerNPC in group:
			fought.append(t.trainer_id)
			GameState.set_flag(StringName(TrainerNPC.DEFEATED_FLAG % t.trainer_id))
		return SceneManager.OUTCOME_WIN

var _world: Node2D
var _player: Player
var _saved_player: Player
var _saved_speed: int


func before_each() -> void:
	GameState.reset()
	FakeChallenge.fought.clear()
	FakeChallenge.group_formats.clear()
	_saved_speed = Dialogue.text_speed
	Dialogue.text_speed = 0
	_world = Node2D.new()
	add_child_autofree(_world)
	_player = PLAYER_SCENE.instantiate()
	_world.add_child(_player)
	_saved_player = SceneManager.player
	SceneManager.player = _player


func after_each() -> void:
	SceneManager.player = _saved_player
	Dialogue.text_speed = _saved_speed
	GameState.clear_input_locks()
	# El último aceptar aún suena al acabar: dejar al servidor liberar las voces.
	for voice: AudioStreamPlayer in AudioManager._se:
		voice.stop()
		voice.stream = null
	await wait_process_frames(2)


func _trainer(id: StringName, tile: Vector2i, facing: Vector2i, sight := 4) -> TrainerNPC:
	var t: TrainerNPC = TRAINER_SCENE.instantiate()
	t.name = String(id)
	t.trainer_id = id
	t.sight_range = sight
	t.challenge_event = FakeChallenge
	_world.add_child(t)
	t.place_at(tile, facing)
	return t


func _wall(tile: Vector2i) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	(shape.shape as RectangleShape2D).size = Vector2(28, 28)
	body.add_child(shape)
	body.position = Grid.to_world(tile)
	_world.add_child(body)


func _press_accept() -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = &"accept"
		event.pressed = pressed
		Input.parse_input_event(event)


## Espera a que acabe la cinemática pasando los diálogos.
func _finish_cutscene(timeout := 6.0) -> void:
	var waited := 0.0
	while (Cutscene.is_running() or Dialogue.is_open) and waited < timeout:
		if Dialogue.is_open:
			_press_accept()
		await wait_physics_frames(2)
		waited += 2.0 / Engine.physics_ticks_per_second


func test_sees_in_a_straight_line_up_to_its_range() -> void:
	var t := _trainer(TRAINER_ID, Vector2i(6, 5), Vector2i.LEFT)
	await wait_physics_frames(2)
	assert_true(t.can_see(Vector2i(5, 5)), "justo delante")
	assert_true(t.can_see(Vector2i(2, 5)), "a 4 casillas")
	assert_false(t.can_see(Vector2i(1, 5)), "a 5, fuera de alcance")
	assert_false(t.can_see(Vector2i(7, 5)), "detrás")
	assert_false(t.can_see(Vector2i(5, 4)), "en diagonal")


func test_walls_and_defeat_block_the_sight() -> void:
	var t := _trainer(TRAINER_ID, Vector2i(6, 5), Vector2i.LEFT)
	_wall(Vector2i(4, 5))
	await wait_physics_frames(2)
	assert_true(t.can_see(Vector2i(5, 5)))
	assert_false(t.can_see(Vector2i(3, 5)), "la pared tapa")
	GameState.set_flag(&"trainer_defeated:ruta1_manolo")
	assert_false(t.can_see(Vector2i(5, 5)), "derrotado ya no te ve")


func test_spotting_the_player_walks_up_and_battles() -> void:
	var t := _trainer(TRAINER_ID, Vector2i(6, 5), Vector2i.LEFT)
	_player.place_at(Vector2i(2, 5), Vector2i.UP)
	await wait_physics_frames(2)
	EventBus.player_stepped.emit(_player.tile_position())
	assert_true(GameState.input_locked, "bloquea al jugador en el mismo paso")
	await _finish_cutscene()
	assert_eq(t.tile_position(), Vector2i(3, 5), "se ha acercado hasta quedarse delante")
	assert_eq(_player.facing, Vector2i.RIGHT, "el jugador le mira")
	assert_eq(FakeChallenge.fought, [TRAINER_ID] as Array[StringName])
	assert_true(t.is_defeated())
	assert_false(GameState.input_locked, "devuelve el control")


func test_out_of_sight_steps_do_nothing() -> void:
	_trainer(TRAINER_ID, Vector2i(6, 5), Vector2i.LEFT)
	_player.place_at(Vector2i(6, 8))
	await wait_physics_frames(2)
	EventBus.player_stepped.emit(_player.tile_position())
	assert_false(Cutscene.is_running())
	assert_true(FakeChallenge.fought.is_empty())


func test_pair_challenges_together_when_either_sees_you() -> void:
	var a := _trainer(TRAINER_ID, Vector2i(6, 5), Vector2i.LEFT)
	var b := _trainer(PARTNER_ID, Vector2i(6, 6), Vector2i.DOWN)
	a.partner = a.get_path_to(b)
	_player.place_at(Vector2i(6, 9), Vector2i.UP)
	await wait_physics_frames(2)
	assert_eq(b.partner_node(), a, "el enlace vale en los dos sentidos")
	EventBus.player_stepped.emit(_player.tile_position())
	await _finish_cutscene()
	assert_eq(FakeChallenge.fought, [PARTNER_ID, TRAINER_ID] as Array[StringName], "primero el que te ha visto")
	assert_eq(FakeChallenge.group_formats,[BattleSetup.Format.DOUBLE],"Un solo combate doble")
	assert_eq(a.facing, Vector2i.DOWN, "la pareja también te mira")


func test_talking_before_battle_challenges_without_walking() -> void:
	var t := _trainer(TRAINER_ID, Vector2i(3, 5), Vector2i.DOWN, 0)
	_player.place_at(Vector2i(2, 5), Vector2i.RIGHT)
	await wait_physics_frames(2)
	t.interact(_player)
	await _finish_cutscene()
	assert_eq(t.tile_position(), Vector2i(3, 5))
	assert_eq(t.facing, Vector2i.LEFT, "se gira hacia el jugador")
	assert_eq(FakeChallenge.fought, [TRAINER_ID] as Array[StringName])


func test_defeated_trainer_says_after_text() -> void:
	var t := _trainer(TRAINER_ID, Vector2i(3, 5), Vector2i.LEFT)
	GameState.set_flag(&"trainer_defeated:ruta1_manolo")
	_player.place_at(Vector2i(2, 5), Vector2i.RIGHT)
	t.interact(_player)
	await wait_physics_frames(2)
	assert_true(Dialogue.is_open, "habla en vez de luchar")
	assert_false(Cutscene.is_running())
	await _finish_cutscene()
	assert_true(FakeChallenge.fought.is_empty())
	assert_eq(t.display_name, "Vendedor de Chupachups Manolo", "nombre de la clase y del entrenador")
