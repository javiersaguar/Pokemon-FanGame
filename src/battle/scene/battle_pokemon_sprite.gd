class_name BattlePokemonSprite
extends Node2D
## Sprite de un Pokémon en el campo, a 1:1 en píxeles de pantalla (frente de
## 192×192 y espalda de 288×288, como vienen en el pack). El nodo está en el borde
## inferior del lienzo; la imagen se dibuja encima.
## Reglas de píxel (BIBLIA.md §3): nada de escalar ni rotar. Salir de la Ball,
## volver a ella y debilitarse se hacen recortando la imagen (región) y con
## destellos; las posiciones se redondean a píxeles del arte.

const SPRITES_DIR := "res://assets/sprites/pokemon/"
## Reposo: 1 píxel de arte arriba y abajo (el set actual no está animado).
const IDLE_INTERVAL := 0.45
const FLASH := Color(3.5, 3.5, 3.5)

## true = sprite de espaldas (el Pokémon del jugador).
@export var back := false

var species_id: StringName = &""
var idle := true

var _sprite: Sprite2D
## Filas vacías bajo los pies en la imagen: se compensan para que los pies queden en el nodo.
var _gap := 0.0
var _home := Vector2.ZERO
static var _gaps: Dictionary[String, int] = {}
var _idle_time := 0.0
var _idle_up := false


func _ready() -> void:
	_home = position
	_sprite = Sprite2D.new()
	_sprite.centered = false
	_sprite.region_enabled = true
	add_child(_sprite)
	hide()


func _process(delta: float) -> void:
	if not idle or not visible:
		return
	_idle_time += delta
	if _idle_time >= IDLE_INTERVAL:
		_idle_time -= IDLE_INTERVAL
		_idle_up = not _idle_up
		_sprite.position.y = -2.0 if _idle_up else 0.0


func set_pokemon(pokemon: Dictionary) -> void:
	species_id = StringName(pokemon.get("species", ""))
	var folder := ("back" if back else "front") + ("_shiny" if pokemon.get("shiny", false) else "")
	var texture := PlaceholderArt.load_texture("%s%s/%s.png" % [SPRITES_DIR, folder, species_id])
	if texture == null:
		texture = PlaceholderArt.pokemon(pokemon.get("types", []), back)
	_sprite.texture = texture
	_gap = _bottom_gap(texture)
	reset()


## Vuelve a su sitio, entero, visible y sin destellos.
func reset() -> void:
	position = _home
	modulate = Color.WHITE
	_sprite.self_modulate = Color.WHITE
	_reveal(1.0)
	show()


func home() -> Vector2:
	return _home


## Centro aproximado de la imagen (para los efectos).
func center() -> Vector2:
	return _home + Vector2(0, -_height() * scale.y / 2.0)


## Sale de la Poké Ball: aparece de abajo arriba en blanco y recupera el color.
func appear(duration: float) -> void:
	reset()
	if duration <= 0.0:
		return
	_sprite.self_modulate = FLASH
	var tween := create_tween()
	tween.tween_method(_reveal, 0.0, 1.0, duration * 0.6)
	tween.tween_property(_sprite, ^"self_modulate", Color.WHITE, duration * 0.4)
	await tween.finished


## Vuelve a la Poké Ball: se pone en blanco y se recoge hacia abajo.
func withdraw(duration: float) -> void:
	if duration > 0.0:
		var tween := create_tween()
		tween.tween_property(_sprite, ^"self_modulate", FLASH, duration * 0.4)
		tween.tween_method(_reveal, 1.0, 0.0, duration * 0.6)
		await tween.finished
	hide()


## Entra deslizándose desde `from_x` (Pokémon salvajes).
func slide_in(from_x: float, duration: float) -> void:
	reset()
	if duration <= 0.0:
		return
	await move_to(Vector2(from_x, _home.y), Vector2(_home.x, _home.y), duration, Tween.EASE_OUT)


func move_to(from: Vector2, to: Vector2, duration: float, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
	position = from.round()
	var tween := create_tween()
	tween.tween_method(_set_position_rounded, from, to, duration).set_ease(ease_type).set_trans(Tween.TRANS_QUAD)
	await tween.finished


## Parpadeo al recibir daño.
func blink(times: int, interval: float) -> void:
	for i: int in times:
		visible = false
		await _wait(interval)
		visible = true
		await _wait(interval)


## Destello blanco (golpe crítico o supereficaz).
func flash(duration: float) -> void:
	if duration <= 0.0:
		return
	_sprite.self_modulate = FLASH
	var tween := create_tween()
	tween.tween_property(_sprite, ^"self_modulate", Color.WHITE, duration)
	await tween.finished


## Se debilita: se hunde en la base (recortándose) y desaparece.
func faint(duration: float) -> void:
	if duration > 0.0:
		var tween := create_tween()
		tween.tween_method(_sink, 0.0, 1.0, duration).set_ease(Tween.EASE_IN)
		await tween.finished
	hide()


## Embestida hacia `target` (ataques físicos).
func lunge(target: Vector2, duration: float) -> void:
	if duration <= 0.0:
		return
	var toward := ((_home + (target - _home).normalized() * 24.0) / 2.0).round() * 2.0
	await move_to(_home, toward, duration * 0.4, Tween.EASE_OUT)
	await move_to(toward, _home, duration * 0.6)


## Muestra la parte de abajo de la imagen: 0 = nada, 1 = entera.
func _reveal(amount: float) -> void:
	if _sprite.texture == null:
		return
	var full := _sprite.texture.get_size()
	var shown := roundf(full.y * clampf(amount, 0.0, 1.0))
	_sprite.region_rect = Rect2(0, full.y - shown, full.x, shown)
	_sprite.offset = Vector2(-full.x / 2.0, -shown + _gap).round()


## Se hunde `amount` (0–1) de su altura: baja y se recorta por debajo de la base.
func _sink(amount: float) -> void:
	if _sprite.texture == null:
		return
	var full := _sprite.texture.get_size()
	var gone := roundf(full.y * clampf(amount, 0.0, 1.0))
	_sprite.region_rect = Rect2(0, 0, full.x, full.y - gone)
	_sprite.offset = Vector2(-full.x / 2.0, -full.y + gone + _gap).round()


## Filas transparentes bajo el dibujo (en píxeles pares, la escala del pack).
static func _bottom_gap(texture: Texture2D) -> int:
	var key := texture.resource_path
	if key != "" and _gaps.has(key):
		return _gaps[key]
	var img := texture.get_image()
	var gap := 0
	if img:
		gap = img.get_height()
		for y: int in range(img.get_height() - 1, -1, -1):
			var empty := true
			for x: int in img.get_width():
				if img.get_pixel(x, y).a8 > 0:
					empty = false
					break
			if not empty:
				gap = img.get_height() - 1 - y
				break
		gap = gap - gap % 2
	if key != "":
		_gaps[key] = gap
	return gap


func _height() -> float:
	return _sprite.texture.get_height() if _sprite.texture else 32.0


## Píxeles pares: los sprites de los packs ya vienen al doble (1 píxel del arte = 2 de pantalla).
func _set_position_rounded(value: Vector2) -> void:
	position = (value / 2.0).round() * 2.0


func _wait(seconds: float) -> void:
	if seconds > 0.0:
		await get_tree().create_timer(seconds).timeout

func set_home(at: Vector2) -> void:
	_home = at.round()
	position = _home

func set_big(on: bool) -> void:
	scale = Vector2(2,2) if on else Vector2.ONE
