class_name SanFerminEvent
extends StoryEvent
## San Fermín en Pamplona (docs/mundo/region.md, tramo 21). Del 6 al 14 de julio, con el reloj real (y el
## desfase de horas de pruebas de Clock), al entrar en Pamplona: el 6, el chupinazo; del 7 al 14, el
## encierro por la Estafeta. Una vez al día (flag "san_fermin_<año>_<día>"). Lo dispara un Trigger al entrar
## (ON_ENTER) de maps/pamplona/exterior.tscn. PROVISIONAL y PENDIENTE JAVIER: textos, si hay combate con
## un Tauros (iría por data/statics.json, regla R.2), premio, decoración de fiestas y el arte de los toros.

## Fecha de pruebas ({"year", "month", "day"}): la pone el F9 o un test; vacía = la del sistema.
static var fecha_de_prueba: Dictionary = {}


## Fecha de hoy con el reloj real (zona horaria del sistema y desfase de pruebas de Clock).
static func hoy() -> Dictionary:
	if not fecha_de_prueba.is_empty():
		return fecha_de_prueba
	var bias: int = Time.get_time_zone_from_system()["bias"]
	var offset: int = Clock.debug_hour_offset if is_instance_valid(Clock) else 0
	var unix := int(Time.get_unix_time_from_system()) + bias * 60 + offset * 3600
	var dt := Time.get_datetime_dict_from_unix_time(unix)
	return {"year": int(dt["year"]), "month": int(dt["month"]), "day": int(dt["day"])}


## Del 6 al 14 de julio, ambos incluidos.
static func en_fiestas(fecha: Dictionary) -> bool:
	return int(fecha.get("month", 0)) == 7 and int(fecha.get("day", 0)) >= 6 and int(fecha.get("day", 0)) <= 14


static func flag_del_dia(fecha: Dictionary) -> StringName:
	return StringName("san_fermin_%d_%d" % [int(fecha.get("year", 0)), int(fecha.get("day", 0))])


func run() -> void:
	var fecha := hoy()
	if not en_fiestas(fecha):
		return
	var flag := flag_del_dia(fecha)
	if GameState.flag(flag):
		return
	GameState.set_flag(flag)
	var town := "Megafonía del Ayuntamiento"
	if int(fecha.day) == 6:
		await Dialogue.say("¡Pamploneses, pamplonesas! ¡Viva San Fermín! ¡Gora San Fermín!", town)
		await Cutscene.shake(4.0, 0.5)
		await Dialogue.say("¡PUM! El chupinazo sale del balcón del Ayuntamiento. Media plaza del Castillo acaba empapada de sangría.")
		await Dialogue.say("Mañana a las ocho, el primer encierro. Quien corra, que corra por la derecha y sin selfis.", town)
		return
	await Dialogue.say("Son las ocho. Ha sonado el cohete: ¡los toros están en la calle!", town)
	await Cutscene.shake(3.0, 0.8)
	if await Dialogue.ask_yes_no("La Estafeta se llena de mozos con el periódico enrollado. ¿Corres el encierro?"):
		await Dialogue.say("Corres delante de seis toros y un cabestro que va a su ritmo. Un Tauros te mira, se lo piensa y sigue de largo.")
		await Cutscene.shake(2.0, 0.4)
		await Dialogue.say("Entras en la plaza de toros con el pañuelo rojo torcido y el corazón en la garganta. ¡Lo has corrido!")
	else:
		await Dialogue.say("Lo ves desde un balcón de la Estafeta. Cuarenta euros por media hora, y el de al lado no para de grabar.")
	await Dialogue.say("¡Uno de enero, dos de febrero...! Mañana, otro encierro. Hasta el día 14.", town)
