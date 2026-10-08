# Arte de las ciudades: qué hay en los packs y qué falta

> Regla de Javier (DIRECTRICES §7): **prohibido el arte generado por código**. Los tiles salen de los packs de la comunidad (copiados tal cual o duplicando píxeles, como el tileset de exteriores) o de **arte hecho a mano** con el método aprobado (`.px` con la paleta, exportado a ×2, como la sombra de los personajes).

## Herramientas

| Herramienta | Qué hace |
|-------------|----------|
| `tools/mundo/osm_plano.py` | Plano real de una ciudad desde OpenStreetMap con la cuadrícula de casillas encima (`docs/mundo/planos/`). Sirve para colocar calles y monumentos donde están |
| `tools/mundo/catalogo_edificios.gd` | Recorta cada edificio de la hoja `BuildingsRMXP.png` del pack 01 y saca hojas de contacto numeradas en `tools/cache/edificios/` (no se suben). Los números de abajo son los de esa herramienta |
| `assets/tilesets/exterior/build_exterior.gd` | Monta el tileset de exteriores copiando las piezas de los packs; los edificios de ciudad se añaden aquí como objetos (como las casas) |
| `maps/_pintura/pintor.gd` | Pinta los mapas con el tileset (suelo, calles, bosque, agua, objetos) |

## Edificios del pack 01 (HGSS for RMXP) que sirven

Rectángulo en píxeles de `BuildingsRMXP.png` a ×1 (se duplican los píxeles al montarlos). Algunas piezas salen unidas en la hoja (marcado con ⚠️): hay que recortarlas a mano en el builder.

| N.º | Pieza (lo que es en HGSS) | Rectángulo (x, y, ancho, alto) | Para qué sirve en Pokémon Spain |
|-----|---------------------------|--------------------------------|---------------------------------|
| 5 | Centro Pokémon (tejado rojo) | 28, 12, 92, 92 | **Centro Pokémon** |
| 199 | Centro Pokémon grande (tejado naranja con la Ball) | 2320, 144, 104, 136 | Centro Pokémon de ciudad grande |
| 1, 2 | Tienda (tejado azul o morado) | 16, 268, 76, 76 · 16, 380, 76, 76 | Base del **Mercadona** y del **Estanco** (el cartel se dibuja a mano) |
| 9–45 | Gimnasios redondos de cada tipo (el color de la cúpula es el del tipo) | p. ej. 160, 56, 120, 100 | Gimnasios genéricos; los de Javier tienen edificio propio (abajo) |
| 47–83 | Gimnasios cuadrados de cada tipo | p. ej. 448, 28, 120, 92 | Ídem |
| 3, 4 | Edificio de la Liga | 16, 464, 104, 140 · 16, 636, 128, 156 | Entrada a la **Calle Victoria** |
| 117, 120 | Grandes almacenes de Ciudad Trigal | 1168, 768, 120, 124 · 1184, 624, 112, 124 | **El Corte Inglés** (Sol, Plaça de Catalunya) |
| 123 ⚠️ | Estadio redondo con cúpula (en dos mitades) | 1312, 148, 128, 428 | Base del **Camp Nou**, **San Mamés** y el **Bernabéu** |
| 119 | Edificio blanco con gradas | 1176, 12, 120, 148 | Estadios pequeños (Coliseum, Butarque) |
| 116 ⚠️, 209–212 | Torre de radio y rascacielos de cristal | 1168, 164, 128, 436 · 2464, 364, 128, 420 | **Cuatro Torres**, **Benidorm**, Torre Picasso |
| 185 | Edificio alto con torre | 2032, 856, 128, 256 | Edificio Telefónica (Gran Vía) |
| 108, 186, 190 | Oficinas y bloques de pisos | 1024, 352, 100, 120 · 2032, 1132, 108, 136 · 2176, 96, 96, 124 | **Ferraz** (sede del Clan), fincas de **Chamberí** |
| 100 | Edificio con jardín en la azotea | 888, 552, 120, 96 | **Ático de Ayuso** (terraza con plantas) |
| 188 | Edificio con cúpula | 2044, 644, 92, 104 | Base para la cúpula del **Edificio Metrópolis** |
| 191 ⚠️ | Edificio de neón (casino) | 2176, 564, 128, 344 | **Akuarela** (discoteca), Real Casino de Murcia, Gran Casino del Sardinero |
| 112, 113 | Teatro con toldo de circo; casino morado y oro | 1024, 1028, 88, 88 · 1024, 1140, 120, 88 | **Club de la comedia** (Sevilla), Teatro Príncipe Gran Vía |
| 205 | Gimnasio de madera | 2320, 1112, 120, 92 | Interior-exterior del club de monólogos |
| 147, 153, 154 ⚠️, 175, 200 | Puestos de mercado y toldos de rayas | 1524, 164, 60, 72 · 1600, 980, 128, 60 | **Mercado de San Miguel**, **Boquería**, **Mercado Central** |
| 149 | Faro de Ciudad Olivo | 1600, 4, 128, 192 | **Faro de Maspalomas**, Torre de Hércules |
| 142 | Torre octogonal | 1468, 352, 64, 112 | **Torre del Oro** (Sevilla) |
| 150 | Barco S.S. Aqua | 1600, 376, 120, 104 | **Ferris** (Barcelona, Ibiza, Huelva) |
| 141 | Velero | 1460, 1136, 88, 88 | **Regatas de Sanxenxo**, yates de Muelle Uno |
| 163 | Torre de socorrista | 1772, 124, 40, 68 | Playas (Malvarrosa, Playa del Inglés, Barceloneta) |
| 106 | Arco de jardín | 1024, 176, 104, 84 | Entradas de parques |
| 101, 102, 162 | Casas de paja y cabaña | 888, 948, 80, 108 · 1756, 204, 76, 76 | Hórreos y casas rurales (Galicia, Asturias) |
| 156, 157, 171–173, 192–197 | Casas y tiendas pequeñas | (ver el catálogo) | Casas de pueblo y barrios |

## Otros packs

| Pack | Qué sirve |
|------|-----------|
| 01, `UrbanRMXP.png` | Suelos de plaza y adoquín, **fuentes**, estatuas, farolas, bancos, papeleras, señales, **molinos de viento** (La Mancha, Palma), sombrillas de playa, vallas, puentes de piedra y de madera |
| 02, `Custom Outside tileset.png` | Casas de DPPt, Centro Pokémon de DPPt, adoquín, farolas, bancos, escaleras, murallas y ruinas de piedra (Ávila, Pamplona, Dalt Vila), acantilados, playa, nieve |
| 03 y 04 | Árboles (pinos, cerezos, palmeras no: **faltan palmeras**), setos y flores |
| 10 y 16 | Fondos de combate de ciudad, playa, cueva, nieve, desierto e interior |

## Lo que no está en ningún pack (hay que dibujarlo a mano)

Por orden de prioridad (lo que más identifica a cada ciudad). Cada pieza, con la paleta de la biblia (`docs/arte/BIBLIA.md`) y a la escala de los packs.

| Prioridad | Pieza | Ciudad | Tamaño orientativo (casillas) |
|-----------|-------|--------|-------------------------------|
| 1 | Fachada del **Palacio Real** | Madrid (Liga) | 16 × 8 |
| 1 | **Real Casa de Correos** con el reloj | Madrid (gimnasio 1) | 8 × 7 |
| 1 | **Sagrada Família** | Barcelona | 8 × 10 |
| 1 | **Giralda** y Catedral | Sevilla | 4 × 9 |
| 1 | **Basílica del Pilar** | Zaragoza | 12 × 7 |
| 1 | **Guggenheim** con Puppy | Bilbao | 10 × 6 |
| 1 | Iglesia de **San Miguel Arcángel** | San Miguel de Bernuy | 5 × 6 |
| 2 | Puerta de Alcalá, Cibeles, Oso y el Madroño, Templo de Debod, Arco de la Victoria | Madrid | 3–6 |
| 2 | Casa Batlló, La Pedrera, Colón | Barcelona | 3–5 |
| 2 | Plaza de España, Torre del Oro (si no vale la 142), Setas | Sevilla | 6–14 |
| 2 | La Seu y Bellver | Palma | 6–8 |
| 2 | Micalet, Torres de Serranos, Ciudad de las Artes | Valencia | 4–10 |
| 2 | Catedral barroca | Murcia | 6 × 7 |
| 2 | Mosaico ondulado de la Explanada (tile repetible) | Alicante | 1 × 1 |
| 2 | Fachada roja de la Plaza Mayor y estatua del Conde Ansúrez | Valladolid | — |
| 2 | Monumento al Minero y castillete | Puertollano | 2 × 6 |
| 2 | La Manquita, cubo del Pompidou | Málaga | 4–6 |
| 2 | Luces de Navidad (adorno animado) y árbol gigante | Vigo | — |
| 2 | Palacio de la Magdalena, Centro Botín | Santander | 6–8 |
| 2 | Quiosco de la Plaza del Castillo, balcón del chupinazo | Pamplona | 3–4 |
| 2 | Catedral de Santa Ana con balcones canarios | Las Palmas | 6 × 7 |
| 3 | **Palmeras** (no hay en los packs 03 y 04) | Elche, Alicante, Málaga, Valencia, Canarias | 2 × 4 |
| 3 | Carteles: Mercadona, Estanco ("Tabacos"), Basic Fit, Schweppes | Todas | 2–4 × 1 |
| 3 | Acueducto de Segovia (tramo repetible) | Ruta 2 | 3 × 5 |
| 3 | Molinos de La Mancha (si no valen los del pack 01) | Ruta 24 | 2 × 4 |

Mientras no estén, cada monumento se coloca con la pieza más parecida de los packs (tabla de arriba) y se marca como **provisional** en `docs/arte/seguimiento.md`.
