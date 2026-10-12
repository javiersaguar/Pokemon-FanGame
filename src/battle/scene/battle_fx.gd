class_name BattleFx
extends Node2D
## Gráficos originales de NikDie, con cuadros y posiciones enteras.
## No dibuja sprites, no rota ni cambia su escala durante la animación.
enum Kind { BURST, ORB, SPARKLE }
const DIR := "res://assets/sprites/ui/battle/moves/"
static var _types: Dictionary = {}
var kind := Kind.BURST
var color := Color.WHITE
var profile: Dictionary = {}
var origin := Vector2.ZERO
var destination := Vector2.ZERO
var particles: Array[Sprite2D] = []
var impact: Sprite2D
var progress := 0.0:
	set(value):
		progress = clampf(value, 0.0, 1.0)
		if is_node_ready(): _pose()

static func type_profile(type: StringName) -> Dictionary:
	if _types.is_empty():
		_types = JSON.parse_string(FileAccess.get_file_as_string("res://data/battle_motion_types.json"))
	return _types.get(String(type), _types.normal).duplicate(true)

static func move(parent: Node, from: Vector2, to: Vector2, details: Dictionary, duration: float) -> void:
	if duration <= 0.0: return
	var category := StringName(str(details.get("category", "physical")).to_lower())
	var style := Kind.SPARKLE if category == &"status" else (Kind.ORB if category == &"special" else Kind.BURST)
	var fx := create(parent, style, from, to, type_profile(StringName(details.get("type", "normal"))), UiColors.type_color(StringName(details.get("type", "normal"))))
	await _play(fx, duration)

static func burst(parent: Node, at: Vector2, tint: Color, duration: float) -> void:
	if duration <= 0.0: return
	await _play(create(parent, Kind.BURST, at, at, {"asset": "eb303", "frame": [64,64]}, tint), duration)

static func orb(parent: Node, from: Vector2, to: Vector2, tint: Color, duration: float) -> void:
	if duration <= 0.0: return
	await _play(create(parent, Kind.ORB, from, to, {"asset": "eb519_2", "frame": []}, tint), duration)

static func sparkle(parent: Node, at: Vector2, tint: Color, duration: float) -> void:
	if duration <= 0.0: return
	await _play(create(parent, Kind.SPARKLE, at, at, {"asset": "eb519_2", "frame": []}, tint), duration)

## Pública para capturas deterministas y comprobación de las hojas importadas.
static func create(parent: Node, style: Kind, from: Vector2, to: Vector2, spec: Dictionary, tint := Color.WHITE) -> BattleFx:
	var fx := BattleFx.new()
	fx.kind = style
	fx.origin = from
	fx.destination = to
	fx.profile = spec
	fx.color = tint
	parent.add_child(fx)
	return fx

static func _play(fx: BattleFx, duration: float) -> void:
	var tween := fx.create_tween()
	tween.tween_property(fx, ^"progress", 1.0, duration)
	await tween.finished
	fx.queue_free()

func _ready() -> void:
	for i: int in int(profile.get("count", 6 if kind == Kind.SPARKLE else 4)):
		var sprite := Sprite2D.new()
		sprite.texture = load(DIR + ("eb519_2" if kind == Kind.SPARKLE and not profile.get("status_asset",false) else str(profile.asset)) + ".png")
		var region: Array = profile.get("region",[])
		if region.size() == 4:
			sprite.region_enabled = true
			sprite.region_rect = Rect2(region[0],region[1],region[2],region[3])
		var frame: Array = [] if kind == Kind.SPARKLE and not profile.get("status_asset",false) else profile.get("frame", [])
		if frame.size() == 2:
			sprite.hframes = int(sprite.texture.get_width() / int(frame[0]))
			sprite.vframes = int(sprite.texture.get_height() / int(frame[1]))
		sprite.flip_h = destination.x < origin.x
		if kind == Kind.SPARKLE: sprite.modulate = color
		add_child(sprite)
		particles.append(sprite)
	impact = Sprite2D.new()
	impact.texture = load(DIR + "eb303.png")
	impact.hframes = 2
	impact.position = destination.round()
	impact.modulate = color
	add_child(impact)
	_pose()

func _pose() -> void:
	for i: int in particles.size():
		var sprite := particles[i]
		var phase := clampf((progress - i * (0.28 / maxf(1.0, particles.size()-1))) / 0.64, 0.0, 1.0)
		sprite.frame = mini(sprite.hframes * sprite.vframes - 1, int(progress * 12.0) % (sprite.hframes * sprite.vframes))
		sprite.modulate.a = sin(phase * PI)
		match kind:
			Kind.ORB:
				sprite.position = origin.lerp(destination, phase).round() + Vector2(0, (i - 1.5) * 12).round()
			Kind.BURST:
				var offsets := [Vector2(-24,-24),Vector2(24,-16),Vector2(-16,16),Vector2(16,24)]
				sprite.position = (destination + offsets[i % offsets.size()] * (1.0 + phase * 0.5)).round()
			Kind.SPARKLE:
				sprite.position = (destination + Vector2((i-2.5)*16, 20 - phase*80)).round()
		match str(profile.get("pattern", "")):
			"slash": sprite.position = (destination + Vector2(24-48*phase,-16+32*phase)).round()
			"peck": sprite.position = (destination + Vector2(0,(i-1)*18)).round()
			"whip": sprite.position = (destination + Vector2((i*2-1)*(50-80*phase), (i*2-1)*16)).round()
			"jet": sprite.position = (origin.lerp(destination,phase)+Vector2(0,(i%3-1)*8)).round()
			"petals": sprite.position = (origin.lerp(destination,phase)+Vector2(sin(phase*TAU+i)*20,(i%5-2)*12)).round()
			"rings": sprite.position = origin.lerp(destination,phase).round()
			"mist": sprite.position = (destination+Vector2((i-1.5)*24,-phase*28)).round()
			"charge":
				var angle := i*TAU/maxi(1,particles.size())
				sprite.position = (destination+Vector2(cos(angle),sin(angle))*(28*(1-phase))).round()
			"beam": sprite.position = (origin.lerp(destination,phase)+Vector2(0,(i%3-1)*4)).round()
			"ice_shards": sprite.position = (destination+Vector2((i-1.5)*16,-phase*30)).round()
			"lightning": sprite.position = (destination+Vector2((1 if i%2 == 0 else -1)*12,-64+phase*80+i*8)).round()
			"psychic_rings":
				var angle := i*TAU/maxi(1,particles.size())+phase*PI
				sprite.position = (destination+Vector2(cos(angle),sin(angle))*28*sin(phase*PI)).round()
			"ground_wave": sprite.position = (destination+Vector2((i-(particles.size()-1)*.5)*20,96-absf(sin(phase*PI))*12)).round()
			"projectile": sprite.position = origin.lerp(destination,phase).round()
			"shadow_burst":
				var angle := i*TAU/maxi(1,particles.size())
				sprite.position = (destination+Vector2(cos(angle),sin(angle))*phase*38).round()
			"flames": sprite.position = (destination+Vector2((i-1.5)*12,12-phase*42)).round()
			"wave":
				sprite.position = Vector2(lerpf(origin.x,destination.x,phase),lerpf(origin.y+48,destination.y+96,phase)).round()
			"water_splash":
				var angle := i*TAU/maxi(1,particles.size())
				sprite.position = (destination+Vector2(cos(angle)*phase*48,72+sin(angle)*phase*24)).round()
			"pressure_jet": sprite.position = (origin.lerp(destination,phase)+Vector2(0,(i%2*2-1)*5)).round()
			"shield": sprite.position = destination.round()
			"shield_motes":
				var angle := i*TAU/maxi(1,particles.size())
				sprite.position = (destination+Vector2(cos(angle)*48,sin(angle)*64)).round()
			"healing": sprite.position = (destination+Vector2((i%4-1.5)*20,38-phase*76-i/4.0*12)).round()
			"swords":
				var angle := i*TAU/maxi(1,particles.size())+phase*TAU
				sprite.position = (destination+Vector2(cos(angle)*38,sin(angle)*18-28*phase)).round()
			"punch": sprite.position = (destination+Vector2(24*(1-phase)*(-1 if destination.x >= origin.x else 1),0)).round()
			"palm": sprite.position = destination.round()
			"chop": sprite.position = (destination+Vector2(0,-40+phase*64)).round()
			"slap": sprite.position = (destination+Vector2(float(profile.get("strike_side",1))*(32-24*phase),0)).round()
			"strike_sparks":
				var angle := i*TAU/maxi(1,particles.size())
				sprite.position = (destination+Vector2(cos(angle),sin(angle))*phase*44).round()
			"heavy_punch": sprite.position = (destination+Vector2(52*(1-phase)*(-1 if destination.x >= origin.x else 1),0)).round()
			"coins": sprite.position = (destination+Vector2((i-2.5)*12*phase,-sin(phase*PI)*42+phase*32)).round()
			"cut": sprite.position = (destination+Vector2(32-64*phase,-32+64*phase)).round()
			"gust":
				sprite.frame = 4+mini(3,int(progress*12)%4)
				sprite.position = origin.lerp(destination,phase).round()
			"ice_fragments":
				var angle := i*TAU/maxi(1,particles.size())
				sprite.position = (destination+Vector2(cos(angle)*phase*36,sin(angle)*phase*28)).round()
	impact.position = (destination+Vector2(0,96 if profile.get("pattern","") == "ground_wave" else 0)).round()
	impact.visible = bool(profile.get("impact",kind != Kind.SPARKLE))
	impact.modulate.a = maxf(0.0, sin(clampf((progress - 0.65) / 0.35, 0, 1) * PI))
	impact.frame = 0 if progress < 0.85 else 1
