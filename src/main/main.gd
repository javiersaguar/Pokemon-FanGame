extends Node
## Escena principal. World (mapa + jugador), Battle, UI y Transition.
## No hace nada más: el flujo del juego lo lleva SceneManager.


func _ready() -> void:
	SceneManager.register_main(self)
	SceneManager.boot()
