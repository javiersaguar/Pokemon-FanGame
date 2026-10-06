extends GutTest
## Flujo completo de la BattleScene con FakeBattle (sin animaciones: `fast`).

const SCENE := preload("res://src/battle/scene/battle_scene.tscn")
const MAX_FRAMES := 3000

var _scene: BattleScene
var _outcome: StringName = &""
var _done := false


func before_each() -> void:
	_scene = SCENE.instantiate()
	_scene.fast = true
	add_child_autofree(_scene)
	_outcome = &""
	_done = false


func after_each() -> void:
	for child: Node in AudioManager.get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null
	await wait_process_frames(2)


func _press(action: StringName) -> void:
	var down := InputEventAction.new()
	down.action = action
	down.pressed = true
	Input.parse_input_event(down)
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)


func _start(setup: Variant) -> void:
	var battle := func() -> void:
		_outcome = await _scene.run(setup)
		_done = true
	battle.call()


## Juega el combate eligiendo siempre `command` (y el primer movimiento u objeto).
## `first_command`, si se indica, solo para el primer turno.
func _autoplay(command: int, first_command: int = -1) -> void:
	var turn := 0
	for frame: int in MAX_FRAMES:
		if _done:
			return
		await wait_physics_frames(1)
		var menu: GridMenu = null
		if _scene._command_menu.is_choosing:
			menu = _scene._command_menu
			menu.select(first_command if turn == 0 and first_command >= 0 else command)
			turn += 1
		elif _scene._move_menu.is_choosing:
			menu = _scene._move_menu
			menu.select(0)
		elif _scene._list_menu.is_choosing:
			menu = _scene._list_menu
			for i: int in menu.disabled.size():
				if not menu.disabled[i]:
					menu.select(i)
					break
		if menu:
			await wait_physics_frames(1)
			_press(&"accept")


func test_wild_battle_until_win() -> void:
	_start(FakeBattle.new({}, 7))
	await _autoplay(BattleScene.Command.FIGHT)
	assert_true(_done, "el combate termina")
	assert_eq(_outcome, SceneManager.OUTCOME_WIN)


func test_run_from_wild_battle() -> void:
	_start(FakeBattle.new({}, 7))
	await _autoplay(BattleScene.Command.RUN)
	assert_eq(_outcome, SceneManager.OUTCOME_RUN)


func test_cannot_run_from_trainer_but_can_win() -> void:
	_start(FakeBattle.new({"trainer_id": "ruta1_manolo"}, 3))
	await _autoplay(BattleScene.Command.FIGHT, BattleScene.Command.RUN)
	assert_eq(_outcome, SceneManager.OUTCOME_WIN, "no se puede huir, pero se gana luchando")


func test_catch_wild_pokemon_with_ball() -> void:
	_start(FakeBattle.new({}, 11))
	await _autoplay(BattleScene.Command.BAG)
	assert_true(_outcome == SceneManager.OUTCOME_CAUGHT or _outcome == SceneManager.OUTCOME_LOSE,
		"acaba capturándolo (o perdiendo si falla muchas veces)")


func test_map_bgm_is_restored_after_battle() -> void:
	AudioManager.play_bgm(&"mapa_de_prueba", 0.0)
	_start(FakeBattle.new({}, 7))
	await _autoplay(BattleScene.Command.RUN)
	assert_eq(AudioManager.current_bgm, &"mapa_de_prueba")
	AudioManager.stop_bgm(0.0)


# --- Con el motor real (EngineDriver) ---

func _engine_party(level: int = 12) -> void:
	GameState.reset()
	GameState.player_name = "Rojo"
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	(GameState.party as Party).add(Pokemon.create(&"charmander", level, rng))


func test_real_engine_wild_battle_until_win() -> void:
	_engine_party(14)
	_start(BattleSetup.wild(&"rattata", 2, {"seed": 5}))
	await _autoplay(BattleScene.Command.FIGHT)
	assert_true(_done, "el combate termina")
	assert_eq(_outcome, SceneManager.OUTCOME_WIN)
	GameState.reset()


func test_real_engine_catch_spends_balls_and_adds_to_party() -> void:
	_engine_party(14)
	(GameState.bag as Bag).add(&"pokeball", 30)
	_start(BattleSetup.wild(&"rattata", 2, {"seed": 9}))
	await _autoplay(BattleScene.Command.BAG)
	assert_eq(_outcome, SceneManager.OUTCOME_CAUGHT)
	assert_lt((GameState.bag as Bag).count(&"pokeball"), 30, "se gastan Poké Balls")
	assert_eq((GameState.party as Party).size(), 2, "el capturado va al equipo")
	GameState.reset()


func test_real_engine_trainer_battle_cannot_run() -> void:
	_engine_party(14)
	_start(BattleSetup.trainer(&"ruta1_manolo", {"seed": 3}))
	await _autoplay(BattleScene.Command.FIGHT, BattleScene.Command.RUN)
	assert_eq(_outcome, SceneManager.OUTCOME_WIN)
	GameState.reset()


# El modo Cambio es opcional; un KO sigue obligando a elegir un sustituto.
func _request_switch(reason: StringName) -> void:
	_scene._driver = FakeBattle.new({}, 7)
	_scene._box.text_speed = 0
	var action: Dictionary = await _scene._ask_player({"kind": BattleDriver.REQUEST_SWITCH, "reason": reason})
	_outcome = StringName(str(action.get("party_index", -99)))
	_done = true

func test_shift_can_be_declined_or_cancelled() -> void:
	_request_switch(&"shift")
	await wait_physics_frames(2)
	_scene._list_menu.select(1)
	_press(&"accept")
	await wait_physics_frames(2)
	assert_true(_done)
	assert_eq(_outcome, &"-1")

func test_shift_party_selection_can_be_cancelled() -> void:
	_request_switch(&"shift")
	await wait_physics_frames(2)
	_press(&"accept")
	await wait_physics_frames(2)
	assert_false(_done)
	_press(&"cancel")
	await wait_physics_frames(2)
	assert_eq(_outcome, &"-1")

func test_fainted_switch_cannot_be_cancelled() -> void:
	_request_switch(&"faint")
	await wait_physics_frames(2)
	_press(&"cancel")
	await wait_physics_frames(2)
	assert_false(_done)
	_scene._list_menu.select(1)
	_press(&"accept")
	await wait_physics_frames(2)
	assert_true(_done)
	assert_eq(_outcome, &"1")
