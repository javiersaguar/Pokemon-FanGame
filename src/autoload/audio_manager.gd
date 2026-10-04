extends Node
## STUB PROVISIONAL creado por el Agente 1 para que el proyecto arranque.
## Dueño: Agente 3, que lo sustituye por la versión real (Fase 16).
## API mínima prevista (docs/contratos.md, sección AudioManager): no suena nada,
## solo recuerda la pista actual.

var current_bgm: StringName = &""


func play_bgm(id: StringName, _fade_time: float = 0.5) -> void:
	current_bgm = id


func stop_bgm(_fade_time: float = 0.5) -> void:
	current_bgm = &""


func play_se(_id: StringName) -> void:
	pass


## Jingle que pausa la BGM. En la versión real se podrá esperar con await.
func play_me(_id: StringName) -> void:
	pass


func play_cry(_species_id: StringName) -> void:
	pass
