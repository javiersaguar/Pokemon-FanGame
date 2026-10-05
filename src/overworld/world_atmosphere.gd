class_name WorldAtmosphere
extends Node2D
## Tinte solo del canvas del mundo; UI/combate van en CanvasLayer distintos.
var map: MapRoot
var tint := CanvasModulate.new()
var particles := CPUParticles2D.new()
var transition: Tween
func _ready() -> void:
	add_child(tint)
	particles.emitting = false
	particles.z_index = 100
	add_child(particles)
	EventBus.time_period_changed.connect(_period_changed)
func _process(_delta: float) -> void:
	if particles.emitting:
		var camera := get_viewport().get_camera_2d()
		if camera:
			particles.global_position = camera.get_screen_center_position() + Vector2(0, -220)
static func tint_for(data: MapData, period: StringName) -> Color:
	if data == null or not data.outdoor:
		return Color.WHITE
	return Color(str(GameState.world_config.get("clock", {}).get("tints", {}).get(String(period), "ffffff")))
func apply_map(value: MapRoot) -> void:
	map = value
	if transition:
		transition.kill()
	tint.color = tint_for(map.data, Clock.period())
	particles.emitting = false
	var weather := String(map.data.weather) if map.data and map.data.outdoor else "none"
	var cfg: Dictionary = GameState.world_config.get("weather", {}).get("presets", {}).get(weather, {})
	var texture_path := str(cfg.get("texture", "")) if cfg.get("texture") != null else ""
	if not texture_path.is_empty() and ResourceLoader.exists(texture_path):
		particles.texture = load(texture_path)
		particles.amount = maxi(1, int(cfg.get("amount", 80)))
		particles.lifetime = maxf(0.1, float(cfg.get("lifetime", 1.0)))
		particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		particles.emission_rect_extents = Vector2(300, 0)
		particles.direction = Vector2.DOWN
		particles.gravity = Vector2.ZERO
		particles.initial_velocity_min = float(cfg.get("velocity", 100))
		particles.initial_velocity_max = particles.initial_velocity_min
		particles.spread = 10.0
		particles.emitting = true
	var ambient := map.data.ambient if map.data and map.data.ambient != &"" else StringName(cfg.get("ambient", ""))
	if ambient != &"":
		AudioManager.play_ambient(ambient)
	else:
		AudioManager.stop_ambient()
func reset() -> void:
	map = null
	if transition:
		transition.kill()
	tint.color = Color.WHITE
	particles.emitting = false
	AudioManager.stop_ambient()
func _period_changed(period: StringName) -> void:
	if not is_instance_valid(map):
		return
	if transition:
		transition.kill()
	transition = create_tween()
	transition.tween_property(tint, "color", tint_for(map.data, period),
		float(GameState.world_config.get("clock", {}).get("tint_transition", 2.0)))
