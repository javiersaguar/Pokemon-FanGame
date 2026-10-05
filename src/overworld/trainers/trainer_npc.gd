@tool
class_name TrainerNPC
extends NPC
## Entrenador en el mapa (Fase 10.4). Contrato: docs/contratos.md §9.8.
## Te ve si estás en línea recta delante de él, a `sight_range` casillas como mucho y
## sin nada en medio: "!", música de su clase, se acerca, dice su intro_text y lucháis.
## Hablarle antes de que te vea también lanza el combate. Si le ganas (flag
## trainer_defeated:<id>), ya no te ve y al hablarle dice su after_text.

const DEFEATED_FLAG := "trainer_defeated:%s"
const DEFAULT_CHALLENGE := preload("res://src/overworld/trainers/trainer_challenge_event.gd")

## Entrenador de data/trainers/*.json.
@export var trainer_id: StringName
## Casillas que ve delante de él. 0 = no te ve: solo lucha si le hablas.
@export_range(0, 10) var sight_range := 4
## El otro entrenador de una pareja: si os ve cualquiera de los dos, os desafían juntos.
## Basta con enlazarlo en uno de los dos.
@export var partner: NodePath
## Opciones de BattleSetup.trainer() (can_lose...).
@export var battle_options: Dictionary = {}
## Evento del desafío (hereda de StoryEvent). Vacío = trainer_challenge_event.gd.
@export var challenge_event: GDScript

## Entrenador con su clase resuelta (TrainerData.get_trainer()).
var data: Dictionary = {}


func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	data = TrainerData.get_trainer(trainer_id) if trainer_id != &"" else {}
	if display_name == "":
		display_name = str(data.get("display_name", ""))
	var sheet := str(data.get("overworld_sprite", ""))
	if sheet != "" and ResourceLoader.exists(sheet):
		sprite_sheet = load(sheet)
	EventBus.player_stepped.connect(_on_player_stepped)


func is_defeated() -> bool:
	return trainer_id != &"" and GameState.flag(StringName(DEFEATED_FLAG % trainer_id))


## true si desde aquí ve la casilla `tile` (la del jugador).
func can_see(tile: Vector2i) -> bool:
	if sight_range <= 0 or trainer_id == &"" or is_defeated() or not is_present() or moving or talking:
		return false
	for i: int in range(1, sight_range + 1):
		var t := tile_position() + facing * i
		if t == tile:
			return true
		if not is_tile_free(t):
			return false
	return false


## Él y su pareja, si la tiene, sin los que ya están derrotados o no están en el mapa.
func group() -> Array[TrainerNPC]:
	var out: Array[TrainerNPC] = []
	for t: TrainerNPC in [self, partner_node()]:
		if t != null and t.is_present() and not t.is_defeated() and not t in out:
			out.append(t)
	return out


## La pareja: la de `partner` o, si no tiene, otro TrainerNPC del mapa que le enlaza a él.
func partner_node() -> TrainerNPC:
	if not partner.is_empty():
		return _linked_partner()
	for sibling: Node in get_parent().get_children() if get_parent() else []:
		if sibling is TrainerNPC and sibling != self and (sibling as TrainerNPC)._linked_partner() == self:
			return sibling as TrainerNPC
	return null


func _linked_partner() -> TrainerNPC:
	return null if partner.is_empty() else get_node_or_null(partner) as TrainerNPC


## Lanza el desafío. `spotted`: te ha visto ("!" y se acerca); si no, le has hablado.
func challenge(spotted: bool) -> void:
	await Cutscene.play(challenge_event if challenge_event else DEFAULT_CHALLENGE, self, {"spotted": spotted})


func _on_interact(player: Player) -> void:
	if trainer_id == &"":
		await super(player)
	elif group().is_empty():
		var after := str(data.get("after_text", ""))
		if after != "":
			await Dialogue.say(after, display_name)
		else:
			await super(player)
	else:
		await challenge(false)


## Se llama de forma síncrona tras cada paso del jugador: bloquear aquí (Cutscene.play
## bloquea antes de su primer await) hace que el jugador deje de andar en esa casilla.
func _on_player_stepped(tile: Vector2i) -> void:
	if GameState.input_locked or Cutscene.is_running() or SceneManager.is_busy():
		return
	if can_see(tile):
		challenge(true)
