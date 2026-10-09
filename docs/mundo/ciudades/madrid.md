# Madrid (gimnasio 1 y Liga Pokémon)

> **Decisión de Javier:** gimnasio 1, líder **Isabel Díaz Ayuso**, combate final **en su ático**. **Liga Pokémon dentro del Palacio Real** (Alto Mando: Iniesta, Nadal, Gasol y Alonso; Líder Supremo: Pedro Sánchez). Móstoles, Leganés y Getafe son pueblos al sur (ficha aparte: [`sur_de_madrid.md`](sur_de_madrid.md)). Lo demás es **propuesta**.
>
> Planos reales: [`../planos/madrid_centro.svg`](../planos/madrid_centro.svg) (casilla = 30 m), [`../planos/madrid_palacio_real.svg`](../planos/madrid_palacio_real.svg) (casilla = 6 m) y [`../planos/madrid_bernabeu_castellana.svg`](../planos/madrid_bernabeu_castellana.svg).

## Estado (2026-10-09)

- **`madrid/moncloa` pintado** (`maps/_pintura/pintar_madrid_moncloa.gd`, 64×52): llegada por la A-6 desde la Ruta 4 (oeste, sin fundido), Palacio de la Moncloa tras la verja (la puerta no se alcanza: hay un escolta; se abrirá con la trama), Faro de Moncloa, glorieta del **Arco de la Victoria** (se pasa por debajo), Princesa, **Ferraz 70** (sede del Clan, con dos reclutas: `data/trainers/madrid.json`), El Corte Inglés de Princesa, **Centro Pokémon**, **Mercadona** y **estanco** de Argüelles, Plaza de España (Cervantes provisional: fuente y busto) y el Parque del Oeste con el **Templo de Debod**, su puerta y el estanque. Encuentros de la ciudad en `data/encounters/madrid.json`.
- Monumentos dibujados a mano: Arco de la Victoria, Templo de Debod (y su puerta), Faro de Moncloa.
- **`madrid/centro` pintado** (`maps/_pintura/pintar_madrid_centro.gd`, 72×56, todo de baldosas): Gran Vía en escalones desde la Plaza de España (unida sin fundido con Moncloa) hasta el Edificio Metrópolis; Callao con el Edificio Carrión y su cartel de Schweppes; la cola de Doña Manolita; El Corte Inglés de Preciados; la **Puerta del Sol** con la **Real Casa de Correos (gimnasio 1)**, el Kilómetro 0, la fuente, Carlos III (busto provisional) y el Oso y el Madroño; la **Plaza Mayor** (Casa de la Panadería, soportales, Arco de Cuchilleros, estanco con lotería) y el Mercado de San Miguel; Centro Pokémon; Barrio de las Letras con el Teatro Español. Entrenadores de ciudad (cuñado, influencer, tertuliano, turista). La Casa de Correos mira al sur, a Sol (en el juego las puertas dan al sur).
- **`madrid/palacio_real` pintado** (`maps/_pintura/pintar_madrid_palacio_real.gd`, 64×56): Jardines de Sabatini, el **Palacio Real** (fachada sur, a la Plaza de la Armería; dentro irá la Liga; dos guardias reales en la puerta), la verja con la puerta abierta, la **Catedral de la Almudena** (mira al sur en el juego), el Campo del Moro con hierba alta y el Mirador de la Cornisa, la calle de Bailén, la **Plaza de Oriente** (Felipe IV a caballo, ocho reyes, jardín) con el **Teatro Real**, el Senado y la calle del Arenal hacia Sol.
- Conexiones: Ruta 4 ⇄ Moncloa (A-6); Moncloa ⇄ centro (Plaza de España); centro ⇄ Palacio Real (Arenal). Un mismo borde puede llevar a varios mapas con `MapConnection.span`.
- **Pendiente:** conexión de `madrid/centro` al este por Alcalá (y 22–25 y 32–34) con `madrid/retiro`; de Moncloa al este (Argüelles, y 14–39) con `madrid/chamberi`; la Calle de la Victoria (mazmorra hacia la Liga) sale de Sol hacia el sur; el monumento a Cervantes de verdad; Ábalos y Koldo (los coloca Javier); interiores.

## Cómo se reparte en el juego

Madrid no cabe en un mapa: se divide en **barrios conectados** (como Ciudad Azafrán o Ciudad Luminalia), cada uno con lo más reconocible de esa zona y las calles en su orientación real.

| Mapa (id propuesto) | Zona real | Qué hay |
|---------------------|-----------|---------|
| `madrid/moncloa` | Moncloa y Argüelles (entrada desde la Ruta 4, por la A-6) | **Arco de la Victoria**, Faro de Moncloa, Palacio de la Moncloa (primer encuentro con el Clan PSOE), **calle Ferraz** (sede del Clan), Templo de Debod |
| `madrid/centro` | Plaza de España, Gran Vía, Sol y Plaza Mayor | **Puerta del Sol** (reloj, Kilómetro 0, Oso y el Madroño, **Real Casa de Correos = gimnasio**), **Gran Vía** (cartel de Schweppes, Edificio Metrópolis, Telefónica), Plaza Mayor, Mercado de San Miguel, **calle de la Victoria** |
| `madrid/palacio_real` | Palacio Real, Plaza de Oriente, Almudena | **Liga Pokémon** (exterior del Palacio y jardines de Sabatini) |
| `madrid/retiro` | Cibeles, Puerta de Alcalá, Retiro, Paseo del Prado, Congreso y Atocha | **Cibeles** (Ayuntamiento: Almeida), **Congreso** (agitadores en la puerta), **Retiro** (estanque, Palacio de Cristal), Museo del Prado, **estación de Atocha** (AVE) |
| `madrid/chamberi` | Chamberí | **El ático de Ayuso** (combate final del gimnasio) |
| `madrid/castellana` (opcional) | Paseo de la Castellana norte | **Santiago Bernabéu**, Cuatro Torres, Torre Picasso |
| `madrid/cloacas` | Bajo el centro | Mazmorra de **Leire Díez, "la fontanera"** |

## Lugares reales y cómo se ven

| Lugar | Qué es | En el juego | Arte |
|-------|--------|-------------|------|
| **Puerta del Sol** | Plaza semicircular; la **Real Casa de Correos** (sede de la presidencia de la Comunidad) con el **reloj de las campanadas**; placa del **Kilómetro 0**; estatuas del **Oso y el Madroño** y de Carlos III a caballo | Plaza central del mapa `madrid/centro`. La Casa de Correos es el **gimnasio 1**. En Nochevieja (reloj real del juego) salen **Chicote y Pedroche** dando las campanadas | Componer: fachada de ladrillo y piedra con torre del reloj (no hay en los packs: **dibujar a mano**). Estatuas: dibujar |
| **Gran Vía** | Avenida de teatros y cines de principios del XX; **Edificio Metrópolis** (cúpula negra con la Victoria alada), **Telefónica**, cartel de **Schweppes** en el Edificio Carrión, **Teatro Príncipe Gran Vía** (*La Revuelta* de Broncano) | Calle diagonal (como la real) con edificios altos, carteles luminosos y gente | Edificios altos de Ciudad Trigal (pack 01) para las fachadas; cúpula del Metrópolis y cartel de Schweppes: dibujar |
| **Plaza Mayor** | Plaza porticada rectangular con la estatua de Felipe III; Casa de la Panadería pintada | Plaza cerrada con soportales y bocadillos de calamares | Soportales: componer con paredes del pack 01 |
| **Mercado de San Miguel** | Mercado de hierro y cristal | Tienda especial de comida (bayas y objetos curativos caros: "precio de turista") | Componer |
| **Palacio Real** | Palacio barroco de piedra blanca, con la Plaza de la Armería, la Catedral de la Almudena enfrente y los jardines de Sabatini y el Campo del Moro | **Liga Pokémon** (ver abajo) | Fachada del palacio: **dibujar a mano** (pieza grande, prioridad alta) |
| **Plaza de Oriente** | Jardines con estatuas de reyes y el Teatro Real | Antesala de la Liga | Estatuas: dibujar; setos: pack 04 |
| **Templo de Debod** | Templo egipcio sobre un estanque, al atardecer | Lugar de un encuentro especial (¿Sigilyph o un Pokémon "egipcio"?) | Dibujar |
| **Arco de la Victoria y Faro de Moncloa** | Arco monumental y torre-mirador a la entrada por la A-6 | Entrada a Madrid desde la Ruta 4 | Arco: dibujar; torre: componer con la torre de radio del pack 01 |
| **Palacio de la Moncloa** | Residencia del presidente, tras una verja | **Primer encuentro con Ábalos y Koldo** (Clan PSOE) | Verja y edificio: componer |
| **Calle Ferraz** | Sede del PSOE (Ferraz 70) | **Base del Clan PSOE** (mazmorra tras el gimnasio 1) | Edificio de oficinas del pack 01 con el logo del Clan |
| **Cibeles** | Fuente de la diosa en su carro de leones; detrás, el Palacio de Cibeles (Ayuntamiento) | Glorieta con la fuente; el Ayuntamiento es donde está **Almeida** | Fuente: dibujar; palacio: componer |
| **Puerta de Alcalá** | Puerta neoclásica en la glorieta de la Independencia | Entrada al Retiro | Dibujar |
| **Parque del Retiro** | Estanque grande con barcas y el monumento a Alfonso XII; **Palacio de Cristal** | Zona verde con hierba alta (encuentros) y barcas | Árboles y setos de los packs 03 y 04; Palacio de Cristal: dibujar |
| **Congreso de los Diputados** | Edificio neoclásico con los leones de bronce | **Vito Quiles y Bertrand Ndongo** a la puerta, micrófono en mano | Leones y fachada: dibujar |
| **Museo del Prado** | Pinacoteca en el Paseo del Prado | Interior con cuadros (un NPC que imita a *Las Meninas*) | Componer |
| **Estación de Atocha** | Estación con el jardín tropical dentro; AVE | Estación de **AVE** (viaje rápido; siempre con retraso: Óscar Puente) | Componer |
| **Santiago Bernabéu** | Estadio del Real Madrid con la nueva cubierta de lamas metálicas | Lugar opcional (Real Madrid) | Estadio grande del pack 01 (Campo de Batalla) como base |
| **Cuatro Torres** | Rascacielos al norte de la Castellana | Fondo del mapa opcional | Rascacielos de Ciudad Trigal (pack 01) |
| **Calle de la Victoria** | Calle estrecha entre Sol y la calle de Alcalá | **La Calle Victoria del juego** antes del Palacio Real | Calle del pack 02 |
| **Chamberí** | Barrio de fincas señoriales | **Ático de Ayuso** | Edificio de viviendas del pack 01 con terraza en la azotea |

## Gimnasio 1: Ayuso (propuesta)

- **Edificio:** la **Real Casa de Correos** en la Puerta del Sol (es de verdad la sede de la presidencia de la Comunidad de Madrid).
- **Tipo:** Fuego (ver `region.md`).
- **Recorrido:** una "ruta de las terrazas" con entrenadores de bar (camareros, el del vermut, una influencer de brunch). Puzle: hay que pagar las cañas en el orden correcto para abrir las puertas. Mensajes de "libertad" en cada mesa.
- **Combate final en su ático:** tras el gimnasio, un ascensor lleva al **ático de Chamberí** (azotea con vistas a las Cuatro Torres). Allí está Ayuso. Medalla y frases en [`../personajes.md`](../personajes.md).

## Liga Pokémon en el Palacio Real (decisión de Javier)

| Sala (propuesta) | Quién | Ambiente |
|------------------|-------|----------|
| Salón de Columnas | **Andrés Iniesta** | Silencio, pasillos estrechos (la visión de juego) |
| Salón del Trono | **Rafa Nadal** | Suelo de tierra batida sobre la alfombra roja |
| Comedor de Gala | **Pau Gasol** | Mesa larguísima; techo altísimo |
| Armería Real | **Fernando Alonso** | Coches y armaduras; el número 33 por todas partes |
| Salón de Gasparini → Plaza de la Armería | **Pedro Sánchez**, Líder Supremo | Sale en el **Falcon** que aterriza en la Plaza de la Armería |

El rey **Felipe VI** recibe al campeón en el Salón del Trono después (Hall de la Fama). Ver `../personajes.md`.

## Personajes y combates en Madrid (propuesta)

| Quién | Dónde |
|-------|-------|
| **Chicote y Cristina Pedroche** (combate doble) | Puerta del Sol, en las campanadas (si el reloj del juego marca Nochevieja; si no, en un plató junto al reloj) |
| **Almeida** | Ayuntamiento de Cibeles |
| **David Broncano** | Teatro Príncipe Gran Vía (*La Revuelta*), con su invitado misterioso |
| **Vito Quiles y Bertrand Ndongo** | Puerta del Congreso |
| **Belén Esteban** y **Jorge Javier** | Platós de televisión (zona opcional de la Castellana) |
| **Ester Expósito** | Gran Vía, en un estreno |
| **Enrique Iglesias** | Concierto en el Bernabéu (opcional) |
| **Ábalos y Koldo** | Moncloa (primer encuentro) y Ferraz |
| **Leire Díez** | Cloacas |
| **Felipe VI** | Palacio Real (tras la Liga) |

## Locales

- **Centro Pokémon** en Sol y en Atocha.
- **Mercadona** en Argüelles y en Lavapiés.
- **Estanco** en la Plaza Mayor (con lotería: el **Gordo de Navidad** como evento).
- **Basic Fit** en la Gran Vía.
- Tiendas especiales: Mercado de San Miguel (comida cara) y El Corte Inglés de Sol como **grandes almacenes** (como el de Ciudad Trigal).

## Pokémon de la zona (propuesta)

Ciudad: Pidove y Tranquill (palomas de la Plaza Mayor), Rattata, Trubbish, Grimer en las cloacas, Garbodor, Meowth, Purrloin. Retiro: Pikipek, Squirrel-tipo (Skwovet), Ducklett en el estanque.

## Conexiones

- **Noroeste:** Ruta 4 (llegada desde la sierra).
- **Sur:** Cercanías C-5 → Getafe, Leganés y Móstoles.
- **Este:** Ruta 5 (Corredor del Henares) hacia Zaragoza.
- **Atocha:** AVE a Valladolid, a Málaga (por Puertollano) y a Barcelona.

## Fuentes

- Planos: © colaboradores de OpenStreetMap (ODbL).
- Real Casa de Correos (sede de la presidencia de la Comunidad de Madrid), Teatro Príncipe Gran Vía (*La Revuelta*), Ferraz 70 (sede del PSOE) y Calle de la Victoria: conocimiento general, contrastado en OSM.
