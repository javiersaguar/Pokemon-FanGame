@tool
class_name NPC
extends Character
## NPC base. Al hablarle se gira hacia el jugador y dice sus `lines`.
## Para un comportamiento propio, hereda (con @tool) y sobrescribe _on_interact().
## TrainerNPC (Agente 3) hereda de aquí.

## Nombre que muestra el cuadro de diálogo (vacío = sin nombre).
@export var display_name: String = ""
## Frases al hablarle, en orden.
@export_multiline var lines: PackedStringArray = []
## Desactívalo para estatuas, personajes dormidos o escenas de espaldas.
@export var turn_on_interact := true
## Compatibilidad con escenas anteriores; usa turn_on_interact en mapas nuevos.
@export var turn_to_player: bool:
	get:
		return turn_on_interact
	set(value):
		turn_on_interact = value
## Evento al hablarle (script que hereda de StoryEvent). Si hay evento, no se
## dicen las `lines`. Se ejecuta en Cutscene y recibe `event_params`.
@export var event: GDScript
@export var event_params: Dictionary = {}

@export_group("Paseo")
## Da pasos al azar alrededor de su casilla inicial.
@export var wander := false
@export_range(1, 10) var wander_radius := 2
## Segundos entre pasos (mínimo y máximo).
@export var wander_interval := Vector2(1.5, 4.0)

var home_tile: Vector2i
var talking := false

var _wander_timer := 0.0


func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	home_tile = tile_position()
	_reset_wander_timer()


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not wander or moving or talking or GameState.input_locked:
		return
	_wander_timer -= delta
	if _wander_timer > 0.0:
		return
	_reset_wander_timer()
	var dir: Vector2i = DIRECTIONS.pick_random()
	var target := tile_position() + dir
	if absi(target.x - home_tile.x) > wander_radius or absi(target.y - home_tile.y) > wander_radius:
		face(dir)
		return
	step(dir)


func interact(player: Player) -> void:
	talking = true
	while moving:
		await step_finished
	if turn_on_interact:
		face_towards(player)
	await _on_interact(player)
	talking = false


## Comportamiento al hablarle. Por defecto, su evento o, si no tiene, sus `lines`.
func _on_interact(_player: Player) -> void:
	if event:
		await Cutscene.play(event, self, event_params)
		return
	for line: String in lines:
		await Dialogue.say(WorldNames.resolve(line), WorldNames.resolve(display_name))


func _reset_wander_timer() -> void:
	_wander_timer = randf_range(wander_interval.x, wander_interval.y)
