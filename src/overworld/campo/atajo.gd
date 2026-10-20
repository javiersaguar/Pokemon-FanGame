@tool
class_name Atajo
extends MapEntity
## Atajo que se abre más tarde: un tronco caído o una cancela que tapa un paso y solo se abre desde un
## lado (el que se alcanza dando la vuelta larga). Al examinarlo desde `open_side` pone su `hidden_if_flag` y
## desaparece para siempre; desde el otro lado solo se lee que no se puede mover.

## Lado desde el que se aparta: dirección desde el atajo hasta donde está el jugador.
@export var open_side := Vector2i.DOWN
## Lo que se lee desde el lado que no abre y al abrir (provisional).
@export var closed_text := "Es un tronco caído. Desde este lado no hay manera de moverlo."
@export var open_text := "Empujas el tronco a un lado. ¡Ya hay un atajo por aquí!"


func can_open_from(tile: Vector2i) -> bool:
	var rel := tile - tile_position()
	return (open_side.x != 0 and signi(rel.x) == open_side.x) or (open_side.y != 0 and signi(rel.y) == open_side.y)


func interact(player: Player) -> void:
	if hidden_if_flag == &"" or not can_open_from(player.tile_position()):
		await Dialogue.say(closed_text)
		return
	await Dialogue.say(open_text)
	GameState.set_flag(hidden_if_flag)
