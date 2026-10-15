# Cobertura de personajes

> Lo genera `tests/mundo/test_cobertura_personajes.gd` (no se edita a mano). Para cada entrenador de `data/trainers/*.json`: sprite del mapa, retrato de combate y dónde sale. Las explicaciones de lo que falta están en `data/personajes_en_el_mapa.json` (`pendientes`, `por_evento`, `sprites_prestados` y `arte_sin_uso`). Los sitios de los famosos son **propuesta**: los decide Javier.

**Resumen:** 361 entrenadores · 361 con sprite de mapa propio · 361 con retrato de combate propio · 361 colocados · 0 pendientes con motivo · 1 personajes sin combate.

- **atlas `id`**: el diseño propio del personaje (`data/character_art.json`): retrato de combate y dieciséis poses de mapa. Si la clase del entrenador es la del personaje, el atlas sale por la clase.
- **hoja / retrato de la clase**: las piezas del pack 11 o el sprite del pack de su clase, con el nombre de la clase (los entrenadores genéricos de una misma clase comparten diseño, como en los juegos).
- **PRESTADO**: usa el sprite de otra clase. **FALTA**: no tiene.
- **Dónde**: `datos` = `data/personajes_en_el_mapa.json` (mapa y casilla); `sala` = sala de gimnasio; `pintado` = nodo del mapa; `evento` = lo lanza un evento.

## `liga.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Dúo del Clan Ábalos | `abalos` | atlas `abalos` | atlas `abalos` | madrid/moncloa (27, 40) | Ferraz, la sede del Clan PSOE |
| Dúo del Clan Ábalos | `abalos_albufera` | atlas `abalos` | atlas `abalos` | ruta_9/exterior (16, 27) | La Albufera (El Palmar), de «vacaciones»: segundo encuentro, con tres medallas (decisión de Javier) |
| Dúo del Clan Ábalos | `abalos_soto` | atlas `abalos` | atlas `abalos` | soto_del_real/carcel (7, 4) | La cárcel de Soto del Real, más adelante: con seis medallas y después de la Albufera (decisión de Javier) |
| Alto Mando Alonso | `alonso` | atlas `alonso` | atlas `alonso` | madrid/liga_alonso (8, 5) | Liga del Palacio Real, cuarta sala del Alto Mando |
| Líder Aupa Athletic | `aupa_athletic` | atlas `aupa_athletic` | atlas `aupa_athletic` | sala: bilbao/gimnasio_lider, pintado: bilbao/gimnasio_lider |  |
| Líder Ayuso | `ayuso` | atlas `ayuso` | atlas `ayuso` | madrid/atico_ayuso (8, 6), sala: madrid/gimnasio_lider | Líder del gimnasio 1: la terraza de su ático en Chamberí (se llega desde el hospital Quirón) |
| Líder Banderas | `banderas` | atlas `banderas` | atlas `banderas` | sala: malaga/gimnasio_lider, pintado: malaga/gimnasio_lider |  |
| Alto Mando Gasol | `gasol` | atlas `gasol` | atlas `gasol` | madrid/liga_gasol (8, 5) | Liga del Palacio Real, tercera sala del Alto Mando |
| Alto Mando Iniesta | `iniesta` | atlas `iniesta` | atlas `iniesta` | madrid/liga_iniesta (8, 5) | Liga del Palacio Real, primera sala del Alto Mando (decisión de Javier: la Liga, en el Palacio Real) |
| Líder Joaquín | `joaquin` | atlas `joaquin` | atlas `joaquin` | sala: sevilla/gimnasio_lider, pintado: sevilla/gimnasio_lider |  |
| Dúo del Clan Koldo | `koldo` | atlas `koldo` | atlas `koldo` | madrid/moncloa (29, 39) | Ferraz, con Ábalos y sus cajas |
| Dúo del Clan Koldo | `koldo_albufera` | atlas `koldo` | atlas `koldo` | ruta_9/exterior (16, 28) | La Albufera (El Palmar), con Ábalos y sus cajas de «arroz» (decisión de Javier) |
| Dúo del Clan Koldo | `koldo_soto` | atlas `koldo` | atlas `koldo` | soto_del_real/carcel (10, 4) | La cárcel de Soto del Real, con Ábalos (decisión de Javier) |
| Líder Labrador | `labrador` | atlas `labrador` | atlas `labrador` | sala: valencia/gimnasio_lider, pintado: valencia/gimnasio_lider |  |
| Líder Laporta | `laporta` | atlas `laporta` | atlas `laporta` | sala: barcelona/gimnasio_lider, pintado: barcelona/gimnasio_lider |  |
| Líder Latasa | `latasa` | atlas `latasa` | atlas `latasa` | sala: valladolid/gimnasio_lider, pintado: valladolid/gimnasio_lider |  |
| Fontanera del Clan Leire | `leire_diez` | atlas `leire_diez` | atlas `leire_diez` | madrid/retiro (13, 58) | Atocha, bajando a las cloacas |
| Alto Mando Nadal | `nadal` | atlas `nadal` | atlas `nadal` | madrid/liga_nadal (8, 5) | Liga del Palacio Real, segunda sala del Alto Mando |
| Líder Supremo Pedro Sánchez | `pedro_sanchez` | atlas `pedro_sanchez` | atlas `pedro_sanchez` | madrid/liga_sanchez (8, 5) | Liga del Palacio Real, el Salón de Columnas: el Líder Supremo, al final (decisión de Javier) |
| Líder Quevedo | `quevedo` | atlas `quevedo` | atlas `quevedo` | sala: playa_del_ingles/gimnasio_lider, pintado: playa_del_ingles/gimnasio_lider |  |
| Recluta del Clan Recluta | `recluta_clan` | hoja de la clase | retrato de la clase | madrid/moncloa (17, 15) | A las puertas de Moncloa |

## `famosos.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Político Abascal | `abascal` | atlas `abascal` | atlas `abascal` | madrid/retiro (4, 35) | Puerta del Congreso, a caballo |
| Político Abascal | `abascal_covadonga` | atlas `abascal` | atlas `abascal` | ruta_18/exterior (35, 26) | Covadonga, delante de la basílica: su segunda aparición (dos apariciones: decisión de Javier; el sitio, propuesta) |
| Cantante Aitana | `aitana` | atlas `aitana` | atlas `aitana` | barcelona/eixample (24, 52) | De gira (Palau Sant Jordi) |
| Alcalde Almeida | `almeida` | atlas `almeida` | atlas `almeida` | madrid/retiro (30, 15) | Ayuntamiento de Cibeles |
| Vecino Amador | `amador_rivas` | atlas `amador_rivas` | atlas `amador_rivas` | mostoles/exterior (35, 46) | Móstoles, de vecino en el Mirador de Montepinar. Propuesta |
| Empresario Amancio | `amancio_ortega` | atlas `amancio_ortega` | atlas `amancio_ortega` | ruta_17/exterior (38, 37) | Ruta 17, a la puerta de la nave de Inditex en Arteixo |
| Mayorista Antonio Recio | `antonio_recio` | atlas `antonio_recio` | atlas `antonio_recio` | mostoles/exterior (30, 43) | Móstoles, en una urbanización nueva: el Mirador de Montepinar de La que se avecina. Propuesta |
| Princesa del pueblo Belén | `belen_esteban` | atlas `belen_esteban` | atlas `belen_esteban` | madrid/moncloa (24, 15) | Plató de televisión, con Jorge Javier |
| Agitador Bertrand | `bertrand_ndongo` | atlas `bertrand_ndongo` | atlas `bertrand_ndongo` | madrid/retiro (10, 35) | Puerta del Congreso, con Vito Quiles |
| Presentador Broncano | `broncano` | atlas `broncano` | atlas `broncano` | madrid/centro (26, 25) | Gran Vía, a la puerta del Teatro Príncipe (La Revuelta) |
| Cocinero de las Campanadas Chicote | `chicote` | atlas `chicote` | atlas `chicote` | madrid/centro (43, 41) | Puerta del Sol, preparando las campanadas |
| Tiktoker El Churumbel | `churumbel` | atlas `churumbel` | atlas `churumbel` | malaga/exterior (29, 44) | Málaga, su ciudad, junto al mercado. Propuesta |
| Tertuliano Coto | `coto_matamoros` | atlas `coto_matamoros` | atlas `coto_matamoros` | malaga/exterior (88, 64) | El paseo marítimo |
| Cantante Bisbal | `david_bisbal` | atlas `david_bisbal` | atlas `david_bisbal` | ruta_12/exterior (64, 27) | Ruta 12, en la entrada desde Murcia: el camino de Almería, su tierra. Propuesta |
| Rapero El Jincho | `el_jincho` | atlas `el_jincho` | atlas `el_jincho` | pintado: madrid_rio/exterior |  |
| Streamer Elxokas | `elxokas` | atlas `elxokas` | atlas `elxokas` | ruta_17/exterior (38, 20) | Ruta 17, al pie de la muralla de Lugo |
| Cantante Enrique | `enrique_iglesias` | atlas `enrique_iglesias` | atlas `enrique_iglesias` | madrid/bernabeu (30, 20) | Concierto en el Bernabéu |
| Actriz Ester | `ester_exposito` | atlas `ester_exposito` | atlas `ester_exposito` | madrid/centro (31, 24) | Gran Vía, en el estreno de su película |
| Rey Felipe VI | `felipe_vi` | atlas `felipe_vi` | atlas `felipe_vi` | madrid/palacio_real (20, 35) | Palacio Real, después de ganar la Liga |
| Delantero Ferran | `ferran_torres` | atlas `ferran_torres` | atlas `ferran_torres` | valencia/turia (26, 32) | El jardín del Turia |
| Youtuber Pokémon Folagor | `folagor` | atlas `folagor` | atlas `folagor` | getafe/exterior (30, 10) | La tienda de cartas de Getafe |
| Fantasma Franco | `franco` | atlas `franco` | atlas `franco` | ruta_3/exterior (10, 67) | Valle de Cuelgamuros |
| Entrenador Pep | `guardiola` | atlas `guardiola` | atlas `guardiola` | ruta_8/exterior (15, 33) | Santpedor, su pueblo |
| Padre orgulloso HustleHard304 | `hustlehard304` | atlas `hustlehard304` | atlas `hustlehard304` | rocafonda/exterior (29, 15) | Rocafonda, a la puerta de la mansión de su hijo Lamine |
| Streamer Ibai | `ibai` | atlas `ibai` | atlas `ibai` | barcelona/les_corts (43, 32) | Kings League, junto a La Masia |
| Delantero Iñaki Williams | `inaki_williams` | atlas `inaki_williams` | atlas `inaki_williams` | bilbao/exterior (15, 24) | A la salida de San Mamés, con su hermano Nico. Propuesta |
| Exministra Irene | `irene_montero` | atlas `irene_montero` | atlas `irene_montero` | ruta_4/exterior (29, 33) | Su chalet de Galapagar |
| Creador Javier Saguar | `javier` | hoja de la clase | retrato de la clase | pueblo_inicial/exterior (38, 41) | San Miguel de Bernuy, delante de su casa, al volver por la Ruta 23 con siete medallas (decisión de Javier). Sustituye al vecino «Javier» del mapa |
| Rapero JC Reyes | `jc_reyes` | atlas `jc_reyes` | atlas `jc_reyes` | sevilla/centro (55, 30) | Sevilla, en el lado este del centro, camino de Palmete, su barrio. Propuesta |
| Campeona del mundo Jenni | `jenni_hermoso` | atlas `jenni_hermoso` | atlas `jenni_hermoso` | ruta_12/exterior (15, 18) | La boda en el cortijo de Granada |
| Culturista Joan Pradells | `joan_pradells` | atlas `joan_pradells` | atlas `joan_pradells` | valencia/malvarrosa (46, 13) | Playa de la Malvarrosa, entrenando al aire libre: es culturista y valenciano. Propuesta |
| Presentador Jorge Javier | `jorge_javier` | atlas `jorge_javier` | atlas `jorge_javier` | madrid/moncloa (22, 15) | Plató de televisión |
| Rey emérito Juan Carlos | `juan_carlos` | atlas `juan_carlos` | atlas `juan_carlos` | ruta_16/exterior (26, 26) | Las regatas de Sanxenxo |
| Presidente de Mercadona Juan Roig | `juan_roig` | atlas `juan_roig` | atlas `juan_roig` | valencia/ciutat_vella (7, 40) | Junto al Mercado Central |
| Cantante Julio | `julio_iglesias` | atlas `julio_iglesias` | atlas `julio_iglesias` | malaga/exterior (63, 68) | Su yate, en el Muelle Uno |
| Hermano pequeño Keyne | `keyne` | atlas `keyne` | atlas `keyne` | rocafonda/exterior (34, 15) | Rocafonda, con su hermano Lamine |
| Crack Lamine | `lamine` | atlas `lamine` | atlas `lamine` | rocafonda/exterior (31, 13) | Rocafonda (Mataró), a la puerta de su mansión |
| Presidente Maduro | `maduro` | atlas `maduro` | atlas `maduro` | las_palmas/canteras (42, 38) | Puerto de La Luz (Las Palmas), con Zapatero. Propuesta |
| Lateral Cucurella | `marc_cucurella` | atlas `marc_cucurella` | atlas `marc_cucurella` | rocafonda/exterior (27, 30) | Rocafonda (Maresme), en el campo de los niños: es de Alella, al lado. Propuesta |
| Actor Mario Casas | `mario_casas` | atlas `mario_casas` | atlas `mario_casas` | malaga/exterior (61, 62) | En el rodaje de Banderas |
| Dictador Mbappé | `mbappe` | atlas `mbappe` | atlas `mbappe` | madrid/bernabeu (22, 18) | Delante del Santiago Bernabéu, en modo dictador (decisión de Javier, 2026-10-14) |
| Cantante Melendi | `melendi` | atlas `melendi` | atlas `melendi` | ruta_18/exterior (22, 24) | Ruta 18, a la puerta de la sidrería |
| Vecino Mente Fría | `mente_fria` | atlas `mente_fria` | atlas `mente_fria` | mostoles/exterior (38, 46) | Móstoles, de vecino en el Mirador de Montepinar. Propuesta |
| Delantero Nico Williams | `nico_williams` | atlas `nico_williams` | atlas `nico_williams` | bilbao/exterior (12, 21) | A la salida de San Mamés, con la medalla 6: la revancha de Copa (dentro combaten por separado). Propuesta |
| Cantante Omar Montes | `omar_montes` | atlas `omar_montes` | atlas `omar_montes` | madrid_rio/exterior (7, 15) | Madrid Río, junto al Matadero, camino de Carabanchel (Pan Bendito, su barrio). Propuesta |
| Ministro de Transportes Óscar Puente | `oscar_puente` | atlas `oscar_puente` | atlas `oscar_puente` | valladolid/exterior (46, 32) | Camino de la estación de Valladolid |
| Streamer Paache | `paache` | atlas `paache` | atlas `paache` | ruta_17/exterior (14, 27) | Ruta 17 (Galicia interior), junto al hórreo. Que esté en Galicia es decisión de Javier; el sitio exacto, propuesta |
| Exvicepresidente Pablo | `pablo_iglesias` | atlas `pablo_iglesias` | atlas `pablo_iglesias` | ruta_4/exterior (28, 35) | Su chalet de Galapagar |
| Presentador Pablo Motos | `pablo_motos` | atlas `pablo_motos` | atlas `pablo_motos` | madrid/centro (33, 25) | Gran Vía, enfrente de La Revuelta de Broncano: la guerra de audiencias. Propuesta |
| Presentadora de las Campanadas Pedroche | `pedroche` | atlas `pedroche` | atlas `pedroche` | madrid/centro (47, 42) | Puerta del Sol, con el vestido de las campanadas |
| Streamer Pereira7 | `pereira7` | atlas `pereira7` | atlas `pereira7` | vigo/exterior (30, 30) | Una cafetería de Vigo |
| Empresario Piqué | `pique` | atlas `pique` | atlas `pique` | barcelona/les_corts (47, 32) | Kings League, con Ibai |
| Jugador de VGC PokeAlex | `pokealex` | atlas `pokealex` | atlas `pokealex` | getafe/exterior (36, 10) | La tienda de cartas, con Folagor |
| Expresident Puigdemont | `puigdemont` | atlas `puigdemont` | atlas `puigdemont` | barcelona/ciutat_vella (18, 49) | Port Vell, junto a la terminal de ferris: listo para fugarse otra vez. Propuesta |
| Motomami Rosalía | `rosalia` | atlas `rosalia` | atlas `rosalia` | ruta_8/exterior (54, 31) | Sant Esteve Sesrovires, su pueblo |
| Invitado de la boda Rubiales | `rubiales` | atlas `rubiales` | atlas `rubiales` | ruta_12/exterior (14, 19) | La boda en el cortijo de Granada |
| Diputado Rufián | `rufian` | atlas `rufian` | atlas `rufian` | barcelona/casa_rufian (5, 5) | Su piso del Eixample (Barcelona), con su habitación al fondo (decisión de Javier). Se sube por el portal 10_31 |
| Tertuliana Sarah | `sarah_santaolalla` | atlas `sarah_santaolalla` | atlas `sarah_santaolalla` | valladolid/exterior (26, 20) | Tertulia de radio, Valladolid |
| Youtuber Pokémon Sekiam | `sekiam` | atlas `sekiam` | atlas `sekiam` | getafe/exterior (33, 10) | La tienda de cartas, con Folagor |
| Defensa Sergio Ramos | `sergio_ramos` | atlas `sergio_ramos` | atlas `sergio_ramos` | sevilla/rio (44, 17) | Junto a la Maestranza |
| Campeón de UFC Topuria | `topuria` | atlas `topuria` | atlas `topuria` | alicante/exterior (6, 22) | Alicante, a la puerta del club de artes marciales donde creció |
| Presidente Trump | `trump` | atlas `trump` | atlas `trump` | playa_del_ingles/exterior (17, 9) | Aeropuerto de Gran Canaria: llega a por Maduro (sale después de ganar a Zapatero y Maduro). Propuesta |
| Youtuber Vegeta | `vegeta` | atlas `vegeta` | atlas `vegeta` | zaragoza/exterior (49, 13) | Salida hacia la Puerta de los Pirineos (camino de Andorra) |
| Futbolista Vinicius Jr. | `vinicius` | atlas `vinicius` | atlas `vinicius` | madrid/bernabeu (18, 18) | Delante del Santiago Bernabéu (decisión de Javier, 2026-10-14) |
| Agitador Vito | `vito_quiles` | atlas `vito_quiles` | atlas `vito_quiles` | madrid/retiro (8, 35) | Puerta del Congreso, micrófono en mano |
| Agitador Vito | `vito_quiles_elche` | atlas `vito_quiles` | atlas `vito_quiles` | ruta_11/exterior (52, 17) | Palmeral de Elche, su ciudad: la revancha (decisión de Javier) |
| Agitador Vito | `vito_quiles_rufian` | atlas `vito_quiles` | atlas `vito_quiles` | barcelona/habitacion_rufian (11, 5) | La habitación de Rufián, escondido junto al armario (decisión de Javier) |
| Youtuber Willyrex | `willyrex` | atlas `willyrex` | atlas `willyrex` | zaragoza/exterior (49, 14) | Con Vegeta, camino de Andorra |
| Expresidente Zapatero | `zapatero` | atlas `zapatero` | atlas `zapatero` | las_palmas/canteras (40, 37) | Puerto de La Luz (Las Palmas), con Maduro: Venezuela es «la octava isla» de Canarias. Propuesta |
| Gemelo Carlos | `zona_gemelos_carlos` | atlas `zona_gemelos_carlos` | atlas `zona_gemelos_carlos` | getafe/exterior (36, 52) | Getafe, su ciudad, a la puerta de la nave donde graban La Casa de los Gemelos. Propuesta |
| Gemelo Dani | `zona_gemelos_dani` | atlas `zona_gemelos_dani` | atlas `zona_gemelos_dani` | getafe/exterior (38, 51) | Getafe, con su gemelo Carlos. Propuesta |

## `gimnasios.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Alcalde Almeida | `almeida_gym` | atlas `almeida` | atlas `almeida` | sala: madrid/gimnasio_1, pintado: madrid/gimnasio_1 |  |
| Extremo Antony | `antony` | atlas `antony` | atlas `antony` | sala: sevilla/gimnasio_1, pintado: sevilla/gimnasio_1 |  |
| Cómico Berto Romero | `berto_romero` | atlas `berto_romero` | atlas `berto_romero` | sala: sevilla/gimnasio_2, pintado: sevilla/gimnasio_2 |  |
| Presentador Buenafuente | `buenafuente` | atlas `buenafuente` | atlas `buenafuente` | pintado: sevilla/gimnasio_lider |  |
| Máster Pablo Casado | `casado` | atlas `casado` | atlas `casado` | sala: madrid/gimnasio_3, pintado: madrid/gimnasio_3 |  |
| Rapero Cruz Cafuné | `cruz_cafune` | atlas `cruz_cafune` | atlas `cruz_cafune` | sala: playa_del_ingles/gimnasio_3, pintado: playa_del_ingles/gimnasio_3 |  |
| Monologuista Dani Rovira | `dani_rovira` | atlas `dani_rovira` | atlas `dani_rovira` | sala: sevilla/gimnasio_3, pintado: sevilla/gimnasio_3 |  |
| Actriz Ester Expósito | `ester_exposito_gym` | atlas `ester_exposito` | atlas `ester_exposito` | sala: malaga/gimnasio_2, pintado: malaga/gimnasio_2 |  |
| Camarero sin propina Paco | `gym1_camarero` | hoja de la clase | retrato de la clase | madrid/centro (36, 36) | Entrenador del gimnasio 1 |
| Concejal Borja Mari | `gym1_concejal_1` | atlas `concejal` | atlas `concejal` | sala: madrid/gimnasio_1, pintado: madrid/gimnasio_1 |  |
| Concejal Pelayo | `gym1_concejal_2` | atlas `concejal` | atlas `concejal` | sala: madrid/gimnasio_1, pintado: madrid/gimnasio_1 |  |
| Concejal Jacobo | `gym1_concejal_3` | atlas `concejal` | atlas `concejal` | sala: madrid/gimnasio_2, pintado: madrid/gimnasio_2 |  |
| Concejal Gonzalo | `gym1_concejal_4` | atlas `concejal` | atlas `concejal` | sala: madrid/gimnasio_2, pintado: madrid/gimnasio_2 |  |
| Concejal Álvaro | `gym1_concejal_5` | atlas `concejal` | atlas `concejal` | sala: madrid/gimnasio_3, pintado: madrid/gimnasio_3 |  |
| Concejal Íñigo | `gym1_concejal_6` | atlas `concejal` | atlas `concejal` | sala: madrid/gimnasio_3, pintado: madrid/gimnasio_3 |  |
| Influencer de LinkedIn Cayetana | `gym1_influencer` | hoja de la clase | retrato de la clase | madrid/centro (40, 34) | Entrenador del gimnasio 1 |
| Padre con la tarjeta del súper Borja | `gym1_padretarjeta` | hoja de la clase | retrato de la clase | madrid/centro (31, 35) | Entrenador del gimnasio 1 |
| Carterista Pau | `gym2_carterista` | hoja de la clase | retrato de la clase | barcelona/les_corts (27, 46) | Entrenador del gimnasio 2 |
| Culé Jordi | `gym2_cule_1` | atlas `cule` | atlas `cule` | sala: barcelona/gimnasio_1, pintado: barcelona/gimnasio_1 |  |
| Culé Pau | `gym2_cule_2` | atlas `cule` | atlas `cule` | sala: barcelona/gimnasio_1, pintado: barcelona/gimnasio_1 |  |
| Culé Arnau | `gym2_cule_3` | atlas `cule` | atlas `cule` | sala: barcelona/gimnasio_2, pintado: barcelona/gimnasio_2 |  |
| Culé Oriol | `gym2_cule_4` | atlas `cule` | atlas `cule` | sala: barcelona/gimnasio_2, pintado: barcelona/gimnasio_2 |  |
| Culé Marc | `gym2_cule_5` | atlas `cule` | atlas `cule` | sala: barcelona/gimnasio_3, pintado: barcelona/gimnasio_3 |  |
| Culé Roger | `gym2_cule_6` | atlas `cule` | atlas `cule` | sala: barcelona/gimnasio_3, pintado: barcelona/gimnasio_3 |  |
| Revisor del Cercanías Montse | `gym2_revisor` | hoja de la clase | retrato de la clase | barcelona/les_corts (32, 45) | Entrenador del gimnasio 2 |
| Tertuliano de bar Jordi | `gym2_tertuliano` | hoja de la clase | retrato de la clase | barcelona/les_corts (22, 45) | Entrenador del gimnasio 2 |
| Alcohólico Vicent | `gym3_alcoholico_1` | atlas `alcoholico` | atlas `alcoholico` | sala: valencia/gimnasio_1, pintado: valencia/gimnasio_1 |  |
| Alcohólico Paco | `gym3_alcoholico_2` | atlas `alcoholico` | atlas `alcoholico` | sala: valencia/gimnasio_2, pintado: valencia/gimnasio_2 |  |
| Cocainómano Borja | `gym3_cocainomano_1` | atlas `cocainomano` | atlas `cocainomano` | sala: valencia/gimnasio_1, pintado: valencia/gimnasio_1 |  |
| Cocainómano Kevin | `gym3_cocainomano_2` | atlas `cocainomano` | atlas `cocainomano` | sala: valencia/gimnasio_2, pintado: valencia/gimnasio_2 |  |
| Cocainómano Iván | `gym3_cocainomano_3` | atlas `cocainomano` | atlas `cocainomano` | sala: valencia/gimnasio_3, pintado: valencia/gimnasio_3 |  |
| Crossfitero Vicent | `gym3_crossfitero` | hoja de la clase | retrato de la clase | valencia/malvarrosa (36, 25) | Entrenador del gimnasio 3 |
| Porreta Ximo | `gym3_porreta_1` | atlas `porreta` | atlas `porreta` | sala: valencia/gimnasio_1, pintado: valencia/gimnasio_1 |  |
| Porreta Nando | `gym3_porreta_2` | atlas `porreta` | atlas `porreta` | sala: valencia/gimnasio_2, pintado: valencia/gimnasio_2 |  |
| Porreta Rafa | `gym3_porreta_3` | atlas `porreta` | atlas `porreta` | sala: valencia/gimnasio_3, pintado: valencia/gimnasio_3 |  |
| Raver Nerea | `gym3_raver` | hoja de la clase | retrato de la clase | valencia/malvarrosa (46, 24) | Entrenador del gimnasio 3 |
| Tronista Rubén | `gym3_tronista` | hoja de la clase | retrato de la clase | valencia/malvarrosa (41, 26) | Entrenador del gimnasio 3 |
| Costalero Curro | `gym4_costalero` | hoja de la clase | retrato de la clase | sevilla/rio (15, 36) | Entrenador del gimnasio 4 |
| Cuñado que sabe de todo Manolo | `gym4_cunado` | hoja de la clase | retrato de la clase | sevilla/rio (6, 36) | Entrenador del gimnasio 4 |
| Flamenca Lola | `gym4_flamenca` | hoja de la clase | retrato de la clase | sevilla/rio (11, 37) | Entrenador del gimnasio 4 |
| Flamenca Rocío | `gym4_flamenca_1` | hoja de la clase | retrato de la clase | sala: sevilla/gimnasio_1, pintado: sevilla/gimnasio_1 |  |
| Flamenca Macarena | `gym4_flamenca_2` | hoja de la clase | retrato de la clase | sala: sevilla/gimnasio_2, pintado: sevilla/gimnasio_2 |  |
| Flamenco Curro | `gym4_flamenco_1` | atlas `flamenco_traje` | atlas `flamenco_traje` | sala: sevilla/gimnasio_1, pintado: sevilla/gimnasio_1 |  |
| Flamenco Manuel | `gym4_flamenco_2` | atlas `flamenco_traje` | atlas `flamenco_traje` | sala: sevilla/gimnasio_3, pintado: sevilla/gimnasio_3 |  |
| Fan de Quevedo Saray | `gym5_fan` | hoja de la clase | retrato de la clase | playa_del_ingles/exterior (46, 28) | Entrenador del gimnasio 5 |
| Nadador Airam | `gym5_nadador` | hoja de la clase | retrato de la clase | playa_del_ingles/exterior (54, 28) | Entrenador del gimnasio 5 |
| Quesito Yaiza | `gym5_quesito_1` | atlas `quesito` | atlas `quesito` | sala: playa_del_ingles/gimnasio_1, pintado: playa_del_ingles/gimnasio_1 |  |
| Quesito Nayra | `gym5_quesito_2` | atlas `quesito` | atlas `quesito` | sala: playa_del_ingles/gimnasio_1, pintado: playa_del_ingles/gimnasio_1 |  |
| Quesito Idaira | `gym5_quesito_3` | atlas `quesito` | atlas `quesito` | sala: playa_del_ingles/gimnasio_2, pintado: playa_del_ingles/gimnasio_2 |  |
| Quesito Tamara | `gym5_quesito_4` | atlas `quesito` | atlas `quesito` | sala: playa_del_ingles/gimnasio_2, pintado: playa_del_ingles/gimnasio_2 |  |
| Quesito Guacimara | `gym5_quesito_5` | atlas `quesito` | atlas `quesito` | sala: playa_del_ingles/gimnasio_3, pintado: playa_del_ingles/gimnasio_3 |  |
| Quesito Dácil | `gym5_quesito_6` | atlas `quesito` | atlas `quesito` | sala: playa_del_ingles/gimnasio_3, pintado: playa_del_ingles/gimnasio_3 |  |
| Surfista Yeray | `gym5_surfista` | hoja de la clase | retrato de la clase | playa_del_ingles/exterior (50, 29) | Entrenador del gimnasio 5 |
| Camarero sin propina Josu | `gym6_camarero` | hoja de la clase | retrato de la clase | bilbao/exterior (16, 20) | Bilbao, camino de San Mamés (antiguo entrenador del gimnasio 6) |
| Crossfitero Aitor | `gym6_crossfitero` | hoja de la clase | retrato de la clase | bilbao/exterior (20, 23) | Bilbao, camino de San Mamés (antiguo entrenador del gimnasio 6) |
| Etarra Aitor | `gym6_etarra_1` | atlas `etarra` | atlas `etarra` | sala: bilbao/gimnasio_1, pintado: bilbao/gimnasio_1 |  |
| Etarra Gorka | `gym6_etarra_2` | atlas `etarra` | atlas `etarra` | sala: bilbao/gimnasio_1, pintado: bilbao/gimnasio_1 |  |
| Etarra Iker | `gym6_etarra_3` | atlas `etarra` | atlas `etarra` | sala: bilbao/gimnasio_1, pintado: bilbao/gimnasio_1 |  |
| Etarra Unai | `gym6_etarra_4` | atlas `etarra` | atlas `etarra` | sala: bilbao/gimnasio_2, pintado: bilbao/gimnasio_2 |  |
| Etarra Asier | `gym6_etarra_5` | atlas `etarra` | atlas `etarra` | sala: bilbao/gimnasio_2, pintado: bilbao/gimnasio_2 |  |
| Etarra Mikel | `gym6_etarra_6` | atlas `etarra` | atlas `etarra` | sala: bilbao/gimnasio_3, pintado: bilbao/gimnasio_3 |  |
| Tertuliano de bar Iñaki | `gym6_tertuliano` | hoja de la clase | retrato de la clase | bilbao/exterior (25, 19) | Bilbao, camino de San Mamés (antiguo entrenador del gimnasio 6) |
| Cayetano Borja | `gym7_cayetano_1` | atlas `cayetano_casco` | atlas `cayetano_casco` | sala: valladolid/gimnasio_1, pintado: valladolid/gimnasio_1 |  |
| Cayetano Jacobo | `gym7_cayetano_2` | atlas `cayetano_casco` | atlas `cayetano_casco` | sala: valladolid/gimnasio_1, pintado: valladolid/gimnasio_1 |  |
| Cayetano Pelayo | `gym7_cayetano_3` | atlas `cayetano_casco` | atlas `cayetano_casco` | sala: valladolid/gimnasio_1, pintado: valladolid/gimnasio_1 |  |
| Cayetano Beltrán | `gym7_cayetano_4` | atlas `cayetano_casco` | atlas `cayetano_casco` | sala: valladolid/gimnasio_2, pintado: valladolid/gimnasio_2 |  |
| Cayetano Tristán | `gym7_cayetano_5` | atlas `cayetano_casco` | atlas `cayetano_casco` | sala: valladolid/gimnasio_2, pintado: valladolid/gimnasio_2 |  |
| Cayetano Rodrigo | `gym7_cayetano_6` | atlas `cayetano_casco` | atlas `cayetano_casco` | sala: valladolid/gimnasio_3, pintado: valladolid/gimnasio_3 |  |
| Cayetano Álvaro | `gym7_cayetano_7` | atlas `cayetano_casco` | atlas `cayetano_casco` | sala: valladolid/gimnasio_3, pintado: valladolid/gimnasio_3 |  |
| Esquiador Álvaro | `gym7_esquiador` | hoja de la clase | retrato de la clase | valladolid/exterior (32, 29) | Entrenador del gimnasio 7 |
| Montañera Elena | `gym7_montanera` | hoja de la clase | retrato de la clase | valladolid/exterior (40, 30) | Entrenador del gimnasio 7 |
| Opositor eterno Sergio | `gym7_opositor` | hoja de la clase | retrato de la clase | valladolid/exterior (36, 28) | Entrenador del gimnasio 7 |
| Actor de reparto Paco | `gym8_actor_1` | atlas `actor_reparto` | atlas `actor_reparto` | sala: malaga/gimnasio_1, pintado: malaga/gimnasio_1 |  |
| Actor de reparto Curro | `gym8_actor_2` | atlas `actor_reparto` | atlas `actor_reparto` | sala: malaga/gimnasio_1, pintado: malaga/gimnasio_1 |  |
| Actor de reparto Antonio | `gym8_actor_3` | atlas `actor_reparto` | atlas `actor_reparto` | sala: malaga/gimnasio_2, pintado: malaga/gimnasio_2 |  |
| Actor de reparto Manolo | `gym8_actor_4` | atlas `actor_reparto` | atlas `actor_reparto` | sala: malaga/gimnasio_3, pintado: malaga/gimnasio_3 |  |
| Camarero sin propina Antonio | `gym8_camarero` | hoja de la clase | retrato de la clase | malaga/exterior (61, 65) | Entrenador del gimnasio 8 |
| Turista con chanclas y calcetines Brian | `gym8_extra` | hoja de la clase | retrato de la clase | malaga/exterior (53, 64) | Entrenador del gimnasio 8 |
| Influencer de LinkedIn Marta | `gym8_productor` | hoja de la clase | retrato de la clase | malaga/exterior (57, 66) | Entrenador del gimnasio 8 |
| Delantero Iñaki Williams | `inaki_williams_gym` | atlas `inaki_williams` | atlas `inaki_williams` | sala: bilbao/gimnasio_2, pintado: bilbao/gimnasio_2 |  |
| Actor Javier Bardem | `javier_bardem` | atlas `javier_bardem` | atlas `javier_bardem` | pintado: malaga/gimnasio_lider |  |
| Humorista José Mota | `jose_mota` | atlas `jose_mota` | atlas `jose_mota` | pintado: sevilla/gimnasio_lider |  |
| Araña Julián Álvarez | `julian_alvarez` | atlas `julian_alvarez` | atlas `julian_alvarez` | sala: barcelona/gimnasio_2, pintado: barcelona/gimnasio_2 |  |
| Cantante La Pantera | `la_pantera` | atlas `la_pantera` | atlas `la_pantera` | sala: playa_del_ingles/gimnasio_1, pintado: playa_del_ingles/gimnasio_1 |  |
| Cantante Lucho RK | `lucho_rk` | atlas `lucho_rk` | atlas `lucho_rk` | sala: playa_del_ingles/gimnasio_2, pintado: playa_del_ingles/gimnasio_2 |  |
| Actor Mario Casas | `mario_casas_gym` | atlas `mario_casas` | atlas `mario_casas` | sala: malaga/gimnasio_1, pintado: malaga/gimnasio_1 |  |
| D10S Messi | `messi` | atlas `messi` | atlas `messi` | sala: barcelona/gimnasio_3, pintado: barcelona/gimnasio_3 |  |
| Delantero Nico Williams | `nico_williams_gym` | atlas `nico_williams` | atlas `nico_williams` | sala: bilbao/gimnasio_3, pintado: bilbao/gimnasio_3 |  |
| Ministro de Transportes Óscar Puente | `oscar_puente_gym` | atlas `oscar_puente` | atlas `oscar_puente` | sala: valladolid/gimnasio_2, pintado: valladolid/gimnasio_2 |  |
| Coordinador Arnaldo Otegi | `otegi` | atlas `otegi` | atlas `otegi` | pintado: bilbao/gimnasio_lider |  |
| Actriz Penélope Cruz | `penelope_cruz` | atlas `penelope_cruz` | atlas `penelope_cruz` | sala: malaga/gimnasio_3, pintado: malaga/gimnasio_3 |  |
| Dueño Peter Lim | `peter_lim` | atlas `peter_lim` | atlas `peter_lim` | sala: valencia/gimnasio_3, pintado: valencia/gimnasio_3 |  |
| Empresario Piqué | `pique_gym` | atlas `pique` | atlas `pique` | sala: barcelona/gimnasio_1, pintado: barcelona/gimnasio_1 |  |
| Expresidente Rajoy | `rajoy_gym` | atlas `rajoy` | atlas `rajoy` | sala: madrid/gimnasio_2, pintado: madrid/gimnasio_2 |  |
| Presidente Ronaldo Nazário | `ronaldo_nazario` | atlas `ronaldo_nazario` | atlas `ronaldo_nazario` | sala: valladolid/gimnasio_3, pintado: valladolid/gimnasio_3 |  |
| Brazo de la ley Torrente | `torrente` | atlas `torrente` | atlas `torrente` | sala: malaga/gimnasio_3, pintado: malaga/gimnasio_3 |  |

## `clases_nuevas.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Mantero Ibrahima | `barcelona_mantero` | hoja de la clase | retrato de la clase | barcelona/ciutat_vella (30, 30) | Clase nueva (decisiones del 2026-10-13, §4) |
| Perroflauta Pol | `barcelona_perroflauta` | hoja de la clase | retrato de la clase | barcelona/ciutat_vella (20, 20) | Clase nueva (decisiones del 2026-10-13, §4) |
| Turista Hans | `barcelona_turista` | hoja de la clase | retrato de la clase | barcelona/eixample (45, 45) | Clase nueva (decisiones del 2026-10-13, §4) |
| Mantero Moussa | `madrid_mantero` | hoja de la clase | retrato de la clase | madrid/centro (30, 20) | Clase nueva (decisiones del 2026-10-13, §4) |
| Perroflauta Lucas | `madrid_perroflauta` | hoja de la clase | retrato de la clase | madrid/centro (20, 36) | Clase nueva (decisiones del 2026-10-13, §4) |
| Turista Jessica | `madrid_turista_sol` | hoja de la clase | retrato de la clase | madrid/centro (50, 44) | Clase nueva (decisiones del 2026-10-13, §4) |
| Mantero Mamadou | `malaga_mantero` | hoja de la clase | retrato de la clase | malaga/exterior (60, 50) | Clase nueva (decisiones del 2026-10-13, §4) |
| Turista Gary | `malaga_turista` | hoja de la clase | retrato de la clase | malaga/exterior (80, 60) | Clase nueva (decisiones del 2026-10-13, §4) |
| Cani Kevin | `orcasitas_cani` | hoja de la clase | retrato de la clase | orcasitas/exterior (31, 22) | Clase nueva (decisiones del 2026-10-13, §4) |
| Turista John | `palacio_turista` | hoja de la clase | retrato de la clase | madrid/palacio_real (30, 35) | Clase nueva (decisiones del 2026-10-13, §4) |
| Cayetano Álvaro | `pozuelo_cayetano` | hoja de la clase | retrato de la clase | pozuelo/exterior (34, 21) | Clase nueva (decisiones del 2026-10-13, §4) |
| Gitano Juan | `ruta12_gitano` | hoja de la clase | retrato de la clase | ruta_12/exterior (7, 20) | Clase nueva (decisiones del 2026-10-13, §4) |
| Pueblerino Eusebio | `ruta6_pueblerino` | hoja de la clase | retrato de la clase | ruta_6/exterior (30, 20) | Clase nueva (decisiones del 2026-10-13, §4) |
| Pueblerino Tomás | `ruta7_pueblerino` | hoja de la clase | retrato de la clase | ruta_7/exterior (30, 20) | Clase nueva (decisiones del 2026-10-13, §4) |
| Gitano Rafael | `sevilla_gitano` | hoja de la clase | retrato de la clase | sevilla/rio (8, 20) | Clase nueva (decisiones del 2026-10-13, §4) |
| Gitano Antonio | `sevilla_gitano_2` | hoja de la clase | retrato de la clase | sevilla/centro (44, 35) | Clase nueva (decisiones del 2026-10-13, §4) |
| Mantero Ousmane | `valencia_mantero` | hoja de la clase | retrato de la clase | valencia/malvarrosa (30, 29) | Clase nueva (decisiones del 2026-10-13, §4) |
| Turista Emma | `valencia_turista` | hoja de la clase | retrato de la clase | valencia/ciutat_vella (28, 32) | Clase nueva (decisiones del 2026-10-13, §4) |

## `alicante.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Crossfitero Borja | `alc_luchador` | hoja de la clase | retrato de la clase | pintado: alicante/exterior |  |
| Nadador Lucía | `alc_nadadora` | hoja de la clase | retrato de la clase | pintado: alicante/exterior |  |
| Regatista Nacho | `alc_regatista` | hoja de la clase | retrato de la clase | pintado: alicante/exterior |  |

## `barcelona.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Turista con chanclas y calcetines Sophie | `bcn_banyista` | hoja de la clase | retrato de la clase | pintado: barcelona/ciutat_vella |  |
| Carterista Nando | `bcn_carterista` | hoja de la clase | retrato de la clase | pintado: barcelona/ciutat_vella |  |
| Turista con chanclas y calcetines Kevin | `bcn_guiri` | hoja de la clase | retrato de la clase | pintado: barcelona/eixample |  |
| Jubilado mirando obras Ramon | `bcn_obrero` | hoja de la clase | retrato de la clase | pintado: barcelona/les_corts |  |
| Cuñado que sabe de todo Jordi | `bcn_soci` | hoja de la clase | retrato de la clase | pintado: barcelona/les_corts |  |
| Influencer de LinkedIn Mireia | `bcn_startup` | hoja de la clase | retrato de la clase | pintado: barcelona/eixample |  |

## `bilbao.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Nadador Ane | `bilbao_remera` | hoja de la clase | retrato de la clase | pintado: bilbao/exterior |  |
| Tertuliano de bar Patxi | `bilbao_txikitero` | hoja de la clase | retrato de la clase | pintado: bilbao/exterior |  |

## `calle_victoria.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Mantero Moussa | `victoria_mantero` | hoja de la clase | retrato de la clase | pintado: calle_victoria/tunel |  |
| Perroflauta Iker | `victoria_perroflauta` | hoja de la clase | retrato de la clase | pintado: calle_victoria/tunel |  |
| Raver Nerea | `victoria_raver` | hoja de la clase | retrato de la clase | pintado: calle_victoria/tunel |  |
| Revisor del Cercanías Óscar | `victoria_revisor` | hoja de la clase | retrato de la clase | pintado: calle_victoria/tunel |  |

## `casa_de_campo.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Padre con la tarjeta del súper Borja | `casadecampo_padretarjeta` | hoja de la clase | retrato de la clase | pintado: casa_de_campo/exterior |  |
| Patinetero eléctrico Lucas | `casadecampo_patinetero` | hoja de la clase | retrato de la clase | pintado: casa_de_campo/exterior |  |

## `getafe.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Cuñado que sabe de todo Sergio | `getafe_aficionado` | hoja de la clase | retrato de la clase | pintado: getafe/exterior |  |
| Estudiante de Ingeniería en exámenes Iván | `getafe_poligono` | hoja de la clase | retrato de la clase | pintado: getafe/exterior |  |

## `huelva.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Marinero Juanma | `huelva_marinero` | hoja de la clase | retrato de la clase | pintado: huelva/exterior |  |
| Regatista Lucía | `huelva_regatista` | hoja de la clase | retrato de la clase | pintado: huelva/exterior |  |

## `ibiza.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Hippie Luna | `ibiza_hippie` | hoja de la clase | retrato de la clase | pintado: ibiza/exterior |  |
| Raver Tito | `ibiza_relaciones` | hoja de la clase | retrato de la clase | pintado: ibiza/exterior |  |

## `las_palmas.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Guagüero Echedey | `lp_guaguero` | hoja de la clase | retrato de la clase | pintado: las_palmas/vegueta_triana |  |
| Nadador Yaiza | `lp_nadadora` | hoja de la clase | retrato de la clase | pintado: las_palmas/canteras |  |
| Surfista Aday | `lp_surfista` | hoja de la clase | retrato de la clase | pintado: las_palmas/canteras |  |
| Turista con chanclas y calcetines Ingrid | `lp_turista` | hoja de la clase | retrato de la clase | pintado: las_palmas/vegueta_triana |  |

## `leganes.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Cuñado que sabe de todo Dani | `leganes_aficionado` | hoja de la clase | retrato de la clase | pintado: leganes/exterior |  |
| Estudiante de Ingeniería en exámenes Álvaro | `leganes_estudiante` | hoja de la clase | retrato de la clase | pintado: leganes/exterior |  |

## `madrid.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Camarero sin propina Julián | `madrid_camarero` | hoja de la clase | retrato de la clase | pintado: madrid/chamberi |  |
| Crossfitero Borja | `madrid_crossfitero` | hoja de la clase | retrato de la clase | pintado: madrid/retiro |  |
| Cuñado que sabe de todo Paco | `madrid_cunado` | hoja de la clase | retrato de la clase | pintado: madrid/centro |  |
| Influencer de LinkedIn Cayetana | `madrid_influencer` | hoja de la clase | retrato de la clase | pintado: madrid/centro |  |
| Domador de palomas Emilio | `madrid_palomas` | hoja de la clase | retrato de la clase | pintado: madrid/retiro |  |
| Patinetero eléctrico Iker | `madrid_patinetero` | hoja de la clase | retrato de la clase | pintado: madrid/retiro |  |
| Recluta del Clan | `madrid_recluta_1` | hoja de la clase | retrato de la clase | pintado: madrid/moncloa |  |
| Recluta del Clan | `madrid_recluta_2` | hoja de la clase | retrato de la clase | pintado: madrid/moncloa |  |
| Tertuliano de bar Ramón | `madrid_tertuliano` | hoja de la clase | retrato de la clase | pintado: madrid/centro |  |
| Turista con chanclas y calcetines Hans | `madrid_turista` | hoja de la clase | retrato de la clase | pintado: madrid/centro |  |

## `madrid_quiron.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Enfermero Lorena | `quiron_enfermera_1` | hoja de la clase | retrato de la clase | pintado: madrid/quiron |  |
| Enfermero Marisa | `quiron_enfermera_3` | hoja de la clase | retrato de la clase | pintado: madrid/quiron |  |
| Enfermero Rubén | `quiron_enfermero_2` | hoja de la clase | retrato de la clase | pintado: madrid/quiron |  |

## `madrid_rio.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Repartidor en bici Dani | `madridrio_repartidor` | hoja de la clase | retrato de la clase | pintado: madrid_rio/exterior |  |

## `malaga.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Turista con chanclas y calcetines Dani | `malaga_playa` | hoja de la clase | retrato de la clase | pintado: malaga/exterior |  |
| Influencer de LinkedIn Sergio | `malaga_rodaje` | hoja de la clase | retrato de la clase | pintado: malaga/exterior |  |

## `maritima_1.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Raver DJ Marta | `maritima1_dj` | hoja de la clase | retrato de la clase | pintado: maritima_1/exterior |  |
| Nadador Biel | `maritima1_nadador` | hoja de la clase | retrato de la clase | pintado: maritima_1/exterior |  |

## `mostoles.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Estudiante de Ingeniería en exámenes Marcos | `mostoles_estudiante` | hoja de la clase | retrato de la clase | pintado: mostoles/exterior |  |
| Domador de palomas Paco | `mostoles_paseante` | hoja de la clase | retrato de la clase | pintado: mostoles/exterior |  |

## `murcia.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Camarero sin propina Ginés | `mur_camarero` | hoja de la clase | retrato de la clase | pintado: murcia/exterior |  |
| Huertano Perico | `mur_huertano` | hoja de la clase | retrato de la clase | pintado: murcia/exterior |  |
| Opositor eterno Fuensanta | `mur_opositora` | hoja de la clase | retrato de la clase | pintado: murcia/exterior |  |

## `palma.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Turista con chanclas y calcetines Klaus | `palma_aleman` | hoja de la clase | retrato de la clase | pintado: palma/exterior |  |
| Regatista Tolo | `palma_regatista` | hoja de la clase | retrato de la clase | pintado: palma/exterior |  |

## `pamplona.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Tuno Fermín | `pamplona_mozo` | hoja de la clase | retrato de la clase | pintado: pamplona/exterior |  |
| Montañera Hans | `pamplona_peregrino` | hoja de la clase | retrato de la clase | pintado: pamplona/exterior |  |

## `playa_del_ingles.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Fan de Quevedo Laura | `pi_fan` | hoja de la clase | retrato de la clase | pintado: playa_del_ingles/exterior |  |
| Surfista Acoidan | `pi_surfista` | hoja de la clase | retrato de la clase | pintado: playa_del_ingles/exterior |  |
| Turista con chanclas y calcetines Sven | `pi_turista` | hoja de la clase | retrato de la clase | pintado: playa_del_ingles/exterior |  |

## `pueblo_inicial.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
|  | `rival_lab_1` | hoja de la clase | retrato de la clase | evento: res://data/world.json | Combate del rival en el laboratorio de Unicoos: lo elige el evento de la historia según el inicial (mvp_story.rival_by_starter) |
|  | `rival_lab_2` | hoja de la clase | retrato de la clase | evento: res://data/world.json | Combate del rival en el laboratorio de Unicoos: lo elige el evento de la historia según el inicial (mvp_story.rival_by_starter) |
|  | `rival_lab_3` | hoja de la clase | retrato de la clase | evento: res://data/world.json | Combate del rival en el laboratorio de Unicoos: lo elige el evento de la historia según el inicial (mvp_story.rival_by_starter) |

## `puertollano.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Jubilado mirando obras Aurelio | `puertollano_minero` | hoja de la clase | retrato de la clase | pintado: puertollano/exterior |  |
| Cuñado que sabe de todo Rafa | `puertollano_poligono` | hoja de la clase | retrato de la clase | pintado: puertollano/exterior |  |

## `ruta_1.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Piragüista Dani | `ruta1_dani` | hoja de la clase | retrato de la clase | pintado: ruta_1/exterior |  |
| Vendedor de Chupachups Manolo | `ruta1_manolo` | hoja de la clase | retrato de la clase | pintado: ruta_1/exterior, pintado: test/test_room |  |
| Ornitóloga Marta | `ruta1_marta` | hoja de la clase | retrato de la clase | pintado: ruta_1/exterior |  |

## `ruta_10.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Camarero sin propina Kevin | `ruta10_camarero` | hoja de la clase | retrato de la clase | pintado: ruta_10/exterior |  |
| Turista con chanclas y calcetines Gary | `ruta10_guiri` | hoja de la clase | retrato de la clase | pintado: ruta_10/exterior |  |
| Jubilado mirando obras Paco | `ruta10_jubilado` | hoja de la clase | retrato de la clase | pintado: ruta_10/exterior |  |
| Surfista Marc | `ruta10_surfista` | hoja de la clase | retrato de la clase | pintado: ruta_10/exterior |  |

## `ruta_11.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Estudiante de Ingeniería en exámenes Sergio | `ruta11_estudiante` | hoja de la clase | retrato de la clase | pintado: ruta_11/exterior |  |
| Huertano Pencho | `ruta11_huertano` | hoja de la clase | retrato de la clase | pintado: ruta_11/exterior |  |
| Ornitóloga Carmen | `ruta11_ornitologa` | hoja de la clase | retrato de la clase | pintado: ruta_11/exterior |  |

## `ruta_12.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Esquiador Iker | `ruta12_esquiador` | hoja de la clase | retrato de la clase | pintado: ruta_12/exterior |  |
| Invitada de boda Rocío | `ruta12_invitada` | hoja de la clase | retrato de la clase | pintado: ruta_12/exterior |  |
| Montañera Paqui | `ruta12_montanera` | hoja de la clase | retrato de la clase | pintado: ruta_12/exterior |  |

## `ruta_13.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Vendedor de aceite Rafael | `ruta13_aceitero` | hoja de la clase | retrato de la clase | pintado: ruta_13/exterior |  |
| Aceitunero Manuel | `ruta13_aceitunero` | hoja de la clase | retrato de la clase | pintado: ruta_13/exterior |  |
| Turista con chanclas y calcetines Gunnar | `ruta13_turista` | hoja de la clase | retrato de la clase | pintado: ruta_13/exterior |  |

## `ruta_14.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Guarda del parque Paco | `ruta14_guarda` | hoja de la clase | retrato de la clase | pintado: ruta_14/exterior |  |
| Ornitóloga Elena | `ruta14_ornitologa` | hoja de la clase | retrato de la clase | pintado: ruta_14/exterior |  |
| Rociero Rafa | `ruta14_rociero` | hoja de la clase | retrato de la clase | pintado: ruta_14/exterior |  |

## `ruta_15.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Guagüero Echedey | `ruta15_guaguero` | hoja de la clase | retrato de la clase | pintado: ruta_15/exterior |  |
| Nadador Nayra | `ruta15_nadadora` | hoja de la clase | retrato de la clase | pintado: ruta_15/exterior |  |
| Surfista Aday | `ruta15_surfista` | hoja de la clase | retrato de la clase | pintado: ruta_15/exterior |  |

## `ruta_16.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Nadador Iria | `ruta16_nadadora` | hoja de la clase | retrato de la clase | pintado: ruta_16/exterior |  |
| Ornitóloga Antía | `ruta16_ornitologa` | hoja de la clase | retrato de la clase | pintado: ruta_16/exterior |  |
| Pescador Xoán | `ruta16_percebeiro` | hoja de la clase | retrato de la clase | pintado: ruta_16/exterior |  |
| Regatista Roi | `ruta16_regatista` | hoja de la clase | retrato de la clase | pintado: ruta_16/exterior |  |

## `ruta_17.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Flautista Brais | `ruta17_gaiteiro` | hoja de la clase | retrato de la clase | pintado: ruta_17/exterior |  |
| Pescador Xurxo | `ruta17_marisquero` | hoja de la clase | retrato de la clase | pintado: ruta_17/exterior |  |
| Montañera Uxía | `ruta17_peregrina` | hoja de la clase | retrato de la clase | pintado: ruta_17/exterior |  |

## `ruta_18.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Camarero sin propina Nel | `ruta18_escanciador` | hoja de la clase | retrato de la clase | pintado: ruta_18/exterior |  |
| Montañera Pelayo | `ruta18_montanero` | hoja de la clase | retrato de la clase | pintado: ruta_18/exterior |  |
| Pastor Covadonga | `ruta18_vaqueira` | hoja de la clase | retrato de la clase | pintado: ruta_18/exterior |  |

## `ruta_19.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Pescador Chema | `ruta19_pescador` | hoja de la clase | retrato de la clase | pintado: ruta_19/exterior |  |
| Surfista Iker | `ruta19_surfista` | hoja de la clase | retrato de la clase | pintado: ruta_19/exterior |  |

## `ruta_2.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Resinero Eusebio | `ruta2_eusebio` | hoja de la clase | retrato de la clase | pintado: ruta_2/exterior |  |
| Turista con chanclas y calcetines Steve | `ruta2_steve` | hoja de la clase | retrato de la clase | pintado: ruta_2/exterior |  |

## `ruta_20.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Crossfitero Joseba | `ruta20_aizkolari` | hoja de la clase | retrato de la clase | pintado: ruta_20/exterior |  |
| Crossfitero Iñaki | `ruta20_harrijasotzaile` | hoja de la clase | retrato de la clase | pintado: ruta_20/exterior |  |
| Pastor Mikel | `ruta20_pastor` | hoja de la clase | retrato de la clase | pintado: ruta_20/exterior |  |

## `ruta_21.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Camarero sin propina Diego | `ruta21_sumiller` | hoja de la clase | retrato de la clase | pintado: ruta_21/exterior |  |
| Vendimiador Toño | `ruta21_vendimiador` | hoja de la clase | retrato de la clase | pintado: ruta_21/exterior |  |

## `ruta_22.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Arqueólogo Luis | `ruta22_arqueologa` | hoja de la clase | retrato de la clase | pintado: ruta_22/exterior |  |
| Estudiante de Ingeniería en exámenes Pablo | `ruta22_paleontologo` | hoja de la clase | retrato de la clase | pintado: ruta_22/exterior |  |

## `ruta_23.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Pastor Ángel | `ruta23_jinete` | hoja de la clase | retrato de la clase | pintado: ruta_23/exterior |  |
| Resinero Raúl | `ruta23_resinero` | hoja de la clase | retrato de la clase | pintado: ruta_23/exterior |  |

## `ruta_24.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Cuñado que sabe de todo Caballero | `ruta24_caballero` | hoja de la clase | retrato de la clase | pintado: ruta_24/exterior |  |
| Pastor Escudero | `ruta24_escudero` | hoja de la clase | retrato de la clase | pintado: ruta_24/exterior |  |

## `ruta_25.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Cuñado que sabe de todo Tomás | `ruta25_camionero` | hoja de la clase | retrato de la clase | pintado: ruta_25/exterior |  |
| Montañera Lola | `ruta25_montanera` | hoja de la clase | retrato de la clase | pintado: ruta_25/exterior |  |

## `ruta_26.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Montañera Inés | `ruta26_escaladora` | hoja de la clase | retrato de la clase | pintado: ruta_26/exterior |  |
| Arqueólogo Elena | `ruta26_guia` | hoja de la clase | retrato de la clase | pintado: ruta_26/exterior |  |

## `ruta_3.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Esquiador Borja | `ruta3_borja` | hoja de la clase | retrato de la clase | pintado: ruta_3/exterior |  |
| Montañera Lucía | `ruta3_lucia` | hoja de la clase | retrato de la clase | pintado: ruta_3/exterior |  |

## `ruta_4.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Padre con la tarjeta del súper Álvaro | `ruta4_alvaro` | hoja de la clase | retrato de la clase | pintado: ruta_4/exterior |  |
| Crossfitero Carla | `ruta4_carla` | hoja de la clase | retrato de la clase | pintado: ruta_4/exterior |  |

## `ruta_5.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Estudiante de Ingeniería en exámenes Álex | `ruta5_estudiante` | hoja de la clase | retrato de la clase | pintado: ruta_5/exterior |  |
| Crossfitero Rubén | `ruta5_mozo` | hoja de la clase | retrato de la clase | pintado: ruta_5/exterior |  |
| Opositor eterno Nuria | `ruta5_opositora` | hoja de la clase | retrato de la clase | pintado: ruta_5/exterior |  |
| Repartidor en bici Wilmer | `ruta5_repartidor` | hoja de la clase | retrato de la clase | pintado: ruta_5/exterior |  |
| Tuno Ignacio | `ruta5_tuno` | hoja de la clase | retrato de la clase | pintado: ruta_5/exterior |  |

## `ruta_6.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Jubilado mirando obras Anselmo | `ruta6_jubilado` | hoja de la clase | retrato de la clase | pintado: ruta_6/exterior |  |
| Ornitóloga Paloma | `ruta6_ornitologa` | hoja de la clase | retrato de la clase | pintado: ruta_6/exterior |  |
| Pastor Cirilo | `ruta6_pastor` | hoja de la clase | retrato de la clase | pintado: ruta_6/exterior |  |

## `ruta_7.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Pastor Joaquín | `ruta7_pastor` | hoja de la clase | retrato de la clase | pintado: ruta_7/exterior |  |
| Raver Kike | `ruta7_raver` | hoja de la clase | retrato de la clase | pintado: ruta_7/exterior |  |
| Raver Vane | `ruta7_raver_f` | hoja de la clase | retrato de la clase | pintado: ruta_7/exterior |  |

## `ruta_8.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Montañera Montse | `ruta8_escaladora` | hoja de la clase | retrato de la clase | pintado: ruta_8/exterior |  |
| Flautista Oriol | `ruta8_flautista` | hoja de la clase | retrato de la clase | pintado: ruta_8/exterior |  |
| Montañera Laia | `ruta8_laia` | hoja de la clase | retrato de la clase | pintado: ruta_8/exterior |  |

## `ruta_9.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Nadador Nerea | `ruta9_nadadora` | hoja de la clase | retrato de la clase | pintado: ruta_9/exterior |  |
| Ornitóloga Pilar | `ruta9_ornitologa` | hoja de la clase | retrato de la clase | pintado: ruta_9/exterior |  |
| Pescador Vicent | `ruta9_pescador` | hoja de la clase | retrato de la clase | pintado: ruta_9/exterior |  |
| Tronista Iván | `ruta9_tronista` | hoja de la clase | retrato de la clase | pintado: ruta_9/exterior |  |

## `santander.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Camarero sin propina Toño | `santander_raba` | hoja de la clase | retrato de la clase | pintado: santander/exterior |  |
| Turista Margaret | `santander_turista` | hoja de la clase | retrato de la clase | pintado: santander/exterior |  |

## `sevilla.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Costalero Antonio | `sevilla_costalero` | hoja de la clase | retrato de la clase | pintado: sevilla/centro |  |
| Flamenca Rocío | `sevilla_flamenca` | hoja de la clase | retrato de la clase | pintado: sevilla/centro |  |
| Flamenca Macarena | `sevilla_flamenca_triana` | hoja de la clase | retrato de la clase | pintado: sevilla/rio |  |
| Turista con chanclas y calcetines Hans | `sevilla_guiri` | hoja de la clase | retrato de la clase | pintado: sevilla/rio |  |
| Domador de palomas Curro | `sevilla_palomas` | hoja de la clase | retrato de la clase | pintado: sevilla/maria_luisa |  |
| Tuno Pepe | `sevilla_tuno` | hoja de la clase | retrato de la clase | pintado: sevilla/maria_luisa |  |

## `valencia.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Abuela que te pone de comer Amparo | `vlc_abuela` | hoja de la clase | retrato de la clase | pintado: valencia/turia |  |
| Crossfitero Andrea | `vlc_corredora` | hoja de la clase | retrato de la clase | pintado: valencia/turia |  |
| Cuñado que sabe de todo Rubén | `vlc_despedida` | hoja de la clase | retrato de la clase | pintado: valencia/malvarrosa |  |
| Tronista Jonathan | `vlc_tronista` | hoja de la clase | retrato de la clase | pintado: valencia/malvarrosa |  |

## `valladolid.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Cuñado que sabe de todo Javi | `valladolid_aficionado` | hoja de la clase | retrato de la clase | pintado: valladolid/exterior |  |
| Domador de palomas Félix | `valladolid_paseante` | hoja de la clase | retrato de la clase | pintado: valladolid/exterior |  |

## `vigo.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Nadador Sabela | `vigo_nadadora` | hoja de la clase | retrato de la clase | pintado: vigo/exterior |  |
| Regatista Uxío | `vigo_regatista` | hoja de la clase | retrato de la clase | pintado: vigo/exterior |  |

## `zaragoza.json`

| Entrenador | Id | Mapa | Combate | Dónde | Nota |
|---|---|---|---|---|---|
| Baturro Jorge | `zaragoza_baturro` | hoja de la clase | retrato de la clase | pintado: zaragoza/exterior |  |
| Camarero sin propina Chema | `zaragoza_tubo` | hoja de la clase | retrato de la clase | pintado: zaragoza/exterior |  |

## Personajes sin combate

Personajes del registro de arte que no son entrenadores (ni por id ni por clase).

| Personaje | Id | Dónde | Nota |
|---|---|---|---|
| Abuela de Lamine | `abuela_lamine` | rocafonda/exterior |  |

