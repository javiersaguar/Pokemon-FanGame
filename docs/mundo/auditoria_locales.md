# Auditoría de locales · 2026-10-10

| Ciudad con gimnasio | Exteriores existentes | Interior de servicios |
|---|---|---|
| Madrid | Moncloa: Centro en (38,29), Mercadona (50,29), estanco (50,39); tiendas adicionales en otros barrios | Tres servicios jugables |
| Barcelona | Eixample: Centro (6,51), Mercadona (3,31), tienda morada (22,19); otras tiendas por barrios | Tres servicios jugables |
| Valencia | Ciutat Vella: Centro (48,24), Mercadona (48,38), estanco (56,24); otro conjunto en Malvarrosa | Tres servicios jugables |
| Sevilla | Centro: Centro grande (5,27), Mercadona (19,20), estanco (52,42) | Tres servicios jugables |
| Las Palmas | Vegueta: Centro (2,20), estanco (9,20); Canteras: Mercadona (30,20) | Tres servicios jugables |
| Bilbao | Sin mapa todavía | No se conecta a destinos inexistentes |
| Valladolid | Centro (18,26), Mercadona (55,26), estanco (61,26) | Tres servicios jugables |
| Málaga | Hospital (27,21), Mercadona (46,21), estanco (52,21) | Tres servicios jugables |

Coordenadas de anclaje del edificio, no de puerta. Fuente: constructores `maps/_pintura/pintar_<ciudad>*.gd` y escenas correspondientes. Fachadas genéricas, provisionales; una tienda morada no siempre es estanco (la de Les Corts representa la Botiga del Barça).

Personajes: `data/trainers/famosos.json` contiene 46 entradas, todas con sprites de combate/mapa según su clase; `assets/sprites/trainers/recetas.json` contiene 123 recetas. Se pueden revisar combatiendo desde F9. No faltan por empezar los personajes de esa lista; falta colocar los que Javier decida en el mundo, con su guion.

Hay un conjunto de tres servicios por ciudad pintada (21 interiores). Los locales adicionales de otros barrios conservan su exterior y siguen pendientes de interiores; no se confunden con el conjunto abierto. Las Palmas: hospital/estanco en `las_palmas/vegueta_triana`, Mercadona en `las_palmas/canteras`. Bilbao continúa pendiente de su exterior.

## Validación final de la entrega

479/479 tests, 19.978 aserciones, 467,06 s; sin errores de script ni fugas al cerrar la suite. Arte: 10.926 PNG, 0 errores/avisos. Datos: 0 errores, 3 avisos anteriores. Cinco pruebas reales de servicios, 190 aserciones: 21 entradas/salidas al barrio correspondiente, curación, derrota, PC y transacciones.

Todos los interiores tienen alcance 0 problemas; siete de los ocho exteriores usados tienen alcance 0. Moncloa conserva una puerta inaccesible de la casa azul del Palacio tras su verja, reproducida en la escena publicada anterior; los tres servicios nuevos son accesibles. No se ha abierto ese palacio ni inventado un evento.

Comparativas: [Madrid](../arte/comparativas/madrid_locales.md), [Barcelona](../arte/comparativas/barcelona_locales.md), [Valencia](../arte/comparativas/valencia_locales.md), [Sevilla](../arte/comparativas/sevilla_locales.md), [Las Palmas](../arte/comparativas/las_palmas_locales.md), [Valladolid](../arte/comparativas/valladolid_locales.md), [Málaga](../arte/comparativas/malaga_locales.md). Arte provisional, pendiente Javier.

## Ampliación del tramo centro y sur (2026-10-10)

Otros **12 interiores**, sumando **33 locales abiertos** en once localidades con mapa. Se conservan los Centros Pokémon en Getafe, Leganés, Móstoles y Puertollano. Los anclajes originales no se mueven; su geometría, conexiones de bordes, NPCs y Cercanías permanecen iguales. Se añaden puertas, llegadas y carteles funcionales.

| Localidad | Centro Pokémon (anclaje) | Mercadona (anclaje) | Estanco (anclaje) | Comparativa |
|---|---|---|---|---|
| Getafe | (4,36) | (15,36) | (25,36) | [capturas](../arte/comparativas/getafe_locales.md) |
| Leganés | (3,24) | (35,23) | (44,23) | [capturas](../arte/comparativas/leganes_locales.md) |
| Móstoles | (21,37) | (33,37) | (43,37) | [capturas](../arte/comparativas/mostoles_locales.md) |
| Puertollano | (4,52) | (19,52) | (40,51) | [capturas](../arte/comparativas/puertollano_locales.md) |

Los dieciséis mapas del conjunto (12 interiores + 4 exteriores) tienen alcance **0 problemas**. La regresión de servicios recorre las 33 puertas por `Player._after_step`, comprueba el barrio de retorno y evita reentrada; además cura, vuelve tras derrota, abre el PC y compra una poción en los cuatro pueblos. Prueba aislada: **6/6**, **342 aserciones**, **67,19 s**; sus fugas de recursos al terminar el proceso aislado siguen presentes, como en la entrega anterior. Suite completa de cierre: **480/480 tests, 20.254 aserciones, 499,10 s**, sin fugas al terminar; conserva una espera antigua marcada deprecada por GUT. El parche dorado se actualiza por los datos de tiendas: comparación del JSON confirma que solo cambia `input_hash`, sin alterar los resultados aleatorios; su huella de prueba incorpora ahora las tiendas. Grafo: **82 mapas, 2 grupos**. Validadores: arte **10.926 PNG, 0 errores/avisos**; datos **0 errores, 3 avisos previos**.

Bilbao espera mapa. El resto de locales todavía cerrados y Basic-Fit no se presentan como jugables. Metro/Calle de la Victoria y colocaciones definitivas de famosos continúan pendientes de sus decisiones y recursos específicos.

## Entradas y servicios adicionales (2026-10-12)

**28 interiores nuevos; 61 locales abiertos en total**. Nueve sanitarios (cinco Centros Pokémon y cuatro hospitales) y diecinueve tiendas nuevas. Hospital también en Sol, Barceloneta, Malvarrosa y Playa del Inglés (sede del gimnasio 5); nombres y fachadas sanitarias genéricos hasta revisión. Mercadona de Cuéllar conservado dentro de Ruta 23.

| Área | Nuevos interiores | Revisión |
|---|---|---|
| Zaragoza | centro, mercadona, estanco | [Comparativa](../arte/comparativas/zaragoza_ampliacion_locales.md) |
| Huelva | centro, mercadona, estanco | [Comparativa](../arte/comparativas/huelva_ampliacion_locales.md) |
| Palma | centro, mercadona, estanco | [Comparativa](../arte/comparativas/palma_ampliacion_locales.md) |
| Ibiza | centro, mercadona, estanco | [Comparativa](../arte/comparativas/ibiza_ampliacion_locales.md) |
| Vigo | centro, mercadona, estanco | [Comparativa](../arte/comparativas/vigo_ampliacion_locales.md) |
| Playa del Inglés | hospital, mercadona, estanco | [Comparativa](../arte/comparativas/playa_del_ingles_ampliacion_locales.md) |
| Cuéllar | mercadona | [Comparativa](../arte/comparativas/ruta_23_cuellar_ampliacion_locales.md) |
| Chamberí | mercadona, estanco | [Comparativa](../arte/comparativas/madrid_chamberi_ampliacion_locales.md) |
| Atocha | mercadona | [Comparativa](../arte/comparativas/madrid_atocha_ampliacion_locales.md) |
| Sol | hospital | [Comparativa](../arte/comparativas/madrid_sol_ampliacion_locales.md) |
| Les Corts | mercadona | [Comparativa](../arte/comparativas/barcelona_les_corts_ampliacion_locales.md) |
| Barceloneta | hospital | [Comparativa](../arte/comparativas/barcelona_barceloneta_ampliacion_locales.md) |
| Malvarrosa | hospital, mercadona, estanco | [Comparativa](../arte/comparativas/valencia_malvarrosa_ampliacion_locales.md) |

Veintiocho interiores y trece exteriores comprobados. Cero problemas de acceso a los locales; los exteriores de Palma/Ibiza dan cero problemas con Surf, que es necesario para sus salidas marítimas. La comparación de los constructores confirma suelo/decoración/bordes sin cambios; en el exterior se incorporan solo nodos de puerta/llegada y rótulos, carteles de servicios y cuatro fachadas sanitarias. Mundo: **110 mapas, 2 grupos**.

Identificadores de salas de barrio separados del mapa exterior: `madrid/sol/hospital`, `madrid/chamberi/mercadona`, etc. Conservan `zone_id` de Madrid/Barcelona/Valencia/Ruta 23. Los IDs de tienda cambian `/` por `_`, conservando los IDs previos. El parche dorado se actualiza por los datos de tienda, sin cambiar resultados aleatorios.

[Inventario de otras puertas](puertas_pendientes.md). La Botiga del Barça y otras tiendas moradas sin identificación inequívoca no se convierten en estancos. Bilbao aún sin exterior; interiores de gimnasios y casas de historia siguen pendientes de diseño/contenido.

Cierre de la suite completa: **486/486 tests, 20.889 aserciones, 579,59 s**, sin errores de script ni fugas al terminar. Arte: 10.926 PNG, 0 errores/avisos; datos: 0 errores y 3 avisos previos.
