class_name BattleScene
extends Control
## Presentación del combate (Fase 7.10). Contrato: docs/contratos.md §9.3.
## Reproduce uno a uno, con await, los eventos de un BattleDriver y le pide al
## jugador sus acciones. No calcula nada del combate: solo dibuja.
## Los textos de mecánicas ("¡X usó Y!") los manda el motor; la escena pone los
## de presentación: aparición, desafío, "¡Adelante, X!", menú y despedida.

## La interfaz va en el UiCanvas (256×192 a ×2); el campo (World) va a 1:1 en
## píxeles de pantalla, porque los sprites de los packs ya vienen al doble.
const MESSAGE_RECT := Rect2(0, 146, 256, 46)
const PROMPT_TEXT_WIDTH := 112.0
const MESSAGE_WAIT := 0.9
const OFFSCREEN_LEFT := -96.0
const OFFSCREEN_RIGHT := 608.0
const PLAYER_BACK_SPRITE := "res://assets/sprites/trainers/player_back_%s.png"
const LIST_ANCHOR := Vector2(252, 146)
const BALL_FROM := Vector2(80, 240)
const SPARKLE := preload("res://assets/sprites/ui/battle/shiny_sparkle.png")
const SPARKLE_FRAMES := 3
const BALL_TEXTURE := preload("res://assets/sprites/ui/battle/ball.png")
## Color de cada botón del menú principal (BIBLIA.md §7).
const COMMAND_COLORS: Array[StringName] = [&"rojo", &"amarillo", &"verde", &"azul"]
## Fase 7.10: "Luchar / Mochila / Pokémon / Huir".
const COMMANDS: Array[String] = ["Luchar", "Mochila", "Pokémon", "Huir"]
enum Command { FIGHT, BAG, POKEMON, RUN }
## Textos de presentación del motor (`tag` en `data`) que la escena pone a su manera.
const SCENE_TEXT_TAGS: Array[String] = ["wild_appear", "challenge", "send_out", "recall"]

## Sin animaciones ni esperas (para los tests).
@export var fast := false

var _driver: BattleDriver
var _info: Dictionary = {}
var _last_command := 0
var _last_move := 0
var _low_hp_music := false
var _music_finished := false
var _field_slots := {BattleDriver.PLAYER:0,BattleDriver.FOE:0}
var _second_sprites: Dictionary = {}
var _second_boxes: Dictionary = {}

@onready var _background: BattleBackground = $World/Background
@onready var _foe_shadow: Sprite2D = $World/FoeShadow
@onready var _foe_trainer: Sprite2D = $World/FoeTrainer
@onready var _foe_sprite: BattlePokemonSprite = $World/FoeSprite
@onready var _player_trainer: Sprite2D = $World/PlayerTrainer
@onready var _player_sprite: BattlePokemonSprite = $World/PlayerSprite
@onready var _fx: Node2D = $World/Fx
@onready var _foe_box: BattleDataBox = $Canvas/FoeBox
@onready var _player_box: BattleDataBox = $Canvas/PlayerBox
@onready var _box: DialogueBox = $Canvas/MessageBox
@onready var _command_panel: Control = $Canvas/Commands
@onready var _command_menu: GridMenu = $Canvas/Commands
@onready var _move_panel: Control = $Canvas/MovePanel
@onready var _move_menu: GridMenu = $Canvas/MovePanel/Moves
@onready var _move_pp: Label = $Canvas/MovePanel/Info/PP
@onready var _move_type: Label = $Canvas/MovePanel/Info/Type
@onready var _list_panel: PanelContainer = $Canvas/ListPanel
@onready var _list_menu: GridMenu = $Canvas/ListPanel/Margin/Menu
@onready var _curtain_a: ColorRect = $Canvas/Curtain/A
@onready var _curtain_b: ColorRect = $Canvas/Curtain/B
var _foe_base: Sprite2D
var _player_base: Sprite2D


func _ready() -> void:
	_box.place_frame(MESSAGE_RECT)
	for i: int in COMMANDS.size():
		_command_menu.add_child(_button(COMMAND_COLORS[i], tr(COMMANDS[i]), Vector2(60, 18)))
	for i: int in 4:
		var move_button := _button(&"claro", "", Vector2(122, 18))
		move_button.align_left = true
		_move_menu.add_child(move_button)
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
	_configure_field()
	_box.text_speed = 0 if fast else Dialogue.text_speed
	AudioManager.save_bgm()
	AudioManager.play_bgm(StringName(_info.get("bgm", "battle_wild")), 0.0)
	_background.set_environment(StringName(_info.get("background", "grass")))
	_apply_bases()
	var start_events := _driver.start()
	await _intro(start_events)
	await _play_events(start_events)
	while not _driver.is_over():
		var action := await _ask_player(_driver.request())
		await _play_events(_driver.submit(action))
	var outcome := _driver.outcome()
	_music_finished = true
	_end_low_hp_music()
	_driver.finish()
	await _outro(outcome)
	await _pending_evolutions()
	AudioManager.restore_bgm()
	return outcome


## Base bajo cada Pokémon (la del entorno, o la provisional). La sombra del pack
## sigue encima. El Agente 4 sustituye el PNG sin tocar esta escena.
func _apply_bases() -> void:
	var base := BattleBackground.load_base(_background.environment)
	var doubles: bool = _info.get("format",&"single") == &"double"
	_foe_base = _base_sprite(_foe_base, base, Vector2(364,124) if doubles else Vector2(384,190), _foe_shadow)
	_player_base = _base_sprite(_player_base, base, Vector2(128,306) if doubles else Vector2(128,328), _player_sprite)


func _base_sprite(sprite: Sprite2D, base: Texture2D, at: Vector2, before: Node) -> Sprite2D:
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.centered = true
		before.get_parent().add_child(sprite)
		before.get_parent().move_child(sprite, before.get_index())
	sprite.texture = base
	sprite.position = at
	sprite.visible = base != null
	return sprite


## El driver que corresponde a `setup`: el motor real con un BattleSetup; FakeBattle
## con un Dictionary (combate de prueba del Debug).
static func make_driver(setup: Variant) -> BattleDriver:
	if setup is BattleDriver:
		return setup
	if setup is BattleSetup:
		return EngineDriver.new(setup)
	return FakeBattle.new(setup)


# --- Eventos ---

func _play_events(events: Array) -> void:
	var victory_at := _victory_index(events)
	for i: int in events.size():
		await _play_event(events[i])
		if i == victory_at:
			_music_finished = true
			_end_low_hp_music()
			AudioManager.play_bgm(&"victory_wild" if _trainer().is_empty() else &"victory_trainer", 0.2)


## Tipos y campos: contratos.md §8.5 (BattleEvent). Los que no conoce, los ignora.
func _play_event(event: Variant) -> void:
	var side := int(_field(event, "side", -1))
	var data: Dictionary = _field(event, "data", {})
	var slot := int(_field(event,"slot",0))
	var type := StringName(_field(event,"type",""))
	if side in [BattleDriver.PLAYER,BattleDriver.FOE] and slot >= 0: _field_slots[side] = slot
	if slot < 0 and type in [&"exp", &"level_up"]:
		if type == &"level_up" and not fast: await AudioManager.play_me(&"level_up")
		return
	match type:
		&"message":
			if str(data.get("tag", "")) not in SCENE_TEXT_TAGS:
				await _message(str(data.get("text", "")))
		&"switch_in":
			await _switch_in(side, data)
			_update_low_hp_music()
		&"switch_out":
			if side == BattleDriver.PLAYER:
				await _message(tr("¡%s, vuelve!") % _data_box(side).pokemon_name)
			await _sprite(side).withdraw(_t(0.3))
			_data_box(side).hide()
		&"move":
			await _animate_move(side, int(data.get("target_side", 1 - side)), data)
		&"damage":
			await _damage(side, int(data.get("hp", 0)), float(data.get("effectiveness", 1.0)))
		&"heal":
			var box := _data_box(side)
			await box.animate_hp(int(data.get("hp", box.hp)), int(data.get("max_hp", -1)), _t(0.5))
			_update_low_hp_music()
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
			_update_low_hp_music()
			if side == BattleDriver.FOE:
				_foe_shadow.hide()
		&"exp":
			if side == BattleDriver.PLAYER:
				AudioManager.play_se(&"exp")
				await _data_box(side).animate_exp(_exp_ratio(data), _t(0.6))
		&"level_up":
			if side == BattleDriver.PLAYER:
				_data_box(side).set_level(int(data.get("level", 1)))
				_data_box(side).set_exp(0.0)
				await _data_box(side).animate_hp(int(data.get("hp", _data_box(side).hp)),
					int(data.get("max_hp", _data_box(side).max_hp)), 0.0)
			if not fast: await AudioManager.play_me(&"level_up")
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
		_foe_shadow.show()
		AudioManager.play_cry(sprite.species_id)
		if pokemon.get("shiny", false):
			await _shiny_sparkles(sprite)
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
	_foe_shadow.visible = _foe_sprite.visible
	AudioManager.play_cry(sprite.species_id)
	if pokemon.get("shiny", false):
		await _shiny_sparkles(sprite)
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
	var target := _sprite(target_side,int(move.get("target_slot",0)))
	if await BattleMoveAnimation.play(_fx, user, target, move, fast or UiPreferences.reduce_motion()): return
	var details := move.duplicate()
	details.category = _category(move.get("category", "physical"))
	if details.category == &"physical":
		await user.lunge(target.home(), _t(0.25))
	await BattleFx.move(_fx, user.center(), target.center(), details, _t(0.65))


func _damage(side: int, hp: int, effectiveness: float) -> void:
	var box := _data_box(side)
	if effectiveness > 1.0:
		AudioManager.play_se(&"hit_super")
	elif effectiveness < 1.0:
		AudioManager.play_se(&"hit_weak")
	else:
		AudioManager.play_se(&"hit_normal")
	if effectiveness > 1.0:
		await _sprite(side).flash(_t(0.15))
	await _sprite(side).blink(3, _t(0.06))
	var change := absf(box.hp - hp) / float(box.max_hp)
	await box.animate_hp(hp, -1, _t(clampf(change * 1.2, 0.25, 1.0)))
	_update_low_hp_music()


func _throw_ball(shakes: int, caught: bool) -> void:
	var ball := Sprite2D.new()
	ball.texture = BALL_TEXTURE
	ball.scale = Vector2(2, 2)
	ball.position = BALL_FROM
	_fx.add_child(ball)
	var target := _foe_sprite.home() + Vector2(0, -80)
	AudioManager.play_se(&"ball_throw")
	if not fast and not UiPreferences.reduce_motion():
		var tween := create_tween()
		tween.tween_method(_ball_arc.bind(ball, target), 0.0, 1.0, 0.6)
		await tween.finished
	ball.position = target
	await _foe_sprite.withdraw(_t(0.3))
	var ground := _foe_sprite.home() + Vector2(0, -12)
	if not fast and not UiPreferences.reduce_motion():
		var drop := create_tween()
		drop.tween_method(func(p: Vector2) -> void: ball.position = _even(p), ball.position, ground, 0.3) \
			.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		await drop.finished
	ball.position = ground
	for i: int in mini(shakes, 3):
		await _wait(_t(0.35))
		AudioManager.play_se(&"ball_shake")
		for step: float in [-2.0, 2.0, -2.0, 0.0]:
			ball.position.x = ground.x + step
			await _wait(_t(0.06))
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


## Destellos y sonido de un shiny al aparecer (DIRECTRICES §8).
func _shiny_sparkles(sprite: BattlePokemonSprite) -> void:
	AudioManager.play_se(&"shiny")
	if fast or UiPreferences.reduce_motion():
		return
	var center := sprite.center()
	var offsets: Array[Vector2] = [Vector2(-56, -40), Vector2(48, -56), Vector2(-24, 24), Vector2(60, 16), Vector2(0, -72)]
	for i: int in offsets.size():
		var sparkle := Sprite2D.new()
		sparkle.texture = SPARKLE
		sparkle.hframes = SPARKLE_FRAMES
		sparkle.scale = Vector2(2, 2)
		sparkle.position = _even(center + offsets[i])
		_fx.add_child(sparkle)
		_animate_sparkle(sparkle, i * 0.08)
	await _wait(0.75)


func _animate_sparkle(sparkle: Sprite2D, delay: float) -> void:
	sparkle.visible = false
	await _wait(delay)
	sparkle.visible = true
	for frame: int in [0, 1, 2, 1, 2, 1, 0]:
		sparkle.frame = frame
		await _wait(0.08)
	sparkle.queue_free()


static func _even(v: Vector2) -> Vector2:
	return (v / 2.0).round() * 2.0


func _ball_arc(t: float, ball: Sprite2D, target: Vector2) -> void:
	ball.position = _even(BALL_FROM.lerp(target, t) + Vector2(0, -sin(t * PI) * 96.0))


# --- Menús ---

func _ask_player(request: Dictionary) -> Dictionary:
	_field_slots[BattleDriver.PLAYER] = int(request.get("slot",0))
	match StringName(request.get("kind", BattleDriver.REQUEST_ACTION)):
		BattleDriver.REQUEST_SWITCH:
			if StringName(request.get("reason", "")) == &"shift":
				var choice := await _list(tr("El rival sacará otro Pokémon.\n¿Quieres cambiar?"),
					[tr("Cambiar Pokémon"), tr("Seguir luchando")], [], true)
				return {"type": &"switch", "party_index": await _choose_party(false) if choice == 0 else -1}
			return {"type": &"switch", "party_index": await _choose_party(true)}
		BattleDriver.REQUEST_LEARN_MOVE:
			return {"type": &"learn_move", "forget_index": await _choose_forget(request)}
	return await _choose_action(request)


func _choose_action(request: Dictionary = {}) -> Dictionary:
	while true:
		var active := _driver.player_active()
		_box.set_text_width(PROMPT_TEXT_WIDTH)
		await _box.play(tr("¿Qué debería hacer %s?") % active.get("name", ""), "", false)
		_command_panel.show()
		var command := await _command_menu.choose(_last_command, false)
		if command >= 0 and not fast:
			await (_command_menu.get_child(command) as BattleButton).press()
		_command_panel.hide()
		_box.set_text_width(-1.0)
		_last_command = command
		match command:
			Command.FIGHT:
				var slot := await _choose_move(active)
				if slot >= 0:
					var target := await _choose_target(active,slot)
					if target >= 0: return {"type": &"fight", "move_slot": slot,"target_slot":target}
			Command.BAG:
				if not request.get("can_use_items",true):
					await _message("No puedes usar objetos en este turno.")
					continue
				var use := await _choose_item()
				if not use.is_empty():
					return use
			Command.POKEMON:
				if not request.get("can_switch",true):
					await _message("No puedes cambiar de Pokémon en este turno.")
					continue
				var index := await _choose_party(false)
				if index >= 0:
					return {"type": &"switch", "party_index": index}
			Command.RUN:
				if request.get("can_run", true):
					return {"type": &"run"}
				await _message(tr("¡No puedes huir de un combate contra un entrenador!"))
	return {}


func _choose_move(active: Dictionary) -> int:
	var moves: Array = active.get("moves", [])
	if moves.all(func(m: Dictionary) -> bool: return int(m.get("pp", 0)) <= 0):
		return 0
	for i: int in 4:
		var button := _move_menu.get_child(i) as BattleButton
		button.text = str(moves[i].get("name", "?")) if i < moves.size() else "—"
		button.set_type_icon(StringName(moves[i].get("type", "")) if i < moves.size() else &"")
		_move_menu.set_disabled(i, i >= moves.size() or int(moves[i].get("pp", 0)) <= 0)
	var update := _show_move_info.bind(moves)
	_move_menu.selection_changed.connect(update)
	_box.clear()
	_move_panel.show()
	var slot := await _move_menu.choose(mini(_last_move, maxi(moves.size() - 1, 0)))
	if slot >= 0 and not fast:
		await (_move_menu.get_child(slot) as BattleButton).press()
	_move_menu.selection_changed.disconnect(update)
	_move_panel.hide()
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
	_move_type.text = {"physical": tr("Físico"), "special": tr("Especial"), "status": tr("Estado")}.get(
		str(move.get("category", "")), "")


## Objeto que usar (y sobre quién). {} = el jugador ha vuelto atrás.
func _choose_item() -> Dictionary:
	var items := _driver.battle_items()
	if items.is_empty():
		await _message(tr("No tienes objetos que puedas usar ahora."))
		return {}
	var labels := PackedStringArray()
	for item: Dictionary in items:
		labels.append("%s ×%d" % [item.get("name", "?"), int(item.get("count", 0))])
	var index := await _list(tr("¿Qué objeto quieres usar?"), labels, [], true)
	if index < 0:
		return {}
	var item_id := StringName(items[index].get("id", ""))
	var target := -1
	if _driver.item_needs_target(item_id):
		target = await _choose_party(false, true)
		if target < 0:
			return {}
	if not _driver.can_use_item(item_id, target):
		await _message(tr("No tendría ningún efecto."))
		return {}
	return {"type": &"item", "item": item_id, "party_index": target}


## Pokémon del equipo: para cambiar (no se puede elegir el activo ni los debilitados)
## o, con `for_item`, como objetivo de un objeto (se puede elegir cualquiera).
func _choose_party(forced: bool, for_item: bool = false) -> int:
	var party := _driver.player_party()
	var labels := PackedStringArray()
	var disabled: Array[bool] = []
	for pokemon: Dictionary in party:
		labels.append("%s  Nv%d  %d/%d" % [pokemon.get("name", "?"), int(pokemon.get("level", 1)),
			int(pokemon.get("hp", 0)), int(pokemon.get("max_hp", 1))])
		disabled.append(not for_item and (not pokemon.get("able", true) or pokemon.get("active", false)))
	var prompt := tr("¿Sobre qué Pokémon?") if for_item else (tr("¿Qué Pokémon sacarás?") if forced else tr("Elige un Pokémon."))
	return await _list(prompt, labels, disabled, not forced)


## Qué movimiento olvidar para aprender `request.move_name` (−1 = no aprenderlo).
func _choose_forget(request: Dictionary) -> int:
	return await LearnMoveScreen.choose(request)


func _list(prompt: String, labels: PackedStringArray, disabled: Array[bool], can_cancel: bool) -> int:
	await _box.play(prompt, "", false)
	_list_menu.set_items(labels)
	for i: int in disabled.size():
		_list_menu.set_disabled(i, disabled[i])
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
	# Sin sprite real (aún no hay entrenadores en combate) no se enseña ningún relleno.
	var player_back := PlaceholderArt.load_texture(PLAYER_BACK_SPRITE % GameState.player_gender)
	_set_trainer_texture(_player_trainer, player_back)
	_player_trainer.visible = player_back != null
	if not trainer.is_empty():
		var sprite := PlaceholderArt.load_texture(str(trainer.get("battle_sprite", "")))
		_set_trainer_texture(_foe_trainer, sprite)
		_foe_trainer.visible = sprite != null
	_curtain_a.hide()
	_curtain_b.hide()
	await BattleEntryTransition.play(self, _info, fast or UiPreferences.reduce_motion())
	var player_home := _player_trainer.position
	_player_trainer.position.x = OFFSCREEN_RIGHT
	var foe_home := _foe_trainer.position
	_foe_trainer.position.x = OFFSCREEN_LEFT
	var wild := _first_wild(start_events)
	if not wild.is_empty():
		_foe_sprite.set_pokemon(wild)
		_foe_sprite.position.x = OFFSCREEN_LEFT
	var duration := maxf(_t(0.6), 0.001)
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT)
	tween.tween_method(func(p: Vector2) -> void: _player_trainer.position = p.round(),
		_player_trainer.position, player_home, duration)
	tween.tween_method(func(p: Vector2) -> void: _foe_trainer.position = p.round(),
		_foe_trainer.position, foe_home, duration)
	if not wild.is_empty():
		tween.tween_method(func(p: Vector2) -> void: _foe_sprite.position = p.round(),
			_foe_sprite.position, _foe_sprite.home(), duration)
	await tween.finished
	if not trainer.is_empty():
		await _message(tr("¡%s te desafía!") % trainer.get("display_name", ""))


func _outro(outcome: StringName) -> void:
	match outcome:
		SceneManager.OUTCOME_LOSE:
			if not _info.get("can_lose", false):
				await _message(Dialogue.format_text(tr("¡{player} está fuera de combate!")))
		SceneManager.OUTCOME_CAUGHT:
			if not fast: await AudioManager.play_me(&"caught")
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
	if _foe_trainer.texture == null or (_foe_trainer.visible and is_equal_approx(_foe_trainer.position.x, _foe_sprite.home().x)):
		return
	_foe_trainer.show()
	await _slide_sprite(_foe_trainer, _foe_sprite.home().x, _t(0.5))


func _open_curtain(horizontal: bool) -> void:
	if horizontal:
		_curtain_a.position = Vector2(0, 0)
		_curtain_a.size = Vector2(256, 96)
		_curtain_b.position = Vector2(0, 96)
		_curtain_b.size = Vector2(256, 96)
	else:
		_curtain_a.position = Vector2(0, 0)
		_curtain_a.size = Vector2(128, 192)
		_curtain_b.position = Vector2(128, 0)
		_curtain_b.size = Vector2(128, 192)
	_curtain_a.show()
	_curtain_b.show()
	if not fast and not UiPreferences.reduce_motion():
		var tween := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		if horizontal:
			tween.tween_property(_curtain_a, ^"position:y", -96.0, 0.3)
			tween.tween_property(_curtain_b, ^"position:y", 192.0, 0.3)
		else:
			tween.tween_property(_curtain_a, ^"position:x", -128.0, 0.3)
			tween.tween_property(_curtain_b, ^"position:x", 256.0, 0.3)
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
	if fast or UiPreferences.reduce_motion():
		return
	var home := box.position
	var from := home + Vector2(24.0 if box.is_player else -24.0, 0)
	box.modulate.a = 0.0
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT)
	tween.tween_method(func(p: Vector2) -> void: box.position = p.round(), from, home, 0.15)
	tween.tween_property(box, ^"modulate:a", 1.0, 0.15)
	await tween.finished


func _slide_sprite(sprite: Node2D, to_x: float, duration: float) -> void:
	if duration <= 0.0:
		sprite.position.x = to_x
		return
	var tween := create_tween()
	tween.tween_method(func(x: float) -> void: sprite.position.x = roundf(x), sprite.position.x, to_x, duration)
	await tween.finished


func _set_trainer_texture(sprite: Sprite2D, texture: Texture2D) -> void:
	sprite.texture = texture
	sprite.centered = false
	if texture == null:
		return
	sprite.offset = Vector2(-texture.get_width() / 2.0, -texture.get_height()).round()


func _button(color: StringName, text: String, button_size: Vector2) -> BattleButton:
	var button := BattleButton.new()
	button.color = color
	button.text = text
	button.custom_minimum_size = button_size
	return button


func _sprite(side: int, slot := -1) -> BattlePokemonSprite:
	var resolved: int = _field_slots.get(side,0) if slot < 0 else slot
	if resolved == 1 and _second_sprites.has(side): return _second_sprites[side]
	return _player_sprite if side == BattleDriver.PLAYER else _foe_sprite


func _data_box(side: int, slot := -1) -> BattleDataBox:
	var resolved: int = _field_slots.get(side,0) if slot < 0 else slot
	if resolved == 1 and _second_boxes.has(side): return _second_boxes[side]
	return _player_box if side == BattleDriver.PLAYER else _foe_box


func _trainer() -> Dictionary:
	var trainers: Array = _info.get("trainers", [])
	return trainers[0] if not trainers.is_empty() else {}


func _t(seconds: float) -> float:
	return 0.0 if fast or UiPreferences.reduce_motion() else seconds


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

func _pending_evolutions() -> void:
	var driver := _driver as EngineDriver
	if _driver is LockeBattleDriver: driver = _driver.inner
	if driver == null: return
	for pending: Dictionary in driver.engine.result.pending_evolutions:
		for p: Pokemon in GameState.party.members:
			if p.uid == str(pending.get("uid", "")) and not p.is_fainted():
				await EvolutionScreen.open(p, pending.get("evolution", {"to": pending.to}), &"", fast)
				break

func _update_low_hp_music() -> void:
	if _music_finished: return
	var low := false
	for slot: int in (2 if _info.get("format",&"single") == &"double" else 1):
		var box := _data_box(BattleDriver.PLAYER,slot)
		low = low or (box.visible and box.hp > 0 and float(box.hp) / maxi(box.max_hp,1) <= 0.2)
	if low and not _low_hp_music:
		AudioManager.save_bgm()
		AudioManager.play_bgm(&"low_hp", 0.15)
		_low_hp_music = true
	elif not low: _end_low_hp_music()

func _end_low_hp_music() -> void:
	if _low_hp_music:
		AudioManager.restore_bgm(0.15)
		_low_hp_music = false

func _configure_field() -> void:
	_field_slots = {BattleDriver.PLAYER:0,BattleDriver.FOE:0}
	if _info.get("format",&"single") != &"double": return
	_player_sprite.set_home(Vector2(68,292))
	_foe_sprite.set_home(Vector2(304,108))
	_foe_shadow.position = Vector2(304,100)
	_player_box.position = Vector2(132,70)
	_foe_box.position = Vector2(4,4)
	for side: int in [BattleDriver.PLAYER,BattleDriver.FOE]:
		if _second_sprites.has(side): continue
		var sprite := BattlePokemonSprite.new()
		sprite.back = side == BattleDriver.PLAYER
		sprite.position = Vector2(188,312) if sprite.back else Vector2(422,132)
		$World.add_child(sprite)
		$World.move_child(sprite,_fx.get_index())
		_second_sprites[side] = sprite
		var box := BattleDataBox.new()
		box.is_player = sprite.back
		box.position = Vector2(132,108) if sprite.back else Vector2(4,40)
		$Canvas.add_child(box)
		$Canvas.move_child(box,_box.get_index())
		box.hide()
		_second_boxes[side] = box

func target_slots(active: Dictionary, move_slot: int) -> Array[int]:
	var targets: Array[int] = []
	if _info.get("format",&"single") != &"double": return [0]
	var moves: Array = active.get("moves",[])
	if move_slot < moves.size():
		var id := StringName(moves[move_slot].get("id",""))
		if DataDB.has_move(id):
			var move := DataDB.move(id)
			if move.targets_user() or move.target in MoveData.FIELD_TARGETS or move.target in [&"adjacent_ally",&"all_adjacent_foes",&"all_adjacent",&"all",&"ally_side"]: return [0]
	for slot: int in 2:
		var box := _data_box(BattleDriver.FOE,slot)
		if box.visible and box.hp > 0: targets.append(slot)
	return targets
func _choose_target(active: Dictionary,move_slot: int) -> int:
	var targets := target_slots(active,move_slot)
	if targets.size() <= 1: return targets[0] if not targets.is_empty() else 0
	var labels := PackedStringArray()
	for slot: int in targets: labels.append("%s / puesto %d" % [_data_box(BattleDriver.FOE,slot).pokemon_name,slot+1])
	var picked := await _list("Elige el objetivo.",labels,[],true)
	return targets[picked] if picked >= 0 else -1
