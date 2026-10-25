# Qué edificios faltan · auditoría del 25 de octubre de 2026

Base revisada: `2cc55828`, compartida por `main` y `feat/edificios-personajes`, sin cambios locales al empezar. Se contrasta el inventario individual de [edificios_reales.md](edificios_reales.md) con el catálogo cargado por Godot y sus colocaciones actuales. Las 137 entradas son **fuentes gráficas**, no 137 edificios: incluyen estatuas, pasos, vegetación y vehículos.

## Diseños terminados y sustituidos

**17 revisiones del inventario original**, más **3 diseños fuera de ese inventario**: finca de Chamberí, teatro del Club de la Comedia y nave del plató de Málaga. Son **20 diseños ya integrados**; su aprobación artística por Javier sigue pendiente. No hay un lote terminado esperando una sustitución general en los mapas.

| Pieza revisada | Usos del inventario |
|---|---|
| `templo_debod` | madrid/moncloa |
| `puerta_debod` | madrid/moncloa |
| `casa_correos` | madrid/centro |
| `palacio_real` | madrid/palacio_real |
| `congreso` | madrid/retiro |
| `leon_congreso` | madrid/retiro, zaragoza/exterior |
| `escenario_festival` | playa_del_ingles/exterior, ruta_7/exterior |
| `camp_nou` | barcelona/les_corts |
| `sagrada_familia` | barcelona/eixample |
| `akuarela` | valencia/malvarrosa |
| `ayuntamiento_valladolid` | valladolid/exterior |
| `giralda` | sevilla/centro |
| `bernabeu` | madrid/bernabeu |
| `san_mames` | bilbao/exterior |
| `centro_botin` | santander/exterior |
| `basilica_covadonga` | ruta_18/exterior |
| `cafe_iruna` | pamplona/exterior |

También están integrados los 30 módulos urbanos. Se corrigieron tres colocaciones recortadas (casa de Ruta 2, casa roja de Bilbao y faro de Ruta 19), conservando sus dibujos de pack. Esas correcciones no se cuentan como redibujos.

El hórreo tiene un **boceto externo**, todavía sin integrar ni validar en el mapa. El boceto del Guggenheim se descartó: sigue pendiente de un diseño que resuelva bien sus volúmenes. No se consideran piezas terminadas.

## Pendientes, uno por uno

**101 fuentes señaladas como pendientes:** 84 fachadas, pasos o estructuras arquitectónicas y 17 estatuas, fuentes u otros monumentos. El estado anterior de ESTADO decía 100: contaba solo las filas con «pendiente de redibujo» y omitía el Guggenheim, que tiene una nota distinta. Esta auditoría incluye ese pendiente.

### Fachadas, pasos y estructuras (84)

| Pieza | Mapas donde repercute sustituirla |
|---|---|
| `iglesia_san_miguel` | pueblo_inicial/exterior, ruta_23/exterior |
| `ermita_virgen_del_rio` | getafe/exterior, mostoles/exterior, pueblo_inicial/exterior, puertollano/exterior, ruta_20/exterior |
| `acueducto_segovia` | ruta_2/exterior |
| `acueducto_segovia_tramo` | ruta_2/exterior |
| `cruz_cuelgamuros` | ruta_3/exterior |
| `basilica_cuelgamuros` | ruta_3/exterior |
| `monasterio_escorial` | ruta_4/exterior |
| `arco_victoria` | madrid/moncloa |
| `faro_moncloa` | madrid/moncloa |
| `soportales` | barcelona/ciutat_vella, bilbao/exterior, getafe/exterior, leganes/exterior, madrid/centro, malaga/exterior, palma/exterior, pamplona/exterior, ruta_5/exterior, santander/exterior, valencia/ciutat_vella, valladolid/exterior |
| `soportales_arco` | bilbao/exterior, madrid/centro, valladolid/exterior |
| `casa_panaderia` | madrid/centro |
| `mercado_san_miguel` | madrid/centro, santander/exterior |
| `edificio_metropolis` | madrid/centro |
| `edificio_carrion` | madrid/centro |
| `catedral_almudena` | madrid/palacio_real |
| `teatro_real` | bilbao/exterior, madrid/palacio_real, santander/exterior, sevilla/rio |
| `palacio_cibeles` | madrid/retiro |
| `puerta_alcala` | madrid/retiro |
| `museo_prado` | madrid/retiro |
| `estacion_atocha` | madrid/retiro |
| `monumento_alfonso_xii` | madrid/retiro |
| `palacio_cristal` | madrid/retiro |
| `boca_metro` | madrid/centro, madrid/chamberi, madrid/palacio_real |
| `nave_logistica` | madrid_rio/exterior, puertollano/exterior, ruta_11/exterior, ruta_17/exterior, ruta_5/exterior, soto_del_real/exterior |
| `universidad_alcala` | ruta_5/exterior |
| `palacio_infantado` | huelva/exterior, pamplona/exterior, ruta_5/exterior |
| `arco_medinaceli` | ruta_6/exterior |
| `torre_mudejar` | ruta_6/exterior |
| `basilica_pilar` | zaragoza/exterior |
| `la_seo` | zaragoza/exterior |
| `monasterio_montserrat` | ruta_8/exterior |
| `casa_batllo` | barcelona/eixample |
| `la_pedrera` | barcelona/eixample |
| `monumento_colon` | barcelona/ciutat_vella |
| `boqueria` | barcelona/ciutat_vella |
| `catedral_barcelona` | barcelona/ciutat_vella |
| `catedral_palma` | palma/exterior |
| `castillo_bellver` | palma/exterior |
| `muralla_dalt_vila` | ibiza/exterior, malaga/exterior |
| `catedral_ibiza` | huelva/exterior, ibiza/exterior |
| `casa_ibicenca` | alicante/exterior, ibiza/exterior, ruta_10/exterior, ruta_14/exterior, ruta_15/exterior, sevilla/centro, sevilla/rio |
| `club_ibiza` | ibiza/exterior |
| `catedral_burgos` | bilbao/exterior, pamplona/exterior, ruta_17/exterior, ruta_22/exterior |
| `cupula_milenio` | valladolid/exterior |
| `san_pablo_valladolid` | valladolid/exterior |
| `catedral_valladolid` | valladolid/exterior |
| `castillo_cuellar` | ruta_23/exterior |
| `magdalena_getafe` | getafe/exterior |
| `alhambra` | ruta_12/exterior |
| `mezquita` | ruta_13/exterior |
| `catedral_sevilla` | sevilla/centro |
| `setas` | sevilla/centro |
| `plaza_espana` | sevilla/maria_luisa |
| `puerta_leon` | sevilla/centro |
| `maestranza` | pamplona/exterior, sevilla/rio |
| `catedral_santa_ana` | las_palmas/vegueta_triana, santander/exterior |
| `castillo_luz` | las_palmas/canteras, malaga/exterior |
| `terminal_aeropuerto` | playa_del_ingles/exterior |
| `san_salvador_leganes` | leganes/exterior |
| `micalet_catedral` | valencia/ciutat_vella |
| `lonja_seda` | valencia/ciutat_vella |
| `mercado_central` | bilbao/exterior, valencia/ciutat_vella |
| `torres_serranos` | valencia/ciutat_vella |
| `hemisferic` | valencia/turia |
| `museu_ciencies` | valencia/turia |
| `palau_arts` | valencia/turia |
| `asuncion_mostoles` | mostoles/exterior, puertollano/exterior |
| `molino_mancha` | ruta_24/exterior |
| `dolmen_antequera` | ruta_26/exterior |
| `catedral_malaga` | malaga/exterior |
| `barraca` | ruta_9/exterior |
| `palau_ducal_gandia` | ruta_9/exterior |
| `iglesia_altea` | ruta_10/exterior, ruta_19/exterior |
| `rascacielos_benidorm` | ruta_10/exterior |
| `intempo` | ruta_10/exterior |
| `castillo_santa_barbara` | alicante/exterior |
| `concatedral_san_nicolas` | alicante/exterior |
| `casa_carbonell` | alicante/exterior, rocafonda/exterior, santander/exterior |
| `basilica_elche` | ruta_11/exterior |
| `catedral_murcia` | murcia/exterior |
| `guggenheim` | bilbao/exterior |
| `horreo` | ruta_17/exterior |
| `ruinas_rocafonda` | rocafonda/exterior |

### Estatuas, fuentes y otros monumentos (17)

| Pieza | Mapas |
|---|---|
| `oso_madrono` | madrid/centro |
| `felipe_iv` | madrid/palacio_real, pamplona/exterior |
| `estatua_rey` | madrid/palacio_real |
| `cibeles` | madrid/retiro |
| `fuente_neptuno` | madrid/retiro |
| `sireno_vigo` | vigo/exterior |
| `conde_ansurez` | valladolid/exterior |
| `sagrado_corazon_getafe` | getafe/exterior |
| `fe_descubridora` | huelva/exterior |
| `escultura_leganes` | leganes/exterior |
| `fuente_peces` | mostoles/exterior |
| `fuente_agria` | puertollano/exterior |
| `castillete_minero` | puertollano/exterior |
| `minero_puertollano` | puertollano/exterior |
| `cubo_pompidou` | malaga/exterior |
| `dama_elche` | ruta_11/exterior |
| `sardina_segura` | murcia/exterior |

### Otras piezas y servicios

Cuatro fuentes sin colocación actual siguen esperando su revisión individual: `puente_piedra`, `puente_triana`, `muelle_tinto` y `explanada_mosaico`. No se cuentan como edificios pendientes de sustituir en un mapa. Las otras 15 entradas del inventario son vegetación, rocas, vehículos o decorado sin fachada; no se declaran redibujadas por haberlas inventariado.

Los hospitales/Centros Pokémon, Mercadona, estancos y casas de pack **no quedan cubiertos por el recuento de 137 fuentes propias**. Su revisión visual sigue pendiente según el encargo; ya hay servicios e interiores funcionales. La tabla del [encargo del 14 de octubre](../edificios/redisenio_2026-10-14.md) contiene tamaños y salas objetivo, no un seguimiento fiable de lo integrado después: no se debe usar su columna antigua «Pendiente» para concluir que Correos o el Bernabéu siguen sin hacer.

## Orden de continuación

1. Monumentos y edificios identificados pendientes: entre los más visibles están el Guggenheim, Acueducto de Segovia, Escorial, Alhambra, Mezquita, Pilar, Batlló, Pedrera, catedrales y castillos de la tabla.
2. Servicios: hospitales/Centros Pokémon, Mercadona y estancos.
3. Casas y otras piezas genéricas.

Conservar fuente, lienzo, ancla, huella y puerta. Si se cambia tamaño o colocación, reservar antes los mapas afectados y coordinar sus interiores. Cada pieza compartida cambia en todos los mapas listados; revisar todos sus usos. No repintar escenas desde los pintores antiguos: se perderían enlaces. Entrada y salida exigidas para edificios; los arcos, estatuas y pasos no se convierten en salas.

## Comprobación de esta auditoría

El catálogo cargado por Godot contiene los **20 diseños integrados en 27 colocaciones, sin recortes**. Siete referencias con SHA-256 idéntico al original y 19 enlaces locales de los tres documentos nuevos comprobados.

Suite completa: **771/771 pruebas. 92.186 aserciones. 631.772 s**. Fondos: **11/11, 2.073 aserciones**. Arte: **11.606 PNG, 0 errores, 0 avisos**. Datos: **0 errores y 0 avisos**. Grafo: **994 mapas, todos alcanzables y con vuelta**. Las fuentes y las capturas no se han modificado durante la suite.

La guía visual y las capturas nuevas no equivalen a haber redibujado los pendientes. Los avisos anteriores de recursos/RID retenidos al cerrar la herramienta de inventario siguen apareciendo; su recorrido termina sin problemas de colocación.
