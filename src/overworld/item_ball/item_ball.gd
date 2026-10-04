@tool
class_name ItemBall
extends MapEntity
## Objeto en el suelo (Poké Ball) u oculto. Al cogerlo se activa la flag
## item_taken:<map_id>:<nombre del nodo> y ya no vuelve a aparecer.

@export var item_id: StringName
@export_range(1, 99) var quantity := 1
## Oculto: no se ve ni bloquea el paso, pero se encuentra pulsando `accept`.
@export var hidden_item := false:
	set(value):
		hidden_item = value
		if is_node_ready():
			_apply_hidden()

@onready var _sprite: Sprite2D = $Sprite
@onready var _body_shape: CollisionShape2D = $Body/CollisionShape2D
@onready var _area_shape: CollisionShape2D = $Area/CollisionShape2D


func _ready() -> void:
	_apply_hidden()
	if Engine.is_editor_hint():
		return
	if GameState.flag(taken_flag()):
		queue_free()
		return
	super()


func taken_flag() -> StringName:
	var map := get_map()
	var map_id := map.get_map_id() if map else &"?"
	return StringName("item_taken:%s:%s" % [map_id, name])


func interact(_player: Player) -> void:
	GameState.set_flag(taken_flag())
	var added := _give()
	AudioManager.play_me(&"item_get")
	var item_name := _item_name()
	var text := "¡{player} ha encontrado %s!" % (item_name if quantity == 1
		else "%d × %s" % [quantity, item_name])
	if not added:
		push_warning("ItemBall: no hay mochila (GameState.bag); '%s' no se ha guardado." % item_id)
	await Dialogue.say(text)
	queue_free()


func _give() -> bool:
	var bag: Variant = GameState.bag
	if bag is Object and bag.has_method(&"add"):
		bag.add(item_id, quantity)
		return true
	return false


func _item_name() -> String:
	var data: Variant = DataDB.item(item_id)
	if data is Object and &"name" in data:
		return str(data.name)
	return String(item_id)


func _apply_hidden() -> void:
	_sprite.visible = not hidden_item
	if Engine.is_editor_hint():
		_sprite.visible = true
		_sprite.modulate.a = 0.4 if hidden_item else 1.0
	_body_shape.disabled = hidden_item
	_area_shape.disabled = not hidden_item


func _set_collisions_enabled(enabled: bool) -> void:
	_body_shape.set_deferred(&"disabled", not enabled or hidden_item)
	_area_shape.set_deferred(&"disabled", not enabled or not hidden_item)
