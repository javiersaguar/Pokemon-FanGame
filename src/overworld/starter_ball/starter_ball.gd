@tool
class_name StarterBall
extends MapEntity
## Poké Ball de la mesa del laboratorio con uno de los tres iniciales (Fase 8.3).
## La especie la decide DataDB.starter(slot) (regla R.2). Ponle
## hidden_if_flag = &"starter_chosen" para que las tres desaparezcan al elegir.

const ChooseStarterEvent := preload("res://src/events/common/choose_starter_event.gd")

## Hueco de data/starters.json: "starter_1", "starter_2" o "starter_3".
@export var starter_slot: StringName = &"starter_1"
## Valor de la var `starter` si se elige (1 Planta, 2 Fuego, 3 Agua: decide el rival).
@export_range(1, 3) var starter_index := 1


func interact(_player: Player) -> void:
	await Cutscene.play(ChooseStarterEvent, self, {"slot": starter_slot, "index": starter_index})
