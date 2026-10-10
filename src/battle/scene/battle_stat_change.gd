class_name BattleStatChange
extends Node2D
## Subida/bajada legible: dos oleadas direccionales y la estadística con signo.
## Usa ebStatParticle original de EBDX, a tamaño nativo y sin rotación.
const PARTICLE := preload("res://assets/sprites/ui/battle/moves/ebStatParticle.png")
const NAMES := {"atk":"Ataque","def":"Defensa","spa":"At. Esp.","spd":"Def. Esp.","spe":"Velocidad","accuracy":"Precisión","evasion":"Evasión"}
var amount := 1
var stat := "atk"
var reduced := false
var particles: Array[Sprite2D] = []
var caption: Label
var progress := 0.0:
	set(value):
		progress = clampf(value,0,1)
		if is_node_ready(): _pose()

static func play(parent: Node, at: Vector2, stat_id: String, delta: int, duration: float) -> void:
	if delta == 0 or duration <= 0: return
	var fx := create(parent,at,stat_id,delta,UiPreferences.reduce_motion())
	var tween := fx.create_tween()
	tween.tween_property(fx,^"progress",1.0,duration)
	await tween.finished
	fx.queue_free()

static func create(parent: Node, at: Vector2, stat_id: String, delta: int, reduce := false) -> BattleStatChange:
	var fx := BattleStatChange.new()
	fx.amount = delta
	fx.stat = stat_id
	fx.reduced = reduce
	fx.position = at.round()
	parent.add_child(fx)
	return fx

func _ready() -> void:
	for i: int in (32 if absi(amount) > 1 else 24):
		var star := Sprite2D.new()
		star.texture = PARTICLE
		star.modulate = Color(3.0,1.6,0.4) if amount > 0 else Color(0.5,1.5,3.0)
		star.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(star)
		particles.append(star)
	caption = Label.new()
	caption.theme = preload("res://src/ui/theme/main_theme.tres")
	caption.add_theme_font_size_override(&"font_size",20)
	caption.add_theme_color_override(&"font_color",Color("fff4d8"))
	caption.add_theme_color_override(&"font_shadow_color",Color("303048"))
	caption.add_theme_constant_override(&"shadow_offset_x",2)
	caption.add_theme_constant_override(&"shadow_offset_y",2)
	caption.text = "%+d %s" % [amount,NAMES.get(stat,stat)]
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.size = Vector2(180,26)
	caption.position = Vector2(-90,clampf(-64, 8-position.y, 270-position.y))
	add_child(caption)
	_pose()

func _pose() -> void:
	for i: int in particles.size():
		var phase := clampf((progress - float(i/8)*0.12 - float(i%8)*0.024)/0.52,0,1)
		var direction := -1 if amount > 0 else 1
		particles[i].position = Vector2((i%8-3.5)*14+sin(phase*PI+i)*8,direction*(-40+phase*88)).round()
		particles[i].modulate.a = sin(phase*PI)
		particles[i].visible = not reduced
	caption.modulate.a = 1.0 if reduced else minf(1.0, minf(progress*10,(1-progress)*10))
