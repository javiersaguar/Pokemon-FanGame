class_name BattlePokemonSprite
extends Node2D
## Sprite de un Pokémon en el campo. El nodo está en los "pies" (centro de la
## base); la imagen se dibuja encima. Si falta el sprite, usa PlaceholderArt.

const SPRITES_DIR := "res://assets/sprites/pokemon/"

## true = sprite de espaldas (el Pokémon del jugador).
@export var back := false

var species_id: StringName = &""

var _sprite: Sprite2D
var _home := Vector2.ZERO


func _ready() -> void:
	_home = position
	_sprite = Sprite2D.new()
	_sprite.centered = false
	add_child(_sprite)
	hide()


func set_pokemon(pokemon: Dictionary) -> void:
	species_id = StringName(pokemon.get("species", ""))
	var folder := ("back" if back else "front") + ("_shiny" if pokemon.get("shiny", false) else "")
	var texture := PlaceholderArt.load_texture("%s%s/%s.png" % [SPRITES_DIR, folder, species_id])
	if texture == null:
		texture = PlaceholderArt.pokemon(pokemon.get("types", []), back)
	_sprite.texture = texture
	_sprite.offset = Vector2(-texture.get_width() / 2.0, -texture.get_height()).round()
	reset()


## Vuelve a su sitio, visible, opaco y a tamaño normal.
func reset() -> void:
	position = _home
	scale = Vector2.ONE
	modulate = Color.WHITE
	_sprite.self_modulate = Color.WHITE
	show()


func home() -> Vector2:
	return _home


## Centro aproximado de la imagen (para los efectos).
func center() -> Vector2:
	var height := _sprite.texture.get_height() if _sprite.texture else 32
	return _home + Vector2(0, -height / 2.0)


## Sale de la Poké Ball: crece desde cero con un destello blanco.
func appear(duration: float) -> void:
	reset()
	scale = Vector2(0.1, 0.1) if duration > 0.0 else Vector2.ONE
	_sprite.self_modulate = Color(4, 4, 4) if duration > 0.0 else Color.WHITE
	if duration <= 0.0:
		return
	var tween := create_tween().set_parallel()
	tween.tween_property(self, ^"scale", Vector2.ONE, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_sprite, ^"self_modulate", Color.WHITE, duration * 1.5)
	await tween.finished


## Vuelve a la Poké Ball: se encoge en rojo.
func withdraw(duration: float) -> void:
	if duration > 0.0:
		var tween := create_tween().set_parallel()
		tween.tween_property(self, ^"scale", Vector2(0.1, 0.1), duration)
		tween.tween_property(_sprite, ^"self_modulate", Color(2.5, 0.6, 0.6), duration)
		await tween.finished
	hide()


## Entra deslizándose desde `from_x` (Pokémon salvajes y entrenadores).
func slide_in(from_x: float, duration: float) -> void:
	reset()
	if duration <= 0.0:
		return
	position.x = from_x
	var tween := create_tween()
	tween.tween_property(self, ^"position:x", _home.x, duration).set_ease(Tween.EASE_OUT)
	await tween.finished


func slide_out(to_x: float, duration: float) -> void:
	if duration > 0.0:
		var tween := create_tween()
		tween.tween_property(self, ^"position:x", to_x, duration).set_ease(Tween.EASE_IN)
		await tween.finished
	hide()


## Parpadeo al recibir daño.
func blink(times: int, interval: float) -> void:
	for i: int in times:
		visible = false
		await _wait(interval)
		visible = true
		await _wait(interval)


## Se debilita: se hunde en la base y desaparece.
func faint(duration: float) -> void:
	if duration > 0.0:
		var tween := create_tween().set_parallel()
		tween.tween_property(self, ^"position:y", _home.y + 24.0, duration).set_ease(Tween.EASE_IN)
		tween.tween_property(self, ^"modulate:a", 0.0, duration)
		await tween.finished
	hide()


## Embestida hacia `target` (ataques físicos).
func lunge(target: Vector2, duration: float) -> void:
	if duration <= 0.0:
		return
	var toward := _home + (target - _home).normalized() * 14.0
	var tween := create_tween()
	tween.tween_property(self, ^"position", toward, duration * 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, ^"position", _home, duration * 0.6).set_ease(Tween.EASE_IN_OUT)
	await tween.finished


func _wait(seconds: float) -> void:
	if seconds > 0.0:
		await get_tree().create_timer(seconds).timeout
