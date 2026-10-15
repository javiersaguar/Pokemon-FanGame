class_name RegionMapScreen
extends MenuScreen
## Mapa de la región (menú de pausa y F9). Fondo: el plano de docs/mundo/mapa_region.svg, la base que
## aprobó Javier (decisiones del 2026-10-13, §1); los puntos salen de data/region.json: todas las ciudades
## y pueblos, las rutas, los barrios de Madrid y el sur de Madrid (en su recuadro). Con las flechas se pasa
## de un punto a otro; a la derecha, su nombre, si ya has estado y dónde estás tú. A: volar a un destino
## visitado si tienes la herramienta de Vuelo (WorldTravel). PROVISIONAL: arte definitivo PENDIENTE JAVIER.
const REGION := "res://data/region.json"
const MAP_RECT := Rect2(4, 30, 172, 140)
const KIND_NAMES := {"city": "Ciudad", "town": "Pueblo", "district": "Barrio", "route": "Ruta", "surf": "Ruta marítima (Surf)"}
## Destinos de vuelo ya visitados (WorldTravel.destinations()) y sus nombres.
var destinations: Array[Dictionary] = []
var choices := PackedStringArray()
## Puntos del mapa: {id, name, kind, cell, maps, gym, note}.
var places: Array[Dictionary] = []
var selected := 0
var here := -1
var _region: Dictionary = {}
var _cursor: Panel
var _you: ColorRect
var _name: Label
var _info: Label
var _done := false
var _busy := false
var _time := 0.0

static func open() -> void:
	var screen := RegionMapScreen.new()
	SceneManager.push_menu(screen)
	await screen.closed
	SceneManager.pop_menu(screen)

func _ready() -> void:
	_region = JsonFile.read_dict(REGION)
	heading.text = "Mapa / %s" % str(GameState.world_config.get("names", {}).get("region", _region.get("name", "")))
	hint.text = "Flechas: mover / Z/A: volar / X/B: volver"
	fill(MAP_RECT.grow(1), Color("2f5e86"))
	var image := Image.new()
	if image.load_svg_from_string(FileAccess.get_file_as_string("res://docs/mundo/mapa_region.svg"), MAP_RECT.size.x * 2.0 / (float(_region.get("size", [32, 26])[0]) * 24.0)) == OK:
		var map := Sprite2D.new()
		map.texture = ImageTexture.create_from_image(image)
		map.centered = false
		map.position = MAP_RECT.position
		map.scale = Vector2(0.5, 0.5)
		canvas.add_child(map)
	panel(Rect2(180, 30, 72, 140))
	_name = label("", Rect2(186, 36, 62, 40), Color("382a38"), 10)
	_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info = label("", Rect2(186, 78, 62, 88), Color("382a38"), 8)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_you = ColorRect.new()
	_you.size = Vector2(4, 4)
	_you.color = Color("d63031")
	_you.mouse_filter = MOUSE_FILTER_IGNORE
	canvas.add_child(_you)
	_cursor = Panel.new()
	_cursor.size = Vector2(9, 9)
	_cursor.mouse_filter = MOUSE_FILTER_IGNORE
	var frame := StyleBoxFlat.new()
	frame.draw_center = false
	frame.set_border_width_all(1)
	frame.border_color = Color("f0b030")
	_cursor.add_theme_stylebox_override(&"panel", frame)
	canvas.add_child(_cursor)
	_refresh()

## Recalcula destinos, puntos y el punto donde estás.
func _refresh() -> void:
	destinations = WorldTravel.destinations()
	choices.clear()
	for destination: Dictionary in destinations:
		choices.append(str(destination.get("name", destination.get("id", ""))))
	places = region_places(_region)
	here = place_of(places, String(GameState.map_id))
	selected = here if here >= 0 else 0
	if here >= 0:
		_you.position = position_of(places[here]) + Vector2(2, -6)
	_you.visible = here >= 0
	_show()

## Todos los puntos de data/region.json: ciudades y pueblos, barrios y rutas con mapa. Lo que aún no tiene
## mapa (reservado por otro agente, "pendiente") no sale hasta que exista.
static func region_places(region: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for id: String in region.get("locations", {}):
		var location: Dictionary = region.locations[id]
		if not SceneManager.map_exists(StringName(str(location.get("map", "")))): continue
		out.append({"id": id, "name": str(location.name), "kind": str(location.kind), "cell": location.cell,
			"maps": location.get("maps", [location.get("map", "")]), "gym": location.get("gym", {}), "note": str(location.get("note", "")),
			"start": id in region.get("start", [])})
	for id: String in region.get("districts", {}):
		var district: Dictionary = region.districts[id]
		out.append({"id": id, "name": str(district.name), "kind": "district", "cell": district.cell, "maps": [district.map],
			"gym": {}, "note": str(district.get("note", "")), "start": false})
	for id: String in region.get("routes", {}):
		var route: Dictionary = region.routes[id]
		# Solo las rutas con mapa (los transportes no son un lugar; la Calle de la Victoria aún no existe).
		if str(route.get("map", "")) == "": continue
		var centre := Vector2.ZERO
		for cell: Array in route.cells: centre += Vector2(cell[0], cell[1])
		centre /= route.cells.size()
		out.append({"id": id, "name": str(route.name), "kind": str(route.get("kind", "route")), "cell": [centre.x, centre.y],
			"maps": [route.map], "gym": {}, "note": str(route.get("note", "")), "start": false})
	return out

## Punto al que pertenece un mapa: el que lo tiene en sus mapas o, si es un interior, el de su ciudad o ruta.
static func place_of(list: Array[Dictionary], map_id: String) -> int:
	for i: int in list.size():
		if map_id in list[i].maps and list[i].kind == "district": return i
	for i: int in list.size():
		if map_id in list[i].maps: return i
	var area := map_id.get_slice("/", 0)
	for i: int in list.size():
		for map: Variant in list[i].maps:
			if str(map).get_slice("/", 0) == area and list[i].kind != "district": return i
	return -1

static func visited(place: Dictionary) -> bool:
	for map: Variant in place.maps:
		if GameState.flag(StringName("visited_map:" + str(map))): return true
	return false

## Casilla de data/region.json → posición en el lienzo.
func position_of(place: Dictionary) -> Vector2:
	var size: Array = _region.get("size", [32, 26])
	var cell := Vector2(float(place.cell[0]) + 0.5, float(place.cell[1]) + 0.5)
	return MAP_RECT.position + cell * MAP_RECT.size / Vector2(float(size[0]), float(size[1]))

## El punto más cercano en esa dirección (en un cono de unos 60 grados), o el mismo si no hay.
func neighbour(from: int, direction: Vector2) -> int:
	var origin := position_of(places[from])
	var best := from
	var best_score := INF
	for i: int in places.size():
		if i == from: continue
		var delta := position_of(places[i]) - origin
		if delta.length() < 0.01: continue
		var cosine := delta.normalized().dot(direction)
		if cosine < 0.5: continue
		var score := delta.length() * (2.0 - cosine)
		if score < best_score:
			best_score = score
			best = i
	return best

func _show() -> void:
	if places.is_empty(): return
	var place: Dictionary = places[selected]
	_cursor.position = position_of(place) - _cursor.size / 2
	_name.text = str(place.name)
	var lines: Array[String] = [str(KIND_NAMES.get(place.kind, "Transporte"))]
	if place.start: lines.append("Pueblo inicial")
	if place.gym is Dictionary and not place.gym.is_empty():
		lines.append("Gimnasio %d: %s" % [int(place.gym.order), str(place.gym.leader)])
	if place.maps.is_empty(): lines.append("Sin mapa todavía")
	elif selected == here: lines.append("Estás aquí")
	else: lines.append("Ya has estado" if visited(place) else "Sin visitar")
	if _destination(place).is_empty() == false: lines.append("A: volar")
	_info.text = "\n".join(lines)

func _destination(place: Dictionary) -> Dictionary:
	for destination: Dictionary in destinations:
		if str(destination.get("id", "")) == str(place.id) or str(destination.get("map", "")) in place.maps:
			return destination
	return {}

func _process(delta: float) -> void:
	_time += delta
	if _cursor: _cursor.visible = UiPreferences.reduce_motion() or fmod(_time, 0.8) < 0.6
	if _you: _you.visible = here >= 0 and (UiPreferences.reduce_motion() or fmod(_time, 1.0) < 0.7)

func _unhandled_input(event: InputEvent) -> void:
	if _done or _busy or not is_visible_in_tree() or places.is_empty(): return
	var moves := {&"move_up": Vector2.UP, &"move_down": Vector2.DOWN, &"move_left": Vector2.LEFT, &"move_right": Vector2.RIGHT}
	for action: StringName in moves:
		if event.is_action_pressed(action, true):
			get_viewport().set_input_as_handled()
			selected = neighbour(selected, moves[action])
			AudioManager.play_se(&"menu_move")
			_show()
			return
	if event.is_action_pressed(&"cancel"):
		get_viewport().set_input_as_handled()
		_close()
	elif event.is_action_pressed(&"accept"):
		get_viewport().set_input_as_handled()
		_fly()

func _fly() -> void:
	var destination := _destination(places[selected])
	if destination.is_empty(): return
	_busy = true
	if await Dialogue.ask_yes_no("¿Volar a %s?" % str(destination.get("name", destination.get("id", "")))):
		var error: Error = await WorldTravel.fly(StringName(str(destination.id)))
		if error == OK:
			_close()
			return
		await Dialogue.say("No puedes volar a este destino ahora.")
	_busy = false

func _close() -> void:
	if _done: return
	_done = true
	closed.emit()
