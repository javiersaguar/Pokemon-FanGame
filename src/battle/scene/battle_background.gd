class_name BattleBackground
extends Node2D
## Fondo del combate según el sitio y la hora (data/battle_backgrounds.json, BattleBackgrounds).
## Monta, como Elite Battle: DX: el fondo del pack (384×308), el cielo de cada momento del día con
## el sol, las nubes o las estrellas, las capas de EBDX (decorados, niebla, público...) y el frente
## compuesto con piezas de los packs y .px2 a mano. Se ve a ×2 exacto y encuadrado en el horizonte
## (Javier, respuesta 14). En los exteriores, el tinte del momento del día (el de EBDX) cubre todo
## menos el cielo. Sin rotar ni escalar nada que no sea ×2.

const DIR := BattleBackgrounds.DIR
const BASES := BattleBackgrounds.BASES_DIR
const ZOOM := 2
## Desplazamiento del fondo ampliado para que el horizonte quede a la altura de Añil.
## Javier (respuesta 14) aceptó el ×2 exacto y este encuadre hasta que llegue EBDX.
const OFFSET := Vector2(-128, -40)
const SIZE := Vector2(384, 308)
## Horizonte del fondo: el sol se esconde detrás.
const HORIZON := 102
## Píxeles del fondo por segundo por cada punto de «velocidad» de EBDX (40 cuadros por segundo).
const SCROLL_UNIT := 40.0
const TONE_SHADER := preload("res://src/battle/scene/battle_background_tone.gdshader")
## Compatibilidad con el menú de pruebas y las capturas antiguas.
const FILES: Dictionary[StringName, String] = {
	&"grass": "forest", &"field": "field", &"forest": "forest", &"cave": "cave",
	&"city": "city", &"water": "water", &"indoor": "indoor_a", &"snow": "snow", &"sand": "sand",
}

## Escena de data/battle_backgrounds.json (los ids antiguos se traducen).
var environment: StringName = &"hierba"
var period: StringName = &"day"
var _holder: Node2D
var _tone: ShaderMaterial
## Capas que se mueven: {sprite, dx, dy, frames, frame_time, t, offset, twinkle}.
var _moving: Array[Dictionary] = []
var _still := false


func set_environment(id: StringName, time_period: StringName = &"") -> void:
	environment = BattleBackgrounds.resolve_id(id if id != &"" else &"hierba")
	period = time_period if time_period != &"" else _clock_period()
	_build()


func scene_data() -> Dictionary:
	return BattleBackgrounds.scene(environment)


func is_outdoor() -> bool:
	return bool(scene_data().get("tono", false))


## Tinte que se aplica ahora (0 en interiores y de día).
func current_tone() -> Vector3:
	if not is_outdoor():
		return Vector3.ZERO
	var t: Array = BattleBackgrounds.period(period).get("tono", [0, 0, 0])
	return Vector3(float(t[0]), float(t[1]), float(t[2])) / 255.0


## Base de la escena, o la provisional. null si no hay ninguna.
func base_texture() -> Texture2D:
	return load_base(environment)


## Base del entorno, o la provisional. null si no hay ninguna.
static func load_base(id: StringName) -> Texture2D:
	for path: String in [BattleBackgrounds.base_path(BattleBackgrounds.resolve_id(id)), BASES + "default.png"]:
		if ResourceLoader.exists(path):
			return load(path)
	return null


func _build() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	_moving.clear()
	_still = UiPreferences.reduce_motion()
	_holder = Node2D.new()
	_holder.name = "Escena"
	_holder.position = OFFSET
	_holder.scale = Vector2(ZOOM, ZOOM)
	add_child(_holder)
	var s := scene_data()
	_tone = null
	var tone := current_tone()
	if tone != Vector3.ZERO:
		_tone = ShaderMaterial.new()
		_tone.shader = TONE_SHADER
		_tone.set_shader_parameter(&"tone", tone)
	_sprite("Fondo", BattleBackgrounds.backdrop_path(environment), Vector2.ZERO, true)
	if bool(s.get("cielo", false)):
		_sky()
	for layer: Dictionary in s.get("capas", []):
		if not bool(layer.get("delante", false)):
			_layer(layer)
	var front := BattleBackgrounds.front_path(environment)
	if not front.is_empty():
		_sprite("Frente", front, Vector2.ZERO, true)
	for layer: Dictionary in s.get("capas", []):
		if bool(layer.get("delante", false)):
			_layer(layer)
	set_process(not _moving.is_empty() and not _still)


func _sprite(node_name: String, path: String, at: Vector2, toned: bool) -> Sprite2D:
	var texture := PlaceholderArt.load_texture(path) if ResourceLoader.exists(path) else null
	if texture == null:
		return null
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = texture
	sprite.centered = false
	sprite.position = at
	if toned and _tone != null:
		sprite.material = _tone
	_holder.add_child(sprite)
	return sprite


## Cielo de EBDX del momento del día (sin tinte), con el sol bajo al amanecer y al atardecer
## (como EBDX: de día queda fuera del encuadre) o las estrellas de noche.
func _sky() -> void:
	var p := BattleBackgrounds.period(period)
	_sprite("Cielo", BattleBackgrounds.layer_path(String(p.get("cielo", "cielo_dia"))), Vector2.ZERO, false)
	if p.has("sol"):
		var at: Array = p["sol"]
		var sun := _sprite("Sol", BattleBackgrounds.layer_path("sol"), Vector2.ZERO, false)
		if sun:
			var size := sun.texture.get_size()
			sun.position = Vector2(int(at[0]) - int(size.x) / 2, int(at[1]))
			sun.region_enabled = true
			sun.region_rect = Rect2(0, 0, size.x, clampi(HORIZON - int(at[1]), 0, int(size.y)))
	var stars := int(p.get("estrellas", 0))
	if stars > 0:
		var rng := RandomNumberGenerator.new()
		rng.seed = hash(String(environment))
		for i: int in stars:
			var star := _sprite("Estrella%d" % i, BattleBackgrounds.layer_path("estrella"), Vector2(rng.randi_range(0, 380), rng.randi_range(2, 78)), false)
			if star:
				star.modulate.a = rng.randf_range(0.5, 1.0)
				_moving.append({"sprite": star, "twinkle": rng.randf_range(0.6, 2.0), "t": rng.randf() * TAU})


## Capa de EBDX: posición, opacidad, desplazamiento y cuadros, como en Environments.rb.
func _layer(layer: Dictionary) -> void:
	var sprite := _sprite(String(layer["img"]), BattleBackgrounds.layer_path(String(layer["img"])), Vector2(float(layer.get("x", 0)), float(layer.get("y", 0))), true)
	if sprite == null:
		return
	sprite.modulate.a = float(layer.get("opacidad", 1.0))
	var frames := int(layer.get("cuadros", 1))
	var speed := float(layer.get("velocidad", 0.0))
	if frames > 1:
		var h := sprite.texture.get_height() / frames
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, sprite.texture.get_width(), h)
		_moving.append({"sprite": sprite, "frames": frames, "frame_time": float(layer.get("velocidad_cuadro", 8)) / SCROLL_UNIT, "t": 0.0, "frame": 0})
	elif speed != 0.0:
		if bool(layer.get("vertical", false)):
			_scrolling(sprite, 0.0, speed)
		else:
			_scrolling(sprite, speed, 0.0)


func _scrolling(sprite: Sprite2D, dx: float, dy: float) -> void:
	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sprite.region_enabled = true
	var size := sprite.texture.get_size()
	sprite.region_rect = Rect2(0, 0, maxf(size.x, SIZE.x) if dx != 0.0 else size.x, size.y)
	_moving.append({"sprite": sprite, "dx": dx, "dy": dy, "offset": Vector2.ZERO})


func _process(delta: float) -> void:
	for m: Dictionary in _moving:
		var sprite: Sprite2D = m["sprite"]
		if m.has("dx"):
			m["offset"] += Vector2(float(m["dx"]), float(m["dy"])) * SCROLL_UNIT * delta
			var off: Vector2 = m["offset"]
			sprite.region_rect.position = Vector2(-roundf(off.x), -roundf(off.y))
		elif m.has("frames"):
			m["t"] += delta
			if float(m["t"]) >= float(m["frame_time"]):
				m["t"] = 0.0
				m["frame"] = (int(m["frame"]) + 1) % int(m["frames"])
				sprite.region_rect.position.y = sprite.region_rect.size.y * int(m["frame"])
		elif m.has("twinkle"):
			m["t"] += delta * float(m["twinkle"])
			sprite.modulate.a = 0.55 + 0.45 * absf(sin(float(m["t"])))


static func _clock_period() -> StringName:
	var loop := Engine.get_main_loop()
	if loop is SceneTree:
		var clock: Node = (loop as SceneTree).root.get_node_or_null(^"Clock")
		if clock and clock.has_method(&"period"):
			return clock.period()
	return &"day"
