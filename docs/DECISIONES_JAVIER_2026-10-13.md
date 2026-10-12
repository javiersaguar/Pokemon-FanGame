# Decisiones de Javier · 2026-10-13

> Respuestas de Javier a las preguntas abiertas de `docs/ESTADO.md`. **Mandan sobre cualquier propuesta anterior** de ESTADO, del GDD y de `docs/mundo/`. Aquí solo se documentan: **los cambios se hacen en sesiones siguientes**, no se ha tocado código, datos ni mapas.
>
> Imágenes que adjuntó Javier: [`docs/arte/referencias/javier_2026-10-13/`](arte/referencias/javier_2026-10-13/).

## 1. Arte

| Tema | Decisión |
|---|---|
| Monumentos hechos con scripts de ayuda (`.px2`) | **Valen como provisionales.** Se retocarán bastante, **uno a uno**, más adelante. |
| Pueblo y ruta de muestra rehechos (preguntas 19 y 20) | **Aprobados.** Todos los mapas se repasarán uno a uno cuando el juego esté más avanzado. |
| Escaleras sin barandilla | Valen así. |
| Entrenadores del pack 12 (pregunta 21) | Duplicar píxeles, ×2 exacto. |
| Fondo de combate con linde de bosque (pregunta 24) | Sí; hacer igual cueva, agua, ciudad, interior y las versiones de noche. |
| Logo (pregunta 27) | Cerrada: vale la portada de Javier. |
| Música (pregunta 29) | **A** (JRPG Pack 1 Exploration, CC0) como base y **B** (4 Chiptunes Adventure) para las rutas. |
| Medallas (pregunta 30) | Javier adjunta sus diseños: [`medallas.webp`](arte/referencias/javier_2026-10-13/medallas.webp). Coinciden en nombre y tipo con `data/gimnasios.json`: Libertad (Madrid, Fuego), Palanca (Barcelona, Acero), Tirantes (Valencia, Lucha), Arte (Sevilla, Planta), Quédate (Las Palmas, Agua), Txapela (Bilbao, Lucha/Fuego), Pucela (Valladolid, Hielo) y Zorro (Málaga, Siniestro). Mapa regional: la propuesta (`docs/mundo/mapa_region.svg` como base). |
| Estilo de los personajes | Javier adjunta dos sprites de referencia hechos fuera del repo, de Rufián y de Zapatero: [`sprites_rufian_zapatero.png`](arte/referencias/javier_2026-10-13/sprites_rufian_zapatero.png). Es el tipo de diseño que quiere para los personajes. |

## 2. Inicio de la partida (cambia el diseño)

- **Iniciales aleatorios en cada partida, de cualquier generación.** Ya no hay tres iniciales fijos.
- **Profesor: Unicoos**, el del canal de YouTube que enseña matemáticas. Foto: [`profesor_unicoos.png`](arte/referencias/javier_2026-10-13/profesor_unicoos.png).
- **Tono: parodia total**, también en la trama.
- **Elección de personaje y pueblo inicial (funcionalidad nueva).** Diseños: [`protagonistas_cayetana_choni_cayetano_cani.webp`](arte/referencias/javier_2026-10-13/protagonistas_cayetana_choni_cayetano_cani.webp).

  | Si eliges | Opciones | Empiezas en |
  |---|---|---|
  | Chico | **Cayetano** o **Cani** | Cayetano: **Pozuelo de Alarcón**. Cani: **Orcasitas** |
  | Chica | **Cayetana** o **Choni** | Cayetana: **Pozuelo de Alarcón**. Choni: **Orcasitas** |

  En la ruta de Orcasitas te puedes encontrar con **El Jincho**. Foto: [`el_jincho.png`](arte/referencias/javier_2026-10-13/el_jincho.png).

  Esto sustituye a los protagonistas "chico B y chica A" de la pregunta 23. **Queda por decidir** qué pasa con San Miguel de Bernuy, que hoy es el pueblo inicial: Javier sigue queriendo salir allí como entrenador al volver por la Ruta 23 (ver §4).
- **Pokédex: todos los Pokémon del juego.** A algunos se les pondrá una *skin* predeterminada, por ejemplo a los iniciales.
- **Herramientas de campo (pregunta 19 de A1):** objetos clave sin MO, uno por medalla: Corte con la 1, Golpe Roca con la 2, Surf con la 3, Fuerza con la 4, Vuelo con la 5 y Cascada con la 7.

## 3. Gimnasios y Madrid

- **Interiores de los gimnasios:** se construyen según `docs/mundo/gimnasios.md`; el resto de diseños los va haciendo el agente.
- **Gimnasio 1 (Ayuso):** antes del combate final te **teletransportas con Ayuso a la terraza de su ático en Chamberí**, y se combate allí.
- **Hospitales reales, uno reconocible por ciudad** (La Paz, Clínic, La Fe…). **El de Madrid es el Quirón:** hay que enfrentarse a **enfermeros** y al final está **Ayuso, que te da acceso al primer gimnasio**. Antes de eso no se puede entrar a retarla.
- **Cercanías C-5:** gratis, se abre tras la 1.ª medalla y tiene un retraso de chiste 1 de cada 4 veces. **Al principio no se puede usar por avería.**
- **Sur de Madrid:** entrenadores de nivel temprano (14–17), sin segunda versión.
- **Calle de la Victoria:** buscar un pack de alcantarillas o de Metro y **hacerla larga**.

## 4. Personajes

| Personaje | Decisión |
|---|---|
| Dónde va cada famoso | Se verá más adelante. Los ya colocados se revisan en el F9. |
| **Vito Quiles** | Segunda aparición en Elche **como revancha**. Además aparece en **Barcelona, en casa de Gabriel Rufián, en su habitación**. |
| **Ábalos y Koldo** | Segundo encuentro en la Albufera (con 3 medallas). También se les puede encontrar más adelante en la **cárcel de Soto del Real**. **Cuando les ganas un combate, aparecen coches de policía y se los llevan detenidos.** |
| **Abascal** | Dos apariciones, como jefe recurrente. |
| **Javier** | En San Miguel de Bernuy al volver por la Ruta 23, con equipo fuerte y su foto real. |
| **Sekiam y PokeAlex** | Javier adjunta una foto de cada uno: [`streamer_1_sekiam_o_pokealex.webp`](arte/referencias/javier_2026-10-13/streamer_1_sekiam_o_pokealex.webp) y [`streamer_2_sekiam_o_pokealex.webp`](arte/referencias/javier_2026-10-13/streamer_2_sekiam_o_pokealex.webp). **Falta que Javier confirme cuál es cuál** (no venían con nombre). |
| **Zapatero** | Imagen con las joyas: [`zapatero_joyas.png`](arte/referencias/javier_2026-10-13/zapatero_joyas.png). **Cuando le ganas en combate te da las joyas, y se pueden vender por muchas monedas (euros).** |
| Combates triples (Lamine y familia; Folagor, Sekiam y PokeAlex) | **Tres combates seguidos, con curación automática después de cada uno.** No se hacen triples de verdad. |
| Líderes: tipos y equipos | Vale la propuesta de `docs/mundo/region.md`. |

**Clases de entrenador nuevas que pide Javier:** perroflauta, cayetano, cani, **pueblerino** (en los pueblos), **gitanos**, **manteros** (en las ciudades grandes) y **turistas** (en las ciudades grandes). Las clases que ya hay valen como provisionales.

## 5. Mundo

| Tema | Decisión |
|---|---|
| Interiores | **Todos los edificios tienen interior.** |
| Aeropuerto en Playa del Inglés | Vale así. |
| Palos y La Rábida (carabelas) | Añadirlo como **zona opcional**. |
| Basic-Fit | Sube EVs pagando. Además existe el objeto **mochila del Basic-Fit**; su uso se decidirá más adelante. |
| Lotería del estanco | Sorteo diario con premio pequeño. |

## 6. Sistemas

| Tema | Decisión |
|---|---|
| Shedinja en RandomLocke (pregunta 28) | Bonus de evolución que no gasta zona, con mote obligatorio. |
| Recordador y tutores (pregunta 31) | Recordador gratis en cada Centro u Hospital; tutores en 3 o 4 ciudades, pagando. |
| MT | Una por líder (ya hecho), el resto en tiendas según medallas y algunas por el suelo. |
| Modo difícil | Sí, opcional: +10 % de nivel e IA un nivel más alta. |
| **RandomLocke** | **Caramelos raros infinitos y tope de nivel (*level cap*).** |

## 7. Lo que queda abierto tras estas respuestas

1. Cuál de las dos fotos es Sekiam y cuál PokeAlex.
2. Qué papel tiene San Miguel de Bernuy ahora que se empieza en Pozuelo o en Orcasitas, y cómo se llega desde allí al resto del mapa.
3. Nombre por defecto del rival y si también cambia según el personaje elegido.
4. Uso de la mochila del Basic-Fit.
5. Qué *skins* llevan qué Pokémon.
6. Dónde va cada famoso que aún no está colocado.
7. En los sprites de referencia de Rufián y Zapatero, se entiende que el de arriba es Rufián y el de abajo Zapatero (por el orden en que los nombró Javier); confirmar.
