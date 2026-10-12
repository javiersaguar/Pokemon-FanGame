# Inventario de entradas pendientes · 2026-10-12

Las **61 puertas de servicios** ya están conectadas. El escaneo de las escenas exteriores encuentra **484 puertas potenciales del catálogo sin Warp**: [coordenadas y objeto](puertas_pendientes.csv). No significa que las 484 deban abrirse: el atlas incluye fachadas residenciales, monumentos y otros edificios cuya función concreta no se ha fijado. No se cuenta como local jugable una simple imagen de puerta.

La tabla sirve para decidir el siguiente conjunto sin alterar entradas ya conectadas. Fuente: escenas `maps/**/*.tscn`, capa `Entities/Objects`, coordenadas/puerta de `ExteriorTiles.objects()`. Excluye muestras/pruebas. Anclaje de objeto y casilla de puerta se conservan por separado. Las variantes que comparten una casilla del atlas se identifican por su recurso, no por un negocio inventado.

| Exterior | Puertas potenciales pendientes |
|---|---|
| `barcelona/ciutat_vella` | 12 |
| `barcelona/eixample` | 26 |
| `barcelona/les_corts` | 13 |
| `getafe/exterior` | 12 |
| `huelva/exterior` | 8 |
| `ibiza/exterior` | 17 |
| `las_palmas/canteras` | 8 |
| `las_palmas/vegueta_triana` | 15 |
| `leganes/exterior` | 9 |
| `madrid/centro` | 34 |
| `madrid/chamberi` | 18 |
| `madrid/moncloa` | 13 |
| `madrid/palacio_real` | 5 |
| `madrid/retiro` | 10 |
| `malaga/exterior` | 15 |
| `maritima_1/exterior` | 1 |
| `mostoles/exterior` | 15 |
| `palma/exterior` | 14 |
| `playa_del_ingles/exterior` | 8 |
| `pueblo_inicial/exterior` | 15 |
| `puertollano/exterior` | 14 |
| `ruta_12/exterior` | 1 |
| `ruta_13/exterior` | 2 |
| `ruta_14/exterior` | 6 |
| `ruta_15/exterior` | 2 |
| `ruta_16/exterior` | 2 |
| `ruta_2/exterior` | 9 |
| `ruta_21/exterior` | 4 |
| `ruta_22/exterior` | 4 |
| `ruta_23/exterior` | 4 |
| `ruta_24/exterior` | 10 |
| `ruta_25/exterior` | 2 |
| `ruta_26/exterior` | 2 |
| `ruta_3/exterior` | 3 |
| `ruta_4/exterior` | 10 |
| `ruta_5/exterior` | 7 |
| `ruta_6/exterior` | 7 |
| `ruta_8/exterior` | 5 |
| `sevilla/centro` | 27 |
| `sevilla/rio` | 29 |
| `valencia/ciutat_vella` | 15 |
| `valencia/malvarrosa` | 13 |
| `valladolid/exterior` | 14 |
| `vigo/exterior` | 7 |
| `zaragoza/exterior` | 17 |

Siguientes casos que requieren contenido: casas con NPC/guion, gimnasios con recorrido y combates, edificios especiales (Botiga del Barça, lotería, museos, Palacio/Clan), Basic-Fit y salas de Metro/Calle de la Victoria. Los servicios concretos/guion no aprobados van a Preguntas para Javier. El motor común `Warp` ya da fundido, cambio, orientación de llegada y retorno, y puede usarse en cada conjunto al disponer de su interior.

Bilbao espera exterior. San Miguel conserva su trama existente; no se cambian casas por salas sanitarias. La lista de famosos ya tiene 46 sprites/datos, pero sus ubicaciones y diálogos siguen pendientes de Javier.

**Repaso posterior del 2026-10-12:** la casa oriental de Getafe está abierta; se añaden tres viviendas urbanas y dos rurales, y un puesto con compra sin interior. El CSV anterior es el inventario previo a este repaso; habrá que volver a escanear al decidir el próximo conjunto de interiores. [Entrega y límites](../arte/comparativas/a3_densidad_getafe_ruta24.md).
