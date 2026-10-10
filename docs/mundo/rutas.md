# Rutas de la región (propuesta)

> Todo es **propuesta** (Javier decidió las ciudades y el orden de los gimnasios; las rutas que las unen salen de la geografía real). Ids y niveles en `data/region.json`; orden de la aventura en `region.md`.

Cada ruta toma su paisaje del camino real entre las dos ciudades.

**Pintadas** (mapa en `maps/ruta_<n>/exterior.tscn`, script en `maps/_pintura/pintar_ruta_<n>.gd`, captura en `docs/arte/comparativas/ruta_<n>_mapa.png`, entrenadores en `data/trainers/ruta_<n>.json` y encuentros en `data/encounters/ruta_<n>.json`):

- **Ruta 1:** Manolo (el de los Chupachups), Dani (piragüista) y Marta (ornitóloga).
- **Ruta 2:** Eusebio (resinero) y Steve (turista). El Acueducto cruza el Azoguejo de lado a lado y se pasa por debajo de los arcos.
- **Ruta 3:** Borja (esquiador) y Lucía (montañera). Se entra por arriba, al puerto nevado (en la nieve salen Pokémon), y se baja por escaleras; el Valle de Cuelgamuros (cruz y basílica dibujadas a mano) está abajo a la izquierda. **Franco (fantasma)** no está puesto: dónde va cada famoso lo decide Javier. Unida con la Ruta 4 por el sur.
- **Ruta 4:** Álvaro (el padre con la tarjeta) y Carla (crossfitera). Monasterio de El Escorial dibujado a mano; urbanización de chalets con setos (el "chalet de la colina" está sin dueño en el mapa: **Pablo Iglesias e Irene Montero** los coloca Javier). Unida con `madrid/moncloa` por la A-6.
- **Ruta 5:** Wilmer (repartidor), Nuria (opositora) y Álex (estudiante). Polígono, Alcalá (Universidad, Cervantes) y Guadalajara (Infantado); sale de Madrid por el norte del Retiro. Unida con la Ruta 6 por el este.
- **Ruta marítima 1:** Biel (nadador) en Sa Dragonera y DJ Marta (raver) junto al velero. Todo es mar (con Surf; `maps/_tools/alcance.gd -- <mapa> default --surf` lo comprueba); Es Vedrà dibujado a mano. Unida con Palma por el norte y con Ibiza por el sur.
- **Ruta 7:** Kike y Vane (ravers, clase nueva) en el festival. Desierto de arena con cerros de yeso. El viento y las tormentas de polvo quedan pendientes (los climas aún no tienen textura). Unida con la Ruta 8 por el este.
- **Ruta 8:** Laia (montañera) y Oriol (flautista). Terraza del monasterio con las agujas; Santpedor y Sant Esteve Sesrovires con su cartel (**Guardiola** y **Rosalía** los coloca Javier). Unida con Barcelona (Les Corts, por la Diagonal).
- **Ruta 6:** Cirilo (pastor, clase nueva) y Anselmo (jubilado mirando obras). Medinaceli en su cerro con el arco romano, el pueblo vaciado con su último vecino y Calatayud (torre mudéjar, mesón de la Dolores). Unida con Zaragoza por el este. Tamaño orientativo: las rutas normales, entre 20 × 50 y 30 × 70 casillas; las de "zona" (Monegros, La Mancha), más anchas.
- **Ruta 16:** Roi (regatista) e Iria (nadadora). Ría al oeste con dos bateas; Sanxenxo al este (cartel de las regatas: el rey emérito no está puesto). Sur, columnas 24–29, unido con Vigo. Norte, columnas 16–21, reservado para la Ruta 17.
- **Ruta 12:** Iker (esquiador), Paqui (montañera) y Rocío (invitada de boda, clase nueva). Altiplano de Guadix con su cartel de las casas cueva, Sierra Nevada en dos alturas (nieve, Pradollano y el Veleta) y la vega con la Alhambra dibujada a mano y el cortijo de la boda (**Rubiales y Jenni Hermoso** los coloca Javier: hay un cartel que lo insinúa). La unión con Murcia la hace el Agente 5; unida con la Ruta 13 por el oeste.
- **Ruta 13:** Manuel (aceitunero), Rafael (vendedor de aceite; las dos clases son nuevas) y Gunnar (turista). Olivares en hileras (olivo dibujado a mano), el cortijo del aceite y Córdoba junto al Guadalquivir con la Mezquita-Catedral dibujada a mano y el Puente Romano, que cruza a la orilla de la Calahorra (la torre está pendiente de dibujar). Unida con la Ruta 12 (este) y con Sevilla · Centro (oeste).
- **Ruta 14:** Elena (ornitóloga), Rafa (rociero) y Paco (guarda del parque; las dos clases son nuevas). El pinar, la aldea de El Rocío (la ermita, pendiente de dibujar), las marismas con su vereda y el observatorio, y las dunas. Unida con Sevilla · Río (este) y con Huelva (oeste).
- **Ruta 15:** Aday (surfista, clase nueva), Nayra (nadadora) y Echedey (guagüero, clase nueva). La costa este de Gran Canaria: malpaís, playas de arena negra de Telde, un barranco con su escalera y las salinas de Arinaga. Unida con Vegueta y Triana (norte) y con Playa del Inglés (sur).


- **Ruta 24:** molinos de Consuegra y Campo de Criptana comprimidos, campos de secano, caballero y escudero genéricos; encuentros 48–51. Getafe ⇄ Ruta 24 ⇄ Puertollano. [Comparativa](../arte/comparativas/ruta_24.md).
- **Ruta 25:** paso con curvas, riscos y embalse del Montoro comprimido al noroeste; camionero y montañera, encuentros 49–52. Puertollano ⇄ Ruta 25 ⇄ Ruta 26. Los Órganos esperan su pieza específica. [Comparativa](../arte/comparativas/ruta_25.md).
- **Ruta 26:** caliza apilada del Torcal y entrada de dolmen bajo túmulo; guía y escaladora, encuentros 50–53. Ruta 25 ⇄ Ruta 26 ⇄ Málaga. Coto Matamoros y la cámara interior quedan pendientes. [Comparativa](../arte/comparativas/ruta_26.md).
- **Calle de la Victoria:** interior bloqueado por recursos/recorrido pendiente; [traspaso](calle_victoria.md), sin mapa pintado ni enlace ficticio.

| Ruta | Paisaje real | Qué tiene en el juego | Entrenadores y personajes | Pokémon propuestos |
|------|--------------|----------------------|---------------------------|--------------------|
| **Ruta 1 · Hoces del Duratón** | Cañón del Duratón entre San Miguel de Bernuy y Sepúlveda: paredes de caliza, **buitres leonados**, la ermita de San Frutos en lo alto, canoas en el río | Camino por la ribera con hierba alta; mirador de los buitres; ruinas de Los Sanmartines | Piragüistas, ornitólogos con prismáticos | Pidgey, Bidoof, Vullaby, Psyduck, Magikarp |
| **Ruta 2 · Tierra de Pinares y Acueducto** | Pinares de Cantalejo (el pueblo de los trillos) hasta **Segovia**, con el **Acueducto** | La ruta pasa **por debajo del Acueducto** (hito); pinares con resina | Resineros, el del cochinillo, turistas haciendo fotos al Acueducto | Pineco, Seedot, Combee, Nuzleaf, Stantler |
| **Ruta 3 · Puerto de Navacerrada** | Sierra de Guadarrama: pinos, granito, nieve en invierno, el puerto de montaña; **Valle de Cuelgamuros** | Subida con nieve (hierba nevada), estación de esquí; desvío al Valle con la cruz gigante | Esquiadores, montañeros; **Franco** (fantasma) en Cuelgamuros | Snover, Snorunt, Swinub, Ponyta, Duskull |
| **Ruta 4 · El Escorial y Galapagar** | Monasterio de El Escorial, urbanizaciones con chalet de la sierra, A-6 | Monasterio de fondo; urbanización con chalets; entrada a Madrid por Moncloa | **Pablo Iglesias e Irene Montero** (doble, chalet de Galapagar); vecinos de urbanización | Lechonk, Skwovet, Deerling, Pidove |
| **Cercanías C-5** | Madrid ⇄ Getafe/Leganés/Móstoles | Viaje en tren con retraso aleatorio | Revisor, pasajeros dormidos | — |
| **Ruta 5 · Corredor del Henares** | Alcalá de Henares (Universidad, Cervantes), Guadalajara, polígonos logísticos | Ruta con naves industriales, la Universidad de Alcalá y una casa de Cervantes | Estudiantes, mozos de almacén, repartidores | Patrat, Trubbish, Electrike, Lillipup |
| **Ruta 6 · Medinaceli y Calatayud** | Páramos de Soria, el **arco romano de Medinaceli**, Calatayud ("la Dolores") | Meseta vacía (España vaciada): pueblos casi sin gente, arco romano | Pastores, el último vecino de un pueblo | Mareep, Wooloo, Skiddo, Geodude |
| **Ruta 7 · Los Monegros** | Desierto de Aragón, yeso, tierras rojas | **Zona de desierto**: arena que frena, tormentas de polvo | Raveros (el festival Monegros Desert Festival) | Trapinch, Sandile, Cacnea, Hippopotas |
| **Ruta 8 · Montserrat** | La montaña de Montserrat (rocas en forma de dedos) y el monasterio; Santpedor y Sant Esteve Sesrovires | Ruta de montaña con cremallera; monasterio con la Moreneta | **Pep Guardiola** (Santpedor) y **Rosalía** (Sant Esteve Sesrovires) | Roggenrola, Boldore, Timburr, Natu |
| **Ruta marítima 1 · Canal de Ibiza** | Mar entre Mallorca e Ibiza; **Es Vedrà** | **Surf** (decisión de Javier); islote de Es Vedrà con misterio | Nadadores, regatistas, un DJ en un barco | Tentacool, Wingull, Mantine, Frillish, Wailmer |
| **Ruta 9 · La Albufera y Gandía** | Lago de La Albufera, arrozales, barracas; la playa de Gandía | Arrozales con agua; barraca valenciana; playa de Gandía con guiños a *Gandía Shore* | Pescadores de la Albufera, *tronistas* de playa; **Ábalos y Koldo** (episodio del Clan) | Lotad, Lombre, Wooper, Krabby |
| **Ruta 10 · Costa Blanca** | Benidorm (rascacielos y guiris) y la costa | Playa con rascacielos detrás (Benidorm) | Jubilados ingleses, socorristas | Wingull, Corphish, Exeggcute |
| **Ruta 11 · Palmeral de Elche** | El palmeral de Elche (Patrimonio de la Humanidad) y la Vega Baja | Bosque de palmeras | **Vito Quiles** (segunda aparición: Elche es su ciudad) | Exeggcute, Tropius, Cherubi |
| **Ruta 12 · Sierra Nevada y Granada** | Sierra Nevada nevada, la **Alhambra** a lo lejos, cortijos | Montaña nevada; **cortijo con una boda** | **Luis Rubiales y Jenni Hermoso** (doble, en la boda) | Snom, Frosmoth, Gligar, Skarmory |
| **Ruta 13 · Mar de olivos** | Olivares de Jaén y Córdoba (la Mezquita de fondo) | Olivares en hileras infinitas | Aceituneros, un vendedor de aceite "a precio de oro" | Bounsweet, Smoliv, Dolliv, Arboliva |
| **Ruta 14 · Doñana** | Marismas de Doñana, flamencos, linces | Marisma con agua poco profunda; puerto de Huelva al final (**ferry a Canarias**) | Ornitólogos, guardas del parque | Flamigo, Ducklett, Marshtomp |
| **Ruta 15 · Costa de Gran Canaria** | Costa este de Gran Canaria hasta Maspalomas | Costa volcánica y de playa | Surfistas, *guagüeros* | Wishiwashi, Sandile, Pyukumuku |
| **Ruta 16 · Rías Baixas** | Rías, bateas de mejillones, **regatas de Sanxenxo** | Ría con bateas; puerto deportivo | **El rey emérito Juan Carlos I** (regatas) | Shellder, Clauncher, Mareep |
| **Ruta 17 · Galicia interior** | Montes, hórreos, *pazos*, lluvia constante; Lugo y su muralla; A Coruña y Arteixo | Lluvia casi siempre (clima del mapa); hórreos | **Elxokas**, **Amancio Ortega** (Inditex, Arteixo), **Pereira7** | Lotad, Shellos, Gloom, Hoothoot |
| **Ruta 18 · Asturias y Picos de Europa** | Picos de Europa, **Covadonga** y sus lagos, sidrerías | Montaña con lagos; sidrería (escanciar como minijuego) | **Melendi** | Mudbray, Tauros, Gligar, Chatot |
| **Ruta 19 · Costa de Cantabria** | Acantilados, Castro Urdiales | Costa con acantilados y faro | Surfistas, pescadores | Wingull, Seel, Pelipper |
| **Ruta 20 · Sierra de Aralar** | Montes de Navarra y Gipuzkoa, bosques, ovejas latxas | Bosque de hayas y ovejas | Pastores, deporte rural vasco (aizkolaris) | Wooloo, Skwovet, Teddiursa |
| **Ruta 21 · Viñedos de La Rioja** | Viñedos y bodegas, Logroño (calle Laurel) | Viñedos en hileras; bodega como cueva | Vendimiadores, sumilleres | Cherubi, Petilil, Sinistea |
| **Ruta 22 · Burgos y Atapuerca** | Catedral de Burgos, yacimientos de **Atapuerca** | Yacimiento con fósiles (excavación) | Arqueólogos, paleontólogos | Fósiles (Kabuto, Omanyte, Anorith), Cubone |
| **Ruta 23 · Cuéllar** | Tierra de Pinares de Segovia, castillo de Cuéllar, encierros a caballo | Pinares y el castillo; vuelta a San Miguel de Bernuy | Resineros, jinetes | Pineco, Nuzleaf, Ponyta |
| **Ruta 24 · La Mancha** | Molinos de viento de Consuegra y Campo de Criptana, llanuras, el Quijote | **Molinos de viento** como hito; llanura enorme | Un caballero que ataca a los molinos y su escudero (guiño al Quijote) | Hoppip, Swablu, Tauros, Doduo |
| **Ruta 25 · Despeñaperros** | Paso de Sierra Morena entre La Mancha y Andalucía; pantano del Montoro | Desfiladero con curvas; presa | Camioneros, cazadores | Gligar, Rhyhorn, Zubat |
| **Ruta 26 · El Torcal de Antequera** | Rocas kársticas apiladas del Torcal, dólmenes de Antequera | Laberinto de rocas | **Coto Matamoros**; escaladores | Roggenrola, Carbink, Nosepass |
| **Calle de la Victoria** | Calle estrecha junto a Sol | La **Calle Victoria** del juego: muy corta en la superficie y larga **bajo tierra** (las cloacas y los túneles del Metro) | Los entrenadores más fuertes | Pokémon de nivel alto |

- **Ruta 21:** viñedos con cepas en espaldera, Ebro y calados; Toño (vendimiador) y Diego (sumiller). Entrada Pamplona reservada al Agente 5. [Ficha y fuentes](ruta_21.md).

- **Ruta 22:** Burgos al oeste, Atapuerca al este y Arlanzón al sur del casco; Luis (arqueólogo) y Pablo (estudiante), encuentros 45–48. [Ficha, plano y fuentes](ruta_22.md). Enlazada con Ruta 21.

## Fuentes

- Datos generales de geografía y patrimonio (Acueducto de Segovia, Montserrat, palmeral de Elche, Doñana, Atapuerca, Torcal de Antequera, molinos de Consuegra): conocimiento general; posiciones contrastadas en OpenStreetMap (© colaboradores de OpenStreetMap, ODbL).
- Regatas de Sanxenxo del rey emérito, ferry Huelva–Canarias y vuelos Gran Canaria–Vigo: conocimiento general (comprobar horarios reales si se quiere fidelidad total).

- **Ruta 23:** Cuéllar y Tierra de Pinares, enlazada entre Valladolid y San Miguel. [Ficha y coordenadas](ruta_23.md).
