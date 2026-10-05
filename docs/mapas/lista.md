# Mapas y entrega del MVP

Los destinos del guion están en `world.mvp_locations`: roles idénticos en perfiles `test` y `real`. Sigue activo test. El perfil real se activa con `MvpLocations.activate("real")` solo cuando todos los mapas y apariciones existen, y después se fija el perfil en world.json. No se crean mapas vacíos para simular una entrega.

| Rol | Mapa real | Aparición | Estado |
|---|---|---|---|
| town | pueblo_inicial/exterior | from_home | previsto, espera pueblo aprobado y pintura A4 |
| home | pueblo_inicial/casa_jugador_pb | from_bedroom | previsto, espera pueblo aprobado y pintura A4 |
| bedroom | pueblo_inicial/casa_jugador_1p | intro | previsto, espera pueblo aprobado y pintura A4 |
| rival_home | pueblo_inicial/casa_rival | from_town | previsto, espera pueblo aprobado y pintura A4 |
| laboratory | pueblo_inicial/laboratorio | from_town | previsto, espera pueblo aprobado y pintura A4 |
| route_1 | ruta_1/exterior | from_town | previsto, espera pueblo aprobado y pintura A4 |
| city_2 | ciudad_2/exterior | from_route | previsto, espera pueblo aprobado y pintura A4 |
| healing | ciudad_2/centro_pokemon | from_city | previsto, espera pueblo aprobado y pintura A4 |
| shop | ciudad_2/tienda | from_city | previsto, espera pueblo aprobado y pintura A4 |

`start` apunta a dormitorio/intro. `healing` apunta al Centro de ciudad 2, hasta que una enfermera fije otra aparición. Interior/escaleras/puertas se conectan por nodos Warp; A4 entrega geometría y apariciones, A1 añade lógica. Los nombres usan `{world:town}` / `{world:city_2}`; Ruta 1 conserva ese nombre. Todas las plantas del pueblo comparten zone_id `pueblo_inicial`; ruta `ruta_1`; ciudad/interiores `ciudad_2`.

Apariciones de retorno necesarias además de las del cuadro: exteriores `from_home`, `from_rival_home`, `from_lab`, `from_route`; casa PB `from_town` y `from_bedroom`; dormitorio `from_home`; ruta `from_city`; ciudad `from_center`, `from_shop`; centro/tienda `default` si procede. La posición la decide el mapa pintado, no el script de historia.

Entrega A4 → A1: reserva liberada, mapa pintado, dimensiones/entradas señaladas y comparativa. A1 reserva e incorpora NPCs/eventos/warps/encuentros/objetos; regenera colocaciones y prueba las conexiones. Las rutas son un contrato técnico propuesto por A1; si A4 necesita otro ID se cambia solo world.json y esta tabla, no el guion.
