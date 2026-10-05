# Contrato de campo (Fase 12)

MapConnection: edge north/south/west/east, target_map, offset paralelo (coordenada destino = origen + offset). Se colocan en MapData.connections. El jugador cruza sin fundido al salir por ese borde; puertas/escaleras siguen usando Warp. Pintura/mapas reales pendientes A4.

FieldActions.available(action,map): world.field.actions → item + required_flag opcional. Objeto clave, no se consume ni exige un movimiento en el equipo. ID null impide usarlo hasta que Javier/A3 definan los datos. FieldObstacle: A4 aporta sprite/collider; cut/rock_smash lo ocultan durante mapa, strength empuja una casilla libre fuera del agua. cleared_flag opcional, registrada por el mapa si se quiere desaparición permanente.

Player.set_transport_mode(walk/bike/surf): exige herramienta y hoja válida, bike respeta can_bike, surf pasa capa agua, sale a pie al tocar suelo; no se permite desmontar en agua. Cascada exige su herramienta. Velocidad bike/surf usa RUN_TIME; no hay arte inventado. Hojas pedidas a A4, acciones aún no entregadas en historia.

WorldTravel.record_visit conserva flags visited_map:<id>; destinations lista destinos configurados y visitados; fly exige herramienta, can_fly_from y destino existente. La región/posiciones finales y el objeto de Vuelo esperan GDD/mapas/UI A3; flight_destinations está vacío deliberadamente.
