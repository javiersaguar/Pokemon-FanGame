class_name BattleBackground
extends Node2D
## Fondo y bases del combate según el entorno (`battle_background` del mapa).
## Si existe assets/sprites/ui/battle/bg_<entorno>.png se usa; si no, se dibuja
## un fondo provisional con los colores de ENVIRONMENTS.

const IMAGE_PATH := "res://assets/sprites/ui/battle/bg_%s.png"
const SCREEN := Vector2(320, 180)
const FOE_BASE := Rect2(180, 66, 112, 22)
const PLAYER_BASE := Rect2(20, 120, 128, 26)
## Colores provisionales: cielo arriba, cielo abajo, suelo y base.
const ENVIRONMENTS: Dictionary[StringName, Array] = {
	&"grass": [Color("88c8f0"), Color("d8f0f8"), Color("88c068"), Color("609848")],
	&"cave": [Color("483830"), Color("706050"), Color("807060"), Color("584838")],
	&"water": [Color("88c8f0"), Color("d8f0f8"), Color("5898d8"), Color("3870b0")],
	&"indoor": [Color("c8b8a0"), Color("e8e0d0"), Color("b8a888"), Color("988868")],
	&"night": [Color("283058"), Color("485890"), Color("486848"), Color("304830")],
}

var environment: StringName = &"grass"
var _image: Texture2D


func set_environment(id: StringName) -> void:
	environment = id if id != &"" else &"grass"
	_image = PlaceholderArt.load_texture(IMAGE_PATH % environment)
	queue_redraw()


func _draw() -> void:
	if _image:
		draw_texture(_image, Vector2.ZERO)
		return
	var colors: Array = ENVIRONMENTS.get(environment, ENVIRONMENTS[&"grass"])
	var horizon := 60
	for y: int in horizon:
		draw_rect(Rect2(0, y, SCREEN.x, 1), (colors[0] as Color).lerp(colors[1], float(y) / horizon))
	draw_rect(Rect2(0, horizon, SCREEN.x, SCREEN.y - horizon), colors[2])
	for y: int in range(horizon, int(SCREEN.y), 6):
		draw_rect(Rect2(0, y, SCREEN.x, 1), (colors[2] as Color).darkened(0.06))
	_draw_base(FOE_BASE, colors[3])
	_draw_base(PLAYER_BASE, colors[3])


func _draw_base(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var radius := rect.size / 2.0
	for y: int in int(rect.size.y):
		var dy := (y + 0.5 - radius.y) / radius.y
		var half := floorf(radius.x * sqrt(maxf(0.0, 1.0 - dy * dy)))
		var row_color := color.lightened(0.15) if y < rect.size.y * 0.4 else color
		draw_rect(Rect2(center.x - half, rect.position.y + y, half * 2.0, 1), row_color)
