class_name StoryEvent
extends RefCounted
## Evento de historia (Fase 13.1): un guion que se lee de arriba abajo con await.
## Hereda, escribe run() y lánzalo con Cutscene.play(TuEvento, quien_lo_lanza, params).
## Se ejecuta dentro del autoload Cutscene, así que sigue vivo aunque cambie el mapa.
## Regla R.2: nada de especies, objetos ni equipos escritos a mano; pídelos por id
## a DataDB (o recíbelos en `params`).

## Quien lo lanzó (NPC, Trigger...). Puede haberse liberado si cambió el mapa.
var source: Node
## Parámetros del que lo lanza (exports event_params del NPC o del Trigger).
var params: Dictionary = {}
## Mapa en el que empezó.
var map: MapRoot
var player: Player


## El guion. Corrutina: Cutscene espera a que termine.
func run() -> void:
	pass


func param(key: String, default: Variant = null) -> Variant:
	return params.get(key, default)


## Entidad del mapa actual por nombre de nodo (dentro de Entities), o null.
func entity(node_name: String) -> MapEntity:
	var current := SceneManager.current_map
	if current == null or current.get_entities() == null:
		return null
	return current.get_entities().get_node_or_null(NodePath(node_name)) as MapEntity


## `source` como entidad del mapa, si todavía existe.
func source_entity() -> MapEntity:
	return source as MapEntity if is_instance_valid(source) else null
