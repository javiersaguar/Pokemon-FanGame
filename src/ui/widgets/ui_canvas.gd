class_name UiCanvas
extends Control
## Lienzo de la interfaz del juego: 256×192 "píxeles de arte" mostrados a ×2 sobre
## la pantalla de 512×384 (BIBLIA.md §2). Las pantallas del juego cuelgan de uno y
## se maquetan en esas coordenadas. Para detalle a 1×, un hijo con escala 0,5.

const SIZE := Vector2(256, 192)
const UI_SCALE := 2


func _init() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	position = Vector2.ZERO
	size = SIZE
	scale = Vector2(UI_SCALE, UI_SCALE)
