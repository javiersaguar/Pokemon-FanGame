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
