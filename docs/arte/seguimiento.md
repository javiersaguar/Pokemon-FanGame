# Seguimiento de arte

Estado de **cada asset visible** del juego (Fase A.7 de la guía). Dueño del archivo: Agente 3; cada agente añade y actualiza las filas de sus assets.

- **Estados:** `placeholder → encargo → silueta → color → animado → integrado → revisado → ✅ final`.
- Un asset solo pasa a **✅ final** con la aprobación de Javier (columna "Aprobado por Javier").
- Los **placeholders** están permitidos durante el desarrollo **solo si están en esta tabla**. Desde la demo `v0.3` no puede quedar ninguno a la vista.
- Licencias de los assets de terceros: `docs/arte/licencias.md`. Créditos: `CREDITOS.md`. Packs descargados: `docs/arte/recursos_terceros.md`.

## Placeholders a la vista

Relleno técnico temporal que hay que sustituir. **Ninguno es arte del juego.**

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|-------|------|-------|--------|-------------------|---------------------|-------|
| Efectos de los movimientos (`BattleFx`) | Animación de combate | A3 | placeholder | Dibujados por código | — | Estallido, proyectil y destellos por tipo. Falta un pack de efectos (pregunta en `docs/ESTADO.md`) |
| Sprite de Pokémon de reserva (`PlaceholderArt.pokemon`) | Pokémon en combate | A3 | placeholder | Generado por código | — | **Solo** si a una especie le falta el sprite; con el Generation 9 Pack no sale ninguno |
| Protagonista provisional (Ethan y Lyra del pack 05) | Personaje en el mapa | A4 | integrado | PurpleZaffre, pack 05 | — | Provisional hasta el diseño del protagonista de Spain (pack 11) |

Ya **no** se ven: las siluetas de entrenador (no se muestra ningún entrenador hasta tener su sprite) ni el fondo dibujado por código.

## Assets de terceros

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|-------|------|-------|--------|-------------------|---------------------|-------|
| Tileset de exteriores (`assets/tilesets/exterior/`: hierba, bosque, caminos, hierba alta, estanque, meseta, bordillo, adoquines, adornos) | Tileset | A4 | integrado | Packs 02 (×2 tal cual) y 01, 03 y 04 (×2 duplicando píxeles); ver CREDITOS.md | ⏳ | Prueba de nivel gráfico: `docs/arte/comparativas/` |
| Casas de HGSS (`casas.png`) | Edificio | A4 | retirado del pueblo | SirMalo, pack 01 | — | Javier: tejados verdeazulados que no encajan con DPPt (respuesta 17). Sustituidas por las casas de DPPt |
| Casas de DPPt (`casas_dppt.png`: roja, azul, azul pequeña, naranja y la de tejado rojo grande; desde el 2026-10-09 también la roja con chimenea, la de dos aguas, la de madera, el granero, el edificio de la cúpula y, para las ciudades, el edificio de cristal y los dos bloques verdes) | Edificio | A4 | integrado | Pack 02 | ⏳ | Completas, con su sombra; de cada rectángulo solo se copia el bloque principal. En el pueblo de muestra v2 y en San Miguel de Bernuy |
| Edificios de ciudad de HGSS (`edificios.png`: centros Pokémon, tiendas, grandes almacenes, oficinas, pisos, ático, teatro, gimnasio de madera, faro, torre, casas...) | Edificio | Agente único | integrado (tileset) | SirMalo, pack 01 (`BuildingsRMXP.png`, ×2) | ⏳ | Para las ciudades; catálogo en `docs/mundo/arte_ciudades.md`. Aún no salen en ningún mapa |
| Adornos urbanos de HGSS (`adornos.png`: farolas, fuentes, bancos, jardinera, sombrilla, busto, abeto en maceta, aerogenerador) | Objeto del mapa | Agente único | integrado | SirMalo, pack 01 (`UrbanRMXP.png`, ×2) | ⏳ | Solo choca la fila de abajo. En la plaza de San Miguel de Bernuy |
| Nieve y pinos nevados (`gen4.png`, filas 32–38) | Tileset | Agente único | integrado | Pack 02 | ⏳ | Suelo nevado (con encuentros, como la nieve honda de DPPt) y bosque de pinos nevados. Ruta 3 |
| Calle de baldosas en espiga (`gen4.png`, filas 27–29) | Tileset | A4 | integrado | Pack 02 | ⏳ | Sustituye a la plaza de círculos y a los adoquines con grietas repetidas |
| Valla de madera (`vallas.png`) | Objeto del mapa | A4 | integrado | SirMalo, pack 01 (×2) | ⏳ | Tramos horizontales; las puntas tapan a quien está detrás |
| Retoque de los verdes de los packs 02, 03 y 04 | Tileset | A4 | integrado | `GREEN_RETOUCH` en `build_exterior.gd` | ⏳ | Hierba con el tono y la viveza de la de Añil (de 85° a 105°, más saturada) |
| Sombra de los personajes y de los Pokémon que te siguen (`effects/sombra.png`) | Efecto | A4 | integrado | Propia, dibujada a mano (`assets/_fuentes/mundo/sombra.px2`) | ⏳ | Elipse de 14×5 píxeles del arte en dos tonos fríos semitransparentes; la integra el Agente 1 |
| Pueblo de muestra v2 (`maps/muestras/pueblo.tscn`) | Mapa | A4 | revisado | Tileset de exteriores | ⏳ | Comparativas `docs/arte/comparativas/pueblo_v2_*.png` |
| San Miguel de Bernuy, exterior (`maps/pueblo_inicial/exterior.tscn`, `maps/_pintura/pintar_san_miguel.gd`) | Mapa | Agente único | integrado | Tileset de exteriores; distribución del plano real de OpenStreetMap | ⏳ | Pueblo inicial: embalse, río Duratón, iglesia, Plaza de España, calle Real, ermita, Molino (laboratorio). Solo casas de DPPt. Comparativa `comparativas/san_miguel_mapa.png` |
| Ruta 1 · Hoces del Duratón (`maps/ruta_1/exterior.tscn`, `maps/_pintura/pintar_ruta_1.gd`) | Mapa | Agente único | integrado | Tileset de exteriores | ⏳ | Río Duratón, ribera con chopos, páramo con mirador de buitres y ruinas de San Frutos (de momento, piedras). Unida sin fundido con el pueblo y con la Ruta 2. Comparativa `comparativas/ruta_1_mapa.png` |
| Ruta 2 · Tierra de Pinares y Acueducto (`maps/ruta_2/exterior.tscn`, `maps/_pintura/pintar_ruta_2.gd`) | Mapa | Agente único | integrado | Tileset de exteriores | ⏳ | Pinares de Cantalejo con el taller de trillos; plaza del Azoguejo con el Acueducto de lado a lado (se pasa por debajo de los arcos); calles de Segovia y el mesón del cochinillo. Unida sin fundido con las Rutas 1 y 3. Comparativa `comparativas/ruta_2_mapa.png` |
| Ruta 3 · Puerto de Navacerrada (`maps/ruta_3/exterior.tscn`, `maps/_pintura/pintar_ruta_3.gd`) | Mapa | Agente único | integrado | Tileset de exteriores | ⏳ | El puerto nevado con la estación de esquí, la ladera de pinos y granito y el Valle de Cuelgamuros. En la nieve salen Pokémon. Unida con las Rutas 2 y 4. Comparativa `comparativas/ruta_3_mapa.png` |
| Ruta 4 · El Escorial y Galapagar (`maps/ruta_4/exterior.tscn`, `maps/_pintura/pintar_ruta_4.gd`) | Mapa | Agente único | integrado | Tileset de exteriores | ⏳ | Monte Abantos con la Silla de Felipe II, el Monasterio con su lonja, la urbanización de chalets con setos y la dehesa. La calle sale por el este hacia Madrid (sin conexión hasta que exista `madrid/moncloa`). Comparativa `comparativas/ruta_4_mapa.png` |
| Madrid · Moncloa (`maps/madrid/moncloa.tscn`, `maps/_pintura/pintar_madrid_moncloa.gd`) | Mapa | Agente único | integrado | Tileset de exteriores; plano real `docs/mundo/planos/madrid_centro.svg` | ⏳ | Palacio de la Moncloa tras la verja, Faro, glorieta del Arco de la Victoria, Princesa y Ferraz (sede del Clan), Argüelles (El Corte Inglés, Centro Pokémon, Mercadona, estanco), Plaza de España y el Parque del Oeste con el Templo de Debod. Comparativa `comparativas/madrid_moncloa_mapa.png` |
| Madrid · Sol y Gran Vía (`maps/madrid/centro.tscn`, `maps/_pintura/pintar_madrid_centro.gd`) | Mapa | Agente único | integrado | Tileset de exteriores; plano real `docs/mundo/planos/madrid_centro.svg` | ⏳ | Gran Vía en escalones (Carrión con Schweppes, cines, Telefónica, Teatro Príncipe Gran Vía, Metrópolis), Callao, El Corte Inglés de Preciados, Puerta del Sol con la Real Casa de Correos (gimnasio 1), Plaza Mayor con la Casa de la Panadería y los soportales, Mercado de San Miguel, Centro Pokémon, Barrio de las Letras. Comparativa `comparativas/madrid_centro_mapa.png` |
| Madrid · Palacio Real (`maps/madrid/palacio_real.tscn`, `maps/_pintura/pintar_madrid_palacio_real.gd`) | Mapa | Agente único | integrado | Tileset de exteriores; plano real `docs/mundo/planos/madrid_palacio_real.svg` | ⏳ | Jardines de Sabatini, Palacio Real (Liga) con la Plaza de la Armería y su verja, Catedral de la Almudena, Campo del Moro y Mirador de la Cornisa, Bailén, Plaza de Oriente (Felipe IV, reyes), Teatro Real, Senado. Comparativa `comparativas/madrid_palacio_real_mapa.png` |
| Madrid · Retiro y Prado (`maps/madrid/retiro.tscn`, `maps/_pintura/pintar_madrid_retiro.gd`) | Mapa | Agente único | integrado | Tileset de exteriores; plano real `docs/mundo/planos/madrid_centro.svg` | ⏳ | Alcalá, Cibeles y el Ayuntamiento, Banco de España, Puerta de Alcalá, Paseo del Prado con Neptuno, Congreso y sus leones, Museo del Prado, Jardín Botánico, Atocha y el Retiro (Estanque con Alfonso XII, Palacio de Cristal). Comparativa `comparativas/madrid_retiro_mapa.png` |
| Madrid · Chamberí (`maps/madrid/chamberi.tscn`, `maps/_pintura/pintar_madrid_chamberi.gd`) | Mapa | Agente único | integrado | Tileset de exteriores | ⏳ | Glorieta de Bilbao con su café, Plaza de Olavide con quiosco y terrazas, Mercadona y estanco, la finca con el ático de Ayuso (`atico_jardin` del pack 01) y la boca de metro de Andén 0 (dibujada a mano). Comparativa `comparativas/madrid_chamberi_mapa.png` |
| Ruta 5 · Corredor del Henares (`maps/ruta_5/exterior.tscn`, `maps/_pintura/pintar_ruta_5.gd`) | Mapa | Agente único | integrado | Tileset de exteriores | ⏳ | Polígono de naves logísticas, Alcalá de Henares (Universidad, Plaza y casa natal de Cervantes, calle Mayor porticada), Guadalajara (Palacio del Infantado) y el río Henares. Unida con el Retiro. Comparativa `comparativas/ruta_5_mapa.png` |
| Ruta 6 · Medinaceli y Calatayud (`maps/ruta_6/exterior.tscn`, `maps/_pintura/pintar_ruta_6.gd`) | Mapa | Agente único | integrado | Tileset de exteriores | ⏳ | Páramo de Soria, Medinaceli en su cerro con el arco romano, un pueblo de la España vaciada y Calatayud con la torre mudéjar y el mesón de la Dolores, junto al Jalón. Comparativa `comparativas/ruta_6_mapa.png` |
| Zaragoza (`maps/zaragoza/exterior.tscn`, `maps/_pintura/pintar_zaragoza.gd`) | Mapa | Agente único | integrado | Tileset de exteriores; plano real `docs/mundo/planos/zaragoza.svg` | ⏳ | El Ebro con el Puente de Piedra (y sus leones) y el de Santiago, la Plaza del Pilar con la Basílica, el Ayuntamiento, La Seo, la fuente de la Hispanidad y Goya, El Tubo, el teatro romano y la ribera con hierba alta. Comparativa `comparativas/zaragoza_mapa.png` |
| Ruta 7 · Los Monegros (`maps/ruta_7/exterior.tscn`, `maps/_pintura/pintar_ruta_7.gd`) | Mapa | Agente único | integrado | Tileset de exteriores | ⏳ | Desierto de arena con cerros de yeso (mesetas), matorral (hierba alta) y el escenario del festival con sus ravers. Los bordes de las mesetas dejan una línea de hierba (es la pieza del pack). Comparativa `comparativas/ruta_7_mapa.png` |
| Ruta 8 · Montserrat (`maps/ruta_8/exterior.tscn`, `maps/_pintura/pintar_ruta_8.gd`) | Mapa | Agente único | integrado | Tileset de exteriores | ⏳ | La terraza del monasterio con las agujas detrás, el camino entre pinares y Santpedor y Sant Esteve Sesrovires al sur. Comparativa `comparativas/ruta_8_mapa.png` |
| Barcelona · Les Corts (`maps/barcelona/les_corts.tscn`, `maps/_pintura/pintar_barcelona_les_corts.gd`) | Mapa | Agente único | integrado | Tileset de exteriores | ⏳ | La Diagonal desde la Ruta 8, Pedralbes, el Spotify Camp Nou (gimnasio 2) con grúas, La Masia, la tienda del Barça y el Basic-Fit. Comparativa `comparativas/barcelona_les_corts_mapa.png` |
| Barcelona · Eixample (`maps/barcelona/eixample.tscn`, `maps/_pintura/pintar_barcelona_eixample.gd`) | Mapa | Agente único | integrado | Tileset de exteriores; plano real `docs/mundo/planos/barcelona_centro.svg` | ⏳ | Cuadrícula de Cerdà (recta), la Diagonal desde Les Corts, el Passeig de Gràcia con La Pedrera y la Casa Batlló, la Sagrada Família con su grúa y la Plaça de Catalunya con El Corte Inglés y el Centro Pokémon. Comparativa `comparativas/barcelona_eixample_mapa.png` |
| Barcelona · Ciutat Vella (`maps/barcelona/ciutat_vella.tscn`, `maps/_pintura/pintar_barcelona_ciutat_vella.gd`) | Mapa | Agente único | integrado | Tileset de exteriores | ⏳ | La Rambla con sus plátanos, la Boqueria, el Liceu, la Catedral, la Plaça Reial, Colón, el Port Vell con el ferry y la playa de la Barceloneta. Comparativa `comparativas/barcelona_ciutat_vella_mapa.png` |
| Palma de Mallorca (`maps/palma/exterior.tscn`, `maps/_pintura/pintar_palma.gd`) | Mapa | Agente único | integrado | Tileset de exteriores; plano real `docs/mundo/planos/palma.svg` | ⏳ | El monte de Bellver con el castillo, el puerto con el ferry (pasarela a Barcelona), el Passeig des Born, La Seu y la torre de la Almudaina, el casco antiguo y la bahía. Comparativa `comparativas/palma_mapa.png` |
| Ruta marítima 1 · Canal de Ibiza (`maps/maritima_1/exterior.tscn`, `maps/_pintura/pintar_maritima_1.gd`) | Mapa | Agente único | integrado | Tileset de exteriores | ⏳ | Mar con Surf, Sa Dragonera, un islote con un velero fondeado y Es Vedrà. Unida con Palma por el norte. Comparativa `comparativas/maritima_1_mapa.png` |
| Ibiza (`maps/ibiza/exterior.tscn`, `maps/_pintura/pintar_ibiza.gd`) | Mapa | Agente único | integrado | Tileset de exteriores; plano real `docs/mundo/planos/ibiza.svg` | ⏳ | El puerto con el ferry, La Marina de casas encaladas, la muralla de Dalt Vila con sus portales, la catedral, el club y la playa d'en Bossa. Se llega con Surf desde el norte. Comparativa `comparativas/ibiza_mapa.png` |
| Valencia · Malvarrosa (`maps/valencia/malvarrosa.tscn`, `maps/_pintura/pintar_valencia_malvarrosa.gd`) | Mapa | Agente único | integrado | Tileset de exteriores | ⏳ | La playa con palmeras y el paseo marítimo, Akuarela Playa (gimnasio 3), el Cabanyal y el puerto con el ferry de Ibiza (pasarela en los dos puertos). Comparativa `comparativas/valencia_malvarrosa_mapa.png` |
| Vigo (`maps/vigo/exterior.tscn`, `maps/_pintura/pintar_vigo.gd`) | Mapa | Agente 2 | integrado | Tileset de exteriores; plano real `docs/mundo/planos/vigo.svg` | ⏳ | Porta do Sol con el árbol de Navidad y el Sireno, Casco Vello, puerto y aeropuerto de Peinador (llegada `from_avion`). Norte hacia la Ruta 16, columnas 24–29. Comparativa `comparativas/vigo_mapa.png` |
| Ruta 16 · Rías Baixas (`maps/ruta_16/exterior.tscn`, `maps/_pintura/pintar_ruta_16.gd`) | Mapa | Agente 2 | integrado | Tileset de exteriores | ⏳ | Ría con dos bateas y Sanxenxo (cartel de las regatas). Sur, columnas 24–29, unida con Vigo. Norte, columnas 16–21, para la Ruta 17. Comparativa `comparativas/ruta_16_mapa.png` |
| Murcia (`maps/murcia/exterior.tscn`, `maps/_pintura/pintar_murcia.gd`) | Mapa | Agente 5 (Levante) | integrado | Tileset de exteriores; plano real `docs/mundo/planos/murcia.svg` | ⏳ | La Catedral en la plaza del Cardenal Belluga, el Real Casino, el Teatro Romea, la Universidad, el Malecón, el Segura con sus dos puentes y la sardina, y el barrio del Carmen con el jardín de Floridablanca y la huerta. Unida con la Ruta 11 por el este y con la Ruta 12 por el oeste. Comparativa `comparativas/murcia_mapa.png` |
| Ruta 11 · Palmeral de Elche (`maps/ruta_11/exterior.tscn`, `maps/_pintura/pintar_ruta_11.gd`) | Mapa | Agente 5 (Levante) | integrado | Tileset de exteriores | ⏳ | Las salinas de Santa Pola, el Palmeral con la Palmera Imperial, Elche con la basílica, la Dama y la fábrica de calzado, la Vega Baja con sus granados y Orihuela. Unida con Alicante por el este. Comparativa `comparativas/ruta_11_mapa.png` |
| Alicante (`maps/alicante/exterior.tscn`, `maps/_pintura/pintar_alicante.gd`) | Mapa | Agente 5 (Levante) | integrado | Tileset de exteriores; plano real `docs/mundo/planos/alicante.svg` | ⏳ | El Benacantil con el Castillo de Santa Bárbara, Santa Cruz, la Concatedral, la plaza de los Luceros, el Teatro Principal, la Explanada con su mosaico y la Casa Carbonell, el puerto y el Postiguet. Unida con la Ruta 10 por el norte. Comparativa `comparativas/alicante_mapa.png` |
| Ruta 10 · Costa Blanca (`maps/ruta_10/exterior.tscn`, `maps/_pintura/pintar_ruta_10.gd`) | Mapa | Agente 5 (Levante) | integrado | Tileset de exteriores | ⏳ | Calp con el Peñón de Ifach, Altea en su cerro, Benidorm con la línea de rascacielos, el Intempo, la grúa y la playa de Levante, y La Vila Joiosa con sus casas de colores. Unida con la Ruta 9 por el norte. Comparativa `comparativas/ruta_10_mapa.png` |
| Ruta 9 · La Albufera y Gandía (`maps/ruta_9/exterior.tscn`, `maps/_pintura/pintar_ruta_9.gd`) | Mapa | Agente 5 (Levante) | integrado | Tileset de exteriores | ⏳ | La Devesa del Saler, el lago con El Palmar (barracas y barcas), la huerta y los arrozales, Cullera con el faro y Gandía con el Palau Ducal y la playa. Sale de la Ciudad de las Artes (Turia) por el sur. Comparativa `comparativas/ruta_9_mapa.png` |
| Valencia · Ciutat Vella y Jardín del Turia (`maps/valencia/ciutat_vella.tscn`, `maps/valencia/turia.tscn`) | Mapa | Agente único | integrado | Tileset de exteriores; plano real `docs/mundo/planos/valencia.svg` | ⏳ | Torres de Serranos, Micalet y catedral, Lonja, Mercado Central, Plaza del Ayuntamiento; el Turia con su parque y la Ciudad de las Artes y las Ciencias. Comparativas `comparativas/valencia_ciutat_vella_mapa.png` y `valencia_turia_mapa.png` |
| Ruta de muestra v2 (`maps/muestras/ruta.tscn`) | Mapa | A4 | revisado | Tileset de exteriores | ⏳ | Tres niveles con escaleras; comparativas `docs/arte/comparativas/ruta_v2_*.png` |
| Ruta 12 · Sierra Nevada y Granada (`maps/ruta_12/exterior.tscn`, `maps/_pintura/pintar_ruta_12.gd`) | Mapa | Agente 1 (tramo sur) | integrado | Tileset de exteriores | ⏳ | El altiplano de Guadix, Sierra Nevada en dos alturas con nieve, pinos nevados, Pradollano y el Veleta, y la vega de Granada con la Alhambra y un cortijo en plena boda. Comparativa `comparativas/ruta_12_mapa.png` |
| Ruta 13 · Mar de olivos (`maps/ruta_13/exterior.tscn`, `maps/_pintura/pintar_ruta_13.gd`) | Mapa | Agente 1 (tramo sur) | integrado | Tileset de exteriores | ⏳ | Olivares en hileras de Jaén y la campiña, el cortijo del aceite y Córdoba junto al Guadalquivir, con la Mezquita-Catedral de fondo y el Puente Romano. Comparativa `comparativas/ruta_13_mapa.png` |
| Sevilla · Centro (`maps/sevilla/centro.tscn`, `maps/_pintura/pintar_sevilla_centro.gd`) | Mapa | Agente 1 (tramo sur) | integrado | Tileset de exteriores | ⏳ | Las Setas, la Avenida de la Constitución con el Centro Pokémon, la Catedral con la Giralda, el Archivo de Indias, el Real Alcázar (Puerta del León) con sus jardines y el barrio de Santa Cruz con el estanco. Comparativa `comparativas/sevilla_centro_mapa.png` |
| Sevilla · Río y Triana (`maps/sevilla/rio.tscn`, `maps/_pintura/pintar_sevilla_rio.gd`) | Mapa | Agente 1 (tramo sur) | integrado | Tileset de exteriores | ⏳ | El Guadalquivir con el Puente de Triana, la Maestranza y la Torre del Oro (la torre octogonal del pack 01, provisional) en el Paseo de Colón, y Triana con el club de la comedia (gimnasio 4), el mercado y la cerámica. Comparativa `comparativas/sevilla_rio_mapa.png` |
| Sevilla · Plaza de España (`maps/sevilla/maria_luisa.tscn`, `maps/_pintura/pintar_sevilla_maria_luisa.gd`) | Mapa | Agente 1 (tramo sur) | integrado | Tileset de exteriores | ⏳ | La Plaza de España con su canal, los bancos de azulejos (carteles) y la fuente, y el Parque de María Luisa con estanques, glorietas y hierba alta. Comparativa `comparativas/sevilla_maria_luisa_mapa.png` |
| Ruta 14 · Doñana (`maps/ruta_14/exterior.tscn`, `maps/_pintura/pintar_ruta_14.gd`) | Mapa | Agente 1 (tramo sur) | integrado | Tileset de exteriores | ⏳ | El pinar, la aldea de El Rocío, las marismas con la vereda y el observatorio de aves, y las dunas de la costa. Comparativa `comparativas/ruta_14_mapa.png` |
| Huelva (`maps/huelva/exterior.tscn`, `maps/_pintura/pintar_huelva.gd`) | Mapa | Agente 1 (tramo sur) | integrado | Tileset de exteriores | ⏳ | La ciudad sobre la ría, con la Casa Colón, la Merced, el Barrio Obrero y los locales; el Muelle del Tinto, la Punta del Sebo con la Fe Descubridora y el puerto con el ferry a Las Palmas (pasarela en los dos puertos). Comparativa `comparativas/huelva_mapa.png` |
| Las Palmas · Las Canteras (`maps/las_palmas/canteras.tscn`, `maps/_pintura/pintar_las_palmas_canteras.gd`) | Mapa | Agente 1 (tramo sur) | integrado | Tileset de exteriores | ⏳ | La playa de Las Canteras con la Barra, La Isleta volcánica, el Castillo de la Luz y el Puerto de La Luz con el ferry de Huelva. Comparativa `comparativas/las_palmas_canteras_mapa.png` |
| Las Palmas · Vegueta y Triana (`maps/las_palmas/vegueta_triana.tscn`, `maps/_pintura/pintar_las_palmas_vegueta.gd`) | Mapa | Agente 1 (tramo sur) | integrado | Tileset de exteriores | ⏳ | Triana con la calle Mayor, el Parque de San Telmo y los locales, y Vegueta con la Catedral de Santa Ana y sus perros, la Casa de Colón y el mercado. Comparativa `comparativas/las_palmas_vegueta_triana_mapa.png` |
| Ruta 15 · Costa de Gran Canaria (`maps/ruta_15/exterior.tscn`, `maps/_pintura/pintar_ruta_15.gd`) | Mapa | Agente 1 (tramo sur) | integrado | Tileset de exteriores | ⏳ | La costa este: malpaís, playas de arena negra de Telde, un barranco, cardonales y las salinas de Arinaga. Comparativa `comparativas/ruta_15_mapa.png` |
| Playa del Inglés (`maps/playa_del_ingles/exterior.tscn`, `maps/_pintura/pintar_playa_del_ingles.gd`) | Mapa | Agente 1 (tramo sur) | integrado | Tileset de exteriores | ⏳ | El aeropuerto con el mostrador de los vuelos a Vigo, los hoteles y los locales, la playa con el escenario del concierto de Quevedo (gimnasio 5), las Dunas de Maspalomas con la Charca y el Faro. Comparativa `comparativas/playa_del_ingles_mapa.png` |
| Pozuelo de Alarcón (`maps/pozuelo/exterior.tscn`, `maps/_pintura/pintar_pozuelo.gd`) | Mapa | Agente B | integrado | Tileset de exteriores e interiores | ⏳ | Urbanización de chalets con setos y piscinas; casa del jugador y del rival enlazadas. Comparativa `comparativas/pozuelo_mapa.png` |
| Orcasitas (`maps/orcasitas/exterior.tscn`, `maps/_pintura/pintar_orcasitas.gd`) | Mapa | Agente B | integrado | Tileset de exteriores e interiores | ⏳ | Bloques, plaza, estanco y descampado; piso del jugador y del rival enlazados. Comparativa `comparativas/orcasitas_mapa.png` |
| Casa de Campo (`maps/casa_de_campo/exterior.tscn`, `maps/_pintura/pintar_casa_de_campo.gd`) | Mapa | Agente B | integrado | Tileset de exteriores e interiores | ⏳ | Ruta inicial Pozuelo → Moncloa: lago, encinar, teleférico. Comparativa `comparativas/casa_de_campo_mapa.png` |
| Madrid Río (`maps/madrid_rio/exterior.tscn`, `maps/_pintura/pintar_madrid_rio.gd`) | Mapa | Agente B | integrado | Tileset de exteriores e interiores | ⏳ | Ruta inicial Orcasitas → Atocha: Manzanares, Puente de Toledo, Matadero y El Jincho. Comparativa `comparativas/madrid_rio_mapa.png` |
| Casas del jugador y del rival y laboratorio de Unicoos (`maps/_pintura/pintar_casas_iniciales.gd`) | Mapa | Agente B | integrado | Tileset de exteriores e interiores | ⏳ | Interiores con el tileset de interiores. Comparativas `comparativas/pozuelo_casa_jugador_mapa.png` y `madrid_laboratorio_mapa.png` |
| Hospital Quirón y terraza del ático de Ayuso (`maps/madrid/quiron.tscn`, `maps/madrid/atico_ayuso.tscn`, `maps/_pintura/pintar_madrid_quiron.gd`) | Mapa | Agente B | integrado | Tileset de interiores y de exteriores | ⏳ | Pasillo con camas y tres enfermeros; terraza con jardineras y sombrillas. Comparativas `comparativas/madrid_quiron_mapa.png` y `madrid_atico_ayuso_mapa.png` |
| Madrid · Bernabéu (`maps/madrid/bernabeu.tscn`, `maps/_pintura/pintar_madrid_bernabeu.gd`) con el estadio Santiago Bernabéu dibujado a mano (`hecho_a_mano/bernabeu.png`, fuente 375) y los sprites de Vinicius (con barba: el pack 11 no tiene barbas) y Mbappé dictador | Mapa | Agente B | integrado | Tileset de exteriores y pack 11 | ⏳ | Comparativas `comparativas/madrid_bernabeu_mapa.png` y `vinicius_mbappe.png` |
| Clases nuevas: perroflauta, cayetano, cani, pueblerino, gitano, mantero, turista (chico y chica), enfermero (chico y chica) y El Jincho (`assets/sprites/trainers/`, recetas del pack 11) | Entrenador | Agente B | integrado | Pack 11 | ⏳ | Comparativa `comparativas/clases_nuevas_2026-10-14.png` |
| Vendedor de Chupachups (`trainers/vendedorchupachups.png` 160×160 y `characters/vendedorchupachups.png`) | Entrenador | A4 | integrado | Poltergeist, pack 11 (capas en `assets/sprites/trainers/recetas.json`) | ⏳ | Sombrero de paja, camisa de rayas, pantalón pirata y bolsa. Comparativas `entrenador_vendedorchupachups_*.png` |
| Rival, chico y chica (`trainers/rival.png`, `rival_f.png` y `characters/rival.png`, `rival_f.png`) | Entrenador | A4 | integrado (mapa) | Poltergeist, pack 11 | ⏳ | Provisional hasta que Javier decida el GDD; el rojo es su color. El de combate espera a la petición 41 |
| Profesor (`trainers/profesor.png` y `characters/profesor.png`) | Personaje | A4 | integrado (mapa) | Poltergeist, pack 11 | ⏳ | Provisional: pelo blanco, gafas y gabardina clara como bata. El de combate (para la intro) espera a la petición 41 |
| Clases Spain, tanda 1: tuno, abuela, jubilado mirando obras, repartidor en bici, turista con chanclas y camarero (`characters/<clase>.png`; combate en `trainers/<clase>.png`) | Entrenador | A4 | integrado (mapa) | Poltergeist, pack 11 | ⏳ | Comparativa `entrenadores_clases_1.png`. Los de combate esperan a la petición 41 |
| Clases de las rutas: piragüista, ornitóloga, resinero, esquiador, montañera, pastor, baturro, raver (chico y chica), carterista, regatista, nadador (chico y chica), hippie y tronista (`characters/` y `trainers/<clase>.png`) | Entrenador | Agente único | integrado | Poltergeist, pack 11 (recetas de `tools/mundo/recetas_famosos.py`) | ⏳ | Rutas 1 a 3 y 6. Comparativa `comparativas/entrenadores_rutas.png` (las tres primeras) |
| Clases Spain, tanda 2: flautista (chico y chica), peruana de 1,50, robasientos, cuñado, influencer de LinkedIn (chico y chica), estudiante de Ingeniería (chico y chica), opositor (chico y chica), patinetero, tertuliano, revisor del Cercanías (chico y chica), domador de palomas, crossfitero (chico y chica), turista con chanclas (chica) y padre con la tarjeta (`characters/<clase>[_f].png`; combate en `trainers/`) | Entrenador | A4 | integrado (mapa) | Poltergeist, pack 11 | ⏳ | Comparativa `entrenadores_clases_2.png`. Los de combate esperan a la petición 41 |
| Fondo de combate de hierba y bosque (`ui/battle/backgrounds/forest.png`, `frente_hierba.png`) | Fondo de combate | A4 | integrado | Fondo *Field* del pack 10 (PhoenixOfLight92 y LackDeJurane) + árboles y arbustos del pack 03 (AnonAlpaca) a ×1, con el retoque de verdes; `build_fondos.gd` | ⏳ | Linde de bosque detrás del rival, como el de Añil. Ahora es una de las 25 escenas de `fondos_combate.md`, con mañana, día, tarde y noche |
| Árboles y flora (`arboles.png`, `flora.png`) | Tileset | A4 | integrado | AnonAlpaca (+ Magiscarf), packs 03 y 04 | ⏳ | Mayor densidad de detalle que el pack 02 |
| Flores animadas y brillo del agua (`animados.png`) | Tileset animado | A4 | integrado | Pack 02 | ⏳ | 4 y 2 cuadros |
| Personajes del mapa (`assets/sprites/characters/*.png`) | Personaje en el mapa | A4 | integrado | PurpleZaffre, pack 05 | ⏳ | Rival, profesor, enfermera, dependiente y vecinos. Giro al hablar: comparativa `comparativas/npc_interaccion.md` (2026-10-05), pendiente de revisión |
| Efectos del mapa (`assets/sprites/characters/effects/`) | Efecto | A4 | integrado | PurpleZaffre, pack 05 | ⏳ | "!", hierba al pisarla, polvo al saltar, brillo shiny |
| Sombras de los personajes | Efecto | A4 arte / A1 integración | integrado | Dibujada a mano por A4, `sombra.px2` | pendiente revisión | `comparativas/sombras_personajes.md`; Character la hereda también en Follower, queda en el suelo al saltar |
| **Generation 9 Resource Pack v3.3.8** (`assets/sprites/pokemon/`: `front`, `front_shiny` 192×192; `back`, `back_shiny` 288×288; `icons`, `icons_shiny` 128×64; `followers`, `followers_shiny` 256×256) | Pokémon (combate, iconos y seguidores) | A2 | integrado | Recopilado por Caruban; autores en `CREDITOS.md` ("Pokémon") | ⏳ | **Set oficial del proyecto** (DIRECTRICES §7.1). Los importa `tools/sprites/` solo de las especies en uso, sin reescalar. Shiny oficiales |
| Objeto Poké Ball (`assets/sprites/items/pokeball.png`, 48×48) | Objeto | A3 | integrado | Generation 9 Pack (`Graphics/Items`) | ⏳ | En la ficha del Pokémon (la Ball en la que se capturó) |
| Sombras de Pokémon (`assets/sprites/ui/battle/shadows/`) | Combate | A3 | integrado | Generation 9 Pack (`Graphics/Pokemon/Shadow`) | ⏳ | Encima de la base, bajo el rival y en la ficha |
| Fondos de combate según el sitio y la hora: 25 escenas (`data/battle_backgrounds.json`; fondos del pack 10 y de EBDX en `backgrounds/`, elementos de EBDX en `backgrounds/capas/`, frentes compuestos `backgrounds/frente_*.png`) | Fondo de combate | Agente de combate | integrado | PhoenixOfLight92 y LackDeJurane (pack 10); Luka S.J. (EBDX); árboles del pack 03; muebles de Akizakura16; piezas `.px2` a mano de los gimnasios y del mundo | ⏳ | Hierba, bosque, olivar, palmeral, montaña, nieve, playa, desierto, agua, ciudad, cueva, cueva oscura, casa, edificio público, monumento, los 8 gimnasios, Alto Mando y campeón. Cielo y tinte de EBDX en exteriores (mañana, día, tarde y noche). Comparativa `comparativas/fondos_combate.md` |
| Bases de combate (`ui/battle/bases/*.png`, 17 materiales) | Base de combate | Agente de combate | integrado | Propio: `.px2` a mano (`assets/_fuentes/mundo/base_combate_*.px2`), un mismo óvalo con la paleta de cada material | ⏳ | Hierba, tierra, nieve, arena, agua, adoquín, roca, madera, baldosa, mármol, alfombra roja, césped, pista de luces, tablas, alfombra granate, plató y tarima de la Liga. Sustituyen al óvalo provisional `default.png` |
| Iconos de tipo en español (`assets/sprites/ui/icons/types_spanish.png`, 64×532) | Icono de tipo | A3 | integrado | *Loaky's Modern Type Icons*: Loaky | ⏳ | En los botones de movimiento y en la ficha, a 1:1 |
| *Truth and Ideals* (`assets/fonts/truth_and_ideals/`) | Fuente | A3 | integrado | *Gen 5 Font – Truth and Ideals*: bonzairob | ⏳ | Tamaño 10 en el UiCanvas (= 20 px en pantalla, píxel de 2×2). Tiene ñ, tildes, ü, ¿¡, ♂, ♀ y ★; le faltan €, — y · |
| Pixel Operator (`assets/fonts/`) | Fuente | A3 | sustituido | Jayvee Enaguas, CC0 1.0 | — | Ya no la usa el Theme; se borrará si Javier aprueba *Truth and Ideals* |

## Integraciones de mundo (A1)

| Comportamiento | Dueño | Estado | Comparativa | Aprobado por Javier |
|---|---|---|---|---|
| Hojas bici/Surf/pesca del pack 05, comportamiento en Player/FieldEncounters | A4 arte / A1 integración | integrado; objeto de Surf pendiente | `comparativas/transporte.md` | pendiente revisión de integración |
| Tinte día/noche del canvas del mundo, Clock real | A1 | integrado, colores provisionales | `comparativas/dia_noche.md` | pendiente revisión; luces/clima esperan arte/audio |
| Alternar carrera con R/Y, hoja de correr pack 05 existente | A1 | integrado | `comparativas/correr_alternar.md` | orden 1b; aviso/opción pendientes A3 |
| Flujo inicial/ranuras/pausa y entrada de nombres con Theme/cuadro A3 existentes | A1 | placeholder de integración | `comparativas/flujo_provisional.md` | pendiente; lo sustituye A3 |
| Recompensa profesor (5 Poké Balls), nombres POR DEFINIR centralizados; usa cuadro de diálogo A3 | A1 | integrado | `comparativas/recompensa_profesor.md` | Cantidad: respuesta 18 del 2026-10-05; captura pendiente |

## Arte propio

Dibujado a mano píxel a píxel con la paleta maestra en archivos de texto (`assets/_fuentes/ui/*.px`) y exportado con `tools/arte/exportar.gd`. Se dibuja a 1× y se ve a ×2 en un `UiCanvas` (escala entera, vecino más próximo), que en pantalla es lo mismo que exportarlo a ×2.

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|-------|------|-------|--------|-------------------|---------------------|-------|
| Botones Luchar / Mochila / Pokémon / Huir y de movimiento (`ui/battle/button_*.png`) | UI de combate | A3 | animado | Propio | ⏳ | Respuesta 12: borde oscuro, luz arriba a la izquierda y sombra de 2 px abajo. Foco que parpadea y se hunde al pulsar |
| Base provisional de combate (`ui/battle/bases/default.png`) | Base de combate | A3 | integrado | Propio | ⏳ | Óvalo de hierba. El Agente 4 la sustituye con `bases/<entorno>.png` cuando llegue EBDX |
| Caja de datos (`ui/battle/databox.png`), marco de la barra de PS (`hp_frame.png`) y etiqueta PS (`tag_ps.png`) | UI de combate | A3 | integrado | Propio | ⏳ | El relleno de las barras de PS (verde, amarillo, rojo, "barra fantasma") y experiencia se pinta con colores de la paleta |
| Panel de mensajes (`ui/battle/panel_message.png`) | UI | A3 | integrado | Propio | ⏳ | También en la cabecera y la banda del equipo de la ficha |
| Iconos de estado en español (`ui/icons/status/*.png`) | Icono de estado | A3 | integrado | Propio | ⏳ | El Generation 9 Pack los trae en inglés (SLP, PSN...) |
| Iconos de sexo y estrella de shiny (`ui/icons/`) | Icono | A3 | integrado | Propio | ⏳ | |
| Destello de shiny (`ui/battle/shiny_sparkle.png`, 3 frames) | Animación de combate | A3 | animado | Propio | ⏳ | DIRECTRICES §8. El sonido `shiny` falta (no hay pack de sonidos) |
| Poké Ball de la captura (`ui/battle/ball.png`) | Combate | A3 | integrado | Propio | ⏳ | La sacudida es un movimiento de 1 píxel, sin rotar |
| Cursor y flecha de continuar (`ui/cursor_*.png`) | UI | A3 | animado | Propio | ⏳ | |
| Ficha del Pokémon: ventana, fondo saturado, cabeceras amarillas e iconos de pestaña (`ui/summary/`) | UI | A3 | integrado | Propio | ⏳ | Respuesta de Javier: sin gris dominante, sprite más grande, encuentro, naturaleza y carácter. Comparativa `datos_lado_a_lado.png` |
| Dama de Elche, Basílica de Santa María, Palmera Imperial, Catedral de Murcia y sardina del Segura (`tilesets/exterior/hecho_a_mano/dama_elche.png`, `basilica_elche.png`, `palmera_imperial.png`, `catedral_murcia.png`, `sardina_segura.png`, fuentes 103–107) | Monumento | Agente 5 (Levante) | integrado | Propio | ⏳ | Las dos últimas son para Murcia. Comparativa `comparativas/ruta_11_piezas.png` |
| Castillo de Santa Bárbara, mosaico de la Explanada, Concatedral de San Nicolás y Casa Carbonell (`tilesets/exterior/hecho_a_mano/castillo_santa_barbara.png`, `explanada_mosaico.png`, `concatedral_san_nicolas.png`, `casa_carbonell.png`, fuentes 99–102) | Monumento | Agente 5 (Levante) | integrado | Propio | ⏳ | El mosaico es suelo: se repite y no choca. Comparativa `comparativas/alicante_piezas.png` |
| Peñón de Ifach, iglesia de Altea, rascacielos de Benidorm e Intempo (`tilesets/exterior/hecho_a_mano/penon_ifach.png`, `iglesia_altea.png`, `rascacielos_benidorm.png`, `intempo.png`, fuentes 95–98) | Monumento | Agente 5 (Levante) | integrado | Propio | ⏳ | El rascacielos se repite para hacer la línea del cielo. Comparativa `comparativas/ruta_10_piezas.png` |
| Barraca valenciana, Palau Ducal dels Borja y barca de la Albufera (`tilesets/exterior/hecho_a_mano/barraca.png`, `palau_ducal_gandia.png`, `barca_albufera.png`, fuentes 92–94) | Monumento | Agente 5 (Levante) | integrado | Propio | ⏳ | La barraca sirve para toda la huerta valenciana. Comparativa `comparativas/ruta_9_piezas.png` |
| Monumentos de Valencia: Micalet y catedral, Lonja de la Seda, Mercado Central, Torres de Serranos (se pasa por la puerta), Hemisfèric, Museu de les Ciències y Palau de les Arts (`tilesets/exterior/hecho_a_mano/`) | Monumento | Agente único | integrado | Propio | ⏳ | Comparativa `comparativas/valencia_monumentos.png` |
| Akuarela Playa y palmera (`tilesets/exterior/hecho_a_mano/akuarela.png`, `palmera.png`) | Monumento | Agente único | integrado | Propio | ⏳ | La palmera sirve para todas las costas. Comparativa `comparativas/valencia_malvarrosa_mapa.png` |
| Árbol de Navidad de la Porta do Sol y el Sireno (`tilesets/exterior/hecho_a_mano/arbol_navidad_vigo.png`, `sireno_vigo.png`, fuentes 250 y 251) | Monumento | Agente 2 | integrado | Propio | ⏳ | El árbol se monta en julio. Comparativa `comparativas/vigo_monumentos.png` |
| Muralla de Dalt Vila, catedral de Ibiza, casa ibicenca y club (`tilesets/exterior/hecho_a_mano/`) | Monumento | Agente único | integrado | Propio | ⏳ | La casa encalada sirve para los pueblos blancos. Cada lienzo de muralla lleva su portal. Comparativa `comparativas/ibiza_mapa.png` |
| Es Vedrà (`tilesets/exterior/hecho_a_mano/es_vedra.png`) | Monumento | Agente único | integrado | Propio | ⏳ | Comparativa `comparativas/maritima_1_mapa.png` |
| La Seu y el Castillo de Bellver (`tilesets/exterior/hecho_a_mano/catedral_palma.png`, `castillo_bellver.png`) | Monumento | Agente único | integrado | Propio | ⏳ | Comparativa `comparativas/palma_mapa.png` |
| Monumento a Colón, Boqueria, Catedral de Barcelona y ferry (`tilesets/exterior/hecho_a_mano/`) | Monumento | Agente único | integrado | Propio | ⏳ | El ferry sirve para todas las líneas. Comparativa `comparativas/barcelona_ciutat_vella_mapa.png` |
| Sagrada Família, Casa Batlló y La Pedrera (`tilesets/exterior/hecho_a_mano/`) | Monumento | Agente único | integrado | Propio | ⏳ | Comparativa `comparativas/barcelona_eixample_mapa.png` |
| Spotify Camp Nou en obras y grúa torre (`tilesets/exterior/hecho_a_mano/camp_nou.png`, `grua.png`) | Monumento | Agente único | integrado | Propio | ⏳ | Gradas azulgrana con asientos vacíos, la tercera grada sin acabar y el letrero. Comparativa `comparativas/barcelona_les_corts_mapa.png` |
| Agujas y Monasterio de Montserrat (`tilesets/exterior/hecho_a_mano/agujas_montserrat.png`, `monasterio_montserrat.png`) | Monumento | Agente único | integrado | Propio | ⏳ | Comparativa `comparativas/ruta_8_mapa.png` |
| Escenario del festival de Los Monegros (`tilesets/exterior/hecho_a_mano/escenario_festival.png`) | Objeto del mapa | Agente único | integrado | Propio | ⏳ | Comparativa `comparativas/ruta_7_mapa.png` |
| Monumentos de Zaragoza: Basílica del Pilar, La Seo y el tablero del Puente de Piedra (va debajo de los personajes) (`tilesets/exterior/hecho_a_mano/`) | Monumento | Agente único | integrado | Propio | ⏳ | Comparativa `comparativas/zaragoza_mapa.png`. Los leones del puente son provisionalmente los del Congreso |
| Hitos de la Ruta 6: arco romano de Medinaceli (se pasa por los vanos) y torre mudéjar (`tilesets/exterior/hecho_a_mano/`) | Monumento | Agente único | integrado | Propio | ⏳ | Comparativa `comparativas/ruta_6_mapa.png`. La torre vale para Aragón |
| Hitos de la Ruta 5: nave logística, Universidad de Alcalá y Palacio del Infantado (`tilesets/exterior/hecho_a_mano/`) | Monumento | Agente único | integrado | Propio | ⏳ | Comparativa `comparativas/ruta_5_mapa.png` |
| Monumentos del Retiro y el Prado: Cibeles, Palacio de Cibeles, Puerta de Alcalá (se pasa por los arcos), Congreso y sus leones, Museo del Prado, Neptuno, estación de Atocha, monumento a Alfonso XII y Palacio de Cristal (`tilesets/exterior/hecho_a_mano/`) | Monumento | Agente único | integrado | Propio | ⏳ | Comparativa `comparativas/madrid_monumentos_retiro.png` |
| Monumentos del Palacio Real: fachada sur del Palacio Real, Catedral de la Almudena, Teatro Real, Felipe IV a caballo, estatua de rey y tramo de verja (`tilesets/exterior/hecho_a_mano/`) | Monumento | Agente único | integrado | Propio | ⏳ | Comparativa `comparativas/madrid_monumentos_palacio.png` |
| Monumentos del centro de Madrid: Real Casa de Correos (con el reloj), el Oso y el Madroño, Casa de la Panadería, soportales de la Plaza Mayor (con y sin arco de paso), Mercado de San Miguel, Edificio Metrópolis y Edificio Carrión con el cartel de Schweppes (`tilesets/exterior/hecho_a_mano/`) | Monumento | Agente único | integrado | Propio | ⏳ | Comparativa `comparativas/madrid_monumentos_centro.png`. Carlos III y Felipe III siguen siendo el busto provisional del pack 01 |
| Monumentos de Moncloa: Arco de la Victoria, Templo de Debod y su puerta, Faro de Moncloa (`tilesets/exterior/hecho_a_mano/`, fuentes en `assets/_fuentes/mundo/`) | Monumento | Agente único | integrado | Propio | ⏳ | Bajo el arco y la puerta se pasa (solo choca la base). Comparativa `comparativas/madrid_monumentos_moncloa.png` |
| Monasterio de El Escorial (`tilesets/exterior/hecho_a_mano/monasterio_escorial.png`, fuente `assets/_fuentes/mundo/monasterio_escorial.px2`) | Monumento | Agente único | integrado | Propio | ⏳ | Fachada de poniente (16×8 casillas): granito con ventanas en cuadrícula, tejados de pizarra, torres con chapiteles, portada con San Lorenzo y la cúpula entre los campanarios. Comparativa `comparativas/ruta_4_mapa.png` |
| Cruz y basílica del Valle de Cuelgamuros (`tilesets/exterior/hecho_a_mano/cruz_cuelgamuros.png`, `basilica_cuelgamuros.png`; fuentes en `assets/_fuentes/mundo/`) | Monumento | Agente único | integrado | Propio | ⏳ | La cruz de granito con los evangelistas (4×10 casillas) y la fachada con la exedra, la puerta de bronce y la Piedad (10×5). Comparativa `comparativas/ruta_3_mapa.png` |
| Acueducto de Segovia (`tilesets/exterior/hecho_a_mano/acueducto_segovia*.png`, fuentes `assets/_fuentes/mundo/acueducto_segovia*.px2`) | Monumento | Agente único | integrado | Propio | ⏳ | Dos tramos de 14×7 casillas que encajan (el central con la hornacina de la Virgen); solo chocan los pilares, se pasa por debajo de los arcos. Comparativa `comparativas/ruta_2_mapa.png` |
| La Alhambra vista de lejos, con la Torre de la Vela, Comares y los cipreses (`tilesets/exterior/hecho_a_mano/alhambra.png`) | Monumento | Agente 1 (tramo sur) | integrado | Propio | ⏳ | Comparativa `comparativas/ruta_12_mapa.png` |
| Olivo y Mezquita-Catedral de Córdoba (`tilesets/exterior/hecho_a_mano/olivo.png`, `mezquita.png`) | Monumento | Agente 1 (tramo sur) | integrado | Propio | ⏳ | El olivo solo choca por la base (se pasa por detrás de la copa) y vale para toda Andalucía. Comparativa `comparativas/ruta_13_mapa.png` |
| Giralda, Catedral de Sevilla, Setas, Puerta del León del Alcázar, Real Maestranza y Puente de Triana (`tilesets/exterior/hecho_a_mano/`) | Monumento | Agente 1 (tramo sur) | integrado | Propio | ⏳ | El puente va debajo de los personajes (no choca). Comparativas `comparativas/tramo_sur_monumentos_1.png` y `_2.png` |
| Plaza de España de Sevilla (`tilesets/exterior/hecho_a_mano/plaza_espana.png`) | Monumento | Agente 1 (tramo sur) | integrado | Propio | ⏳ | De frente, sin la curva. Comparativa `comparativas/tramo_sur_monumentos_2.png` |
| Monumento a la Fe Descubridora y Muelle del Tinto, de Huelva (`tilesets/exterior/hecho_a_mano/`) | Monumento | Agente 1 (tramo sur) | integrado | Propio | ⏳ | El muelle va debajo de los personajes. Comparativas `comparativas/huelva_mapa.png` y `tramo_sur_monumentos_3.png` |
| Catedral de Santa Ana y Castillo de la Luz, de Las Palmas (`tilesets/exterior/hecho_a_mano/`) | Monumento | Agente 1 (tramo sur) | integrado | Propio | ⏳ | Comparativa `comparativas/tramo_sur_monumentos_3.png` |
| Terminal del Aeropuerto de Gran Canaria y mostrador de facturación (`tilesets/exterior/hecho_a_mano/`) | Monumento | Agente 1 (tramo sur) | integrado | Propio | ⏳ | Comparativa `comparativas/playa_del_ingles_mapa.png` |
| Portada de la pantalla de título (`sprites/ui/title/portada.png`) con el barrido de la imagen, el brillo del logo y la entrada animada de los botones | UI | Agente 1 | integrado | Imagen de Javier | ⏳ | Comparativas `comparativas/portada_titulo.png` y `portada_menu.png` |
| Iglesia de San Miguel Arcángel y ermita de la Virgen del Río (`tilesets/exterior/hecho_a_mano/`, fuentes `assets/_fuentes/mundo/*.px2`) | Edificio | Agente único | integrado | Propio (ningún pack trae iglesias) | ⏳ | Románico de Segovia: torre con campanas y cigüeña, teja árabe y galería porticada; la ermita, neorrománica con espadaña, óculo y arquivoltas. Se exportan a ×2 con `exportar_mundo.gd`. La iglesia queda algo pequeña al lado de las casas de DPPt (ver la comparativa) |
| Símbolo del dinero `₽` (`assets/fonts/pokedolar/`, fuentes `assets/_fuentes/fuentes/pokedolar*.px`) | Glifo de fuente | A3 | integrado | Propio | ⏳ | *Truth and Ideals* no lo trae (petición 11). Una P con dos barras en el palo, con el trazo de 1 px y la altura de las mayúsculas de cada fuente (6×10 la normal, 4×7 la pequeña). Va como fuente de respaldo del Theme, así que sale en cualquier texto con `₽` |

| 2026-10-05 | A1 | Flujo provisional RandomLocke y zona/mote con Theme/Dialogue existentes | `comparativas/randomlocke_flujo.md` | Pendiente revisión; A3 sustituye pantallas |

| 2026-10-05 | A1 | Carga segura: origen preservado ante mapa inválido, arte de ruta A4 existente | `comparativas/robustez_carga.md` | Comprobado; no altera pintura |

## Interfaz de la sesión 2026-10-07 (A3)

| Pantallas | Estado | Comparativa | Aprobado por Javier |
| --- | --- | --- | --- |
| Opciones/controles, PC, Pokédex, tarjeta, dobles/mecánicas, accesibilidad y repaso general | Integradas; sprites y marcos existentes | [76 capturas e informe](comparativas/a3_repaso_interfaz.md) | pendiente |
| Detalles de ficha, MT en mochila, recordador/tutor | MT y detalle integrados; recordador/tutor pendientes de ubicación/catálogo/precio del mundo | [Movimientos](comparativas/repaso_2026-10-07/a3_summary_moves.png), [recordador](comparativas/repaso_2026-10-07/a3_recordador.png), [tutor](comparativas/repaso_2026-10-07/a3_tutor.png) | pendiente |
| Guardería/eclosión | Presentación revisada; guardado de servicio/huevos pendiente A2 | [Comparativa](comparativas/a3_guarderia_eclosion.md) | pendiente |
| Mapa regional y ocho medallas | Bloqueados por datos/diseño/arte (pregunta 30) | [Destino disponible](comparativas/a3_pc_dex_tarjeta_mapa.md) | pendiente |

El repaso conserva las aprobaciones parciales anteriores; estas capturas no convierten los nuevos assets o pantallas en arte final aprobado.

| Ruta 21 · Viñedos de La Rioja y cepa propia | Exterior provisional, fuente 350; plano OSM y alcance | [Comparativa](comparativas/ruta_21.md) | pendiente Javier |
| Ruta 22 · Burgos y Atapuerca, catedral propia | Exterior y fuente 351 provisionales; sin entrega de fósiles | [Comparativa](comparativas/ruta_22.md) | pendiente Javier |
| Valladolid · Plaza Mayor, Campo Grande y Pisuerga | Exterior provisional, fuentes 352–356; cuatro locales; adaptaciones arquitectónicas pendientes de revisión | [Comparativa](comparativas/valladolid.md) | pendiente Javier |

| Mundo centro: Ruta 23 y acceso San Miguel | Castillo fuente 357; puente existente | PROVISIONAL, pendiente Javier | `comparativas/ruta_23.md` |

| Mundo centro: Getafe | Fuentes 358–359; cancha y edificios compuestos | PROVISIONAL, pendiente Javier | `comparativas/getafe.md` |

| Mundo centro: Leganés | Fuentes 360–361; Butarque y cuartel compuestos | PROVISIONAL, pendiente Javier | `comparativas/leganes.md` |
| Mundo centro: Móstoles | Fuentes 362/365; El Soto y campus compuestos | PROVISIONAL, pendiente Javier | `comparativas/mostoles.md` |

| Menú de pruebas F9 | Sesión independiente, editor y juego continuo; recursos/UI existentes | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/a3_menu_pruebas.md) |
| Animación de estadísticas | Partícula original EBDX, dirección y rótulo; reducción accesible | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/a3_menu_pruebas.md) |

| Mundo centro: Ruta 24 · La Mancha | Molino manual fuente 366, llanura y dos conjuntos comprimidos | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/ruta_24.md) |

| Mundo centro: Puertollano | Fuentes manuales 367–369, paseo y parque minero, cuatro locales | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/puertollano.md) |

| Mundo centro: Ruta 25 · Despeñaperros | Curvas, riscos y presa con recursos existentes; Los Órganos sin pieza específica | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/ruta_25.md) |

| Mundo centro: Ruta 26 · Torcal/Antequera | Caliza y entrada manuales 373–374, túmulo y pasos entre bases | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/ruta_26.md) |

| Mundo centro: Málaga | Catedral adaptada 371, cubo manual 372, puerto y patrimonio compuesto | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/malaga.md) |

| Interiores de Málaga: hospital, Mercadona y estanco | Akizakura16, recortes nativos; fachadas genéricas y servicios reales | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/malaga_locales.md) |

| Madrid: hospital, Mercadona y estanco | Interior Akizakura16 y fachada urbana del pack con rótulo | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/madrid_locales.md) |

| Barcelona: hospital, Mercadona y estanco | Interior Akizakura16 y fachada urbana del pack con rótulo | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/barcelona_locales.md) |

| Valencia: hospital, Mercadona y estanco | Interior Akizakura16 y fachada urbana del pack con rótulo | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/valencia_locales.md) |

| Sevilla: hospital, Mercadona y estanco | Interior Akizakura16 y fachada urbana del pack con rótulo | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/sevilla_locales.md) |

| Las Palmas: hospital, Mercadona y estanco | Interior Akizakura16 y fachada urbana del pack con rótulo | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/las_palmas_locales.md) |

| Valladolid: hospital, Mercadona y estanco | Interior Akizakura16 y fachada urbana del pack con rótulo | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/valladolid_locales.md) |

| Getafe: Centro Pokémon, Mercadona y estanco | Interior Akizakura16, fachadas existentes y servicios reales | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/getafe_locales.md) |

| Leganés: Centro Pokémon, Mercadona y estanco | Interior Akizakura16, fachadas existentes y servicios reales | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/leganes_locales.md) |

| Móstoles: Centro Pokémon, Mercadona y estanco | Interior Akizakura16, fachadas existentes y servicios reales | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/mostoles_locales.md) |

| Puertollano: Centro Pokémon, Mercadona y estanco | Interior Akizakura16, fachadas existentes y servicios reales | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/puertollano_locales.md) |

| Mapa interactivo F9 | Plano documental y controles de depuración | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/a3_mapa_f9.md) |
| Mapa F9 con toda la región (A4, 2026-10-15) | Plano `mapa_region.svg` regenerado, puntos de todas las ciudades, pueblos, barrios, rutas y transportes, recuadro de Madrid, búsqueda y filtro | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/a4_mapa_region.md) |
| Mapa regional del juego (A4, 2026-10-15) | Menú de pausa: plano `mapa_region.svg` (base aprobada) con cursor, ficha del lugar y vuelo | PROVISIONAL, pendiente Javier (arte definitivo) | [Comparativa](comparativas/a4_mapa_region.md) |
| Calle de la Victoria (A4, 2026-10-15) | Túnel del Metro y cloacas con el tileset de interiores existente; bocas de metro (pieza `boca_metro`) en Sol y en el Palacio Real | PROVISIONAL, pendiente Javier (pack definitivo) | [Comparativa](comparativas/a4_calle_victoria.md) |
| Falcon aparcado (A4, 2026-10-15) | Pieza `falcon` dibujada a mano (`assets/_fuentes/mundo/falcon.px2`, fuente 383) en Playa del Inglés y en Peinador, con su cartel | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/a4_falcon.md) |
| 28 interiores adicionales / 13 exteriores | Akizakura16 y personajes existentes, puertas/rótulos | PROVISIONAL, pendiente Javier | [Trece comparativas](../mundo/auditoria_locales.md) |

| Repaso Getafe/Ruta 24 y casa visitable | Recursos originales y mobiliario/interacciones | PROVISIONAL, pendiente Javier | [Antes/después](comparativas/a3_densidad_getafe_ruta24.md) |

| Seis ataques por fases y selector F9 de habilidades/sets | EBDX/NikDie a escala nativa y controles existentes | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/a3_fases_y_habilidades.md) |

| Compatibilidad de regalos de las casas ampliadas | Interiores existentes y entrega real de objetos | PROVISIONAL, pendiente Javier | [ROM anterior/actual](comparativas/a3_casas_recompensas.md) |

| Ocho ataques adicionales y vista de repetición F9 | Recursos EBDX/NikDie del pack 17, recorte nativo de ola y controles existentes | PROVISIONAL, pendiente Javier | [Antes/después y acceso](comparativas/a3_ocho_y_vista_animaciones.md) |

| Ocho movimientos por índice de WikiDex | Impactos, puños, monedas, corte y tornado de EBDX/NikDie; originales a escala nativa | PROVISIONAL, pendiente Javier | [Comparativa](comparativas/a3_movimientos_por_indice.md) |

## Protagonistas de Spain · sesión del 14 de octubre

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|---|---|---|---|---|---|---|
| `characters/protagonistas/cayetano.png` | Frente, espalda y mapa | A | integrado, provisional | Diseño a partir de la referencia de Javier | ⏳ | Polo azul, jersey crema, pantalón beige; Pozuelo; comparativa `a_inicio_personajes.md` |
| `characters/protagonistas/cani.png` | Frente, espalda y mapa | A | integrado, provisional | Diseño a partir de la referencia de Javier | ⏳ | Chándal negro/rojo; Orcasitas; misma comparativa |
| `characters/protagonistas/cayetana.png` | Frente, espalda y mapa | A | integrado, provisional | Diseño a partir de la referencia de Javier | ⏳ | Chaqueta beige, diadema, bolso; Pozuelo; misma comparativa |
| `characters/protagonistas/choni.png` | Frente, espalda y mapa | A | integrado, provisional | Diseño a partir de la referencia de Javier | ⏳ | Coleta, chaqueta rosa, aros; Orcasitas; misma comparativa |
| Elección de personaje | Interfaz | A | integrado, provisional | Panel y controles existentes | ⏳ | Selección previa a nueva partida, cancelar seguro; `a_inicio_*.png` |

Los PNG nuevos se conservan intactos; se muestran por regiones registradas y filtro nearest. En mapa se presentan a 56 px de alto; frente y espalda encajan proporcionalmente en la interfaz. Las variantes específicas de bici/surf/pesca siguen pendientes de estos cuatro diseños; siguen usando las hojas anteriores del pack. Los protagonistas anteriores siguen disponibles para las partidas migradas sin identidad nueva.

| Oferta de iniciales por partida | Interfaz de intro | A | integrado, provisional | Iconos del pack 06 existentes | ⏳ | `a_iniciales_aleatorios.md`; el profesor se sustituye en la tarea 3 |

## Profesor Unicoos · sesión del 14 de octubre

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|---|---|---|---|---|---|---|
| `trainers/unicoos.png` | Retrato de intro | A | integrado, provisional | Diseño según foto de Javier | ⏳ | `a_unicoos.md`; gafas, canas, polo azul |
| `characters/unicoos_mapa.png` | Personaje de mapa | A | integrado, provisional | Diseño según foto de Javier | ⏳ | Chibi idle, marca `profesor` del laboratorio de B |
| Intro y recepción en Moncloa | Interfaz/guion | A | integrado, provisional | Recursos nuevos y panel existente | ⏳ | Oferta, tutorial y regalos sin repetir |

## Pokédex nacional · sesión del 14 de octubre

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|---|---|---|---|---|---|---|
| Lista nacional de 1.025 especies | Interfaz | A | integrado, provisional | Panel e iconos existentes | ⏳ | Dos folios reales en `a_pokedex_nacional.md`; entradas ocultas hasta verse |
| Asignaciones de skins | Sprite Pokémon | A | pendiente | PENDIENTE JAVIER | ⏳ | Base de datos y resolver listos; ninguna especie asignada |

## Dificultad y RandomLocke · sesión del 14 de octubre

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|---|---|---|---|---|---|---|
| Selección de dificultad y Caramelo Raro ∞ | Interfaz | A | integrado, provisional | Panel e icono existentes | ⏳ | `a_randomlocke_dificultad.md`; capturas reales |

## Personajes con referencia fotográfica · entrega 1

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|---|---|---|---|---|---|---|
| `characters/famosos_atlas/rajoy.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; referencias en `personajes_fotograficos.md` | ⏳ | Comparativa `personajes_entrega_1.md`; original conservado |
| `characters/famosos_atlas/puigdemont.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; referencias en `personajes_fotograficos.md` | ⏳ | Comparativa `personajes_entrega_1.md`; original conservado |
| `characters/famosos_atlas/zapatero.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; referencias en `personajes_fotograficos.md` | ⏳ | Comparativa `personajes_entrega_1.md`; original conservado |
| `characters/famosos_atlas/rufian.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; referencias en `personajes_fotograficos.md` | ⏳ | Comparativa `personajes_entrega_1.md`; original conservado |
| `characters/famosos_atlas/almeida.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; referencias en `personajes_fotograficos.md` | ⏳ | Comparativa `personajes_entrega_1.md`; original conservado |
| `characters/famosos_atlas/trump.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; referencias en `personajes_fotograficos.md` | ⏳ | Comparativa `personajes_entrega_1.md`; original conservado |
| `characters/famosos_atlas/maduro.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; referencias en `personajes_fotograficos.md` | ⏳ | Comparativa `personajes_entrega_1.md`; original conservado |
| Galería de personajes | Interfaz debug | A | integrado, provisional | Paneles existentes | ⏳ | F9 → Galerías; caminar en cuatro direcciones |

## Personajes con referencia fotográfica · entrega 2

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|---|---|---|---|---|---|---|
| `characters/famosos_atlas/mbappe.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño según referencia de Javier | ⏳ | `personajes_entrega_2.md`; PNG intacto |
| `characters/famosos_atlas/vinicius.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño según referencia de Javier | ⏳ | `personajes_entrega_2.md`; PNG intacto |
| `characters/famosos_atlas/sekiam.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño según referencia de Javier | ⏳ | `personajes_entrega_2.md`; PNG intacto |
| `characters/famosos_atlas/pokealex.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño según referencia de Javier | ⏳ | `personajes_entrega_2.md`; PNG intacto |
| `characters/famosos_atlas/paache.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño según referencia de Javier | ⏳ | `personajes_entrega_2.md`; PNG intacto |
| `characters/famosos_atlas/el_jincho.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño según referencia de Javier | ⏳ | `personajes_entrega_2.md`; PNG intacto |

## Líderes · entrega 3

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|---|---|---|---|---|---|---|
| `characters/famosos_atlas/ayuso.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; fuente en `personajes_fotograficos.md` | ⏳ | `personajes_entrega_3.md` |
| `characters/famosos_atlas/laporta.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; fuente en `personajes_fotograficos.md` | ⏳ | `personajes_entrega_3.md` |
| `characters/famosos_atlas/labrador.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; fuente en `personajes_fotograficos.md` | ⏳ | `personajes_entrega_3.md` |
| `characters/famosos_atlas/joaquin.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; fuente en `personajes_fotograficos.md` | ⏳ | `personajes_entrega_3.md` |
| `characters/famosos_atlas/quevedo.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; fuente en `personajes_fotograficos.md` | ⏳ | `personajes_entrega_3.md` |
| `characters/famosos_atlas/latasa.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; fuente en `personajes_fotograficos.md` | ⏳ | `personajes_entrega_3.md` |
| `characters/famosos_atlas/banderas.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; fuente en `personajes_fotograficos.md` | ⏳ | `personajes_entrega_3.md` |
| `characters/famosos_atlas/aupa_athletic.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo; fuente en `personajes_fotograficos.md` | ⏳ | `personajes_entrega_3.md` |

## Alto Mando · entrega 4

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|---|---|---|---|---|---|---|
| `characters/famosos_atlas/iniesta.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo con referencia documentada | ⏳ | Equipación española y bandera como capa; `personajes_entrega_4.md` |
| `characters/famosos_atlas/nadal.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo con referencia documentada | ⏳ | Equipación española y bandera como capa; `personajes_entrega_4.md` |
| `characters/famosos_atlas/gasol.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo con referencia documentada | ⏳ | Equipación española y bandera como capa; `personajes_entrega_4.md` |
| `characters/famosos_atlas/alonso.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño nuevo con referencia documentada | ⏳ | Equipación española y bandera como capa; `personajes_entrega_4.md` |

## Clan PSOE · entrega 5

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|---|---|---|---|---|---|---|
| `characters/famosos_atlas/pedro_sanchez.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño según foto oficial | ⏳ | `personaje_pedro_sanchez.png`; traje azul, Líder Supremo |
| `characters/famosos_atlas/abalos.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño con referencia documentada | ⏳ | `personajes_entrega_5.md` |
| `characters/famosos_atlas/koldo.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño con referencia documentada | ⏳ | `personajes_entrega_5.md` |
| `characters/famosos_atlas/leire_diez.png` | Combate y 16 poses de mapa | A | integrado, provisional | Diseño con referencia documentada | ⏳ | `personajes_entrega_5.md` |
| Entrada de combate en pareja | Interfaz | A | integrado, provisional | Retratos existentes y panel EBDX | ⏳ | Ambos retratos, movimiento y salida conjunta |

## Famosos · entrega 6

| Asset | Tipo | Responsable | Estado | Fuente | Javier | Notas |
|---|---|---|---|---|---|---|
| `characters/famosos_atlas/ibai.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_6.md` |
| `characters/famosos_atlas/elxokas.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_6.md` |
| `characters/famosos_atlas/rosalia.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_6.md` |
| `characters/famosos_atlas/lamine.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_6.md` |
| `characters/famosos_atlas/hustlehard304.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_6.md` |
| `characters/famosos_atlas/keyne.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_6.md` |
| `characters/famosos_atlas/enrique_iglesias.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_6.md` |
| `characters/famosos_atlas/julio_iglesias.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_6.md` |

## Famosos · entrega 7

| Asset | Tipo | Responsable | Estado | Fuente | Javier | Notas |
|---|---|---|---|---|---|---|
| `characters/famosos_atlas/sarah_santaolalla.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_7.md` |
| `characters/famosos_atlas/sergio_ramos.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_7.md` |
| `characters/famosos_atlas/guardiola.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_7.md` |
| `characters/famosos_atlas/pique.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_7.md` |
| `characters/famosos_atlas/aitana.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_7.md` |
| `characters/famosos_atlas/ester_exposito.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_7.md` |
| `characters/famosos_atlas/folagor.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_7.md` |
| `characters/famosos_atlas/pereira7.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_7.md` |

## Famosos · entrega 8

| Asset | Tipo | Responsable | Estado | Fuente | Javier | Notas |
|---|---|---|---|---|---|---|
| `characters/famosos_atlas/amancio_ortega.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_8.md` |
| `characters/famosos_atlas/abascal.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_8.md` |
| `characters/famosos_atlas/topuria.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_8.md` |
| `characters/famosos_atlas/nico_williams.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_8.md` |
| `characters/famosos_atlas/inaki_williams.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_8.md` |
| `characters/famosos_atlas/broncano.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_8.md` |
| `characters/famosos_atlas/oscar_puente.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_8.md` |
| `characters/famosos_atlas/mario_casas.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_8.md` |

## Famosos · entrega 9

| Asset | Tipo | Responsable | Estado | Fuente | Javier | Notas |
|---|---|---|---|---|---|---|
| `characters/famosos_atlas/pablo_iglesias.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_9.md` |
| `characters/famosos_atlas/irene_montero.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_9.md` |
| `characters/famosos_atlas/franco.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_9.md` |
| `characters/famosos_atlas/chicote.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_9.md` |
| `characters/famosos_atlas/pedroche.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_9.md` |
| `characters/famosos_atlas/rubiales.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_9.md` |
| `characters/famosos_atlas/jenni_hermoso.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_9.md` |
| `characters/famosos_atlas/jorge_javier.png` | Combate y 16 poses de mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_9.md` |

## Famosos · entrega 10

| Asset | Tipo | Responsable | Estado | Fuente | Javier | Notas |
|---|---|---|---|---|---|---|
| Felipe VI (`characters/famosos_atlas/felipe_vi.png`) | Personaje | Agente A; cierre del Agente 5 | integrado | Foto documentada | ⏳ | Retrato y dieciséis poses. Comparativa `comparativas/personaje_felipe_vi.png` |
| Juan Carlos I (`characters/famosos_atlas/juan_carlos.png`) | Personaje | Agente A; cierre del Agente 5 | integrado | Foto documentada | ⏳ | Retrato y dieciséis poses. Comparativa `comparativas/personaje_juan_carlos.png` |
| Vito Quiles (`characters/famosos_atlas/vito_quiles.png`) | Personaje | Agente A; cierre del Agente 5 | integrado | Foto documentada | ⏳ | Retrato y dieciséis poses. Comparativa `comparativas/personaje_vito_quiles.png` |
| Bertrand Ndongo (`characters/famosos_atlas/bertrand_ndongo.png`) | Personaje | Agente A; cierre del Agente 5 | integrado | Foto documentada | ⏳ | Retrato y dieciséis poses. Comparativa `comparativas/personaje_bertrand_ndongo.png` |
| Belén Esteban (`characters/famosos_atlas/belen_esteban.png`) | Personaje | Agente A; cierre del Agente 5 | integrado | Foto documentada | ⏳ | Retrato y dieciséis poses. Comparativa `comparativas/personaje_belen_esteban.png` |
| Coto Matamoros (`characters/famosos_atlas/coto_matamoros.png`) | Personaje | Agente A; cierre del Agente 5 | integrado | Foto documentada | ⏳ | Retrato y dieciséis poses. Comparativa `comparativas/personaje_coto_matamoros.png` |
| Ferran Torres (`characters/famosos_atlas/ferran_torres.png`) | Personaje | Agente A; cierre del Agente 5 | integrado | Foto documentada | ⏳ | Retrato y dieciséis poses. Comparativa `comparativas/personaje_ferran_torres.png` |
| Juan Roig (`characters/famosos_atlas/juan_roig.png`) | Personaje | Agente A; cierre del Agente 5 | integrado | Foto documentada | ⏳ | Retrato y dieciséis poses. Comparativa `comparativas/personaje_juan_roig.png` |
| Melendi (`characters/famosos_atlas/melendi.png`) | Personaje | Agente A; cierre del Agente 5 | integrado | Foto de Javier; versión joven | ⏳ | Retrato y dieciséis poses. Comparativa `comparativas/personaje_melendi.png` |
| Vegetta777 (`characters/famosos_atlas/vegeta.png`) | Personaje | Agente A; cierre del Agente 5 | integrado | Foto documentada | ⏳ | Retrato y dieciséis poses. Comparativa `comparativas/personaje_vegeta.png` |
| Willyrex (`characters/famosos_atlas/willyrex.png`) | Personaje | Agente A; cierre del Agente 5 | integrado | Foto documentada | ⏳ | Retrato y dieciséis poses. Comparativa `comparativas/personaje_willyrex.png` |

## Interiores · 2026-10-14

| Asset | Tipo | Responsable | Estado | Fuente | Javier | Notas |
|---|---|---|---|---|---|---|
| 153 interiores de edificios (Alicante, Murcia, Pozuelo, Orcasitas, Bernabéu y casas de las rutas) y servicios de Alicante y Murcia | Mapa | Agente 5 | integrado | Tileset de interiores (Akizakura16) | ⏳ | Generados por tema; provisionales. Rótulo con el nombre del edificio |
| Salas de los ocho gimnasios (32 mapas, `maps/<ciudad>/gimnasio_*.tscn`) | Mapa | Agente 5 | integrado | Tileset de interiores (Akizakura16) | ⏳ | Zigzag con vigilantes; personajes con sprite provisional. Comparativas `comparativas/gimnasio_*.png` |
| Gimnasio 1 por dentro: Registro, Salón de Plenos, Archivo de Títulos, Despacho de la Presidenta y terraza del ático (`maps/madrid/gimnasio_*.tscn`, `maps/madrid/atico_ayuso.tscn`) | Mapa | Agente 3 | integrado | Tileset de los gimnasios (Akizakura16 y nueve piezas a mano, fuentes 20–28; `docs/arte/gimnasios.md`) | ⏳ | Plano a mano por sala, vigilantes que se apartan, rótulo en placa. [Antes y después](comparativas/gimnasios_2026-10-15.md). PROVISIONAL, pendiente de Javier |
| Gimnasio 2 por dentro: Vestuario, Sala de Palancas, Palco y Despacho del President (`maps/barcelona/gimnasio_*.tscn`) | Mapa | Agente 3 | integrado | Tileset de los gimnasios (Akizakura16 y diez piezas a mano, fuentes 29–38) | ⏳ | Taquillas, vallas de obra, palancas, butacas azulgranas, escudo y copas. [Antes y después](comparativas/gimnasios_2026-10-15.md). PROVISIONAL, pendiente de Javier |
| Gimnasio 3 por dentro: Pista, Reservado, Zona VIP y Cabina (`maps/valencia/gimnasio_*.tscn`) | Mapa | Agente 3 | integrado | Tileset de los gimnasios (Akizakura16 y ocho piezas a mano, fuentes 39–46) | ⏳ | Pista de luces, altavoces, bolas de espejos, cabina del DJ, piscina y tumbonas. [Antes y después](comparativas/gimnasios_2026-10-15.md). PROVISIONAL, pendiente de Javier |
| Gimnasio 4 por dentro: Platea, Camerinos, Entre Bambalinas y Escenario (`maps/sevilla/gimnasio_*.tscn`) | Mapa | Agente 3 | integrado | Tileset de los gimnasios (Akizakura16 y nueve piezas a mano, fuentes 47–55) | ⏳ | Butacas de teatro, espejos de camerino, trajes de flamenca, focos, micro y borde del escenario. [Antes y después](comparativas/gimnasios_2026-10-15.md). PROVISIONAL, pendiente de Javier |
| Gimnasio 5 por dentro: Pista, Zona VIP, Backstage y Escenario (`maps/playa_del_ingles/gimnasio_*.tscn`) | Mapa | Agente 3 | integrado | Tileset de los gimnasios (Akizakura16 y seis piezas a mano, fuentes 56–61) | ⏳ | Vallas de concierto, sombrillas, tablas de surf, neveras, batería y escenario. Falta la fachada del exterior. [Antes y después](comparativas/gimnasios_2026-10-15.md). PROVISIONAL, pendiente de Javier |
| Gimnasio 6 por dentro: Grada de Animación, Vestuario, Túnel y Césped (`maps/bilbao/gimnasio_*.tscn`) | Mapa | Agente 3 | integrado | Tileset de los gimnasios (Akizakura16 y seis piezas a mano, fuentes 62–67) | ⏳ | Butacas y taquillas rojiblancas, escudo, césped a franjas y portería. [Antes y después](comparativas/gimnasios_2026-10-15.md). PROVISIONAL, pendiente de Javier |
| Gimnasio 7 por dentro: Soportales, Salón de Plenos, Palco del Zorrilla y Balcón del Ayuntamiento (`maps/valladolid/gimnasio_*.tscn`) | Mapa | Agente 3 | integrado | Tileset de los gimnasios (Akizakura16 y cinco piezas a mano, fuentes 68–72; reutiliza escaños, atril, bandera, retrato y butacas) | ⏳ | Columnatas, lámparas de araña, barandilla dorada y estufa. [Antes y después](comparativas/gimnasios_2026-10-15.md). PROVISIONAL, pendiente de Javier |
| Gimnasio 8 por dentro: Catering, Camerinos, Maquillaje y Plató (`maps/malaga/gimnasio_*.tscn`) | Mapa | Agente 3 | integrado | Tileset de los gimnasios (Akizakura16 y cinco piezas a mano, fuentes 73–77; reutiliza focos, espejos, burros y cajas) | ⏳ | Cámaras de cine, silla de director, claqueta, café y decorado. Falta la fachada del exterior. [Antes y después](comparativas/gimnasios_2026-10-15.md). PROVISIONAL, pendiente de Javier |


## Revisión de personajes · 2026-10-14

| Asset | Tipo | Responsable | Estado | Fuente | Javier | Notas |
|---|---|---|---|---|---|---|
| `characters/famosos_atlas/aitana.png` | Combate y 16 poses | A | revisado, provisional | Foto de Javier | ⏳ | `personajes_revision_2026-10-14.md` |
| `characters/famosos_atlas/belen_esteban.png` | Combate y 16 poses | A | revisado, provisional | Foto de Javier | ⏳ | `personajes_revision_2026-10-14.md` |
| `characters/famosos_atlas/bertrand_ndongo.png` | Combate y 16 poses | A | revisado, provisional | Foto de Javier | ⏳ | `personajes_revision_2026-10-14.md` |
| `characters/famosos_atlas/broncano.png` | Combate y 16 poses | A | revisado, provisional | Foto de Javier | ⏳ | `personajes_revision_2026-10-14.md` |
| `characters/famosos_atlas/ester_exposito.png` | Combate y 16 poses | A | revisado, provisional | Foto de Javier | ⏳ | `personajes_revision_2026-10-14.md` |
| `characters/famosos_atlas/ferran_torres.png` | Combate y 16 poses | A | revisado, provisional | Foto de Javier | ⏳ | `personajes_revision_2026-10-14.md` |
| `characters/famosos_atlas/folagor.png` | Combate y 16 poses | A | revisado, provisional | Foto de Javier | ⏳ | `personajes_revision_2026-10-14.md` |
| `characters/famosos_atlas/hustlehard304.png` | Combate y 16 poses | A | revisado, provisional | Foto de Javier | ⏳ | `personajes_revision_2026-10-14.md` |
| `characters/famosos_atlas/oscar_puente.png` | Combate y 16 poses | A | revisado, provisional | Foto de Javier | ⏳ | `personajes_revision_2026-10-14.md` |
| `characters/famosos_atlas/pedroche.png` | Combate y 16 poses | A | revisado, provisional | Foto de Javier | ⏳ | `personajes_revision_2026-10-14.md` |
| `characters/famosos_atlas/pereira7.png` | Combate y 16 poses | A | revisado, provisional | Foto de Javier | ⏳ | `personajes_revision_2026-10-14.md` |
| `characters/famosos_atlas/quevedo.png` | Combate y 16 poses | A | revisado, provisional | Foto de Javier | ⏳ | `personajes_revision_2026-10-14.md` |


## Personajes nuevos · entrega 11

| Asset | Tipo | Responsable | Estado | Fuente | Javier | Notas |
|---|---|---|---|---|---|---|
| `characters/famosos_atlas/pablo_motos.png` | Combate y 16 poses | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_11.md` |
| `characters/famosos_atlas/omar_montes.png` | Combate y 16 poses | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_11.md` |
| `characters/famosos_atlas/zona_gemelos_carlos.png` | Combate y 16 poses | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_11.md` |
| `characters/famosos_atlas/zona_gemelos_dani.png` | Combate y 16 poses | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_11.md` |
| `characters/famosos_atlas/churumbel.png` | Combate y 16 poses | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_11.md` |
| `characters/famosos_atlas/joan_pradells.png` | Combate y 16 poses | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_11.md` |
| `characters/famosos_atlas/jc_reyes.png` | Combate y 16 poses | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_11.md` |
| `characters/famosos_atlas/marc_cucurella.png` | Combate y 16 poses | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_11.md` |
| `characters/famosos_atlas/david_bisbal.png` | Combate y 16 poses | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_11.md` |
| `characters/famosos_atlas/mente_fria.png` | Combate y 16 poses | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_11.md` |
| `characters/famosos_atlas/amador_rivas.png` | Combate y 16 poses | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_11.md` |
| `characters/famosos_atlas/antonio_recio.png` | Combate y 16 poses | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_11.md` |


## Pueblos y ciudades · detalle urbano del 14 de octubre

| Asset | Tipo | Responsable | Estado | Fuente | Javier | Notas |
|---|---|---|---|---|---|---|
| 33 mapas urbanos: viviendas, paseos, mobiliario y vecinos | Mundo | A | integrado, provisional | Packs de exteriores existentes | ⏳ | 62 viviendas, 962 adornos/arbolado, 99 vecinos. Comparativa `tejido_urbano_2026-10-14.md` |
| 89 casas antes incompletas, en ciudades, rutas y muestras | Mundo | A | integrado, provisional | Piezas completas del pack DPPt | ⏳ | La puerta queda en la misma casilla; colores de algunas casas cambiados. Capturas antes/después |
| 62 interiores nuevos | Interiores | A | integrado, provisional | Método de interiores existente, Akizakura16 | ⏳ | Mobiliario, dos vecinos y entrada/regreso. Una captura por interior en la comparativa |


## Personajes · entrega 12 · gimnasios

| Asset | Tipo | Responsable | Estado | Fuente | Javier | Notas |
|---|---|---|---|---|---|---|
| `casado` | Combate y mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_12.md`; dieciséis poses |
| `messi` | Combate y mapa | A | integrado, provisional | Pokémon Iberia V2.10 | ⏳ | `personajes_entrega_12.md`; cuatro poses quietas |
| `julian_alvarez` | Combate y mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_12.md`; dieciséis poses |
| `peter_lim` | Combate y mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_12.md`; dieciséis poses |
| `antony` | Combate y mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_12.md`; dieciséis poses |
| `jose_mota` | Combate y mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_12.md`; dieciséis poses |
| `buenafuente` | Combate y mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_12.md`; dieciséis poses |
| `berto_romero` | Combate y mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_12.md`; dieciséis poses |
| `dani_rovira` | Combate y mapa | A | integrado, provisional | Foto documentada | ⏳ | `personajes_entrega_12.md`; dieciséis poses |

## Gimnasios · Entrega 13

| Personaje | Recurso | Revisión | Estado |
| --- | --- | --- | --- |
| La Pantera (`la_pantera`) | Atlas: combate y 16 poses de mapa | [Comparativa](comparativas/personajes_entrega_13.md) | Provisional, pendiente de Javier |
| Lucho RK (`lucho_rk`) | Atlas: combate y 16 poses de mapa | [Comparativa](comparativas/personajes_entrega_13.md) | Provisional, pendiente de Javier |
| Cruz Cafuné (`cruz_cafune`) | Atlas: combate y 16 poses de mapa | [Comparativa](comparativas/personajes_entrega_13.md) | Provisional, pendiente de Javier |
| Arnaldo Otegi (`otegi`) | Atlas: combate y 16 poses de mapa | [Comparativa](comparativas/personajes_entrega_13.md) | Provisional, pendiente de Javier |
| Ronaldo Nazário (`ronaldo_nazario`) | Atlas: combate y 16 poses de mapa | [Comparativa](comparativas/personajes_entrega_13.md) | Provisional, pendiente de Javier |
| Torrente (`torrente`) | Atlas: combate y 16 poses de mapa | [Comparativa](comparativas/personajes_entrega_13.md) | Provisional, pendiente de Javier |
| Penélope Cruz (`penelope_cruz`) | Atlas: combate y 16 poses de mapa | [Comparativa](comparativas/personajes_entrega_13.md) | Provisional, pendiente de Javier |
| Javier Bardem (`javier_bardem`) | Atlas: combate y 16 poses de mapa | [Comparativa](comparativas/personajes_entrega_13.md) | Provisional, pendiente de Javier |
| Abuela de Lamine (`abuela_lamine`) | Atlas: combate y 16 poses de mapa | [Comparativa](comparativas/personajes_entrega_13.md) | Provisional, pendiente de Javier |

## Clases de gimnasios · Entrega 14

| Clase | Recurso | Revisión | Estado |
| --- | --- | --- | --- |
| Concejal del PP (`concejal`) | Retrato y 16 frames de mapa | [Entrega 14](comparativas/personajes_entrega_14.md) | Provisional, pendiente de Javier |
| Culé (`cule`) | Retrato y 16 frames de mapa | [Entrega 14](comparativas/personajes_entrega_14.md) | Provisional, pendiente de Javier |
| Alcohólico (`alcoholico`) | Retrato y 16 frames de mapa | [Entrega 14](comparativas/personajes_entrega_14.md) | Provisional, pendiente de Javier |
| Porreta (`porreta`) | Retrato y 16 frames de mapa | [Entrega 14](comparativas/personajes_entrega_14.md) | Provisional, pendiente de Javier |
| Cocainómano (`cocainomano`) | Retrato y 16 frames de mapa | [Entrega 14](comparativas/personajes_entrega_14.md) | Provisional, pendiente de Javier |
| Flamenco de traje (`flamenco_traje`) | Retrato y 16 frames de mapa | [Entrega 14](comparativas/personajes_entrega_14.md) | Provisional, pendiente de Javier |
| Quesito en bikini (`quesito`) | Retrato y 16 frames de mapa | [Entrega 14](comparativas/personajes_entrega_14.md) | Provisional, pendiente de Javier |
| Etarra (`etarra`) | Retrato y 16 frames de mapa | [Entrega 14](comparativas/personajes_entrega_14.md) | Provisional, pendiente de Javier |
| Cayetano de pelo casco (`cayetano_casco`) | Retrato y 16 frames de mapa | [Entrega 14](comparativas/personajes_entrega_14.md) | Provisional, pendiente de Javier |
| Actor de reparto (`actor_reparto`) | Retrato y 16 frames de mapa | [Entrega 14](comparativas/personajes_entrega_14.md) | Provisional, pendiente de Javier |

## Personajes en su sitio · Agente 2 (2026-10-15)

| Asset | Tipo | Comparativa | Estado |
|---|---|---|---|
| Coche de la Policía Nacional (`assets/_fuentes/mundo/coche_policia.px2` → `characters/coche_policia.png`) | Propio, dibujado a mano con la paleta (detención de Ábalos y Koldo) | [Personajes 2026-10-15](comparativas/personajes_2026-10-15.md) | Integrado, provisional, pendiente de Javier |
| Policía (`characters/policia.png`) | Pack 05, PurpleZaffre, sin tocar | [Personajes 2026-10-15](comparativas/personajes_2026-10-15.md) | Integrado, pendiente de Javier |
| Joyas de Zapatero (`items/joyas_zapatero.png`) | Real Brazal del Generation 9 Pack, sin tocar | [Personajes 2026-10-15](comparativas/personajes_2026-10-15.md) | Integrado, pendiente de Javier |
| Hojas del pack 11 de 19 clases nuevas (`trainers/` y `characters/`: omar_montes, pablo_motos, zona_gemelos_carlos, zona_gemelos_dani, amador_rivas, antonio_recio, mente_fria, marc_cucurella, joan_pradells, david_bisbal, jc_reyes, puigdemont, rufian, zapatero, maduro, trump, paache, churumbel, javier) | Pack 11 montado con `build_trainers.gd`; en el juego sale el atlas del personaje, salvo Javier | [Personajes 2026-10-15](comparativas/personajes_2026-10-15.md) | Integrado, provisional; Javier: PENDIENTE JAVIER (su aspecto) |
| Mapas nuevos: piso de Rufián (salón y habitación) y cárcel de Soto del Real (exterior y módulo) | Tiles de los packs; muebles y carteles provisionales | [Personajes 2026-10-15](comparativas/personajes_2026-10-15.md) | Integrado, provisional, pendiente de Javier |

## Interiores personalizados · 2026-10-15 (Agente 1)

| Asset | Tipo | Responsable | Estado | Fuente | Javier | Notas |
|---|---|---|---|---|---|---|
| Interiores de Ibiza (34 salas, `data/interiores/ibiza.json`) | Mapa | Agente 1 | integrado, provisional | Tileset de interiores (Akizakura16), catálogo `data/interiores/_piezas.json` | ⏳ | Casas ibicencas con recibidor y dormitorio, catedral, club con barra, socorrismo, casa payesa y farmacia. [Comparativa](comparativas/interiores_2026-10-15.md) |
| Interiores de Madrid (88 salas, `data/interiores/madrid.json`) | Mapa | Agente 1 | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | Gran Vía, Sol, Moncloa, Chamberí, Retiro, Palacio y Bernabéu; salas nuevas en Debod, Cibeles, Congreso, Prado, Teatro Real y Almudena. [Comparativa](comparativas/interiores_2026-10-15.md) |
| Interiores de Barcelona (63 salas, `data/interiores/barcelona.json`) | Mapa | Agente 1 | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | Ciutat Vella, Eixample y Les Corts; salas de dentro en la catedral (claustro), La Pedrera (vivienda), Casa Batlló (planta noble y azotea) y Sagrada Familia (cripta). [Comparativa](comparativas/interiores_2026-10-15.md) |
| Interiores de Valencia (36 salas, `data/interiores/valencia.json`) | Mapa | Agente 1 | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | Ciutat Vella y Malvarrosa; salas de dentro en la Lonja (Consulado del Mar), la catedral (campanas del Micalet) y el Mercado Central (pescadería). [Comparativa](comparativas/interiores_2026-10-15.md) |


## Ciudades y rutas al nivel de Añil (Agente 5, 2026-10-15)

Exteriores rehechos sin repintarlos con `maps/_tools/vestir_exterior.gd` y una receta por mapa (`maps/_pintura/vestir/`): se conservan puertas, pasarelas, apariciones, conexiones y personajes colocados. Siguiendo la [guía de composición](../mundo/guia_composicion_anil_2026-10-15.md), primero la estructura (límites continuos, pasos de 2 a 4 casillas y un **paso obligado por hierba** de lado a lado entre las conexiones, que comprueba la propia herramienta) y después el detalle. Mapa completo a escala 0,5 y vista real de 512×384 en el paso de hierba. Todo **provisional**, pendiente de Javier.

| Mapa | Antes | Después | 512×384 | Hierba mínima entre bordes | Qué cambia | Estado |
|------|-------|---------|---------|----------------------------|------------|--------|
| Ruta 16 · Rías Baixas | [antes](comparativas/ruta_16_antes.png) | [después](comparativas/ruta_16_despues.png) | [paso](comparativas/ruta_16_512.png) | 3 (antes 0) | Camino de 3 (antes 6 de ancho), playa con rocas, paso de hierba de la ría al monte, monte con meseta y escalera, prado con bordillo, viñedo de albariño, jardín, estanque, barcas y bosque; 2 entrenadores, 1 vecina y 3 objetos (2 ocultos) | Provisional, pendiente de Javier |
| Ruta 5 · Corredor del Henares | [antes](comparativas/ruta_5_antes.png) | [después](comparativas/ruta_5_despues.png) | [paso](comparativas/ruta_5_512.png) | 2 (antes 0) | Cerro con escalera, pinar al norte, farolas en la A-2, obras con desvío por la hierba junto al Infantado, polígono vallado, plaza de Cervantes con banco y flores, paseo del Henares con juncos y pescador; 2 entrenadores y 3 objetos | Provisional, pendiente de Javier |
| Ruta 6 · Medinaceli y Calatayud | [antes](comparativas/ruta_6_antes.png) | [después](comparativas/ruta_6_despues.png) | [paso](comparativas/ruta_6_512.png) | 4 (antes 0) | Calle empedrada, fuente y banco en Medinaceli, pinar de Soria, muela con escalera, descampado de hierba en Calatayud, campos arados, chopos y camino del Jalón; 1 entrenadora, 1 vecino y 3 objetos | Provisional, pendiente de Javier |
| Ruta 7 · Los Monegros | [antes](comparativas/ruta_7_antes.png) | [después](comparativas/ruta_7_despues.png) | [paso](comparativas/ruta_7_512.png) | 3 (antes 0) | Laguna de Sariñena con juncos, cerros y mesas de yeso (con escalera los visitables), matorral obligado entre dos mesas, roquedo y madera seca, público, luces y barra del festival; 1 entrenador, 3 vecinos y 3 objetos | Provisional, pendiente de Javier |
| Ruta 8 · Montserrat | [antes](comparativas/ruta_8_antes.png) | [después](comparativas/ruta_8_despues.png) | [paso](comparativas/ruta_8_512.png) | 2 (antes 0) | Pinar y roquedo en las laderas, meseta con hierba alta, explanada con cipreses, flores y bancos, collado de hierba al este del macizo, bordillos, viñas del Bages, frutales; 1 entrenadora, 1 vecina y 3 objetos | Provisional, pendiente de Javier |
| Ruta 26 · El Torcal | [antes](comparativas/rutas_anil_2026-10-19/ruta_26_antes.png) | [después](comparativas/rutas_anil_2026-10-19/ruta_26_despues.png) | [paso](comparativas/rutas_anil_2026-10-19/ruta_26_512.png) | 4 (antes 0) | Borrador del 15 aplicado y validado (2026-10-19): laberinto de bloques de caliza (mesetas) con piedras apiladas, pasillos de 2 a 4 casillas, paso obligado por hierba en el pasillo del oeste, claro de hierba alta y mirador al este con entrada desde la explanada del dolmen, prado y encinas al bajar a Málaga; se conservan dolmen, casa del guarda, carteles, guía y escaladora. 1 entrenador (`ruta26_guarda`) y 3 objetos (2 ocultos) | Provisional, pendiente de Javier. Las cimas de los bloques quedan lisas |
| Ruta 21 · Viñedos de La Rioja | [antes](comparativas/rutas_anil_2026-10-19/ruta_21_antes.png) | [después](comparativas/rutas_anil_2026-10-19/ruta_21_despues.png) | [paso](comparativas/rutas_anil_2026-10-19/ruta_21_512.png) | 4 (antes 0) | Bosque continuo en los bordes, juncos en el Ebro, cepas junto a las bodegas, cerro de San Vicente con escalera, hierba alta y banco-mirador, terrazas de viña con bordillo, camino que serpentea (antes recto de 4), paso obligado por hierba al salir del pueblo y viñedos vallados hasta Burgos; 3 objetos (2 ocultos) | Provisional, pendiente de Javier |
| Ruta 22 · Burgos y Atapuerca | [antes](comparativas/rutas_anil_2026-10-19/ruta_22_antes.png) | [después](comparativas/rutas_anil_2026-10-19/ruta_22_despues.png) | [paso](comparativas/rutas_anil_2026-10-19/ruta_22_512.png) | 4 (antes 0) | Pinares a la entrada, farolas, bancos y flores en la plaza de Burgos, juncos en las dos orillas del Arlanzón, prado del sur con chopos, charca con nenúfar, camino con recodo y paso obligado por hierba de lado a lado; Ultra Ball en los yacimientos de Atapuerca y 2 objetos ocultos | Provisional, pendiente de Javier |
| Ruta 24 · La Mancha | [antes](comparativas/rutas_anil_2026-10-19/ruta_24_antes.png) | [después](comparativas/rutas_anil_2026-10-19/ruta_24_despues.png) | [paso](comparativas/rutas_anil_2026-10-19/ruta_24_512.png) | 2 (antes 0) | Paso obligado por hierba a la salida de Getafe (de la loma de los molinos al borde del este), campos vallados, olivares y encinas en hileras en lugar de bosque cerrado, flores de campo; 3 objetos (2 ocultos) | Provisional, pendiente de Javier. La llanura sigue muy abierta: sin relieve nuevo ni agua |
| Ruta 25 · Despeñaperros | [antes](comparativas/rutas_anil_2026-10-19/ruta_25_antes.png) | [después](comparativas/rutas_anil_2026-10-19/ruta_25_despues.png) | [paso](comparativas/rutas_anil_2026-10-19/ruta_25_512.png) | 2 (antes 0) | Paso obligado por hierba en lo más estrecho de la garganta, pinares y encinas cerrando las laderas, roquedo y flores en lo alto de los Órganos, juncos en el embalse y piedras sueltas; 3 objetos (2 ocultos) | Provisional, pendiente de Javier |
| Ruta 11 · Palmeral de Elche | [antes](comparativas/rutas_anil_2026-10-19/ruta_11_antes.png) | [después](comparativas/rutas_anil_2026-10-19/ruta_11_despues.png) | [paso](comparativas/rutas_anil_2026-10-19/ruta_11_512.png) | 2 (antes 0) | Paso obligado por hierba donde el camino del huerto cruza la carretera, tapias del huerto al norte y al sur de la balsa, huertos vallados, palmeras en lugar de bosque y flores; 3 objetos (2 ocultos) | Provisional, pendiente de Javier. La carretera sigue siendo una franja de 4 de lado a lado |
| Ruta 15 · Costa de Gran Canaria | [antes](comparativas/rutas_anil_2026-10-19/ruta_15_antes.png) | [después](comparativas/rutas_anil_2026-10-19/ruta_15_despues.png) | [paso](comparativas/rutas_anil_2026-10-19/ruta_15_512.png) | 2 (antes 0) | Paso obligado por hierba de la ladera del barranco a la playa, palmeras y roquedo volcánico en lugar de bosque, piedras en la arena y flores; 3 objetos (2 ocultos) | Provisional, pendiente de Javier |
| Ruta 9 · La Albufera y la huerta | [antes](comparativas/rutas_anil_2026-10-19/ruta_9_antes.png) | [después](comparativas/rutas_anil_2026-10-19/ruta_9_despues.png) | [paso](comparativas/rutas_anil_2026-10-19/ruta_9_512.png) | 1 (antes 0) | Paso obligado por hierba de la Albufera a la arena del Saler (la avenida se corta por las obras del carril bici, con su cartel), juncos y barcas en la Albufera, pinada y arboleda lejos de la avenida; 3 objetos (2 ocultos) | Provisional, pendiente de Javier. La avenida empedrada sigue siendo recta |
| Ruta 10 · Costa Blanca | [antes](comparativas/rutas_anil_2026-10-19/ruta_10_antes.png) | [después](comparativas/rutas_anil_2026-10-19/ruta_10_despues.png) | [paso](comparativas/rutas_anil_2026-10-19/ruta_10_512.png) | 1 (antes 0) | Paso obligado por hierba al salir del paseo hacia Alicante, del pinar a la arena; palmeras y pinos sueltos, flores; 3 objetos (2 ocultos) | Provisional, pendiente de Javier. El paseo empedrado sigue muy ancho |
| Ruta 13 · Olivares del Guadalquivir | [antes](comparativas/rutas_anil_2026-10-19/ruta_13_antes.png) | [después](comparativas/rutas_anil_2026-10-19/ruta_13_despues.png) | [paso](comparativas/rutas_anil_2026-10-19/ruta_13_512.png) | 2 (antes 0) | Paso obligado por hierba entre dos hileras de olivos, del bosque del norte al río; juncos en la orilla del Guadalquivir y flores en la vega; 3 objetos (2 ocultos) | Provisional, pendiente de Javier. El noroeste sigue abierto |

## Recuperación del cierre del 15 de octubre

| Recurso | Área | Responsable | Estado | Procedencia | Aprobación Javier | Comparativa |
|---|---|---|---|---|---|---|
| 59 interiores de Sevilla | Mapa | Agente 1, cierre de sesión | recuperados, provisionales | Akizakura16 | ⏳ | [Antes/después](comparativas/interiores_2026-10-15.md#sevilla--cierre-del-trabajo-interrumpido) |
| Entrada del Palacio y cinco salas de Liga | Mapa | Agente 2, cierre de sesión | conexión cerrada, provisional | Tileset de interiores | ⏳ | [Comparativa](comparativas/cierre_2026-10-15.md) |

## Edificios reales · 20 de octubre de 2026

| Recurso | Estado | Aprobación Javier | Evidencia |
|---|---|---|---|
| Casa de Ruta 2, casa roja de Bilbao y faro de Ruta 19 | colocaciones corregidas, recurso del pack intacto | pendiente | [Tres comparativas y contrato de puertas](comparativas/edificios_reales.md#bloque-1--piezas-recortadas-20-de-octubre) |
| 137 fuentes propias | inventariadas con usos, dimensiones, puertas y captura previa; redibujo individual en curso | pendiente | [Lista completa y motivos](comparativas/edificios_reales.md#inventario-individual-de-fuentes-propias) |

## Interiores personalizados · 20 de octubre de 2026

| Recurso | Área | Responsable | Estado | Procedencia | Aprobación Javier | Comparativa |
|---|---|---|---|---|---|---|
| Interiores de Zaragoza (24 salas, `data/interiores/zaragoza.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Palma (18 salas, `data/interiores/palma.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Alicante (24 salas, `data/interiores/alicante.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Murcia (23 salas, `data/interiores/murcia.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Málaga (20 salas, `data/interiores/malaga.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Las Palmas (27 salas, `data/interiores/las_palmas.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Playa del Inglés (8 salas, `data/interiores/playa_del_ingles.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Vigo (12 salas, `data/interiores/vigo.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Huelva (9 salas, `data/interiores/huelva.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Valladolid (15 salas, `data/interiores/valladolid.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Puertollano (20 salas, `data/interiores/puertollano.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Getafe (16 salas, `data/interiores/getafe.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Leganés (15 salas, `data/interiores/leganes.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Móstoles (19 salas, `data/interiores/mostoles.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Santander (13 salas, `data/interiores/santander.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Bilbao (14 salas, `data/interiores/bilbao.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Pamplona (10 salas, `data/interiores/pamplona.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Rocafonda (3 salas, `data/interiores/rocafonda.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de San Miguel de Bernuy (14 salas, `data/interiores/pueblo_inicial.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Pozuelo (7 salas, `data/interiores/pozuelo.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Orcasitas (4 salas, `data/interiores/orcasitas.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Ruta 5 (7 salas, `data/interiores/ruta_5.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Ruta 6 (7 salas, `data/interiores/ruta_6.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Ruta 8 (5 salas, `data/interiores/ruta_8.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Ruta 16 (2 salas, `data/interiores/ruta_16.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Ruta 26 (2 salas, `data/interiores/ruta_26.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Ruta 21 (4 salas, `data/interiores/ruta_21.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Ruta 22 (5 salas, `data/interiores/ruta_22.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Ruta 24 (12 salas, `data/interiores/ruta_24.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Interiores de Ruta 25 (2 salas, `data/interiores/ruta_25.json`) | Mapa | Interiores (Agente 1) | integrado, provisional | Tileset de interiores (Akizakura16) | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
| Gente de los 74 locales de servicio | Mapa | Interiores (Agente 1) | integrado, provisional | Textos propios | ⏳ | [Capturas](comparativas/interiores_2026-10-20.md) |
