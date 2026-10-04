class_name BattleScene
extends Control
## Presentación del combate (Fase 7.10). Contrato: docs/contratos.md §9.3.
## Reproduce uno a uno, con await, los eventos de un BattleDriver y le pide al
## jugador sus acciones. No calcula nada del combate: solo dibuja.
## Los textos de mecánicas ("¡X usó Y!") los manda el motor; la escena pone los
## de presentación: aparición, desafío, "¡Adelante, X!", menú y despedida.

const PROMPT_TEXT_WIDTH := 160.0
const MESSAGE_WAIT := 0.9
const OFFSCREEN_LEFT := -64.0
const OFFSCREEN_RIGHT := 384.0
const PLAYER_BACK_SPRITE := "res://assets/sprites/trainers/player_back_%s.png"
const LIST_ANCHOR := Vector2(316, 132)
const BALL_FROM := Vector2(40, 120)
## Fase 7.10: "Luchar / Mochila / Pokémon / Huir".
const COMMANDS: Array[String] = ["Luchar", "Mochila", "Pokémon", "Huir"]
enum Command { FIGHT, BAG, POKEMON, RUN }

## Sin animaciones ni esperas (para los tests).
@export var fast := false

var _driver: BattleDriver
var _info: Dictionary = {}
var _last_command := 0
var _last_move := 0

@onready var _background: BattleBackground = $Field/Background
@onready var _foe_trainer: Sprite2D = $Field/FoeTrainer
@onready var _foe_sprite: BattlePokemonSprite = $Field/FoeSprite
@onready var _player_trainer: Sprite2D = $Field/PlayerTrainer
@onready var _player_sprite: BattlePokemonSprite = $Field/PlayerSprite
@onready var _fx: Node2D = $Field/Fx
@onready var _foe_box: BattleDataBox = $FoeBox
@onready var _player_box: BattleDataBox = $PlayerBox
@onready var _box: DialogueBox = $MessageBox
@onready var _command_panel: Control = $CommandPanel
@onready var _command_menu: GridMenu = $CommandPanel/Menu
@onready var _move_panel: Control = $MovePanel
@onready var _move_menu: GridMenu = $MovePanel/Moves/Menu
@onready var _move_pp: Label = $MovePanel/Info/PP
@onready var _move_type: Label = $MovePanel/Info/Type
@onready var _list_panel: PanelContainer = $ListPanel
@onready var _list_menu: GridMenu = $ListPanel/Margin/Menu
@onready var _curtain_a: ColorRect = $Curtain/A
@onready var _curtain_b: ColorRect = $Curtain/B


func _ready() -> void:
	var labels := PackedStringArray()
	for command: String in COMMANDS:
		labels.append(tr(command))
	_command_menu.set_items(labels)
	_command_panel.hide()
	_move_panel.hide()
	_list_panel.hide()
	_foe_box.hide()
	_player_box.hide()
	_foe_trainer.hide()
	_player_trainer.hide()


## Contrato de SceneManager: corrutina que devuelve un SceneManager.OUTCOME_*.
func run(setup: Variant) -> StringName:
	_driver = make_driver(setup)
	_info = _driver.info()
	_box.text_speed = 0 if fast else Dialogue.text_speed
	AudioManager.save_bgm()
	AudioManager.play_bgm(StringName(_info.get("bgm", "battle_wild")), 0.0)
	_background.set_environment(StringName(_info.get("background", "grass")))
	var start_events := _driver.start()
	await _intro(start_events)
	await _play_events(start_events)
	while not _driver.is_over():
		var action := await _ask_player(_driver.request())
		await _play_events(_driver.submit(action))
	var outcome := _driver.outcome()
	_driver.finish()
	await _outro(outcome)
	AudioManager.restore_bgm()
	return outcome


## El driver que corresponde a `setup`. Mientras no exista el motor real, FakeBattle.
static func make_driver(setup: Variant) -> BattleDriver:
	if setup is BattleDriver:
		return setup
	return FakeBattle.new(setup)


# --- Eventos ---

func _play_events(events: Array) -> void:
	var victory_at := _victory_index(events)
	for i: int in events.size():
		await _play_event(events[i])
		if i == victory_at:
			AudioManager.play_bgm(&"victory_wild" if _trainer().is_empty() else &"victory_trainer", 0.2)


## Tipos y campos: contratos.md §8.5 (BattleEvent). Los que no conoce, los ignora.
func _play_event(event: Variant) -> void:
	var side := int(_field(event, "side", -1))
	var data: Dictionary = _field(event, "data", {})
	match StringName(_field(event, "type", "")):
		&"message":
			await _message(str(data.get("text", "")))
		&"switch_in":
			await _switch_in(side, data)
		&"switch_out":
			if side == BattleDriver.PLAYER:
				await _message(tr("¡%s, vuelve!") % _player_box.pokemon_name)
			await _sprite(side).withdraw(_t(0.3))
			_data_box(side).hide()
		&"move":
			await _animate_move(side, int(data.get("target_side", 1 - side)), data)
		&"damage":
			await _damage(side, int(data.get("hp", 0)), float(data.get("effectiveness", 1.0)))
		&"heal":
			var box := _data_box(side)
			await box.animate_hp(int(data.get("hp", box.hp)), int(data.get("max_hp", -1)), _t(0.5))
		&"status":
			_data_box(side).set_status(StringName(data.get("status", "")))
		&"boost":
			var amount := int(data.get("amount", 0))
			AudioManager.play_se(&"stat_up" if amount > 0 else &"stat_down")
			var tint := Color("f87858") if amount > 0 else Color("5888f8")
			await BattleFx.sparkle(_fx, _sprite(side).center(), tint, _t(0.6))
		&"cant_move":
			await BattleFx.sparkle(_fx, _sprite(side).center(), Color("d8d8d8"), _t(0.4))
		&"faint":
			AudioManager.play_cry(_sprite(side).species_id)
			await _sprite(side).faint(_t(0.4))
			_data_box(side).hide()
		&"exp":
			if side == BattleDriver.PLAYER:
				AudioManager.play_se(&"exp")
				await _player_box.animate_exp(_exp_ratio(data), _t(0.6))
		&"level_up":
			if side == BattleDriver.PLAYER:
				_player_box.set_level(int(data.get("level", 1)))
				_player_box.set_exp(0.0)
				await _player_box.animate_hp(int(data.get("hp", _player_box.hp)),
					int(data.get("max_hp", _player_box.max_hp)), 0.0)
			await AudioManager.play_me(&"level_up")
		&"catch":
			await _throw_ball(int(data.get("shakes", 0)), bool(data.get("caught", false)))
		&"trainer_speech":
			await _trainer_returns()
			await _message(Dialogue.format_text(str(data.get("text", ""))))


## Índice del último debilitado del rival si el combate se gana en esta tanda
## (ahí empieza la música de victoria). −1 si no.
func _victory_index(events: Array) -> int:
	var won := false
	var last_faint := -1
	for i: int in events.size():
		var type := StringName(_field(events[i], "type", ""))
		if type == &"faint" and int(_field(events[i], "side", -1)) == BattleDriver.FOE:
			last_faint = i
		elif type == &"end":
			won = StringName((_field(events[i], "data", {}) as Dictionary).get("outcome", "")) == &"win"
	return last_faint if won else -1


func _switch_in(side: int, data: Dictionary) -> void:
	var sprite := _sprite(side)
	var box := _data_box(side)
	var pokemon := _summary(data)
	var pokemon_name := str(pokemon.get("name", "?"))
	if side == BattleDriver.FOE and data.get("wild", false):
		if not (sprite.visible and sprite.species_id == StringName(pokemon.get("species", ""))):
			sprite.set_pokemon(pokemon)
			await sprite.slide_in(OFFSCREEN_LEFT, _t(0.6))
		AudioManager.play_cry(sprite.species_id)
		await _show_box(box, pokemon)
		await _message(tr("¡Un %s salvaje apareció!") % pokemon_name)
		return
	if side == BattleDriver.FOE:
		if _foe_trainer.visible:
			await _slide_sprite(_foe_trainer, OFFSCREEN_RIGHT, _t(0.4))
			_foe_trainer.hide()
		await _message(tr("¡%s sacó a %s!") % [_trainer().get("display_name", ""), pokemon_name])
	else:
		if _player_trainer.visible:
			await _slide_sprite(_player_trainer, OFFSCREEN_LEFT, _t(0.4))
			_player_trainer.hide()
		await _message(tr("¡Adelante, %s!") % pokemon_name)
	sprite.set_pokemon(pokemon)
	AudioManager.play_se(&"ball_open")
	await sprite.appear(_t(0.3))
	AudioManager.play_cry(sprite.species_id)
	await _show_box(box, pokemon)


## Resumen para el sprite y la caja de datos a partir de los datos de switch_in.
func _summary(data: Dictionary) -> Dictionary:
	var pokemon := data.duplicate()
	var species := StringName(data.get("species", ""))
	if not pokemon.has("types"):
		pokemon["types"] = Array(DataDB.species(species).types) if DataDB.has_species(species) else []
	pokemon["exp_ratio"] = _exp_ratio(data)
	return pokemon


static func _exp_ratio(data: Dictionary) -> float:
	var start := float(data.get("exp_level_start", 0))
	var span := float(data.get("exp_next_level", 0)) - start
	return clampf((float(data.get("exp", 0)) - start) / span, 0.0, 1.0) if span > 0.0 else 0.0


func _animate_move(side: int, target_side: int, move: Dictionary) -> void:
	var user := _sprite(side)
	var target := _sprite(target_side)
	var color := UiColors.type_color(StringName(move.get("type", "normal")))
	match _category(move.get("category", "physical")):
		&"physical":
			await user.lunge(target.home(), _t(0.25))
			await BattleFx.burst(_fx, target.center(), color, _t(0.25))
		&"special":
			await BattleFx.orb(_fx, user.center(), target.center(), color, _t(0.5))
		_:
			await BattleFx.sparkle(_fx, target.center(), color, _t(0.6))


func _damage(side: int, hp: int, effectiveness: float) -> void:
	var box := _data_box(side)
	if effectiveness > 1.0:
		AudioManager.play_se(&"hit_super")
	elif effectiveness < 1.0:
		AudioManager.play_se(&"hit_weak")
	else:
		AudioManager.play_se(&"hit_normal")
	await _sprite(side).blink(3, _t(0.06))
	var change := absf(box.hp - hp) / float(box.max_hp)
	await box.animate_hp(hp, -1, _t(clampf(change * 1.2, 0.25, 1.0)))
	if side == BattleDriver.PLAYER and hp > 0 and float(hp) / box.max_hp <= 0.2:
		AudioManager.play_se(&"low_hp")


func _throw_ball(shakes: int, caught: bool) -> void:
	var ball := Sprite2D.new()
	ball.texture = PlaceholderArt.ball()
	ball.position = BALL_FROM
	_fx.add_child(ball)
	var target := _foe_sprite.home() + Vector2(0, -28)
	AudioManager.play_se(&"ball_throw")
	if not fast:
		var tween := create_tween()
		tween.tween_method(_ball_arc.bind(ball, target), 0.0, 1.0, 0.6)
		await tween.finished
	ball.position = target
	await _foe_sprite.withdraw(_t(0.3))
	var ground := _foe_sprite.home() + Vector2(0, -5)
	if not fast:
		var drop := create_tween()
		drop.tween_property(ball, ^"position", ground, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		await drop.finished
	ball.position = ground
	for i: int in mini(shakes, 3):
		await _wait(_t(0.35))
		AudioManager.play_se(&"ball_shake")
		if not fast:
			var wobble := create_tween()
			wobble.tween_property(ball, ^"rotation", -0.5, 0.08)
			wobble.tween_property(ball, ^"rotation", 0.5, 0.16)
			wobble.tween_property(ball, ^"rotation", 0.0, 0.08)
			await wobble.finished
	await _wait(_t(0.35))
	if caught:
		AudioManager.play_se(&"ball_caught")
		ball.modulate = Color(0.6, 0.6, 0.6)
		await BattleFx.sparkle(_fx, ground, Color.WHITE, _t(0.5))
		_foe_box.hide()
		return
	ball.queue_free()
	AudioManager.play_se(&"ball_open")
	await _foe_sprite.appear(_t(0.3))


func _ball_arc(t: float, ball: Sprite2D, target: Vector2) -> void:
	ball.position = BALL_FROM.lerp(target, t) + Vector2(0, -sin(t * PI) * 48.0)
	ball.rotation = t * TAU * 2.0


# --- Menús ---

func _ask_player(request: Dictionary) -> Dictionary:
	match StringName(request.get("kind", BattleDriver.REQUEST_ACTION)):
		BattleDriver.REQUEST_SWITCH:
			return {"type": &"switch", "party_index": await _choose_party(true)}
		BattleDriver.REQUEST_LEARN_MOVE:
			return {"type": &"learn_move", "forget_index": await _choose_forget(request)}
	return await _choose_action()


func _choose_action() -> Dictionary:
	while true:
		var active := _driver.player_active()
		_box.set_text_width(PROMPT_TEXT_WIDTH)
		await _box.play(tr("¿Qué debería hacer %s?") % active.get("name", ""), "", false)
		_command_panel.show()
		var command := await _command_menu.choose(_last_command, false)
		_command_panel.hide()
		_box.set_text_width(-1.0)
		_last_command = command
		match command:
			Command.FIGHT:
				var slot := await _choose_move(active)
				if slot >= 0:
					return {"type": &"fight", "move_slot": slot}
			Command.BAG:
				var item := await _choose_item()
				if item != &"":
					return {"type": &"item", "item": item}
			Command.POKEMON:
				var index := await _choose_party(false)
				if index >= 0:
					return {"type": &"switch", "party_index": index}
			Command.RUN:
				return {"type": &"run"}
	return {}


func _choose_move(active: Dictionary) -> int:
	var moves: Array = active.get("moves", [])
	var names := PackedStringArray()
	for i: int in 4:
		names.append(str(moves[i].get("name", "?")) if i < moves.size() else "—")
	_move_menu.set_items(names)
	for i: int in 4:
		_move_menu.disabled[i] = i >= moves.size() or int(moves[i].get("pp", 0)) <= 0
	var update := _show_move_info.bind(moves)
	_move_menu.selection_changed.connect(update)
	_box.hide()
	_move_panel.show()
	var slot := await _move_menu.choose(mini(_last_move, maxi(moves.size() - 1, 0)))
	_move_menu.selection_changed.disconnect(update)
	_move_panel.hide()
	_box.show()
	if slot >= 0:
		_last_move = slot
	return slot


func _show_move_info(index: int, moves: Array) -> void:
	if index >= moves.size():
		_move_pp.text = ""
		_move_type.text = ""
		return
	var move: Dictionary = moves[index]
	_move_pp.text = tr("PP %d/%d") % [int(move.get("pp", 0)), int(move.get("max_pp", 0))]
	_move_type.text = _type_name(StringName(move.get("type", "normal")))
	_move_type.add_theme_color_override(&"font_color",
		UiColors.type_color(StringName(move.get("type", "normal"))).darkened(0.35))


func _choose_item() -> StringName:
	var items := _driver.battle_items()
	if items.is_empty():
		await _message(tr("No tienes objetos que puedas usar ahora."))
		return &""
	var labels := PackedStringArray()
	for item: Dictionary in items:
		labels.append("%s ×%d" % [item.get("name", "?"), int(item.get("count", 0))])
	var index := await _list(tr("¿Qué objeto quieres usar?"), labels, [], true)
	return StringName(items[index].get("id", "")) if index >= 0 else &""


func _choose_party(forced: bool) -> int:
	var party := _driver.player_party()
	var labels := PackedStringArray()
	var disabled: Array[bool] = []
	for pokemon: Dictionary in party:
		labels.append("%s  Nv%d  %d/%d" % [pokemon.get("name", "?"), int(pokemon.get("level", 1)),
			int(pokemon.get("hp", 0)), int(pokemon.get("max_hp", 1))])
		disabled.append(not pokemon.get("able", true) or pokemon.get("active", false))
	var prompt := tr("¿Qué Pokémon sacarás?") if forced else tr("Elige un Pokémon.")
	return await _list(prompt, labels, disabled, not forced)


## Qué movimiento olvidar para aprender `request.move_name` (−1 = no aprenderlo).
func _choose_forget(request: Dictionary) -> int:
	var moves: Array = _driver.player_active().get("moves", [])
	var labels := PackedStringArray()
	for move: Dictionary in moves:
		labels.append(str(move.get("name", "?")))
	labels.append(tr("No aprender %s") % request.get("move_name", ""))
	var index := await _list(tr("¿Qué movimiento olvidas?"), labels, [], false)
	return index if index < moves.size() else -1


func _list(prompt: String, labels: PackedStringArray, disabled: Array[bool], can_cancel: bool) -> int:
	await _box.play(prompt, "", false)
	_list_menu.set_items(labels)
	for i: int in disabled.size():
		_list_menu.disabled[i] = disabled[i]
	_list_panel.reset_size()
	_list_panel.position = (LIST_ANCHOR - _list_panel.get_combined_minimum_size()).round()
	_list_panel.show()
	var index := await _list_menu.choose(0, can_cancel)
	_list_panel.hide()
	return index


# --- Entrada y salida ---

## Cortinilla y entrada de los entrenadores. En combates salvajes, el Pokémon
## salvaje (primer switch_in de `start_events`) entra a la vez que el jugador.
func _intro(start_events: Array) -> void:
	var trainer := _trainer()
	var player_back := PlaceholderArt.load_texture(PLAYER_BACK_SPRITE % GameState.player_gender)
	_set_trainer_texture(_player_trainer, player_back if player_back else PlaceholderArt.trainer(true))
	_player_trainer.show()
	if not trainer.is_empty():
		var sprite := PlaceholderArt.load_texture(str(trainer.get("battle_sprite", "")))
		_set_trainer_texture(_foe_trainer, sprite if sprite else PlaceholderArt.trainer(false))
		_foe_trainer.show()
	await _open_curtain(trainer.is_empty())
	var player_home := _player_trainer.position
	_player_trainer.position.x = OFFSCREEN_RIGHT
	var foe_home := _foe_trainer.position
	_foe_trainer.position.x = OFFSCREEN_LEFT
	var wild := _first_wild(start_events)
	if not wild.is_empty():
		_foe_sprite.set_pokemon(wild)
		_foe_sprite.position.x = OFFSCREEN_LEFT
	var tween := create_tween().set_parallel()
	tween.tween_property(_player_trainer, ^"position", player_home, maxf(_t(0.6), 0.001))
	tween.tween_property(_foe_trainer, ^"position", foe_home, maxf(_t(0.6), 0.001))
	if not wild.is_empty():
		tween.tween_property(_foe_sprite, ^"position:x", _foe_sprite.home().x, maxf(_t(0.6), 0.001))
	await tween.finished
	if not trainer.is_empty():
		await _message(tr("¡%s te desafía!") % trainer.get("display_name", ""))


func _outro(outcome: StringName) -> void:
	match outcome:
		SceneManager.OUTCOME_LOSE:
			if not _info.get("can_lose", false):
				await _message(Dialogue.format_text(tr("¡{player} está fuera de combate!")))
		SceneManager.OUTCOME_CAUGHT:
			await AudioManager.play_me(&"caught")
		SceneManager.OUTCOME_RUN:
			AudioManager.play_se(&"flee")
	await _wait(_t(0.4))


func _first_wild(events: Array) -> Dictionary:
	for event: Variant in events:
		var data: Dictionary = _field(event, "data", {})
		if _field(event, "type", "") == &"switch_in" and int(_field(event, "side", -1)) == BattleDriver.FOE \
				and data.get("wild", false):
			return _summary(data)
	return {}


func _trainer_returns() -> void:
	if _foe_trainer.visible and is_equal_approx(_foe_trainer.position.x, _foe_sprite.home().x):
		return
	_foe_trainer.show()
	await _slide_sprite(_foe_trainer, _foe_sprite.home().x, _t(0.5))


func _open_curtain(horizontal: bool) -> void:
	if horizontal:
		_curtain_a.position = Vector2(0, 0)
		_curtain_a.size = Vector2(320, 90)
		_curtain_b.position = Vector2(0, 90)
		_curtain_b.size = Vector2(320, 90)
	else:
		_curtain_a.position = Vector2(0, 0)
		_curtain_a.size = Vector2(160, 180)
		_curtain_b.position = Vector2(160, 0)
		_curtain_b.size = Vector2(160, 180)
	_curtain_a.show()
	_curtain_b.show()
	if not fast:
		var tween := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		if horizontal:
			tween.tween_property(_curtain_a, ^"position:y", -90.0, 0.4)
			tween.tween_property(_curtain_b, ^"position:y", 180.0, 0.4)
		else:
			tween.tween_property(_curtain_a, ^"position:x", -160.0, 0.4)
			tween.tween_property(_curtain_b, ^"position:x", 320.0, 0.4)
		await tween.finished
	_curtain_a.hide()
	_curtain_b.hide()


# --- Utilidades ---

func _message(text: String) -> void:
	await _box.play(text, "", false)
	await _wait_or_accept(_t(MESSAGE_WAIT))


func _show_box(box: BattleDataBox, pokemon: Dictionary) -> void:
	box.show_pokemon(pokemon)
	box.show()
	if fast:
		return
	var home := box.position
	box.position.x += -40.0 if box == _foe_box else 40.0
	box.modulate.a = 0.0
	var tween := create_tween().set_parallel()
	tween.tween_property(box, ^"position", home, 0.2)
	tween.tween_property(box, ^"modulate:a", 1.0, 0.2)
	await tween.finished


func _slide_sprite(sprite: Node2D, to_x: float, duration: float) -> void:
	if duration <= 0.0:
		sprite.position.x = to_x
		return
	var tween := create_tween()
	tween.tween_property(sprite, ^"position:x", to_x, duration)
	await tween.finished


func _set_trainer_texture(sprite: Sprite2D, texture: Texture2D) -> void:
	sprite.texture = texture
	sprite.centered = false
	sprite.offset = Vector2(-texture.get_width() / 2.0, -texture.get_height()).round()


func _sprite(side: int) -> BattlePokemonSprite:
	return _player_sprite if side == BattleDriver.PLAYER else _foe_sprite


func _data_box(side: int) -> BattleDataBox:
	return _player_box if side == BattleDriver.PLAYER else _foe_box


func _trainer() -> Dictionary:
	var trainers: Array = _info.get("trainers", [])
	return trainers[0] if not trainers.is_empty() else {}


func _t(seconds: float) -> float:
	return 0.0 if fast else seconds


func _wait(seconds: float) -> void:
	if seconds > 0.0:
		await get_tree().create_timer(seconds).timeout


## Espera `seconds` o hasta que el jugador pulse accept.
func _wait_or_accept(seconds: float) -> void:
	var elapsed := 0.0
	while elapsed < seconds:
		await get_tree().process_frame
		if Input.is_action_just_pressed(&"accept"):
			return
		elapsed += get_process_delta_time()


func _type_name(type: StringName) -> String:
	return DataDB.type_name(type)


static func _category(value: Variant) -> StringName:
	if value is int:
		return [&"physical", &"special", &"status"][clampi(value, 0, 2)]
	return StringName(value)


static func _field(event: Variant, key: String, default: Variant) -> Variant:
	if event is Dictionary:
		return event.get(key, default)
	if event is Object and key in event:
		return event.get(key)
	return default
