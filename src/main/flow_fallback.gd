extends Node
## Flujo provisional con los cuadros existentes; A3 sustituye por sus escenas.
var kind: StringName
func _ready() -> void:
	start.call_deferred()
func start() -> void:
	if kind == &"title":
		SceneManager.run_title_fallback()
	else:
		SceneManager.run_pause_fallback(self)
