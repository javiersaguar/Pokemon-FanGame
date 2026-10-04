# Recursos de terceros para descargar

Prueba de nivel gráfico, paso 1 (`docs/DIRECTRICES.md` §7). Lista preparada por el Agente 3; **Javier los descarga** en `assets/_terceros/<pack>/` (sin modificar) y los agentes copian de ahí lo que se use.

- Todos los enlaces son las páginas oficiales del recurso (comprobadas el 2026-10-04). La mayoría pide cuenta en Eevee Expo para descargar.
- **Licencias**: copiadas de la página de cada recurso. **Hay que confirmarlas al descargar** (el pack suele traer un `README` o un archivo de créditos). Cuando se use un recurso, va a `docs/arte/licencias.md` y a `CREDITOS.md`.
- Casi todos los packs de estilo oficial son **extraídos de los juegos** (Game Freak) o **derivados**: es lo normal en los fangames, pero son **solo para uso no comercial** (ya es nuestra regla) y suben el riesgo de retirada si el juego se hace muy visible.

> ⚠️ **Antes de descargar, decide esto (pregunta en `docs/ESTADO.md`):** algunos autores piden expresamente **no redistribuir** su pack (por ejemplo, PurpleZaffre). Si `assets/_terceros/` se sube al repo público de GitHub, eso es redistribuirlo. **Propuesta:** `assets/_terceros/` fuera de Git (en `.gitignore`, cada persona lo descarga) y en el repo solo los archivos que el juego usa de verdad, ya integrados en `assets/`.

---

## 1. Pokémon en combate (propuesta del set, A.3)

**Un mismo set para todas las especies**, frente y espalda, normal y **shiny con los colores oficiales**, más iconos.

| Opción | Recurso | Qué trae | Créditos | Enlace |
|--------|---------|----------|----------|--------|
| **A (recomendada)** | *Animated Pokemon System* (pack de sprites) | Sprites **animados** de todas las especies hasta la 9.ª gen, frente/espalda, normal y shiny, iconos y iconos shiny, huellas | Gen 1–5: Luka S.J.; Gen 6–9: colaboradores de los proyectos de sprites de Smogon (X/Y, Sol/Luna, Espada/Escudo, Escarlata/Púrpura); colaboradores del plugin español **"Sprites Animados"** (entre ellos **EricLostie, DPertierra y Skyflyer, el equipo de Añil**); iconos: Alaguesia, harveydentmd, Marin, MapleBranchWing, Larry Turbo, Leparagon, StarrWolf, equipo de Pokémon Shattered Light, LuigiTKO, ezerart, JordanosArt; recopilación: Golisopod User, UberDunsparce, Caruban, Lucidious89 | https://eeveeexpo.com/resources/1544/ (enlace **[SPRITES]**) |
| B | Carpetas de sprites de **Pokémon Showdown** (`gen5`, `gen5-shiny`, `gen5-back`, `gen5-back-shiny`) | Sprites **estáticos** estilo 5.ª gen de todas las especies (proyecto de sprites de Smogon). Los descarga el script del Agente 2 (`DIRECTRICES.md` §7, paso 2) | Game Freak; Smogon Sprite Project | (script del Agente 2) |

- **Por qué A:** es el **mismo linaje de sprites que usa Añil** (sprites animados de la comunidad española), así que da directamente su nivel en movimiento. Riesgos: según las reseñas, algunos sprites de 9.ª gen hechos por fans tienen tamaños o calidad irregulares (hay que revisarlos uno a uno) y muchos vienen ya ampliados (se reducen a la mitad exacta al importar, `BIBLIA.md` §5).
- **B** es la alternativa segura y coherente (todo estático; el "reposo" de 1 píxel se hace por código, A.5). **No se mezclan A y B.**

## 2. Tilesets (exterior, interior y cueva)

Para el Agente 1 (mapas de muestra, `DIRECTRICES.md` §7 paso 3).

| Recurso | Estilo | Autores a acreditar | Licencia / condiciones | Enlace |
|---------|--------|---------------------|------------------------|--------|
| *Ready to use Tilesets* (recopilación de Aki) | 4.ª/5.ª gen: **Gen 5 exterior**, **Gen 5 interior**, sets de Magiscarf (exterior e interior), Kyle-Dove, LotusKing, Kaliser, SailorVicious... | Cada artista del set que se use (UltimoSpriter; Akizakura16, Shiney570 y UltimoSpriter para el interior Gen 5; Magiscarf; Kyle-Dove...). **No acreditar a Aki** por recopilar | Uso libre acreditando al artista | https://eeveeexpo.com/resources/15/ |
| *Tileset ver.3 [Free\*]* | 4.ª/5.ª gen (muy usado) | Magiscarf | Gratis y editable **solo para uso no comercial** | https://www.deviantart.com/magiscarf/art/Tileset-ver-3-Free-690477146 |
| *Revamped Tiles* | 4.ª/5.ª gen | Magiscarf | CC BY-NC-SA 3.0 (no comercial, compartir igual) | https://www.deviantart.com/magiscarf/art/Revamped-Tiles-829482346 |
| *Big Tree Pack* | Árboles en perspectiva de 5.ª gen | AnonAlpaca | Uso libre acreditando; se pueden editar | https://eeveeexpo.com/resources/602/ |
| *Big Flora Pack* | Hierba alta, flores y plantas (5.ª gen) | AnonAlpaca | Uso libre acreditando; se pueden editar | https://eeveeexpo.com/resources/607/ |
| *Sinnoh Underground Tileset* | Cueva (4.ª gen) | Somersault | Uso libre acreditando | https://eeveeexpo.com/resources/732/ |

- **Cueva de 5.ª gen**: no he encontrado un set público claro; el más cercano es el de Somersault (4.ª gen). **PENDIENTE**: buscar más o hacerla a mano con la biblia.

## 3. Personajes del mapa

| Recurso | Qué trae | Créditos | Condiciones | Enlace |
|---------|----------|----------|-------------|--------|
| *ULTIMATE Gen 5 Overworlds Pack* | Todos los personajes humanos de Negro/Blanco y N2/B2 (casi 200), Pokémon que no siguen y objetos del mapa | PurpleZaffre (solo él) | **"Please do not redistribute this anywhere else."** (ver el aviso de arriba) | https://eeveeexpo.com/resources/619/ |

## 4. Pokémon que te siguen (normal y shiny)

| Recurso | Qué trae | Créditos | Enlace |
|---------|----------|----------|--------|
| *Following Pokemon EX* (v21.1) | En v21.1 incluye los sprites de seguidores en carpetas **normal y shiny** | NoNoNever, Golisopod User, Help-14, zingzags, Rayd12smitty, mej71, PurpleZaffre, Akizakura16, Thundaga, Armin, Maruno, Chubbichu | https://eeveeexpo.com/resources/516/ (port a v21.1: https://eeveeexpo.com/resources/1464/) |
| *Generation 8 Pack* (v20.1) | Sprites del mapa de todos los Pokémon hasta la 8.ª gen, con su lista de artistas por generación | La lista larga de la página (Gen 1–5, 6, 7 y 8) | https://eeveeexpo.com/resources/952/ |
| *Overworld Swimming Sprites* | Pokémon nadando (Surf), con shiny | Swdfm | https://eeveeexpo.com/threads/7300/ |

## 5. Fondos y bases de combate

| Recurso | Qué trae | Créditos | Enlace |
|---------|----------|----------|--------|
| *Elite Battle System: Gen 5 visual overhaul* | Fondos y bases de N2/B2 (256×192, el tamaño canónico), sprites de entrenadores de 5.ª gen y bolas | Fondos: Eli (extracción); bases: lilatraube; sprites: Game Freak, Pokecheck.org, Luka S.J., PinkCatDragon, Tebited15; bolas: Spriters-Resource (redblueyellow) | https://eeveeexpo.com/resources/24/ |
| *Elite Battle: DX* | Entornos de combate **modulares y animados** (cielo, agua, partículas): lo más parecido a la profundidad de los fondos de Añil | Luka S.J. y la lista de su página | https://luka-sj.com/essentials/resources/EBDX |
| *ORAS/XY themed battle backgrounds for EBDX* | Fondos estilo 6.ª gen para EBDX | Los de su página | https://eeveeexpo.com/resources/729/ |
| *How to make your own battle backgrounds* | Método + 5 fondos públicos (bosque, agua, cueva, nieve, bajo el agua) | Los de su pestaña de créditos | https://eeveeexpo.com/resources/40/ |

- Para la **muestra de combate** propongo empezar con los fondos y bases de *Elite Battle System* (encajan a 256×192) y probar uno de *EBDX* al lado para que elijas.

## 6. Fuente pixel

| Fuente | Licencia | ¿ñ, tildes, ¿¡? | Enlace |
|--------|----------|-----------------|--------|
| **Pixel Operator** (la actual) | CC0 1.0 | Sí (faltan º, ª, ♂, ♀) | https://www.dafont.com/pixel-operator.font |
| *Power Green Remade* (estilo de las fuentes de Essentials) | SIL OFL 1.1 | **Por comprobar** | https://fontstruct.com/fontstructions/download/2901783 |
| *Pokemon B/W* (estilo del diálogo de Negro/Blanco, "en desarrollo") | CC BY 3.0 | **Por comprobar** | https://fontstruct.com/fontstructions/show/563645/pokemon_b_w_1 |

- Las fuentes "Power ..." que trae Pokémon Essentials no tienen una licencia clara: **no las propongo**.

## 7. Entrenadores en combate

- Los sprites de entrenadores de 5.ª gen vienen en *Elite Battle System* (sección 5). Las **clases Panchito** no existen en ningún sitio: son **arte propio** (biblia §9). Lista de lo que falta en `docs/entrenadores.md`.
