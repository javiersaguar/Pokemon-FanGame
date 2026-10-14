extends SceneTree
## Ferris y avión por dentro (docs/mundo/region.md, «Transportes»). Cada trayecto es un mapa propio:
## la pasarela del puerto (o la puerta de embarque) lleva dentro, al entrar salta el viaje
## (src/events/viaje_event.gd) y la puerta del mapa baja en el destino.
##   Ferris: transporte/ferry_<origen>_<destino> (salón con bar, sofás y pasajeros).
##   Avión: <ciudad>/aeropuerto (terminal con facturación y control de seguridad,
##   src/events/control_seguridad_event.gd) → transporte/avion_<origen>_<destino> (cabina) → la
##   terminal de llegada. Las pasarelas de los exteriores se redirigen con maps/_tools/redirigir_puerta.gd.
## Uso: godot --headless --path . -s res://maps/_pintura/pintar_transportes.gd

const INTERIOR := "res://assets/tilesets/interior/interior.tres"
const FONT := "res://assets/fonts/truth_and_ideals/TruthAndIdeals-Normal.ttf"
const TRIP_EVENT := "res://src/events/viaje_event.gd"
const SECURITY_EVENT := "res://src/events/control_seguridad_event.gd"
const SIZE := Vector2i(16, 12)
const FLOORS: Array[Vector2i] = [
	Vector2i(1, 1), Vector2i(2, 5), Vector2i(1, 9), Vector2i(2, 13), Vector2i(1, 17), Vector2i(2, 21),
	Vector2i(1, 25), Vector2i(2, 29), Vector2i(1, 33), Vector2i(2, 37), Vector2i(1, 41), Vector2i(2, 45),
	Vector2i(1, 49), Vector2i(2, 53), Vector2i(1, 57), Vector2i(2, 61),
]
const WALLS: Array[int] = [4, 9, 14, 19, 24, 29, 34, 39, 44, 49, 54, 59, 64, 69, 74]
const DOWN := 0
const LEFT := 1
const RIGHT := 2
const UP := 3
const SOFA := Rect2i(3, 59, 3, 2)
const SEAT := Rect2i(6, 61, 1, 2)
const SEAT_B := Rect2i(7, 61, 1, 2)
const BAR := Rect2i(0, 17, 3, 2)  # mostradores (fuente 3)
const PLANT_A := Rect2i(0, 36, 1, 2)
const PLANT_B := Rect2i(2, 36, 1, 2)
const STOOL := Rect2i(1, 62, 1, 1)

## Ferris: [mapa, título, destino, aparición en el destino, salida, trayecto, llegada, pasajeros].
## Pasajero: [nombre, hoja, casilla, mirada, frases].
var FERRIES: Array = [
	["transporte/ferry_barcelona_palma", "Ferry Barcelona · Palma", "palma/exterior", "from_ferry", [
		"Señores pasajeros, bienvenidos a bordo del ferry a Palma de Mallorca. Duración prevista: siete horas.",
		"El bar abre al salir del puerto. Las tumbonas de cubierta son por orden de llegada: una toalla encima no es una reserva."],
		["El ferry cruza el Mediterráneo de noche. Alguien ronca en el sofá de al lado. Puede que seas tú."],
		["Estamos atracando en el puerto de Palma. Los pasajeros a pie, por la puerta de abajo. Bon dia!"], [
		["Aleman", "turistachanclas", Vector2i(12, 6), LEFT, ["Ich habe die Tumbona reserviert. Con la toalla, ja. Desde Barcelona.", "En Mallorca hablamos todos alemán. Los mallorquines también, pero no les gusta."]],
		["Abuela", "npc_old_woman", Vector2i(3, 8), RIGHT, ["Voy a Palma a ver a mi nieta. Le llevo fuet, que dice que allí no hay del bueno.", "Y una ensaimada de vuelta. En la caja redonda, que si no te miran mal en el puerto."]],
		["Regatista", "regatista", Vector2i(13, 9), UP, ["Voy a la regata de la Copa del Rey. Del de ahora, que el otro ya navega en Sanxenxo."]],
	]],
	["transporte/ferry_palma_barcelona", "Ferry Palma · Barcelona", "barcelona/ciutat_vella", "from_ferry", [
		"Bienvenidos a bordo del ferry a Barcelona. Llegada prevista al Port Vell en siete horas.",
		"Recuerden que las ensaimadas viajan en su caja, no en el asiento de al lado."],
		["La isla se queda atrás. Las luces de Palma se apagan una a una, y después solo hay mar."],
		["Estamos entrando en el Port Vell de Barcelona. Vigilen la cartera al bajar: aquí trabajan rápido."], [
		["Ensaimadas", "npc_woman", Vector2i(12, 6), LEFT, ["Llevo seis ensaimadas. Una es para mí y cinco para quedar bien con la familia de Badalona."]],
		["Mochilero", "npc_youngster", Vector2i(3, 8), RIGHT, ["He estado una semana en Magaluf y no me acuerdo de nada. Según las fotos, me lo pasé bien."]],
		["Marinero", "marinero", Vector2i(13, 9), UP, ["Treinta años haciendo esta línea. El mar siempre es el mismo; los guiris cambian cada verano."]],
	]],
	["transporte/ferry_valencia_ibiza", "Ferry Valencia · Ibiza", "ibiza/exterior", "from_ferry", [
		"Bienvenidos a bordo del ferry a Ibiza. Cinco horas de travesía.",
		"Se ruega no empezar la fiesta antes de salir del puerto. Ni dentro del barco. Vale: no en el bar."],
		["Alguien ha puesto música electrónica en el móvil. Sin auriculares. Cinco horas."],
		["Atracamos en el puerto de Ibiza. La fiesta empieza a la salida; el after, mañana a las nueve."], [
		["Raver", "raver", Vector2i(12, 6), LEFT, ["Voy a Ibiza a trabajar. De relaciones públicas. Es decir, a repartir flyers en el West End."]],
		["Hippie", "hippie", Vector2i(3, 8), RIGHT, ["Yo voy al mercadillo de Las Dalias. A vender pulseras que compro en Valencia. Shhh."]],
		["Padre", "padretarjeta", Vector2i(13, 9), UP, ["Vamos en familia. Mi hijo quiere ir de discotecas y yo a Cala Comte. Ganará él, como siempre."]],
	]],
	["transporte/ferry_ibiza_valencia", "Ferry Ibiza · Valencia", "valencia/malvarrosa", "from_ferry", [
		"Bienvenidos a bordo del ferry a Valencia. Cinco horas de travesía.",
		"Los pasajeros que todavía no hayan dormido desde el jueves pueden usar los sofás. Con cuidado."],
		["Medio barco duerme. El otro medio pregunta por qué le duele la cabeza."],
		["Llegamos al puerto de Valencia. Se ve la Malvarrosa a la izquierda. ¡Bienvenidos a la tierra de la paella!"], [
		["Resaca", "npc_youngster", Vector2i(12, 6), LEFT, ["No me hables. No me hables muy alto. No me hables."]],
		["Fallera", "flamenca", Vector2i(3, 8), RIGHT, ["Vuelvo a Valencia para las Fallas. Bueno, faltan once meses, pero el traje no se plancha solo."]],
		["Camionero", "cunado", Vector2i(13, 9), UP, ["Llevo un camión de naranjas a Ibiza y vuelvo vacío. Allí las naranjas las cobran a seis euros. En zumo, a doce."]],
	]],
	["transporte/ferry_huelva_las_palmas", "Ferry Huelva · Las Palmas", "las_palmas/canteras", "from_ferry", [
		"Bienvenidos a bordo del ferry a Las Palmas de Gran Canaria. Duración de la travesía: más de un día.",
		"Sí, más de un día. Esto es el Atlántico, no el Retiro. El bar abre por turnos; las películas, también."],
		["Pasa un día entero. Has visto tres veces la misma película, dos delfines y un camionero que no ha dejado de hablar de Canarias."],
		["Señores pasajeros, estamos entrando en el puerto de La Luz, en Las Palmas. ¡Bienvenidos a Gran Canaria, mi niño!"], [
		["Camionero", "cunado", Vector2i(12, 6), LEFT, ["Hago este viaje cada semana con el camión. Es más barato que el avión. Y tengo más tiempo para contarte mi vida."]],
		["Canaria", "npc_woman", Vector2i(3, 8), RIGHT, ["Vuelvo a casa. En la península nos llaman a todos «canarios». Y en Gran Canaria, a los de Tenerife, otra cosa."]],
		["Ornitologa", "ornitologa", Vector2i(13, 9), UP, ["He visto dos delfines y un Wingull mareado. Lo apunto todo en mi libreta."]],
	]],
	["transporte/ferry_las_palmas_huelva", "Ferry Las Palmas · Huelva", "huelva/exterior", "from_ferry", [
		"Bienvenidos a bordo del ferry a Huelva. Más de un día de travesía.",
		"Recuerden: el mojo picón no se considera equipaje de mano. Se considera arma."],
		["Pasa un día entero en el Atlántico. Al segundo día, alguien ya ha montado una partida de mus en el bar."],
		["Llegamos al puerto de Huelva. ¡Bienvenidos a la tierra de las gambas y de Colón!"], [
		["Mus", "jubiladoobras", Vector2i(12, 6), LEFT, ["¿Juegas al mus? Me falta pareja desde Las Palmas. La última se mareó en el primer órdago."]],
		["Estudiante", "estudianteinge", Vector2i(3, 8), RIGHT, ["Voy a estudiar a Sevilla. Llevo papas arrugadas para un mes y mojo para un año."]],
		["Surfista", "surfista", Vector2i(13, 9), UP, ["Me voy a la península a surfear. Me han dicho que en Huelva no hay olas. Ya veremos."]],
	]],
]

## Vuelos: [mapa, título, terminal de llegada, salida, trayecto, llegada, pasajeros].
var FLIGHTS: Array = [
	["transporte/avion_gran_canaria_vigo", "Vuelo Gran Canaria · Vigo", "vigo/aeropuerto", [
		"Buenos días, les habla el comandante. Bienvenidos a bordo del vuelo a Vigo. Duración: unas dos horas y media.",
		"Abróchense el cinturón, pongan el asiento en posición vertical y no le pidan al Pokémon que vuele más rápido que el avión."],
		["El avión atraviesa unas turbulencias. Alguien grita. Era el Psyduck de la fila doce."],
		["Iniciamos el descenso a Vigo. En tierra, catorce grados y lluvia. Como siempre.",
		"Les recordamos que el alcalde ya ha encendido las luces de Navidad. Estamos en octubre."], [
		["Gallego", "npc_old_man", Vector2i(2, 9), RIGHT, ["¿Que si vuelvo a Vigo? Depende. ¿Usted de dónde es? Depende."]],
		["Guiri", "turista", Vector2i(13, 9), LEFT, ["Vengo de una semana en Maspalomas y ahora voy a hacer el Camino de Santiago. Por eso estoy tan moreno."]],
	]],
	["transporte/avion_vigo_gran_canaria", "Vuelo Vigo · Gran Canaria", "playa_del_ingles/aeropuerto", [
		"Buenos días, les habla el comandante. Bienvenidos a bordo del vuelo a Gran Canaria. Duración: unas dos horas y media.",
		"Pueden quitarse el abrigo. Y el jersey. Y lo que quieran, que vamos a Maspalomas."],
		["El avión atraviesa unas turbulencias sobre el Atlántico. Una señora reza en gallego."],
		["Iniciamos el descenso a Gran Canaria. En tierra, veinticuatro grados y sol. Como siempre."], [
		["Pulpeira", "npc_old_woman", Vector2i(2, 9), RIGHT, ["Llevo pulpo en la maleta para mi hijo, que vive en Las Palmas. Dice que allí lo cortan mal."]],
		["Fan", "fan_quevedo", Vector2i(13, 9), LEFT, ["¡Voy al concierto de Quevedo! No tengo entrada, pero algo se hará. «Quédate», le diré."]],
	]],
]

## Terminales: [mapa, título, calle, aparición en la calle, vuelo que sale de aquí, flag del control].
var AIRPORTS: Array = [
	["playa_del_ingles/aeropuerto", "Aeropuerto de Gran Canaria", "playa_del_ingles/exterior", "from_avion",
		"transporte/avion_gran_canaria_vigo", "control_seguridad_gran_canaria", "Vigo"],
	["vigo/aeropuerto", "Aeropuerto de Peinador · Vigo", "vigo/exterior", "from_avion",
		"transporte/avion_vigo_gran_canaria", "control_seguridad_vigo", "Gran Canaria"],
]


func _initialize() -> void:
	await process_frame
	for f: Array in FERRIES:
		_ferry(f)
	for f: Array in FLIGHTS:
		_flight(f)
	for a: Array in AIRPORTS:
		_airport(a)
	quit()


func _shell(map_id: String, title: String, zone: String, floor_index: int, wall_index: int) -> Pintor:
	var d := MapData.new()
	d.id = StringName(map_id)
	d.display_name = title
	d.zone_id = StringName(zone)
	d.outdoor = false
	d.fixed_camera = true
	d.can_bike = false
	d.can_run = false
	d.can_fly_from = false
	d.followers_allowed = false
	d.battle_background = &"indoor"
	var p := Pintor.new("Transporte", SIZE, d)
	var tiles: TileSet = load(INTERIOR)
	for layer: TileMapLayer in [p.ground, p.decor, p.objects, p.above]:
		layer.tile_set = tiles
	var wall: int = WALLS[wall_index]
	for at: Vector2i in Pintor.cells(Rect2i(Vector2i.ZERO, SIZE)):
		p.ground.set_cell(at, 0, FLOORS[floor_index])
	for x: int in SIZE.x:
		p.decor.set_cell(Vector2i(x, 0), 1, Vector2i(1, wall - 1))
		p.decor.set_cell(Vector2i(x, 1), 1, Vector2i(1, wall))
		p.decor.set_cell(Vector2i(x, 11), 1, Vector2i(1, wall))
	for y: int in range(2, 11):
		for x: int in [0, 15]:
			p.decor.set_cell(Vector2i(x, y), 1, Vector2i(1, wall), TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	var label := Label.new()
	label.name = "Rotulo"
	label.position = Vector2(8, 4)
	label.size = Vector2(SIZE.x * 32 - 16, 24)
	label.text = title.replace(" · ", ": ")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", load(FONT))
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("fff4d8"))
	label.add_theme_color_override("font_shadow_color", Color("303048"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	p.root.add_child(label)
	return p


## Puerta en la pared de arriba (y = 1) o de abajo (y = 11): quita la pared y pone el Warp.
func _door(p: Pintor, warp_name: String, cell: Vector2i, target: String, spawn: String, facing: Warp.Facing) -> void:
	p.decor.erase_cell(cell)
	p.warp(warp_name, cell, StringName(target), StringName(spawn))
	p.root.get_node("Warps/" + warp_name).arrival_facing = facing


## El Trigger se escribe en el .tscn ya guardado: fuera del juego (sin autoloads) trigger.gd no compila
## y no se puede poner como script de un nodo.
func _save_with_trigger(p: Pintor, map_id: String, trigger_name: String, cell: Vector2i, event_path: String,
		params: Dictionary, mode: int) -> void:
	var path := "res://maps/%s.tscn" % map_id
	var err := p.save(path)
	if err == OK:
		var text := FileAccess.get_file_as_string(path)
		var head := "[ext_resource type=\"Script\" path=\"res://src/overworld/trigger/trigger.gd\" id=\"trigger_script\"]
" 			+ "[ext_resource type=\"Script\" path=\"%s\" id=\"trigger_event\"]
" % event_path
		var at := text.find("[ext_resource")
		text = text.insert(at, head)
		text = text.rstrip("
") + "

[node name=\"%s\" type=\"Node2D\" parent=\"Triggers\"]
" % trigger_name 			+ "position = Vector2(%d, %d)
" % [int(Grid.to_world(cell).x), int(Grid.to_world(cell).y)] 			+ "script = ExtResource(\"trigger_script\")
event = ExtResource(\"trigger_event\")
" 			+ "event_params = %s
mode = %d
" % [var_to_str(params), mode]
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_string(text)
		file.close()
	print("%s: %s" % [map_id, error_string(err)])


func _passengers(p: Pintor, list: Array) -> void:
	for who: Array in list:
		p.npc(str(who[0]), str(who[1]), who[2], who[3], PackedStringArray(who[4]))


## Salón del ferry: ventanas al mar, el bar a la izquierda, sofás a la derecha y la salida abajo.
func _ferry(f: Array) -> void:
	var map_id: String = f[0]
	var p := _shell(map_id, f[1], "transporte", 6, 2)
	_piece(p, Vector2i(1, 2), BAR, 3)
	for x: int in [1, 2, 3]:
		_piece(p, Vector2i(x, 5), STOOL)
	_piece(p, Vector2i(9, 3), SOFA)
	_piece(p, Vector2i(12, 3), SOFA)
	_piece(p, Vector2i(9, 7), SOFA)
	_piece(p, Vector2i(1, 9), PLANT_A)
	_piece(p, Vector2i(14, 9), PLANT_B)
	p.npc("Camarero", "camarero", Vector2i(4, 3), DOWN, PackedStringArray([
		"¿Un café? Cuatro euros. Es que estamos en alta mar. Bueno, a la salida del puerto, pero cuenta.",
		"Bocadillo de tortilla, nueve euros. Sin tortilla, siete. Es pan con aceite, pero aquí lo llamamos «mediterráneo»."]))
	p.npc("Sobrecargo", "marinero", Vector2i(10, 10), LEFT, PackedStringArray([
		"Por la puerta de abajo se baja al puerto. Cuando lleguemos, claro: nadar no te dejo.",
		"Si te mareas, mira al horizonte. Si no hay horizonte, mira al bar."]))
	_passengers(p, f[7])
	_door(p, "Desembarcar", Vector2i(8, 11), f[2], f[3], Warp.Facing.DOWN)
	p.spawn("default", Vector2i(8, 10))
	_save_with_trigger(p, map_id, "Viaje", Vector2i(8, 10), TRIP_EVENT,
		{"hablante": "Megafonía", "salida": f[4], "trayecto": f[5], "llegada": f[6]}, 1)


## Cabina del avión: dos filas de asientos a cada lado del pasillo, la azafata y la puerta delante.
func _flight(f: Array) -> void:
	var map_id: String = f[0]
	var p := _shell(map_id, f[1], "transporte", 4, 0)
	for y: int in [3, 5, 7]:
		for x: int in [2, 3, 4, 5, 10, 11, 12, 13]:
			_piece(p, Vector2i(x, y), SEAT if x < 8 else SEAT_B)
	p.npc("Azafata", "influencerlinkedin_f", Vector2i(9, 9), LEFT, PackedStringArray([
		"Bienvenido a bordo. Su asiento es el 14C. No, ese es el 14D. Bueno, siéntese donde quiera, que vamos medio vacíos.",
		"El carrito pasa en media hora. Agua, tres euros. Sándwich, ocho. Tranquilidad, gratis."]))
	_passengers(p, f[6])
	_door(p, "Bajar", Vector2i(8, 1), f[2], "from_llegadas", Warp.Facing.DOWN)
	p.spawn("default", Vector2i(8, 10))
	_save_with_trigger(p, map_id, "Viaje", Vector2i(8, 10), TRIP_EVENT,
		{"hablante": "Comandante", "salida": f[3], "trayecto": f[4], "llegada": f[5], "turbulencias": true}, 1)


## Terminal: a la izquierda, salidas (control de seguridad y puerta de embarque); a la derecha, llegadas
## (se baja del avión sin pasar el control) y facturación; la calle, abajo.
func _airport(a: Array) -> void:
	var map_id: String = a[0]
	var p := _shell(map_id, a[1], map_id.get_slice("/", 0), 12, 0)
	var wall: int = WALLS[0]
	for y: int in range(2, 7):
		p.decor.set_cell(Vector2i(8, y), 1, Vector2i(1, wall), TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	for x: int in range(1, 8):
		if x != 4:
			p.decor.set_cell(Vector2i(x, 6), 1, Vector2i(1, wall))
	_piece(p, Vector2i(11, 7), BAR, 3)
	_piece(p, Vector2i(1, 9), SOFA)
	_piece(p, Vector2i(14, 9), PLANT_B)
	_piece(p, Vector2i(14, 2), PLANT_A)
	p.npc("Guardia", "npc_man", Vector2i(5, 7), LEFT, PackedStringArray([
		"Control de seguridad. Por el arco, de uno en uno.", "Los Pokémon de acero hacen pitar el arco. Los de agua, también: son líquidos."]),
		{"display_name": "Guardia Civil"})
	p.npc("Embarque", "influencerlinkedin_f", Vector2i(5, 2), LEFT, PackedStringArray([
		"Vuelo a %s, embarcando por esta puerta. Tarjeta de embarque y DNI... Vale, pase." % a[6],
		"Una pieza de equipaje de mano. Las Poké Balls no cuentan: van en el cinturón."]))
	p.npc("Facturacion", "npc_lass", Vector2i(12, 9), UP, PackedStringArray([
		"Mostrador de facturación. ¿Maleta? Veintitrés kilos. ¿Veinticuatro? Son cincuenta euros.",
		"Si no factura, al control de la izquierda, y de ahí a la puerta de embarque."]))
	p.npc("Spotter", "npc_youngster", Vector2i(2, 3), UP, PackedStringArray([
		"¿Ves ese avión blanco aparcado en la pista? Es el Falcon del Líder Supremo.",
		"Lo he fotografiado en catorce aeropuertos este mes. Siempre dice que viaja por trabajo."]))
	_door(p, "Embarque", Vector2i(4, 1), a[4], "default", Warp.Facing.UP)
	p.spawn("from_llegadas", Vector2i(11, 2))
	_door(p, "Salida", Vector2i(8, 11), a[2], a[3], Warp.Facing.DOWN)
	p.spawn("default", Vector2i(8, 10))
	_save_with_trigger(p, map_id, "ControlSeguridad", Vector2i(4, 6), SECURITY_EVENT,
		{"flag": a[5], "guardia": "Guardia Civil"}, 0)


func _piece(p: Pintor, at: Vector2i, rect: Rect2i, source: int = 2) -> void:
	for y: int in rect.size.y:
		for x: int in rect.size.x:
			p.decor.set_cell(at + Vector2i(x, y), source, rect.position + Vector2i(x, y))
