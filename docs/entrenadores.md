# Entrenadores Spain

Registro de clases y entrenadores (Fase 10 de la guía). **Imprescindible para el balanceo (Fase 20).**

- Datos de las clases: `data/trainer_classes.json`.
- Entrenadores concretos: `data/trainers/<zona>.json` (un archivo por zona).
- Formato de ambos archivos: `docs/contratos.md`, sección *Entrenadores*.

> **Valores provisionales.** El dinero base y el nivel de IA de cada clase son una primera propuesta: se ajustan en el balanceo (Fase 20).
> Los equipos dependen de la Pokédex regional y de los iniciales, que están **PENDIENTE JAVIER** (ver `docs/GDD.md`): hasta entonces usan especies provisionales.

Leyenda de sprites: ✅ terminado · 🟨 provisional (placeholder) · ⏳ falta.

Los **sprites** (combate y mapa) los monta el **Agente 4** con el pack 11. El traspaso (qué hay, rutas y orden) está en `docs/ESTADO.md`, sección del Agente 3. Los datos de esta página siguen siendo del Agente 3.

---

## 1. Registro de entrenadores

| ID | Clase | Nombre | Mapa | Nivel medio | Obligatorio | Sprite combate | Sprite mapa |
|----|-------|--------|------|-------------|-------------|----------------|-------------|
| `rival_lab_1` | `rival` | {rival} | Laboratorio (pueblo inicial) | 5 | Sí (se puede perder) | ⏳ | ⏳ |
| `rival_lab_2` | `rival` | {rival} | Laboratorio (pueblo inicial) | 5 | Sí (se puede perder) | ⏳ | ⏳ |
| `rival_lab_3` | `rival` | {rival} | Laboratorio (pueblo inicial) | 5 | Sí (se puede perder) | ⏳ | ⏳ |
| `ruta1_manolo` | `vendedorchupachups` | Manolo | Ruta 1 | 4 | Sí (MVP) | ⏳ | ⏳ |

---

## 2. Clases

Propuesta inicial: las 20 clases de la tabla 10.2 de la guía y el rival. Objetivo: **25–40 clases** (las nuevas, **PENDIENTE JAVIER**).

| ID | Nombre en el juego | Sexo | Dinero base | IA | Tema del equipo (sugerencia de la guía) | Zona sugerida | Sprite combate | Sprite mapa |
|----|--------------------|------|-------------|----|------------------------------------------|---------------|----------------|-------------|
| `rival` | *(solo el nombre del rival)* | Mixto | 48 | 1 | Inicial con ventaja sobre el tuyo | Historia | ⏳ | ⏳ |
| `vendedorchupachups` | Vendedor de Chupachups | Hombre | 24 | 1 | Hada y dulces: Swirlix, Slurpuff, Applin, Alcremie | Ruta 1, ferias | ⏳ | ⏳ |
| `flautista` | Flautista | Mixto | 24 | 1 | Sonido: Whismur, Loudred, Kricketune, Noibat | | ⏳ | ⏳ |
| `peruana150` | Peruana de 1,50 | Mujer | 16 | 1 | Pequeños pero matones: Joltik, Cutiefly, Flabébé, Klefki | | ⏳ | ⏳ |
| `robasientos` | Robasientos del metro | Hombre | 16 | 1 | Rapidísimos: Ninjask, Jolteon, Electrode, Accelgor | Metro, ciudad | ⏳ | ⏳ |
| `cunado` | Cuñado que sabe de todo | Hombre | 32 | 1 | Normal "todoterreno": Ditto, Bibarel, Slaking | | ⏳ | ⏳ |
| `jubiladoobras` | Jubilado mirando obras | Hombre | 40 | 1 | Roca y Lucha: Roggenrola, Timburr, Diglett | Zonas de obras | ⏳ | ⏳ |
| `abuela` | Abuela que te pone de comer | Mujer | 40 | 1 | Glotones: Munchlax, Snorlax, Chansey | | ⏳ | ⏳ |
| `influencerlinkedin` | Influencer de LinkedIn | Mixto | 60 | 1 | Psíquico: Espeon, Mr. Mime, Indeedee | | ⏳ | ⏳ |
| `repartidorbici` | Repartidor en bici | Hombre | 32 | 1 | Rápidos o voladores: Talonflame, Dodrio, Rapidash | Carriles bici | ⏳ | ⏳ |
| `estudianteinge` | Estudiante de Ingeniería en exámenes | Mixto | 20 | 1 | Eléctrico/Acero: Magnemite, Rotom, Porygon | | ⏳ | ⏳ |
| `opositor` | Opositor eterno | Mixto | 24 | 1 | Lentos pero sabios: Slowpoke, Bronzor, Hypno | | ⏳ | ⏳ |
| `patinetero` | Patinetero eléctrico | Hombre | 32 | 1 | Eléctrico: Pachirisu, Emolga, Electrike | | ⏳ | ⏳ |
| `tertuliano` | Tertuliano de bar | Hombre | 40 | 1 | Charlatanes: Chatot, Murkrow, Meowth | | ⏳ | ⏳ |
| `revisorcercanias` | Revisor del Cercanías | Mixto | 40 | 1 | Acero: Klink, Magneton, Bronzong | Metro, ciudad | ⏳ | ⏳ |
| `domadorpalomas` | Domador de palomas | Hombre | 32 | 1 | Pidove, Pidgey, Tranquill, Unfezant | | ⏳ | ⏳ |
| `crossfitero` | Crossfitero | Mixto | 24 | 1 | Lucha: Machop, Makuhita, Hawlucha | | ⏳ | ⏳ |
| `turistachanclas` | Turista con chanclas y calcetines | Mixto | 50 | 1 | Playeros: Krabby, Wingull, Corsola | Playa | ⏳ | ⏳ |
| `tuno` | Tuno | Hombre | 24 | 1 | Música: Kricketot, Jigglypuff, Toxtricity | | ⏳ | ⏳ |
| `camarero` | Camarero sin propina | Hombre | 20 | 1 | Fuego y cocina: Slugma, Darumaka, Litwick | | ⏳ | ⏳ |
| `padretarjeta` | Padre con la tarjeta del súper | Hombre | 48 | 1 | Normal: Lillipup, Zigzagoon, Bidoof | | ⏳ | ⏳ |

Frases de derrota de ejemplo de la guía (para los entrenadores de cada clase):

| Clase | Frase |
|-------|-------|
| `vendedorchupachups` | "¿Uno de fresa para olvidar la derrota?" |
| `flautista` | "Se me ha ido la nota..." |
| `peruana150` | "Pequeña, pero la próxima te tumbo." |
| `robasientos` | "Ese asiento estaba libre, te lo juro." |
| `cunado` | "Yo esto lo hubiera hecho mejor." |
| `jubiladoobras` | "Eso no se hace así, chaval." |
| `abuela` | "Ay, qué delgado estás. Toma, cómete esto." |
| `influencerlinkedin` | "Humilde y agradecido de anunciar mi derrota." |
| `repartidorbici` | "Tu pedido ha sido cancelado." |
| `estudianteinge` | "Llevo tres días sin dormir, no cuenta." |
| `opositor` | "Este año sí que me saco la plaza." |
| `patinetero` | "Se me ha acabado la batería." |
| `tertuliano` | "Pues en mis tiempos..." |
| `revisorcercanias` | "Billete y DNI, por favor." |
| `domadorpalomas` | "Mis palomas volverán." |
| `crossfitero` | "Hoy tocaba día de pierna." |
| `turistachanclas` | "Me voy a la playa a llorar." |
| `tuno` | "Clavelitos, clavelitos..." |
| `camarero` | "¿Le cobro ya, caballero?" |
| `padretarjeta` | "Ve a por el pan, que ya voy yo." |

---

## 3. Fichas

### {rival} (laboratorio)
- **ID:** `rival_lab_1` / `rival_lab_2` / `rival_lab_3` (clase: `rival`), según la variable `starter` (1 Planta, 2 Fuego, 3 Agua)
- **Mapa:** Laboratorio del pueblo inicial, justo después de elegir inicial
- **Visión:** — (lo lanza la cinemática, no la línea de visión)
- **Equipo:** el inicial con ventaja sobre el tuyo, Nv5. **Provisional** hasta decidir los iniciales: Charmander (si eliges Planta), Squirtle (si eliges Fuego), Bulbasaur (si eliges Agua)
- **Reglas:** se puede perder sin consecuencias (`can_lose`)
- **Al verte:** — (los diálogos previos van en la cinemática)
- **Derrota:** "¿¡Qué!? ¡Pero si he elegido el que tenía ventaja!"
- **Victoria:** "¡Ja! Te dije que el mío era mejor."
- **Sprite:** ⏳ combate / ⏳ mapa
- **Estado:** borrador (textos pendientes de revisar por Javier)

### Vendedor de Chupachups Manolo
- **ID:** `ruta1_manolo` (clase: `vendedorchupachups`)
- **Mapa:** Ruta 1
- **Visión:** 4 casillas
- **Equipo:** Swirlix Nv4, Milcery Nv4 (**provisional** hasta cerrar la Pokédex regional)
- **Al verte:** "¡Chupachups, chupachups! ¿De fresa o de cola? Si los quieres, gánatelos."
- **Derrota:** "¿Uno de fresa para olvidar la derrota?"
- **Victoria:** "Pues ahora te los cobro a precio de feria."
- **Después:** "Los de cola se me han acabado. Los de fresa también... me los he comido yo."
- **Revancha:** —
- **Sprite:** ⏳ combate / ⏳ mapa
- **Estado:** borrador (textos pendientes de revisar por Javier)

---

## 4. Arte pendiente

Mientras no haya arte definitivo, cada clase usa un placeholder.

- **Sprites de combate** (`assets/sprites/trainers/<id>.png`; las clases mixtas tienen además `<id>_f.png`): **21 clases**, 7 de ellas mixtas (28 sprites). Mismo tamaño, paleta y grosor de contorno para todas (Fase 10.3).
- **Spritesheets del mapa** (`assets/sprites/characters/<id>.png`, 4 direcciones × 3–4 frames): carpeta del Agente 1. Mismo número de sprites que en combate.
- Si se usan bases ajenas: **pedir permiso y acreditar** en `CREDITOS.md`.
