# Barcelona (gimnasio 2)

> **Decisión de Javier:** gimnasio 2, líder **Joan Laporta**, combate **en el Camp Nou**. Lo demás es **propuesta**.
>
> Planos reales: [`../planos/barcelona_centro.svg`](../planos/barcelona_centro.svg) (casilla = 40 m) y [`../planos/barcelona_camp_nou.svg`](../planos/barcelona_camp_nou.svg) (casilla = 8 m).

## Estado (2026-10-09)

- **`barcelona/les_corts` pintado** (`maps/_pintura/pintar_barcelona_les_corts.gd`, 64×48): se llega por la Diagonal desde la Ruta 8 (sin fundido). Al norte, Pedralbes y Les Corts; al sur, la explanada del **Spotify Camp Nou** (gimnasio 2, dibujado a mano con la tercera grada sin acabar y asientos vacíos) con dos grúas, La Masia, la tienda del Barça y el Basic-Fit. Entrenadores en `data/trainers/barcelona.json` (un socio y el jubilado de las obras) y encuentros de la ciudad en `data/encounters/barcelona.json` (con agua de mar para la Barceloneta y el puerto).
- **`barcelona/eixample` pintado** (`maps/_pintura/pintar_barcelona_eixample.gd`, 72×60, unido con Les Corts por la Diagonal): la cuadrícula de Cerdà (recta), el Passeig de Gràcia con **La Pedrera** y la **Casa Batlló**, la **Sagrada Família** con su grúa, Mercadona, estanco y la **Plaça de Catalunya** con fuentes, El Corte Inglés y el Centro Pokémon. Entrenadores: una de startup y un guiri.
- **`barcelona/ciutat_vella` pintado** (`maps/_pintura/pintar_barcelona_ciutat_vella.gd`, 72×60, unido con el Eixample por La Rambla): La Rambla con plátanos, una estatua humana y un carterista; el Raval con la **Boqueria**, el Liceu y el estanco; el Barri Gòtic con la **Catedral** y la Plaça Reial; el **Monumento a Colón**; el Port Vell con la terminal y el **ferry** atracado (la taquilla aún no vende billetes); la playa de la **Barceloneta** con el Centro Pokémon, la torre del socorrista y sombrillas. Mar con Surf y caña.
- El ferry ya lleva a Palma: pasarela (Warp) junto a la taquilla del puerto. No pide billete ni medalla (falta el evento).
- **Pendiente:** Park Güell y Montjuïc (opcionales).

## Cómo se reparte en el juego

| Mapa (id propuesto) | Zona real | Qué hay |
|---------------------|-----------|---------|
| `barcelona/eixample` | L'Eixample (la cuadrícula de Cerdà con las esquinas cortadas, *xamfrans*) | **Sagrada Família**, **Casa Batlló** y **La Pedrera** en el Passeig de Gràcia, Plaça de Catalunya |
| `barcelona/ciutat_vella` | Las Ramblas, Barrio Gótico, El Born, la Barceloneta | **La Rambla** (Boquería, estatuas humanas), **Catedral**, **Colón** al final de la Rambla, **Barceloneta** (playa) y el **puerto** (ferry a Palma) |
| `barcelona/les_corts` | Les Corts | **Spotify Camp Nou** (gimnasio 2) |
| `barcelona/montjuic` (opcional) | Montjuïc | Estadi Olímpic (donde jugó el Barça durante las obras), Fuente Mágica, Palau Nacional |
| `barcelona/park_guell` (opcional) | Gràcia, El Carmel | **Park Güell** (dragón de trencadís, banco ondulado) |

## Lugares reales y cómo se ven

| Lugar | Qué es | En el juego | Arte |
|-------|--------|-------------|------|
| **Sagrada Família** | Basílica de Gaudí, aún en obras; torres de las fachadas del Nacimiento y la Pasión | Monumento central de `barcelona/eixample`, con grúas siempre (chiste: "la acaban antes que el Camp Nou") | **Dibujar a mano** (pieza grande, prioridad alta) |
| **Passeig de Gràcia: Casa Batlló y La Pedrera** | Modernismo de Gaudí: tejado de dragón y fachada ondulada de piedra | Dos fachadas reconocibles en la avenida | Dibujar |
| **Cuadrícula del Eixample** | Manzanas cuadradas con esquinas en chaflán | El mapa entero sigue la cuadrícula a 45°... en el juego, recta (calles en cruz con chaflanes) | Calles y aceras del pack 02; edificios de viviendas del pack 01 |
| **Plaça de Catalunya** | Gran plaza con fuentes y palomas; El Corte Inglés | Plaza central con **grandes almacenes** | Componer |
| **La Rambla** | Paseo peatonal arbolado, quioscos, estatuas humanas, el **Mercat de la Boqueria** | Paseo con NPCs (estatuas humanas que se mueven al hablarles, carteristas que te "roban" una Poké Ball) | Árboles del pack 03 en fila; Boquería: componer |
| **Barrio Gótico y Catedral** | Calles estrechas de piedra; Catedral gótica | Laberinto pequeño | Componer con muros de piedra |
| **Monumento a Colón** | Columna con Colón señalando al mar | Final de la Rambla, junto al puerto | Dibujar |
| **Port Vell y terminal de ferris** | Puerto con los ferris a Baleares | **Ferry a Palma** (tramo 8 de `region.md`) | Barcos del pack 01 (el ferry de Ciudad Olivo) |
| **Barceloneta** | Playa urbana | Playa con Surf y bañistas | Arena y agua del pack 02 |
| **Spotify Camp Nou** | Estadio del Barça, reabierto en noviembre de 2025 con **aforo parcial**; faltan la tercera grada y la cubierta | **Gimnasio 2** (ver abajo) | Estadio grande del pack 01 (Campo de Batalla) como base, con grúas y lonas de obra |
| **Park Güell** | Parque de Gaudí con el dragón de trencadís | Zona opcional con encuentros | Dragón y banco: dibujar |
| **Montjuïc** | Montaña con el Estadi Olímpic y la Font Màgica | Opcional | Componer |

## Gimnasio 2: Laporta en el Camp Nou (propuesta)

- **Tipo:** Acero (las palancas, las grúas y un estadio que no se acaba nunca).
- **Recorrido:** el estadio **en obras**. Hay que cruzar andamios, grúas y la grada sin terminar; los entrenadores son obreros, socios con abono "en suspenso" y un comercial de las **palancas económicas** que te "vende" el siguiente pasillo.
- **Combate:** en el césped, con Laporta celebrando desde el palco antes de bajar. Frases en [`../personajes.md`](../personajes.md).
- Cuando se gana: un NPC dice que el estadio estará al 100 % "la temporada que viene" (y no cambia nunca).

## Personajes y combates (propuesta)

| Quién | Dónde |
|-------|-------|
| **Ibai Llanos** | Estudio de la Kings League (Cupra Arena) o en un directo en la Plaça de Catalunya |
| **Lamine Yamal, su padre HustleHard304 y su hermano Keyne** (combate triple) | Barrio de **Rocafonda (Mataró)**, código postal 08304 (el "304"), zona opcional por Rodalies; o en la Ciutat Esportiva del Barça |
| **Gerard Piqué** | Kings League (con Ibai) o en el puerto con un yate |
| **Aitana** | Concierto en el Palau Sant Jordi (Montjuïc) |
| **Pep Guardiola** | **Ruta 8**, en Santpedor (su pueblo, junto a Montserrat) |
| **Rosalía** | **Ruta 8**, en Sant Esteve Sesrovires (su pueblo) |

## Locales

**Centro Pokémon** en Plaça de Catalunya y en la Barceloneta; **Mercadona** en el Eixample; **Estanco** en la Rambla; **Basic Fit** en Les Corts, junto al Camp Nou.

## Pokémon de la zona (propuesta)

Ciudad: Pidove, Purrloin, Trubbish, Meowth; puerto y playa: Wingull, Pelipper, Krabby, Tentacool; Park Güell: Spinda, Smeargle (el pintor del trencadís).

## Conexiones

- **Oeste:** Ruta 8 (Montserrat) desde Zaragoza.
- **Puerto:** ferry a Palma de Mallorca.
- **Atocha–Sants:** AVE a Madrid (cuando esté desbloqueado).

## Fuentes

- Estado del Camp Nou: [FC Barcelona, Pase Spotify Camp Nou 2026/27](https://www.fcbarcelona.es/es/noticias/4510623/pase-spotify-camp-nou-202627), [3Cat](https://www.3cat.cat/esport3/el-futur-del-camp-nou-senreda/noticia/3328261/) y [Football España](https://www.football-espana.net/2026/04/02/april-2027-barcelona-set-target-to-have-camp-nou-operating-at-capacity).
- Lamine Yamal y su familia: [El Español](https://www.elespanol.com/corazon/famosos/20260720/keyne-hermano-pequeno-lamine-yamal-estrella-inesperada-mundial-talisman-seleccion/1003744328012_0.amp.html), [beIN Sports](https://www.beinsports.com/en-us/soccer/la-liga/articles/lamine-yamal-s-father-sets-social-media-ablaze-with-a-cryptic-message-2025-10-09).
- Planos: © colaboradores de OpenStreetMap (ODbL).
