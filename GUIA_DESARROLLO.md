# Pokémon Panchito — Guía de desarrollo completa (Godot 4)

> Fangame **sin ánimo de lucro** al estilo de *Pokémon Añil*, programado **desde cero en Godot 4 con GDScript**.
> Repositorio: <https://github.com/javiersaguar/Pokemon-Panchito>

Esta guía va **en orden**. Cada fase se apoya en las anteriores. No pases a la siguiente sin cumplir su **criterio de "hecho"**. Las tareas se marcan con `- [ ]` y se tachan con `- [x]` (GitHub las muestra como checkboxes).

---

## Índice

- [0. Cómo usar esta guía](#0-cómo-usar-esta-guía)
- [Fase 1 — Entorno y repositorio](#fase-1--entorno-y-repositorio)
- [Fase 2 — Preproducción (documento de diseño)](#fase-2--preproducción-documento-de-diseño)
- [Fase 3 — Arquitectura base del proyecto](#fase-3--arquitectura-base-del-proyecto)
- [Fase 4 — Pipeline de datos (Pokémon, movimientos, objetos...)](#fase-4--pipeline-de-datos-pokémon-movimientos-objetos)
- [Fase 5 — Mundo jugable: movimiento, mapas e interacción](#fase-5--mundo-jugable-movimiento-mapas-e-interacción)
- [Fase 6 — Modelo de Pokémon, equipo y PC](#fase-6--modelo-de-pokémon-equipo-y-pc)
- [Fase 7 — Motor de combate (núcleo)](#fase-7--motor-de-combate-núcleo)
- [Fase 8 — MVP jugable (Pueblo inicial + Ruta 1)](#fase-8--mvp-jugable-pueblo-inicial--ruta-1)
- [Fase 9 — Combate avanzado (mecánicas modernas)](#fase-9--combate-avanzado-mecánicas-modernas)
- [Fase 10 — Entrenadores Panchito (clases humorísticas)](#fase-10--entrenadores-panchito-clases-humorísticas)
- [Fase 11 — Objetos e inventario (+ objetos especiales Panchito)](#fase-11--objetos-e-inventario--objetos-especiales-panchito)
- [Fase 12 — Mundo: región, mapas y navegación](#fase-12--mundo-región-mapas-y-navegación)
- [Fase 13 — Historia, eventos y cinemáticas](#fase-13--historia-eventos-y-cinemáticas)
- [Fase 14 — Sistemas de mundo vivo](#fase-14--sistemas-de-mundo-vivo)
- [Fase 15 — Interfaz (UI/UX)](#fase-15--interfaz-uiux)
- [Fase 16 — Audio](#fase-16--audio)
- [Fase 17 — Producción de contenido por tramos (8 gimnasios)](#fase-17--producción-de-contenido-por-tramos-8-gimnasios)
- [Fase 18 — Liga Pokémon y postgame](#fase-18--liga-pokémon-y-postgame)
- [Fase 19 — Contenido secundario, competitivo y online](#fase-19--contenido-secundario-competitivo-y-online)
- [Fase 20 — Balanceo, QA y testing](#fase-20--balanceo-qa-y-testing)
- [Fase 21 — Exportación, publicación y mantenimiento](#fase-21--exportación-publicación-y-mantenimiento)
- [Apéndices](#apéndices)

---

## 0. Cómo usar esta guía

### 0.1 Qué implica hacerlo desde cero

En Godot **no hay nada hecho**: el movimiento por cuadrícula, los menús, la Pokédex, el guardado y, sobre todo, el **motor de combate** los programas tú. A cambio tienes control total, aprendes muchísimo y el resultado es tuyo de verdad.

Dónde se va el tiempo, aproximadamente:

| Bloque | Peso relativo |
|--------|---------------|
| Motor de combate (núcleo + mecánicas modernas) | ████████████ el más grande |
| Contenido (mapas, entrenadores, historia) | ██████████ |
| UI (menús, Pokédex, mochila, PC...) | ██████ |
| Mundo (movimiento, eventos, sistemas) | █████ |
| Datos (importar y validar) | ███ |

> 🔑 **La clave para no ahogarse:** los datos de Pokémon, movimientos, objetos y tipos **no se escriben a mano**: se **importan** de fuentes abiertas (Fase 4). Y la mayoría de los movimientos funcionan **solo con sus datos** (potencia, precisión, efecto secundario...); solo los raros necesitan código propio (Fase 9).

### 0.2 Hitos (versiones jugables)

| Hito | Versión | Contenido | Fases |
|------|---------|-----------|-------|
| H0 | `v0.0` | Proyecto Godot arrancando con la arquitectura base y los datos importados | 1–4 |
| H1 | `v0.1` | **MVP**: moverse, pueblo inicial, elegir inicial, Ruta 1, combate salvaje, captura, rival y 1 entrenador Panchito, guardado | 5–8 |
| H2 | `v0.2` | Combate moderno completo, entrenadores, objetos | 9–11 |
| H3 | `v0.3` | **Demo pública**: hasta el 1.er gimnasio, con historia, UI y audio propios | 12–16 + tramo 1 de la 17 |
| H4 | `v0.5` | Hasta el 4.º gimnasio | 17 (tramos 2–4) |
| H5 | `v0.8` | Hasta el 8.º gimnasio | 17 (tramos 5–8) |
| H6 | `v1.0` | Liga, créditos, postgame básico, build pública | 18, 20, 21 |
| H7 | `v1.x` | Secundario, Frente de Batalla, online | 19 |

### 0.3 Reglas de oro

1. **La lógica del combate no sabe nada de la pantalla.** El motor calcula y la escena de combate solo dibuja (Fase 7.1). Es la decisión de arquitectura más importante del proyecto.
2. **Los datos van en archivos de datos, no en el código.** Ninguna potencia, nivel ni precio dentro de un `.gd`.
3. **Un commit por cambio lógico**, con tests del motor de combate antes de mergear.
4. **Prueba cada sistema en la escena de pruebas** antes de usarlo en el juego.
5. **Apunta los créditos desde el primer recurso que uses** (`CREDITOS.md`).
6. **Es un fangame: nunca se monetiza.** Nada de ventas, donaciones a cambio de builds ni anuncios.

### 0.4 Glosario rápido de Godot

| Término | Significado |
|---------|-------------|
| **Nodo / Escena** | Bloques de construcción. Una escena (`.tscn`) es un árbol de nodos reutilizable: el jugador, un NPC, un mapa, un menú... |
| **Script** | Archivo `.gd` (GDScript, parecido a Python) que da comportamiento a un nodo |
| **Resource** | Objeto de datos guardable (`.tres`), por ejemplo los datos de un mapa |
| **Autoload** | Script o escena global que existe siempre (singleton): `GameState`, `DataDB`... |
| **Señal** | Evento que emite un nodo y que otros escuchan (`signal hp_changed`) |
| **`await`** | Espera a que algo termine (una animación, un diálogo) sin bloquear el juego. Base de las cinemáticas |
| **TileMapLayer** | Nodo para pintar mapas con tiles |
| **`res://` / `user://`** | Carpeta del proyecto / carpeta de datos del usuario (partidas guardadas) |

---

## Fase 1 — Entorno y repositorio

**Objetivo:** proyecto de Godot vacío pero bien configurado, versionado en el repo y abrible por cualquiera del grupo.

### 1.1 Software necesario

- [ ] **Godot 4** (última versión 4.x estable, *edición estándar*, no la .NET), desde la web oficial godotengine.org. **Todo el grupo con la misma versión exacta.** Apúntala en el `README.md`.
- [ ] **Git** + **Git LFS** (audio y gráficos fuente pesados).
- [ ] **VS Code** + extensión **godot-tools** (opcional; el editor de scripts de Godot es suficiente).
- [ ] **Python 3** o **Node.js** para los scripts de importación de datos (Fase 4). Recomendado: **Node.js**, porque los datos de Showdown están en TypeScript/JS.
- [ ] **Aseprite** (de pago) o **LibreSprite / Piskel** (gratis) para pixel art.
- [ ] **Audacity** para el audio.
- [ ] *(Opcional)* **Tiled** si prefieres bocetar mapas fuera de Godot.

### 1.2 Crear el proyecto en el repo

El repo `Pokemon-Panchito` está clonado en `C:\Users\Javier\Pokemon-Panchito`.

- [ ] Godot → **Nuevo proyecto** → ruta: la raíz del repo → renderizador **Compatibility** (máxima compatibilidad: PCs antiguos, web y móvil) o **Forward+** si solo apuntas a PCs modernos. Para un 2D pixel art, **Compatibility** es suficiente.
- [ ] Nombre del proyecto: **Pokémon Panchito**.
- [ ] Comprueba que se crea `project.godot` en la raíz.

### 1.3 Estructura de carpetas

```
Pokemon-Panchito/
├── project.godot
├── addons/                    # Plugins del editor (tests, diálogo...)
├── assets/
│   ├── audio/{bgm,se,me,cries}/
│   ├── fonts/
│   ├── sprites/
│   │   ├── pokemon/{front,back,icons,front_shiny,back_shiny}/
│   │   ├── trainers/          # Sprites de combate de clases Panchito
│   │   ├── characters/        # Spritesheets del mapa (jugador, NPCs)
│   │   ├── items/
│   │   └── ui/
│   └── tilesets/
├── data/                      # ★ Datos del juego (JSON generados + JSON propios)
│   ├── generated/             # Importados de Showdown/PokeAPI. NO se editan a mano
│   ├── species_overrides.json # Cambios propios sobre especies (evoluciones, etc.)
│   ├── trainer_classes.json   # ★ Clases Panchito
│   ├── trainers/              # Un JSON por zona
│   ├── items_panchito.json    # ★ Objetos especiales
│   ├── encounters/            # Un JSON por mapa
│   ├── shops.json
│   └── regional_dex.json
├── src/
│   ├── autoload/              # GameState, DataDB, SceneManager, AudioManager...
│   ├── battle/
│   │   ├── engine/            # ★ Lógica pura del combate (sin nodos)
│   │   ├── effects/           # Habilidades, objetos y movimientos con código propio
│   │   ├── ai/
│   │   └── scene/             # Presentación del combate (sprites, barras, menús)
│   ├── overworld/             # Jugador, NPCs, warps, triggers, cámara
│   ├── events/                # API de cinemáticas y eventos de historia
│   ├── pokemon/               # Clase Pokemon, Party, PC
│   ├── ui/                    # Menús
│   └── util/
├── maps/                      # Una escena .tscn por mapa
├── tests/                     # Tests automáticos (sobre todo del combate)
├── tools/                     # Scripts de importación y validación
├── docs/                      # GDD, guion, listas, reservas de mapas
├── CREDITOS.md
├── GUIA_DESARROLLO.md
└── README.md
```

### 1.4 `.gitignore` y `.gitattributes`

- [ ] `.gitignore`:

```gitignore
# Caché de Godot (se regenera sola)
.godot/

# Builds
/builds/
*.pck
*.zip

# Presets de exportación (pueden contener rutas o claves locales)
export_presets.cfg

# Sistema y editor
.vscode/
Thumbs.db
desktop.ini

# Dependencias de las herramientas
tools/node_modules/
tools/.venv/
tools/cache/
```

> ⚠️ **Sí se versionan** los archivos `*.import` que Godot crea junto a cada imagen y sonido: guardan cómo se importa cada recurso.

- [ ] `.gitattributes`:

```gitattributes
* text=auto eol=lf
*.png  binary
*.ogg  filter=lfs diff=lfs merge=lfs -text
*.wav  filter=lfs diff=lfs merge=lfs -text
*.mp3  filter=lfs diff=lfs merge=lfs -text
*.aseprite filter=lfs diff=lfs merge=lfs -text
*.psd  filter=lfs diff=lfs merge=lfs -text
```

- [ ] `git lfs install`.

### 1.5 Flujo de trabajo en Git

En Godot casi todo es **texto** (`.tscn`, `.tres`, `.gd`, `.json`), así que se mergea mucho mejor que en RPG Maker. Pero los **mapas** guardan los tiles en un array compacto que **no se puede mergear a mano**.

- [ ] **Rama `main`**: siempre jugable y con los tests en verde.
- [ ] **Ramas por tarea**: `feat/motor-combate-dobles`, `map/ruta-3`, `data/entrenadores-tramo2`, `fix/...`
- [ ] **Reserva de mapas**: antes de pintar un mapa, apúntalo en `docs/mapas/reservas.md` o en una issue. **Un mapa = una persona a la vez.**
- [ ] **Pull requests** para mergear a `main`, aunque seáis pocos: obligan a revisar.
- [ ] `git tag v0.1` y similares en cada hito.

### 1.6 Addons recomendados (`addons/`)

- [ ] **GUT** o **gdUnit4**: tests automáticos. **Imprescindible para el motor de combate.**
- [ ] *(Opcional)* **Dialogue Manager** (Nathan Hoad): diálogos con condiciones y ramas en archivos de texto. Alternativa: tu propio sistema simple (Fase 5.6).
- [ ] *(Opcional)* **Aseprite Wizard**: importa animaciones de Aseprite directamente.
- [ ] Antes de instalar un addon: comprueba que es **compatible con tu versión de Godot** y apunta autor y licencia en `CREDITOS.md`.

### 1.7 Primer commit

- [ ] `README.md`: qué es, versión de Godot, cómo abrir y cómo pasar los tests.
- [ ] `git add . && git commit -m "Proyecto base de Godot"` → `git push -u origin main`.
- [ ] Clona en otra carpeta, abre con Godot y comprueba que arranca.

✅ **Criterio de "hecho":** clonar → abrir con Godot → ejecutar (F5) muestra una escena vacía sin errores.

---

## Fase 2 — Preproducción (documento de diseño)

**Objetivo:** decidir **qué** vas a hacer antes de hacerlo. Todo va en `docs/GDD.md`.

### 2.1 Identidad del juego

- [ ] **Título:** Pokémon Panchito.
- [ ] **Tono:** humor absurdo y costumbrista español (clases de entrenador y objetos de broma) con una aventura que se toma en serio lo justo. ¿Parodia total o aventura seria con chistes?
- [ ] **Pitch de una frase**, por ejemplo *"Una aventura Pokémon clásica en una región donde los entrenadores son los personajes de tu barrio."*
- [ ] **¿Quién o qué es Panchito?** ¿Protagonista, profesor, mascota, villano, región? Condiciona el logo, la intro y la trama.
- [ ] **Idioma:** español.
- [ ] **Resolución y estilo de pixel art** (se decide aquí, se configura en la Fase 3.2).

### 2.2 La región

- [ ] Nombre de la región (puede parodiar un lugar real: barrios, metro, sierra, costa...).
- [ ] Boceto del **mapa mundial** con:
  - [ ] Pueblo inicial
  - [ ] 8 ciudades con gimnasio y 2–4 pueblos sin gimnasio
  - [ ] Rutas numeradas
  - [ ] Biomas variados: bosque, cueva, montaña, mar, volcán, nieve, ciudad, metro...
  - [ ] Calle Victoria y Liga
  - [ ] Bloqueos de progreso (árboles, rocas, agua o un "asiento reservado del metro" en vez del Snorlax dormido)
  - [ ] Zonas de postgame
- [ ] Marca **la ruta crítica** y dónde se abre el mundo.

### 2.3 Gimnasios y Liga

| # | Ciudad | Líder | Tipo | Nivel as | Medalla | MT premio | Puzle | Desbloquea |
|---|--------|-------|------|----------|---------|-----------|-------|------------|
| 1 | | | | 12–14 | | | | Corte |
| 2 | | | | 18–20 | | | | |
| 3 | | | | 24–26 | | | | Surf |
| 4 | | | | 29–31 | | | | |
| 5 | | | | 34–36 | | | | |
| 6 | | | | 39–41 | | | | |
| 7 | | | | 44–46 | | | | |
| 8 | | | | 48–50 | | | | Cascada |
| Alto Mando 1–4 | | | | 52–58 | | | | |
| Campeón | | | | 58–62 | | | | Postgame |

- [ ] Rellenar. Los tipos de los gimnasios deben repartir ventajas y desventajas entre los 3 iniciales.

### 2.4 Pokédex regional

- [ ] **~150–250 especies** (cada especie extra = más sprites, balance y encuentros).
- [ ] **3 iniciales**.
- [ ] **Legendarios**: portada, trío, postgame.
- [ ] Reparto por zonas (3–5 especies nuevas por ruta y exclusivas de día o de noche).
- [ ] **Tabla de cobertura de tipos** por tramo.

### 2.5 Curva de niveles y economía

- [ ] Nivel esperado del equipo en cada punto (tabla de gimnasios).
- [ ] Entrenadores de ruta 2–4 niveles por debajo del líder siguiente; salvajes 5–8 por debajo.
- [ ] Precios frente a dinero ganado: que el jugador pueda curarse pero tenga que elegir.

### 2.6 Historia (esqueleto)

- [ ] **Equipo villano** (nombre, motivación, reclutas, almirantes, jefe), con los reclutas como otra clase Panchito.
- [ ] **Rival** (personalidad, 5–7 combates, inicial con ventaja sobre el tuyo).
- [ ] **Profesor** e intro.
- [ ] **3 actos**: presentación (gimnasios 1–3), conflicto (4–6), clímax con legendario (7–8) y Liga.
- [ ] Lista de **momentos clave** (cinemáticas).

### 2.7 Alcance de mecánicas

Como lo programas tú, **decide y documenta** qué entra en cada versión:

| Mecánica | MVP (v0.1) | v0.2 | v1.0 | Postgame / v1.x |
|----------|-----------|------|------|-----------------|
| Combate individual | ✅ | | | |
| Habilidades y objetos equipados | | ✅ | | |
| Clima, campos, trampas | | ✅ | | |
| Combates dobles | | ✅ | | |
| Megaevolución | | | ✅ | |
| Movimientos Z | | | | ✅ |
| Dinamax / Gigamax | | | | ✅ |
| Teracristalización | | | | ✅ |
| Crianza y huevos | | | ✅ | |
| Online | | | | ✅ (opcional) |

> **Recomendación:** Megas como gimmick principal de la historia, y Tera, Dinamax y Z en postgame, raids o contenido opcional. Tener las cuatro a la vez en la historia es caótico.

### 2.8 Listas maestras

- [ ] `docs/entrenadores.md` (Fase 10)
- [ ] `docs/objetos_especiales.md` (Fase 11.4), **por definir más adelante**
- [ ] `docs/flags.md`: registro de flags de historia (Fase 13.2)

✅ **Criterio de "hecho":** `docs/GDD.md` con región, gimnasios, Pokédex aproximada, iniciales, villano, rival, curva de niveles y tabla de alcance de mecánicas.

---

## Fase 3 — Arquitectura base del proyecto

**Objetivo:** el "esqueleto" sobre el que se construye todo. Hacerlo bien aquí ahorra meses después.

### 3.1 Convenciones de código

- [ ] Guía de estilo oficial de GDScript: `snake_case` para variables y funciones, `PascalCase` para clases, `UPPER_CASE` para constantes.
- [ ] **Tipado estático siempre** (`var hp: int`, `func f() -> void`). Activa en *Project Settings → Debug → GDScript* el aviso de variables sin tipo.
- [ ] `class_name` en cada clase reutilizable.
- [ ] IDs de datos en **minúsculas y sin espacios** (`pikachu`, `thunderbolt`, `robasientos`), iguales a los de Showdown cuando existan.
- [ ] Textos visibles en **español**. Para una futura traducción, pásalos por `tr()` desde el principio.

> Los ejemplos de esta guía usan 4 espacios. Godot usa tabuladores por defecto: si pegas código, conviértelo con *Editor de scripts → Editar → Convertir sangría a tabuladores*.

### 3.2 Resolución y pixel art

- [ ] **Tiles de 16×16 px** (estándar de Pokémon 2D).
- [ ] **Resolución base**: dos opciones razonables:
  - **320×180** (16:9). Escala entera ×4 = 1280×720, ×6 = 1920×1080. **Recomendado.**
  - **256×192** (4:3, la de DS, la de Añil). Bandas negras en pantallas panorámicas.
- [ ] *Project Settings*:
  - `display/window/size/viewport_width/height` = resolución base
  - `display/window/size/window_width/height_override` = ×4 (ventana inicial)
  - `display/window/stretch/mode` = `viewport`
  - `display/window/stretch/aspect` = `keep`
  - `display/window/stretch/scale_mode` = `integer`
  - `rendering/textures/canvas_textures/default_texture_filter` = `Nearest`
  - `rendering/2d/snap/snap_2d_transforms_to_pixel` = `true`
- [ ] Prueba a cambiar el tamaño de la ventana: el pixel art no debe verse borroso ni deformado.

### 3.3 Input Map

*Project Settings → Input Map*. **Nunca leas teclas directamente**; usa siempre acciones:

| Acción | Teclado | Mando |
|--------|---------|-------|
| `move_up/down/left/right` | Flechas / WASD | Cruceta / stick |
| `accept` (A) | Z / Enter / Espacio | A |
| `cancel` (B) | X / Escape / Retroceso | B |
| `menu` | C / Enter | Start |
| `run` | Shift | B (mantener) |
| `speed_up` | Tab | — |
| `debug` | F9 | — |

### 3.4 Autoloads (singletons)

*Project Settings → Globals → Autoload*, **en este orden**:

| Autoload | Responsabilidad |
|----------|-----------------|
| `DataDB` | Carga los JSON de `data/` al arrancar y da acceso: `DataDB.species("pikachu")` |
| `EventBus` | Señales globales (`player_stepped`, `battle_started`, `flag_changed`...). Desacopla sistemas |
| `GameState` | Estado de la partida: jugador, equipo, mochila, dinero, flags, medallas, posición, tiempo jugado, Pokédex |
| `SaveManager` | Guardar y cargar `GameState` en `user://` |
| `SceneManager` | Cambiar de mapa con fundido, entrar y salir de combate, apilar menús |
| `AudioManager` | BGM con crossfade, SE, ME (jingles que pausan la BGM), gritos |
| `Dialogue` | Cuadro de texto: `await Dialogue.say("...")`, `await Dialogue.ask("...", ["Sí","No"])` |
| `Clock` | Hora del juego (real o interna), día de la semana, momento del día |
| `Debug` | Consola y menú de depuración (solo en builds de debug) |

### 3.5 SceneManager: estructura de escenas

```
Main (Node)
├── World (Node2D)          # Aquí se carga el mapa actual + jugador
├── Battle (CanvasLayer)    # Se instancia la escena de combate encima
├── UI (CanvasLayer)        # Menús, cuadro de diálogo
└── Transition (CanvasLayer) # Fundidos y animaciones de entrada a combate
```

- [ ] `SceneManager.change_map(map_id, spawn_id)`: fundido a negro → descarga el mapa → carga el nuevo → coloca al jugador → fundido de entrada.
- [ ] `await SceneManager.start_battle(battle_setup)` devuelve el resultado (victoria, derrota, huida, captura) para usarlo en eventos.

### 3.6 Escena de pruebas y menú Debug

- [ ] `maps/test/test_room.tscn`: sala con NPCs que dan Pokémon, objetos y combates de cada tipo. **Tu laboratorio durante todo el desarrollo.**
- [ ] Menú Debug (F9, solo en debug): teletransporte a cualquier mapa, añadir Pokémon u objetos, curar, cambiar flags, cambiar la hora, atravesar paredes y desactivar encuentros.
- [ ] Usa `OS.is_debug_build()` para que nada de esto llegue a la build pública.

✅ **Criterio de "hecho":** el juego arranca con la resolución correcta, los autoloads cargan, se puede cambiar entre dos escenas de prueba con fundido y el menú Debug se abre con F9.

---

## Fase 4 — Pipeline de datos (Pokémon, movimientos, objetos...)

**Objetivo:** tener **todos** los datos oficiales en JSON, con nombres en español, generados automáticamente. Nadie escribe a mano las estadísticas de 1000 Pokémon.

### 4.1 Fuentes de datos

| Fuente | Qué aporta | Notas |
|--------|------------|-------|
| **Pokémon Showdown** (repo `smogon/pokemon-showdown`, carpeta `data/`) | Especies, movimientos (con efectos secundarios, prioridad y flags), habilidades, objetos, tabla de tipos, learnsets y formas | Código con licencia MIT. Es la referencia de mecánicas más fiable que existe |
| **PokeAPI** (repo `PokeAPI/pokeapi`, carpeta `data/v2/csv/`) | **Nombres y descripciones en español**, entradas de la Pokédex, grupos de experiencia, ratio de género, ratio de captura, grupos huevo y pasos de eclosión | En los CSV, el idioma español tiene `local_language_id = 7` (compruébalo en `languages.csv`) |
| **Sprites** | Front, back, shiny, iconos | El repo de sprites de PokeAPI o los packs de la comunidad. Elige **un estilo** (por ejemplo, los de 5.ª generación, como Añil) |

> Los Pokémon, sus nombres y sus sprites son propiedad de Nintendo, Game Freak y The Pokémon Company. Acredita las fuentes en `CREDITOS.md`.

### 4.2 Script de importación (`tools/import_data`)

- [ ] Script en Node.js o Python que:
  1. Descarga o lee los datos de Showdown y los CSV de PokeAPI (con una versión **fijada**: no "lo último").
  2. Une ambas fuentes por especie, movimiento, objeto y habilidad.
  3. Añade los **nombres y descripciones en español**.
  4. Escribe `data/generated/species.json`, `moves.json`, `abilities.json`, `items.json`, `types.json`, `learnsets.json`, `exp_tables.json` y `natures.json`.
  5. Muestra un resumen: cuántos registros hay y cuáles no tienen nombre en español.
- [ ] `data/generated/` **no se edita nunca a mano**: se regenera. Los cambios propios van en archivos aparte (4.4).
- [ ] Documenta en el `README.md` cómo ejecutarlo.

### 4.3 Formato de los datos

`species.json` (ejemplo de entrada):

```json
"pikachu": {
  "num": 25,
  "name": "Pikachu",
  "types": ["electric"],
  "base_stats": {"hp": 35, "atk": 55, "def": 40, "spa": 50, "spd": 50, "spe": 90},
  "abilities": {"0": "static", "H": "lightningrod"},
  "gender_ratio": 0.5,
  "catch_rate": 190,
  "base_exp": 112,
  "exp_group": "medium_fast",
  "ev_yield": {"spe": 2},
  "egg_groups": ["field", "fairy"],
  "hatch_steps": 2560,
  "base_friendship": 50,
  "height": 0.4,
  "weight": 6.0,
  "evolutions": [{"to": "raichu", "method": "item", "item": "thunderstone"}],
  "forms": [],
  "dex_entry": "Cuanto más potente es la energía eléctrica que genera..."
}
```

`moves.json` (ejemplo):

```json
"thunderbolt": {
  "name": "Rayo",
  "type": "electric",
  "category": "special",
  "power": 90,
  "accuracy": 100,
  "pp": 15,
  "priority": 0,
  "target": "normal",
  "flags": {"protect": true, "mirror": true},
  "secondary": {"chance": 10, "status": "par"},
  "description": "Ataca con una potente descarga eléctrica..."
}
```

### 4.4 Datos propios del juego

- [ ] `species_overrides.json`: cambios sobre las especies oficiales:
  - **Evoluciones por intercambio sustituidas** por nivel u objeto (Kadabra, Machoke, Graveler, Haunter, Onix→Steelix, Scyther→Scizor, Poliwhirl→Politoed, Slowpoke→Slowking, Seadra, Porygon, Electabuzz, Magmar, Dusclops, Rhydon, Feebas, Boldore, Gurdurr...)
  - *(Opcional)* **Formas regionales Panchito**
- [ ] `regional_dex.json`: orden de la Pokédex de Panchito.
- [ ] `trainer_classes.json`, `trainers/*.json` (Fase 10).
- [ ] `items_panchito.json` (Fase 11).
- [ ] `encounters/*.json` (Fase 5.7).
- [ ] `shops.json`.

### 4.5 `DataDB` en Godot

- [ ] Carga todos los JSON al arrancar (`FileAccess` + `JSON.parse_string`).
- [ ] Aplica los overrides sobre los datos generados.
- [ ] Convierte cada entrada en una **clase tipada** (`SpeciesData`, `MoveData`, `ItemData`...) para tener autocompletado y errores claros.
- [ ] API: `DataDB.species(id)`, `DataDB.move(id)`, `DataDB.item(id)`, `DataDB.type_effectiveness(atk_type, def_types)`...
- [ ] Error **claro** si se pide un ID que no existe (con `push_error` y el nombre del ID).

```gdscript
class_name MoveData
extends RefCounted

enum Category { PHYSICAL, SPECIAL, STATUS }

var id: StringName
var name: String
var type: StringName
var category: Category
var power: int
var accuracy: int        # 0 = no falla nunca
var pp: int
var priority: int
var target: StringName
var flags: Dictionary
var secondary: Dictionary
var description: String
```

### 4.6 Validador (`tools/validate`)

- [ ] Script (puede ser un test de GUT o gdUnit4) que comprueba:
  - [ ] Cada especie de la Pokédex regional existe, tiene sprites y aparece en algún encuentro, evolución o regalo.
  - [ ] No quedan evoluciones por intercambio sin sustituir.
  - [ ] Cada entrenador usa especies, movimientos, objetos y clases que existen.
  - [ ] Cada movimiento usado en el juego está **implementado** (Fase 9.2).
  - [ ] Cada objeto vendido o colocado existe y tiene icono.
- [ ] Se ejecuta antes de cada merge a `main`.

✅ **Criterio de "hecho":** `DataDB.species("pikachu").name` devuelve "Pikachu", `DataDB.move("thunderbolt").name` devuelve "Rayo" y el validador se ejecuta.

---

## Fase 5 — Mundo jugable: movimiento, mapas e interacción

### 5.1 Jugador con movimiento en cuadrícula

- [ ] Escena `Player.tscn`: `Node2D` + `AnimatedSprite2D` (4 direcciones × quieto / andar / correr / bici / surf) + `RayCast2D` para detectar colisiones.
- [ ] Movimiento **de casilla en casilla** con `Tween` (andar ≈ 0,25 s por casilla; correr ≈ 0,125 s).
- [ ] **Girar sin moverse** con una pulsación corta y andar si se mantiene (como en los juegos oficiales).
- [ ] **Buffer de input**: si mantienes la dirección, encadena casillas sin parones.
- [ ] Choque contra la pared: animación de andar en el sitio + sonido "bump".
- [ ] Señal `EventBus.player_stepped(tile)` al terminar cada paso (encuentros, triggers, contadores de pasos...).

```gdscript
class_name Player
extends Node2D

const TILE := 16
const WALK_TIME := 0.25
const RUN_TIME := 0.125

var facing := Vector2i.DOWN
var moving := false

@onready var ray: RayCast2D = $RayCast2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _process(_delta: float) -> void:
    if moving or GameState.input_locked:
        return
    var dir := _read_direction()
    if dir == Vector2i.ZERO:
        sprite.play("idle_" + _dir_name(facing))
        return
    facing = dir
    _try_step(dir)

func _try_step(dir: Vector2i) -> void:
    ray.target_position = Vector2(dir * TILE)
    ray.force_raycast_update()
    if ray.is_colliding():
        sprite.play("idle_" + _dir_name(facing))
        return
    moving = true
    var running := Input.is_action_pressed("run")
    sprite.play(("run_" if running else "walk_") + _dir_name(dir))
    var tween := create_tween()
    tween.tween_property(self, "position", position + Vector2(dir * TILE), RUN_TIME if running else WALK_TIME)
    await tween.finished
    moving = false
    EventBus.player_stepped.emit(tile_position())

func tile_position() -> Vector2i:
    return Vector2i(position / TILE)

func _read_direction() -> Vector2i:
    if Input.is_action_pressed("move_up"): return Vector2i.UP
    if Input.is_action_pressed("move_down"): return Vector2i.DOWN
    if Input.is_action_pressed("move_left"): return Vector2i.LEFT
    if Input.is_action_pressed("move_right"): return Vector2i.RIGHT
    return Vector2i.ZERO

func _dir_name(d: Vector2i) -> String:
    match d:
        Vector2i.UP: return "up"
        Vector2i.LEFT: return "left"
        Vector2i.RIGHT: return "right"
        _: return "down"
```

### 5.2 Tilesets y capas del mapa

- [ ] Elige **un estilo** de tileset (4.ª o 5.ª generación, con un aire parecido a Añil) de recursos **con permiso de uso**. Acredita al autor.
- [ ] Crea un **TileSet** de 16×16 con:
  - **Physics layer** (colisiones de paredes, árboles, agua...)
  - **Custom data layers**: `terrain` (`grass`, `tall_grass`, `water`, `waterfall`, `ice`, `sand`, `ledge_down`, `cave`...), `encounter` (bool) y `footstep_sound`
  - **Terrain sets** para el autotiling de caminos, agua y acantilados
  - **Animaciones de tiles** (agua y flores)
- [ ] Cada mapa usa varias **TileMapLayer**:
  1. `Ground`: suelo
  2. `Decor`: objetos a la altura del jugador (con colisión)
  3. `Above`: lo que se dibuja **por encima** del jugador (copas de árboles, tejados)
- [ ] **Y-sort** activo en el nodo que contiene al jugador y a los NPCs, para que quien está más abajo se dibuje delante.

### 5.3 Estructura de una escena de mapa

```
Ruta1 (Node2D)  ← script MapRoot.gd con @export var data: MapData
├── Ground (TileMapLayer)
├── Decor (TileMapLayer)
├── Entities (Node2D, y_sort_enabled)
│   ├── (aquí entra el Player al cargar)
│   ├── NPC_Paco (NPC.tscn)
│   └── ItemBall_Pocion (ItemBall.tscn)
├── Above (TileMapLayer)
├── Warps (Node2D)
│   └── Warp_ToPueblo (Warp.tscn: destino map_id + spawn_id)
├── Spawns (Node2D)
│   └── from_pueblo (Marker2D)
└── Triggers (Node2D)
    └── Trigger_Rival (Area o casillas que lanzan un evento)
```

`MapData` (Resource `.tres`):

```gdscript
class_name MapData
extends Resource

@export var id: StringName
@export var display_name: String          # "Ruta 1" (cartel al entrar)
@export var bgm: AudioStream
@export var outdoor := true               # Afecta al tinte día/noche
@export var weather: StringName = &"none"
@export var encounter_table: StringName   # id del JSON de encuentros
@export var battle_background: StringName
@export var region_map_position: Vector2i
@export var can_fly_from := true
@export var can_bike := true
@export var healing_spot: StringName      # A dónde vuelves si pierdes
```

### 5.4 Cámara

- [ ] `Camera2D` hija del jugador, **centrada** y con `limit_*` ajustados a los bordes de cada mapa (que no se vea fuera del mapa).
- [ ] En interiores pequeños, cámara fija y centrada en la habitación.

### 5.5 Warps y transiciones

- [ ] Puertas: animación de la puerta → fundido → nuevo mapa en el `spawn_id`.
- [ ] Bordes de ruta: al cruzar el borde, cambio de mapa con fundido. **Más adelante** (opcional, Fase 12.4) puedes hacer **mapas conectados sin cortes**, como en los juegos oficiales.
- [ ] Escaleras y cuevas con su sonido.

### 5.6 Interacción y diálogo

- [ ] Tecla `accept` → mira la casilla de delante → si hay una entidad con método `interact()`, la ejecuta.
- [ ] **Cuadro de diálogo** (`Dialogue`, autoload):
  - [ ] Texto letra a letra con velocidad configurable; `accept` completa la línea o pasa a la siguiente
  - [ ] Saltos de página automáticos y flecha de "continuar"
  - [ ] Variables en el texto: `{player}`, `{rival}`, `{pokemon}`
  - [ ] Colores en línea (BBCode de `RichTextLabel`)
  - [ ] Preguntas Sí/No y menús de opciones: `var r := await Dialogue.ask("¿Eliges a Bulbasaur?", ["Sí", "No"])`
  - [ ] Nombre del hablante opcional (para personajes importantes)
- [ ] **NPC base** (`NPC.tscn`): sprite, dirección inicial, se gira hacia el jugador al hablarle, movimiento aleatorio opcional y script de interacción propio.
- [ ] **Carteles**, **objetos en el suelo** (`ItemBall.tscn`, que desaparecen y se guardan en flags) y **objetos ocultos**.

### 5.7 Encuentros salvajes

- [ ] En cada `player_stepped`, si la casilla tiene `encounter = true`, tira probabilidad (≈ 1/10 por paso en hierba alta y ajustable por mapa).
- [ ] Tabla de encuentros por mapa, con variantes de día y noche:

```json
{
  "land": {
    "day":   [{"species": "pidgey", "min": 2, "max": 4, "weight": 40},
              {"species": "rattata", "min": 2, "max": 4, "weight": 30},
              {"species": "sentret", "min": 3, "max": 4, "weight": 20},
              {"species": "hoppip", "min": 3, "max": 3, "weight": 10}],
    "night": [{"species": "hoothoot", "min": 2, "max": 4, "weight": 40},
              {"species": "rattata", "min": 2, "max": 4, "weight": 30},
              {"species": "spinarak", "min": 3, "max": 4, "weight": 30}]
  },
  "water": [],
  "old_rod": [], "good_rod": [], "super_rod": [],
  "rock_smash": [], "headbutt": []
}
```

- [ ] Repelente: impide encuentros con Pokémon de nivel inferior al primero del equipo.

✅ **Criterio de "hecho":** te mueves por dos mapas conectados, hablas con NPCs, recoges un objeto del suelo y la hierba alta dispara un "encuentro" (de momento basta con un mensaje).

---

## Fase 6 — Modelo de Pokémon, equipo y PC

### 6.1 Clase `Pokemon` (instancia)

`SpeciesData` = los datos fijos de la especie. `Pokemon` = **un** Pokémon concreto del jugador o de un rival.

- [ ] Campos:

| Campo | Notas |
|-------|-------|
| `species_id`, `form` | |
| `nickname` | Vacío = nombre de la especie |
| `level`, `exp` | La experiencia según el grupo de crecimiento |
| `ivs` (0–31 ×6), `evs` (0–252, total ≤ 510) | |
| `nature` | 25 naturalezas: +10 % / −10 % |
| `ability_slot` | `"0"`, `"1"` o `"H"` (oculta) |
| `gender` | Según el ratio de la especie |
| `shiny` | 1/4096 por defecto (configurable) |
| `moves` (máx. 4) | Cada uno con `id`, `pp` y `pp_ups` |
| `current_hp`, `status` | `par`, `brn`, `psn`, `tox`, `slp` (+ turnos), `frz` |
| `held_item` | |
| `friendship` | |
| `ball` | Con qué Ball se capturó |
| `original_trainer`, `trainer_id`, `met_level`, `met_location`, `met_date` | |
| `pokerus` | |
| `tera_type` | Si hay Tera |
| `ribbons` / `marks` | Opcional |

- [ ] **Fórmulas de estadísticas** (generación 3 en adelante):
  - PS = `floor((2·Base + IV + floor(EV/4)) · Nivel / 100) + Nivel + 10`
  - Resto = `floor((floor((2·Base + IV + floor(EV/4)) · Nivel / 100) + 5) · Naturaleza)`
  - (Shedinja siempre tiene 1 PS.)
- [ ] Generación de un Pokémon salvaje o de regalo: IVs aleatorios, naturaleza, género, habilidad (normal o, con baja probabilidad, oculta) y los **últimos 4 movimientos aprendibles por nivel**.
- [ ] `to_dict()` / `from_dict()` para el guardado.

### 6.2 Experiencia y subida de nivel

- [ ] Tablas de los 6 grupos de crecimiento (`exp_tables.json`, generado).
- [ ] **Fórmula de experiencia**: usa la escalada moderna (generación 5 o 7+). Consulta la fórmula exacta en Bulbapedia y escríbela con tests.
- [ ] Subir varios niveles de golpe.
- [ ] Al subir de nivel: recalcular estadísticas manteniendo el daño recibido, aprender movimientos ("¿Olvidar uno?") y comprobar la **evolución al final del combate**.
- [ ] EVs ganados al derrotar Pokémon.
- [ ] Repartir Experiencia moderno (todo el equipo, con opción de desactivarlo).

### 6.3 Evolución

- [ ] Métodos: nivel, nivel + hora, nivel + objeto equipado, objeto (piedra), amistad (+ hora), movimiento conocido, especie en el equipo, clima, lugar, sexo, PS... Implementa **los que necesiten las especies de tu Pokédex**.
- [ ] Escena de evolución (animación, cancelar con B, evoluciones con objeto que no se pueden cancelar).
- [ ] Shedinja / Nincada (caso especial).

### 6.4 Equipo y PC

- [ ] `Party` (máx. 6): reordenar y comprobar si todos están debilitados (→ derrota).
- [ ] `PCStorage`: N cajas × 30 huecos, nombres y fondos de caja, mover entre caja y equipo, liberar (con confirmación) y movimiento masivo.
- [ ] Al capturar con el equipo lleno → va al PC con mensaje.

### 6.5 Pokédex (datos)

- [ ] Por especie: `visto`, `capturado`, formas vistas y shiny visto.
- [ ] Se marca "visto" al ver en combate y "capturado" al capturar, evolucionar, recibir o eclosionar.

### 6.6 Tests

- [ ] Tests de estadísticas con valores conocidos (compáralos con una calculadora online).
- [ ] Tests de experiencia y nivel.
- [ ] Test de guardar → cargar un Pokémon idéntico.

✅ **Criterio de "hecho":** desde el Debug puedes crear un Pokémon de cualquier especie y nivel con estadísticas correctas, meterlo al equipo o al PC, y guardarlo y cargarlo.

---

## Fase 7 — Motor de combate (núcleo)

**Objetivo:** combate individual completo contra salvajes y entrenadores, **sin habilidades ni objetos equipados todavía** (eso va en la Fase 9). Es la parte más importante del proyecto.

### 7.1 Arquitectura: lógica separada de presentación

```
┌───────────────────────┐   acciones del jugador   ┌───────────────────────┐
│     BattleScene        │ ───────────────────────▶ │     BattleEngine       │
│  (nodos, sprites,      │                          │  (RefCounted, sin      │
│   barras, menús,       │ ◀─────────────────────── │   nodos, determinista) │
│   animaciones)         │   lista de BattleEvent   │                        │
└───────────────────────┘                          └───────────────────────┘
```

- [ ] **`BattleEngine`** (`src/battle/engine/`): **no usa nodos, ni `await`, ni nada visual**. Recibe las acciones de cada bando, resuelve el turno y devuelve una **lista de eventos**:
  `[Message("¡Pikachu usó Rayo!"), Damage(target, 34), Effectiveness(2.0), Message("¡Es supereficaz!"), Faint(target), ...]`
- [ ] **`BattleScene`** (`src/battle/scene/`): reproduce los eventos **uno a uno con `await`**: animación del movimiento → la barra de PS baja → mensaje → ...
- [ ] **RNG con semilla** propio del combate (`RandomNumberGenerator` con `seed`): permite reproducir bugs y hacer tests, y en el futuro, el online.

Ventajas: el motor se puede testear sin abrir el juego, la IA puede "simular" turnos y el online sería posible (solo se envían las acciones).

### 7.2 Estructuras del motor

- [ ] `BattleSetup`: tipo (salvaje o entrenador), formato (individual o doble), equipos, entrenadores, reglas (se puede perder, sin objetos, sin experiencia...), fondo, música y clima inicial.
- [ ] `Battler`: el Pokémon **en el campo** (envuelve a un `Pokemon`). Tiene estado temporal: niveles de estadísticas (−6 a +6), estados volátiles (confusión, drenadoras, atrapado...), turnos en el campo, último movimiento usado...
- [ ] `Side`: bando (equipo, efectos de bando: Reflejo, Pantalla de Luz, trampas...).
- [ ] `Field`: clima, campo y efectos globales (Espacio Raro...).
- [ ] `BattleAction`: `Fight(move_slot, target)`, `Switch(party_index)`, `UseItem(item, target)`, `Run`.

### 7.3 Flujo de un turno

1. [ ] Cada bando elige su acción (jugador por menú, rival por IA).
2. [ ] **Orden**: huir y cambiar primero → objetos → movimientos por **prioridad** (−7 a +5) → dentro de la misma prioridad, **Velocidad efectiva** (con niveles y parálisis) → empate aleatorio.
3. [ ] Ejecutar cada acción:
   - [ ] Comprobar si puede moverse (dormido, congelado, paralizado 25 %, confuso, retroceso...)
   - [ ] Restar PP
   - [ ] **Precisión**: `precisión del movimiento × multiplicador (nivel de precisión del atacante − nivel de evasión del defensor)`
   - [ ] **Daño** (7.4)
   - [ ] Efectos secundarios (estado, cambios de estadísticas, retroceso...)
   - [ ] Comprobar debilitados
4. [ ] **Fin de turno**: clima, quemadura y veneno, Drenadoras, Restos (Fase 9)...
5. [ ] Sustituir a los debilitados (el jugador elige, la IA elige).
6. [ ] ¿Ha terminado el combate? → victoria, derrota, huida o captura.

### 7.4 Fórmula de daño (5.ª generación en adelante)

```
base = floor(floor(floor(2 × Nivel / 5 + 2) × Potencia × A / D) / 50) + 2

daño = base
     × objetivos (0,75 si golpea a varios en dobles)
     × clima (1,5 / 0,5)
     × crítico (1,5)
     × aleatorio (85..100 / 100)
     × STAB (1,5; 2 con Adaptable)
     × efectividad (0, 0,25, 0,5, 1, 2, 4)
     × quemadura (0,5 si es físico)
     × otros (objetos, habilidades, pantallas...)
```

- [ ] `A` y `D` = Ataque y Defensa (o At. Esp. y Def. Esp.) **con sus niveles aplicados**. En un crítico se ignoran los niveles negativos del atacante y los positivos del defensor.
- [ ] **Multiplicadores de nivel**: `max(2, 2+n) / max(2, 2−n)` para estadísticas y `max(3, 3+n) / max(3, 3−n)` para precisión y evasión.
- [ ] **Crítico**: nivel 0 = 1/24, +1 = 1/8, +2 = 1/2, +3 = siempre.
- [ ] Los juegos oficiales redondean los modificadores en base 4096. Para que el daño sea **exacto**, imita el redondeo de Showdown (`sim/battle.ts`, funciones de modificadores) y compara con la calculadora de daño de Showdown en los tests.
- [ ] Daño mínimo 1 (salvo inmunidad).

### 7.5 Tipos, estados y estadísticas

- [ ] Tabla de tipos 18×18 desde `types.json`.
- [ ] **Estados principales**: parálisis, quemadura, veneno, veneno grave, sueño (1–3 turnos) y congelación (20 % de descongelarse por turno). Inmunidades por tipo (Fuego no se quema, Eléctrico no se paraliza, etc.).
- [ ] **Confusión** y **retroceso** (volátiles).
- [ ] **Subidas y bajadas de estadísticas** con sus mensajes ("¡El Ataque de X subió mucho!").
- [ ] Movimientos **de estado** solo con datos: Gruñido, Látigo, Danza Espada, Paralizador, Hipnosis...

### 7.6 Efectos de movimiento "por datos"

Showdown describe la mayoría de los movimientos con campos estándar. Implementa estos campos **una vez** y cientos de movimientos funcionarán solos:

- [ ] `secondary` (probabilidad de estado, cambio de estadística o retroceso en el objetivo o en uno mismo)
- [ ] `boosts` / `self.boosts` (cambios de estadísticas)
- [ ] `status` (movimientos de estado que causan estados)
- [ ] `drain` (Absorber, Gigadrenado) y `recoil` (Doble Filo, Envite Ígneo)
- [ ] `multihit` (Doble Patada 2, Pin Misil 2–5)
- [ ] `priority`
- [ ] `critRatio` (Tajo Cruzado, Cuchillada)
- [ ] `ohko` (Fisura, Guillotina)
- [ ] `heal` (Recuperación, Respiro)
- [ ] `flags` (contacto, sonido, puñetazo, mordisco, bala...) para usarlos en la Fase 9

### 7.7 Combate salvaje: captura y huida

- [ ] **Huida**: fórmula por Velocidad e intentos; no se puede huir de entrenadores.
- [ ] **Captura** (fórmula moderna):
  - `a = ((3·PSmáx − 2·PSactual) · ratio_captura · bonus_ball / (3·PSmáx)) · bonus_estado` (sueño o congelación ×2,5; parálisis, quemadura o veneno ×1,5)
  - `b = 65536 / (255 / a)^0,1875`, y **4 comprobaciones de sacudida** (`random(0..65535) < b`)
  - Captura crítica según el número de especies capturadas
  - Bonus de cada Ball (Ocaso, Veloz, Turno, Nido, Malla, Rápida...)
- [ ] Animación: lanzar → sacudidas → "¡Ya está!" → mote → Pokédex → equipo o PC.

### 7.8 Experiencia, recompensas y fin del combate

- [ ] Experiencia a los que participaron (o a todos con Repartir Experiencia), EVs, subidas de nivel y movimientos nuevos.
- [ ] **Dinero** al ganar a un entrenador = `dinero_base_clase × nivel del último Pokémon` (Fase 10).
- [ ] **Derrota**: perder dinero → volver al último Centro Pokémon con el equipo curado (salvo en combates "que se pueden perder").
- [ ] Evoluciones pendientes al terminar.

### 7.9 IA básica

- [ ] Nivel 0 (salvajes): movimiento aleatorio.
- [ ] Nivel 1 (entrenadores débiles): elige el movimiento que más daño hace (usando el propio motor para calcularlo, sin RNG).
- [ ] Los niveles superiores van en la Fase 9.7.

### 7.10 Presentación (`BattleScene`)

- [ ] Transición de entrada (barrido o destello distinto para salvaje, entrenador y líder).
- [ ] Fondo y bases según el entorno.
- [ ] Sprite del rival entrando, sprite del entrenador saliendo y lanzamiento de la Ball.
- [ ] **Cajas de datos**: nombre, nivel, género, estado, barra de PS animada (verde → amarilla → roja) y barra de experiencia.
- [ ] **Menú principal**: Luchar / Mochila / Pokémon / Huir.
- [ ] **Menú de movimientos**: tipo, PP y (opcional) efectividad.
- [ ] Mensajes con el cuadro de diálogo de combate.
- [ ] **Animaciones de movimientos**: empieza con animaciones **genéricas por tipo y categoría** (golpe físico, rayo especial, estado) y añade animaciones específicas solo a los movimientos importantes.
- [ ] Parpadeo al recibir daño, desaparición al debilitarse, gritos y sonidos de golpe según la efectividad.

### 7.11 Tests del motor

- [ ] Tests de daño con casos conocidos (compara con la calculadora de Showdown).
- [ ] Tests de orden de turno (prioridad, Velocidad, parálisis).
- [ ] Tests de estados (el quemado hace la mitad de daño físico, etc.).
- [ ] Tests de captura (que con una Master Ball siempre se capture).
- [ ] **Combate simulado completo** con semilla fija: debe dar siempre el mismo resultado.

✅ **Criterio de "hecho":** combate individual completo contra salvaje (con captura) y contra entrenador (con IA nivel 1), con experiencia, subida de nivel, aprender movimientos y evolución. Tests en verde.

---

## Fase 8 — MVP jugable (Pueblo inicial + Ruta 1)

**Objetivo:** unir todo lo anterior en **un trozo pequeño pero completo** del juego.

### 8.1 Pantalla de título y nueva partida

- [ ] Título provisional: logo, "Pulsa Enter" y Nueva partida / Continuar.
- [ ] **Intro del profesor**: presentación del mundo, elegir chico o chica, introducir nombre (teclado en pantalla) y nombre del rival.
- [ ] El jugador aparece en su habitación.

### 8.2 Mapas del MVP

- [ ] Pueblo inicial: casa del jugador, casa del rival y laboratorio.
- [ ] Interiores: casa del jugador (2 plantas), casa del rival y laboratorio.
- [ ] Ruta 1 con hierba alta, objetos y 1–2 entrenadores.
- [ ] Ciudad 2 (aunque solo tenga Centro Pokémon y Tienda).

### 8.3 Elección de inicial

- [ ] 3 Poké Balls en la mesa del laboratorio (3 entidades).
- [ ] Al interactuar: mostrar el sprite → `await Dialogue.ask("¿Eliges a X?")` → añadir al equipo → flag `starter_chosen` + variable `starter`.
- [ ] Las otras dos Poké Balls desaparecen.
- [ ] El rival elige el inicial con **ventaja de tipo**.

### 8.4 Primer combate contra el rival

- [ ] Combate que **se puede perder** sin consecuencias.
- [ ] El equipo del rival depende de tu inicial (3 versiones en el JSON de entrenadores).

### 8.5 Pokédex, Poké Balls, Centro Pokémon y Tienda

- [ ] El profesor da la Pokédex (flag) y Poké Balls.
- [ ] **Centro Pokémon**: la enfermera cura (animación + jingle) y fija el `healing_spot`.
- [ ] **Tienda**: comprar y vender, con el catálogo de `shops.json`.
- [ ] **Derrota** → vuelta al último Centro Pokémon.

### 8.6 Primer entrenador Panchito

- [ ] Una clase humorística completa (por ejemplo, **Vendedor de Chupachups**) siguiendo la Fase 10, con sprite provisional.
- [ ] En la Ruta 1, con visión, frase de desafío, combate y frase de derrota.

### 8.7 Menú de pausa mínimo y guardado

- [ ] Menú: Pokédex, Pokémon, Mochila, Jugador, Guardar y Opciones (versiones básicas).
- [ ] **Guardado** (`SaveManager`):
  - [ ] `GameState` → `Dictionary` → JSON → `user://saves/slot_1.json`
  - [ ] Incluye `save_version` para migrar partidas antiguas en el futuro
  - [ ] Escritura segura: escribe a `.tmp` y renombra (si se va la luz, no se corrompe la partida)
  - [ ] Cargar restaura el mapa, la posición, la dirección, el equipo, la mochila, los flags y la hora jugada

✅ **Criterio de "hecho" (hito `v0.1`):** alguien que no conoce el juego empieza partida, elige inicial, pelea con el rival, captura un Pokémon, gana al Vendedor de Chupachups, se cura, compra, guarda, cierra, carga y sigue. **Sin el menú Debug.**

---

## Fase 9 — Combate avanzado (mecánicas modernas)

**Objetivo:** convertir el núcleo en un combate **moderno completo**.

### 9.1 Sistema de efectos (la pieza clave)

Habilidades, objetos equipados, movimientos especiales, climas y campos **reaccionan a momentos del combate**. En vez de llenar el motor de `if`, crea un **sistema de eventos** (como hace Showdown):

- [ ] El motor lanza "eventos" en momentos concretos y pregunta a todos los efectos activos:

| Hook (ejemplos) | Para qué |
|-----------------|----------|
| `on_switch_in` | Intimidación, Llovizna, trampas de entrada |
| `on_before_move` | Comprobaciones previas (Sueño, Mofa) |
| `on_modify_move` | Cambiar el tipo (Piel Feérica...) |
| `on_modify_atk` / `spa` / `def` / `spd` / `spe` | Agallas, Chaleco Asalto, Elección... |
| `on_base_power` | Experto, Fuerza Bruta, Mar Llamas... |
| `on_modify_damage` | Vidasfera, Filtro, Multiescamas |
| `on_try_hit` | Inmunidades (Levitación, Absorbe Agua) |
| `on_damaging_hit` | Elec. Estática, Cuerpo Llama, Casco Dentado |
| `on_after_move` | Vidasfera (retroceso), Elección (bloquear) |
| `on_residual` | Restos, Cura Lluvia, daño de clima |
| `on_set_status` | Inmunidades a estados |
| `on_faint` | Detonación de Resquicio... |

- [ ] Cada efecto es un script que **solo implementa los hooks que necesita**:

```gdscript
# src/battle/effects/abilities/intimidate.gd
extends BattleEffect

func on_switch_in(battle: BattleEngine, owner: Battler) -> void:
    for foe in battle.active_foes_of(owner):
        battle.change_stat(foe, &"atk", -1, owner)
```

- [ ] Registro: `Effects.ability(&"intimidate")`, `Effects.item(&"leftovers")`, `Effects.move(&"protect")`...
- [ ] **Orden de resolución** de los efectos (Velocidad, prioridad de efecto) como en los juegos oficiales.

### 9.2 Cobertura de movimientos, habilidades y objetos

Implementar **todo** es enorme. Estrategia:

- [ ] Lista de **qué se usa realmente**: movimientos que pueden aprender las especies de tu Pokédex + los de entrenadores + las MT. Genera la lista con un script.
- [ ] Marca cada movimiento como `data_only` (funciona con la Fase 7.6) o `needs_script`.
- [ ] Implementa por prioridad: primero lo que usan los líderes y los iniciales, después el resto.
- [ ] El validador (Fase 4.6) **avisa** de movimientos usados que no están implementados.
- [ ] Usa el código de Showdown (`data/moves.ts`, `data/abilities.ts`, `data/items.ts`, `data/conditions.ts`) como **referencia de comportamiento**.

Movimientos que suelen necesitar script: Protección, Sustituto, Relevo, Ida y Vuelta / Voltiocambio, movimientos de 2 turnos (Rayo Solar, Vuelo, Excavar), Contraataque, Mismo Destino, Transformación, Metrónomo, Mofa, Otra Vez, Tormento, Truco, Deseo, Golpe Bajo, Sorpresa, Defensa Férrea...

### 9.3 Clima, campos y efectos de bando y globales

- [ ] **Clima**: sol, lluvia, arena, granizo/nieve y los climas extremos (Hogaroso, Diluvio, Turbulencia). Duración de 5 turnos (8 con su roca).
- [ ] **Campos**: eléctrico, psíquico, de hierba y de niebla.
- [ ] **Efectos de bando**: Reflejo, Pantalla de Luz, Velo Aurora, Viento Afín, Velo Sagrado, Neblina...
- [ ] **Trampas**: Púas, Púas Tóxicas, Trampa Rocas y Red Viscosa (y Giro Rápido o Despejar para quitarlas).
- [ ] **Efectos globales**: Espacio Raro, Zona Mágica, Zona Extraña, Gravedad.

### 9.4 Combates dobles

- [ ] 2 Pokémon por bando, menús de **selección de objetivo** (rival izquierdo o derecho, aliado, todos...).
- [ ] `target` de los movimientos: `normal`, `allAdjacentFoes` (×0,75 de daño), `allAdjacent`, `self`, `ally`, `allySide`, `foeSide`, `all`, `randomNormal`...
- [ ] Redirección: si el objetivo se ha debilitado, se busca otro válido. Señuelo, Pararrayos y Colector.
- [ ] Movimientos de apoyo: Refuerzo, Paz Mental...
- [ ] **Formatos**: un entrenador doble, dos entrenadores a la vez (muy de Añil), **combate con un compañero** NPC a tu lado y dobles salvajes.
- [ ] *(Opcional)* Triples y hordas.

### 9.5 Habilidades y objetos equipados

- [ ] Habilidades de las especies de tu Pokédex (prioridad: iniciales, Pokémon de líderes y las más comunes).
- [ ] Objetos equipados de combate: Restos, Vidasfera, Banda Focus, Elección (Banda/Gafas/Pañuelo), Chaleco Asalto, Casco Dentado, bayas de curación, de estado y de resistencia, gemas, platos...
- [ ] Habilidades fuera de combate: Pies Rápidos o Intimidación reducen encuentros, Cuerpo Llama acelera la eclosión, Recogida...

### 9.6 Gimmicks generacionales

Cada una es un "modo" que se activa una vez por combate. Prográmalas **en el orden de la tabla de la Fase 2.7**:

- [ ] **Megaevolución**: Megapiedra equipada + Megapulsera (objeto clave). Cambio de forma con estadísticas y habilidad nuevas. Animación.
- [ ] **Movimientos Z**: Cristal Z + Pulsera Z. Convierten un movimiento en su versión Z (potencia según una tabla), y los Z de estado dan un efecto extra.
- [ ] **Dinamax / Gigamax**: 3 turnos, PS ×1,5–2, movimientos Max con efectos de campo. Solo en ciertos lugares (como en los juegos oficiales: estadios o raids).
- [ ] **Teracristalización**: cambia el tipo al Teratipo, reglas especiales de STAB y Teraorbe que se recarga en el Centro Pokémon.
- [ ] **Incursiones** (raids): combate 4 contra 1 con escudos (requiere dobles o un formato especial). Para el postgame.

### 9.7 IA avanzada

| Nivel | Comportamiento | Para quién |
|-------|----------------|-----------|
| 0 | Movimiento aleatorio | Salvajes |
| 1 | Movimiento de más daño | Entrenadores de ruta iniciales |
| 2 | + Evita movimientos inútiles (de estado repetido o contra una inmunidad), usa los de estado con sentido | Entrenadores de ruta medios |
| 3 | + Cambia de Pokémon ante desventaja clara, usa objetos de curación | Líderes |
| 4 | + Simula 1 turno con el motor para elegir la mejor jugada, prevé los cambios del jugador y usa gimmicks | Alto Mando, Campeón, postgame |

- [ ] El nivel de IA lo da la **clase de entrenador** (Fase 10) y se puede sobrescribir por entrenador.
- [ ] La IA nunca "hace trampa" con información oculta, salvo que lo decidas para el modo difícil.

### 9.8 Reglas y modos

- [ ] Reglas por combate: se puede perder, sin objetos, sin experiencia, nivel fijo (para torres y exhibiciones).
- [ ] Opción del jugador: modo **"Cambio"** (avisa del siguiente Pokémon del rival) frente a **"Fijo"**.
- [ ] *(Opcional)* **Modo difícil o Nuzlocke** activable al empezar (sube niveles e IA y aplica sus reglas).

✅ **Criterio de "hecho":** en la sala de pruebas hay un NPC por mecánica (clima, campos, trampas, dobles, compañero, Mega...) y todas funcionan. Tests del motor en verde.

---

## Fase 10 — Entrenadores Panchito (clases humorísticas)

> 🎭 **La seña de identidad del juego.** Aquí no hay "Cazabichos Pepe" ni "Entrenador Guay Luis". Hay **"Vendedor de Chupachups Manolo"**, **"Flautista Iker"**, **"Peruana de 1,50 Rosa"** o **"Robasientos del metro Paco"**.

### 10.1 Modelo de datos

**Clase** (`data/trainer_classes.json`): nombre que aparece delante, sexo, dinero, IA, sprites y música.

```json
"robasientos": {
  "name": "Robasientos del metro",
  "gender": "male",
  "base_money": 40,
  "ai_level": 1,
  "battle_sprite": "res://assets/sprites/trainers/robasientos.png",
  "overworld_sprite": "res://assets/sprites/characters/robasientos.png",
  "intro_bgm": "encounter_suspicious",
  "battle_bgm": "battle_trainer"
}
```

**Entrenador concreto** (`data/trainers/ruta_3.json`):

```json
"ruta3_paco": {
  "class": "robasientos",
  "name": "Paco",
  "intro_text": "¡Eh, tú! Ese sitio del vagón es mío.",
  "lose_text": "Ese asiento estaba libre, te lo juro.",
  "after_text": "Mañana vuelvo a pillarlo, que lo sepas.",
  "items": [],
  "party": [
    {"species": "ninjask", "level": 14},
    {"species": "pikachu", "level": 15,
     "moves": ["quickattack", "thundershock", "doubleteam", "thunderwave"],
     "item": "oranberry"}
  ],
  "rematches": ["ruta3_paco_2"]
}
```

- [ ] En combate se muestra **"<Clase> <Nombre>"**: *"¡Robasientos del metro Paco te desafía!"*.
- [ ] Campos opcionales por Pokémon: `moves`, `ability`, `item`, `nature`, `ivs`, `evs`, `gender`, `shiny`, `form`, `nickname`, `tera_type`.
- [ ] Si no se indican movimientos, se usan los 4 últimos aprendidos por nivel.

### 10.2 Lista de clases Panchito (propuesta inicial, amplíala)

| ID | Nombre en el juego | Sexo | Tema del equipo (sugerencia) | Frase de derrota (ejemplo) |
|----|--------------------|------|------------------------------|-----------------------------|
| `vendedorchupachups` | Vendedor de Chupachups | Hombre | Hada y dulces: Swirlix, Slurpuff, Applin, Alcremie | "¿Uno de fresa para olvidar la derrota?" |
| `flautista` | Flautista | Mixto | Sonido: Whismur, Loudred, Kricketune, Noibat | "Se me ha ido la nota..." |
| `peruana150` | Peruana de 1,50 | Mujer | Pequeños pero matones: Joltik, Cutiefly, Flabébé, Klefki | "Pequeña, pero la próxima te tumbo." |
| `robasientos` | Robasientos del metro | Hombre | Rapidísimos: Ninjask, Jolteon, Electrode, Accelgor | "Ese asiento estaba libre, te lo juro." |
| `cunado` | Cuñado que sabe de todo | Hombre | Normal "todoterreno": Ditto, Bibarel, Slaking | "Yo esto lo hubiera hecho mejor." |
| `jubiladoobras` | Jubilado mirando obras | Hombre | Roca y Lucha: Roggenrola, Timburr, Diglett | "Eso no se hace así, chaval." |
| `abuela` | Abuela que te pone de comer | Mujer | Glotones: Munchlax, Snorlax, Chansey | "Ay, qué delgado estás. Toma, cómete esto." |
| `influencerlinkedin` | Influencer de LinkedIn | Mixto | Psíquico: Espeon, Mr. Mime, Indeedee | "Humilde y agradecido de anunciar mi derrota." |
| `repartidorbici` | Repartidor en bici | Hombre | Rápidos o voladores: Talonflame, Dodrio, Rapidash | "Tu pedido ha sido cancelado." |
| `estudianteinge` | Estudiante de Ingeniería en exámenes | Mixto | Eléctrico/Acero: Magnemite, Rotom, Porygon | "Llevo tres días sin dormir, no cuenta." |
| `opositor` | Opositor eterno | Mixto | Lentos pero sabios: Slowpoke, Bronzor, Hypno | "Este año sí que me saco la plaza." |
| `patinetero` | Patinetero eléctrico | Hombre | Eléctrico: Pachirisu, Emolga, Electrike | "Se me ha acabado la batería." |
| `tertuliano` | Tertuliano de bar | Hombre | Charlatanes: Chatot, Murkrow, Meowth | "Pues en mis tiempos..." |
| `revisorcercanias` | Revisor del Cercanías | Mixto | Acero: Klink, Magneton, Bronzong | "Billete y DNI, por favor." |
| `domadorpalomas` | Domador de palomas | Hombre | Pidove, Pidgey, Tranquill, Unfezant | "Mis palomas volverán." |
| `crossfitero` | Crossfitero | Mixto | Lucha: Machop, Makuhita, Hawlucha | "Hoy tocaba día de pierna." |
| `turistachanclas` | Turista con chanclas y calcetines | Mixto | Playeros: Krabby, Wingull, Corsola | "Me voy a la playa a llorar." |
| `tuno` | Tuno | Hombre | Música: Kricketot, Jigglypuff, Toxtricity | "Clavelitos, clavelitos..." |
| `camarero` | Camarero sin propina | Hombre | Fuego y cocina: Slugma, Darumaka, Litwick | "¿Le cobro ya, caballero?" |
| `padretarjeta` | Padre con la tarjeta del súper | Hombre | Normal: Lillipup, Zigzagoon, Bidoof | "Ve a por el pan, que ya voy yo." |

- [ ] Elige las clases definitivas: **25–40 clases** dan variedad para 8 gimnasios.
- [ ] Reparte las clases **por zonas con sentido**: Robasientos y Revisor en el metro o la ciudad, Turista en la playa, Jubilado en zonas de obras...
- [ ] Aplica el humor también a los **reclutas del villano**, al **rival** y a los **líderes**, si quieres.
- [ ] Que el humor vaya sobre **situaciones y personajes cotidianos** y que sea gracioso para la gente a la que va dirigido.

### 10.3 Gráficos de cada clase

- [ ] **Sprite de combate** (`assets/sprites/trainers/<id>.png`), del mismo tamaño y estilo que el resto.
- [ ] **Spritesheet del mapa** (`assets/sprites/characters/<id>.png`): 4 direcciones × 3–4 frames.
- [ ] *(Opcional)* Retrato para los diálogos importantes.
- [ ] **Estilo coherente**: misma paleta y mismo grosor de contorno. Si usas bases ajenas, **pide permiso y acredita**.
- [ ] Mientras no haya arte: placeholder + **lista de pendientes** en `docs/entrenadores.md`.

### 10.4 Entrenador en el mapa (`TrainerNPC.tscn`)

Hereda de `NPC.tscn` y añade:

- [ ] `@export var trainer_id: StringName` y `@export var sight_range := 4`.
- [ ] **Línea de visión**: en cada `player_stepped`, comprueba si el jugador está en línea recta delante, a ≤ `sight_range` casillas y sin obstáculos en medio (raycast).
- [ ] Al verte: bloquea el input → "!" sobre la cabeza + música de intro de su clase → camina hasta ti → `intro_text` → combate.
- [ ] Al ganar: `lose_text` en el combate, flag `trainer_defeated:<id>` y después `after_text` al hablarle.
- [ ] Si ya está derrotado, no te ve (pero te habla).
- [ ] **Parejas** (combate doble): dos `TrainerNPC` enlazados que se activan juntos si te ve cualquiera de ellos.

### 10.5 Revanchas

- [ ] Elige un sistema: **teléfono** (Fase 14.6), **Buscapelea** (objeto clave) o revanchas automáticas por progreso de historia.
- [ ] Cada revancha es otro entrenador en el JSON (`rematches`) con un equipo más fuerte.

### 10.6 Registro

- [ ] `docs/entrenadores.md` con clase, nombre, mapa, nivel medio, obligatorio sí/no y estado del sprite. **Imprescindible para el balanceo (Fase 20).**

✅ **Criterio de "hecho":** al menos 10 clases Panchito con datos, sprites (aunque sean provisionales), música e IA, probadas en individual y en doble y con línea de visión correcta.

---

## Fase 11 — Objetos e inventario (+ objetos especiales Panchito)

### 11.1 Mochila

- [ ] **Bolsillos**: Objetos, Medicinas, Poké Balls, MT/MO, Bayas, Objetos de combate, Objetos clave y **"Cosas de Panchito"** (opcional, para los especiales).
- [ ] Cantidades (máx. 999), ordenar y registrar un objeto clave en un atajo (bici, caña...).
- [ ] Usar, equipar, tirar y ver la descripción.

### 11.2 Sistema de efectos de objetos

Igual que en el combate, cada objeto con comportamiento tiene un script con los métodos que necesita:

```gdscript
# src/items/effects/potion.gd
extends ItemEffect

@export var heal_amount := 20

func can_use_on(pkmn: Pokemon) -> bool:
    return not pkmn.is_fainted() and pkmn.current_hp < pkmn.max_hp()

func use_on(pkmn: Pokemon) -> String:
    var healed := pkmn.heal(heal_amount)
    return "%s recuperó %d PS." % [pkmn.display_name(), healed]
```

- [ ] **Usos**: en el campo sobre un Pokémon (pociones, vitaminas, piedras evolutivas), en el campo sin objetivo (Repelente, Cuerda Huida, bici), en combate sobre un Pokémon, en combate sin objetivo (Poké Balls), equipables (hooks del combate, Fase 9.1) y clave.
- [ ] Muchos objetos son **paramétricos**: una sola clase `HealItem` con `heal_amount` sirve para Poción, Superpoción, Hiperpoción...

### 11.3 Objetos estándar (revisar y repartir)

- [ ] **Curación**: Pociones, Antídoto, Despertar, Antiquemar, Antihielo, Antiparalizador, Cura Total, Revivir, Éter, Elixir, bayas...
- [ ] **Poké Balls modernas**: Poké, Super, Ultra, Master, Ocaso, Veloz, Turno, Nido, Malla, Lujo, Amigo, Sanadora, Buceo, Rápida, Ensueño...
- [ ] **Equipables competitivos** (Fase 9.5).
- [ ] **Piedras evolutivas** y objetos de evolución (incluidos los sustitutos del intercambio).
- [ ] **Megapiedras**, Megapulsera, Cristales Z, Teraorbe, Pulsera Dinamax (según la tabla de la Fase 2.7).
- [ ] **Vitaminas**, Caramelos Raros, Caramelos Exp., mentas, Parche Habilidad, Cápsula Habilidad, Más PP...
- [ ] **Objetos clave**: Bicicleta, cañas, Buscapelea, Pokégear o teléfono, Zahorí, Repartir Experiencia, Pokéflauta...
- [ ] **MT** reutilizables (estilo moderno) y **MO** o sus sustitutos (Fase 12.5).

### 11.4 Objetos especiales Panchito (por definir)

> 📝 **Estos objetos se definirán más adelante.** Esta sección deja preparado el sistema y una plantilla. Las ideas de abajo son solo **ejemplos para inspirar**; la lista real irá en `docs/objetos_especiales.md`.

**Ideas de ejemplo (no definitivas):**

| ID | Nombre | Tipo de uso | Posible efecto |
|----|--------|-------------|----------------|
| `bocatacalamares` | Bocata de calamares | Medicina | Cura 60 PS |
| `tuppermama` | Tupper de mamá | Medicina | Cura a todo el equipo fuera de combate (reutilizable cada X horas) |
| `tortillaconcebolla` / `tortillasincebolla` | Tortilla con o sin cebolla | Equipable | Dos versiones con efectos opuestos (el eterno debate) |
| `chupachupssuerte` | Chupachups de la suerte | Equipable | Sube el índice de crítico |
| `abanicoabuela` | Abanico de la abuela | Equipable | Inmune a quemaduras |
| `bonometro` | Bono de metro | Clave | Viaje rápido entre estaciones |
| `asientoreservado` | Asiento reservado | Clave | Desbloquea una zona (el "Snorlax" de Panchito) |

**Plantilla para crear un objeto especial:**

1. **Datos** en `data/items_panchito.json`:

```json
"bocatacalamares": {
  "name": "Bocata de calamares",
  "name_plural": "Bocatas de calamares",
  "pocket": "medicine",
  "price": 350,
  "description": "Un clásico. Restaura 60 PS a un Pokémon. Mejor con mayonesa.",
  "field_use": "on_pokemon",
  "battle_use": "on_pokemon",
  "effect": "heal_hp",
  "effect_params": {"amount": 60}
}
```

2. **Icono**: `assets/sprites/items/bocatacalamares.png`.
3. **Efecto**:
   - Si encaja en un efecto existente (`heal_hp`, `cure_status`, `boost_stat`...), **solo con el JSON ya funciona**.
   - Si es único, crea `src/items/effects/panchito/<id>.gd` con sus métodos (y sus hooks de combate si es equipable).
4. **Dónde se consigue**: tienda, suelo, NPC, premio o entrenador. Apúntalo en `docs/objetos_especiales.md`.
5. **Prueba**: dáselo con el Debug, úsalo dentro y fuera de combate, equípalo, véndelo y comprueba la descripción.

### 11.5 Distribución de objetos en el mundo

- [ ] **Objetos visibles** (`ItemBall.tscn`) y **ocultos** (detectables con el Zahorí).
- [ ] **Regalos de NPCs** (una sola vez, con flag).
- [ ] **Tiendas por ciudad** con catálogo que crece con las medallas.
- [ ] **Tiendas especiales**: grandes almacenes, tienda de MT, bayas y una **tienda Panchito** (kiosko de chuches, bar o mercadillo).

✅ **Criterio de "hecho" (hito `v0.2` junto con las Fases 9–10):** mochila completa, objetos estándar funcionando y al menos 1 objeto Panchito de prueba creado con la plantilla.

---

## Fase 12 — Mundo: región, mapas y navegación

### 12.1 Convenciones de mapas

- [ ] Nombres: `maps/<zona>/<nombre>.tscn`, por ejemplo `maps/ciudad1/exterior.tscn` o `maps/ciudad1/centro_pokemon.tscn`.
- [ ] Tamaños de ruta en múltiplos de la pantalla para que las conexiones encajen.
- [ ] Bordes con árboles, agua o acantilados: **que nunca se vea el vacío** (la cámara tiene límites, pero el borde debe ser bonito).
- [ ] **Escenas plantilla** (`Centro Pokémon`, `Tienda`, `Casa pequeña`) que se instancian o se copian en cada ciudad.

### 12.2 Lista de producción

Tabla en `docs/mapas/lista.md` con el estado (`boceto → pintado → entidades → probado`):

- [ ] Pueblo inicial e interiores
- [ ] 8 ciudades con gimnasio (exterior, gimnasio, Centro Pokémon, Tienda y 2–4 casas)
- [ ] 2–4 pueblos sin gimnasio
- [ ] ~20–25 rutas
- [ ] Cuevas con varios pisos, bosque, montaña, zonas de agua y buceo, islas
- [ ] Guarida del villano
- [ ] Calle Victoria, Liga (recepción, 4 salas, Campeón, Hall de la Fama)
- [ ] Zonas del postgame
- [ ] **Zonas Panchito**: estación de metro como mazmorra, mercadillo, fiestas del pueblo...

### 12.3 Mapa de la región y vuelo

- [ ] Imagen del mapa de la región + `region_map_position` de cada mapa.
- [ ] Pantalla del mapa: cursor, nombre de la zona y "estás aquí".
- [ ] **Vuelo**: elegir una ciudad visitada en el mapa → animación → aparecer en la puerta de su Centro Pokémon.

### 12.4 Mapas conectados sin cortes (opcional, avanzado)

- [ ] En vez de un fundido en el borde, cargar el mapa vecino **desplazado** junto al actual y descargar el anterior al alejarte, como en los juegos oficiales.
- [ ] Requiere definir conexiones (`map_connections.json`: mapa A, lado, desplazamiento, mapa B).
- [ ] Hazlo solo cuando todo lo demás funcione; no es imprescindible.

### 12.5 Movimientos de campo y obstáculos

- [ ] Decide el estilo: **MO clásicas** (enseñar Corte...) o **moderno** (objetos o "Pokémon de montura" que no ocupan ranura de movimiento). **Recomendado: moderno**, porque es mejor experiencia.
- [ ] Obstáculos: árbol cortable, roca rompible, roca de fuerza (puzles), agua (Surf), cascada, buceo, zonas oscuras (Destello) y paredes escalables.
- [ ] **Surf**: cambio de sprite, encuentros en el agua y bajar a tierra.
- [ ] **Bicicleta**: velocidad ×2 y zonas donde es obligatoria.
- [ ] **Bordillos (ledges)**: saltar hacia abajo con su animación.
- [ ] **Hielo resbaladizo**, cintas o flechas y teletransportadores (para cuevas y gimnasios).
- [ ] *(Opcional)* **Bono de metro Panchito** como viaje rápido alternativo.

✅ **Criterio de "hecho":** todos los mapas de la ruta crítica están pintados y conectados, el mapa de la región y el vuelo funcionan, y cada obstáculo tiene su mecánica.

---

## Fase 13 — Historia, eventos y cinemáticas

### 13.1 API de cinemáticas con `await`

La gran ventaja de Godot: un evento de historia es **un script que se lee como un guion**.

```gdscript
# maps/pueblo_inicial/events/rival_te_para.gd
extends StoryEvent

func run() -> void:
    if GameState.flag(&"rival_intro_done"):
        return
    await Cutscene.lock_player()
    await Cutscene.music("rival_theme")
    await Cutscene.emote(rival, "!")
    await Cutscene.walk(rival, [Vector2i.DOWN, Vector2i.DOWN, Vector2i.LEFT])
    await Cutscene.face_each_other(rival, player)
    await Dialogue.say("¡{player}! ¡Espera! ¿No te irás sin pelear conmigo?", rival)
    var result := await Battle.trainer(&"rival_lab_" + str(GameState.var_int(&"starter")),
                                       {"can_lose": true})
    await Dialogue.say("Bah, ha sido suerte.", rival)
    await Cutscene.walk(rival, [Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.UP])
    rival.hide()
    GameState.set_flag(&"rival_intro_done")
    await Cutscene.unlock_player()
```

- [ ] Funciones de `Cutscene`: `lock_player`/`unlock_player`, `walk(entity, path)`, `face(entity, dir)`, `emote`, `wait(seg)`, `fade_out`/`fade_in`, `shake`, `tint`, `music`, `sfx`, `camera_pan`/`camera_reset`, `show_entity`/`hide_entity` y `give_item`/`give_pokemon`.
- [ ] **Disparadores** de eventos: al hablar con algo, al pisar una casilla (`Trigger`), al entrar en el mapa y automáticos según un flag.

### 13.2 Flags y variables

- [ ] `GameState.flags: Dictionary` con **claves de texto** (`&"got_pokedex"`, `&"gym1_won"`) en vez de números. Mucho más legible que los switches numerados.
- [ ] `GameState.vars` para números (`&"story_progress"`, `&"starter"`).
- [ ] Registro de todas las claves en `docs/flags.md`.
- [ ] `story_progress` con valores espaciados (0, 10, 20...) para poder insertar pasos.
- [ ] Las entidades del mapa pueden tener `visible_if_flag` / `hidden_if_flag` para aparecer o desaparecer según la historia, sin escribir código.

### 13.3 Guion

- [ ] `docs/guion/` con un archivo por capítulo (`01_inicio.md`, `02_ruta1_a_ciudad1.md`...).
- [ ] Tono: humor en NPCs y entrenadores, **momentos serios** cuando la trama lo pide.
- [ ] *(Si usas Dialogue Manager)* los diálogos largos van en archivos `.dialogue` y los eventos solo los llaman.

### 13.4 Momentos clave (mínimo)

- [ ] Intro y elección de inicial (ya en el MVP)
- [ ] Combates contra el rival (5–7)
- [ ] Primera aparición del equipo villano
- [ ] Infiltración en la guarida (reclutas, puzle y jefe)
- [ ] Combates de líder: presentación, combate, medalla, MT y desbloqueo
- [ ] Encuentro con el legendario de portada
- [ ] Final del villano
- [ ] Liga y créditos
- [ ] Desbloqueo del postgame

### 13.5 Protección contra bloqueos

- [ ] El jugador **nunca** puede quedarse atascado: sin forma de cortar un árbol, sin dinero, encerrado en una cueva... Pon salidas alternativas.
- [ ] Si el legendario se debilita o el jugador huye: reaparece tras la Liga o se puede reintentar.
- [ ] Las cinemáticas **no se pueden romper** abriendo el menú (input bloqueado).

✅ **Criterio de "hecho":** guion de la historia principal escrito y la historia del primer tramo implementada.

---

## Fase 14 — Sistemas de mundo vivo

### 14.1 Tiempo y día/noche

- [ ] `Clock`: **reloj real** (`Time.get_datetime_dict_from_system()`) o **reloj interno** (acelerado). Decídelo en el GDD.
- [ ] Momentos: mañana, día, tarde y noche.
- [ ] **Tinte**: `CanvasModulate` en el mapa cuyo color sale de un `Gradient` según la hora (solo si `outdoor`).
- [ ] Luces nocturnas (farolas y ventanas) con `PointLight2D` o sprites aditivos.
- [ ] Encuentros, evoluciones y eventos según la hora y el día de la semana.
- [ ] *(Opcional)* Estaciones por mes.

### 14.2 Clima

- [ ] Lluvia, tormenta (con relámpagos), nieve, ventisca, niebla, sol y arena: capa de partículas (`GPUParticles2D` / `CPUParticles2D`) + tinte + sonido ambiente.
- [ ] El clima del mapa pasa al combate (Fase 9.3).
- [ ] Encuentros especiales con cierto clima.

### 14.3 Crianza

- [ ] **Guardería**: dejar dos Pokémon, compatibilidad por grupo huevo y sexo (Ditto como comodín), probabilidad de huevo por pasos.
- [ ] **Herencia**: especie base (incluidos los bebés con incienso), movimientos huevo, IVs (3 al azar, 5 con Lazo Destino), naturaleza (Piedra Eterna), habilidad oculta y Ball.
- [ ] **Eclosión** por pasos (Cuerpo Llama la acelera) con animación.
- [ ] Método Masuda (más shiny con padres de distinto idioma): opcional y humorístico.

### 14.4 Encuentros especiales

- [ ] **Shiny** (con Amuleto Iris en el postgame) y animación de brillo.
- [ ] **Pokérus**.
- [ ] **Pesca** (3 cañas, minijuego de "¡Pican!"), **Golpe Cabeza** en árboles y **Golpe Roca**.
- [ ] **Errantes** (aparecen al azar en rutas y huyen).
- [ ] **Estáticos** (legendarios y Pokémon dormidos que bloquean el paso).
- [ ] *(Opcional)* Encuentros visibles en el mapa (como en los juegos modernos), Poké Radar y cadenas.
- [ ] *(Opcional)* Incursiones y SOS.

### 14.5 Pokémon que te sigue

- [ ] El primer Pokémon del equipo camina detrás: sigue el **historial de casillas** del jugador.
- [ ] Sprites del mapa por especie (de la comunidad, acreditados), con fallback si falta alguno.
- [ ] Hablarle → frase según el estado, la amistad o el lugar (otro sitio estupendo para el humor).
- [ ] Se esconde al hacer Surf, ir en bici o entrar en ciertos interiores.

### 14.6 Bayas y teléfono

- [ ] **Plantación de bayas**: plantar, regar y crecimiento por tiempo real.
- [ ] **Teléfono o Pokégear**: contactos, llamadas de entrenadores (revanchas), de la madre o del profesor, y radio (opcional). Ideal para el humor Panchito.

### 14.7 Amistad

- [ ] La amistad sube al caminar, al usar vitaminas y al subir de nivel, y baja al debilitarse o con hierbas amargas.
- [ ] NPC que te dice la amistad, evoluciones por amistad y movimientos como Retribución o Frustración.

✅ **Criterio de "hecho":** cada sistema tiene al menos un uso real en el juego, no solo en la sala de pruebas.

---

## Fase 15 — Interfaz (UI/UX)

### 15.1 Base técnica

- [ ] **Theme** global de Godot (fuentes, colores, `StyleBox` de los marcos): **un solo sitio** para cambiar el aspecto de todo.
- [ ] **Fuente pixel** con **ñ, tildes, ¿ y ¡** (compruébalo antes de elegirla). Revisa su licencia.
- [ ] **Navegación 100 % con teclado o mando**: foco (`grab_focus`, `focus_neighbor_*`), cursor visible y sonido al moverte, aceptar o cancelar.
- [ ] **Pila de menús** en `SceneManager` (abrir un menú encima de otro y volver con `cancel`).
- [ ] Animaciones de entrada y salida rápidas (≤ 0,15 s); nunca deben ralentizar al jugador.

### 15.2 Identidad visual

- [ ] **Logo de Pokémon Panchito** con tipografía propia parecida a la oficial.
- [ ] **Pantalla de título** con fondo, logo, música, "Pulsa Enter" y una animación sencilla.
- [ ] Paleta y marcos (cuadros de diálogo) con estilo Panchito; el jugador puede elegir el marco en las opciones.

### 15.3 Pantallas

- [ ] **Menú de pausa**
- [ ] **Equipo**: lista, reordenar, ver datos, usar objeto, movimientos de campo
- [ ] **Datos del Pokémon** (*Summary*): info, estadísticas (con IVs y EVs visibles opcionalmente), movimientos con descripción, cintas
- [ ] **Mochila** con bolsillos
- [ ] **Pokédex**: lista, entrada con sprite, grito, tipos, altura y peso, descripción, área en el mapa y formas
- [ ] **PC** con cajas
- [ ] **Tarjeta de entrenador** y **estuche de medallas** con **diseño propio de las 8 medallas**
- [ ] **Mapa de la región**
- [ ] **Opciones**: velocidad de texto, volumen (música, efectos y gritos por separado), modo de combate (cambio o fijo), animaciones de combate sí/no, marco, controles y pantalla completa
- [ ] **Guardar y cargar** con resumen (tiempo, medallas, equipo) y varias ranuras
- [ ] **Teclado de nombres** (para el nombre del jugador y los motes)
- [ ] **Tiendas** (comprar y vender con selector de cantidad)
- [ ] **Interfaz de combate** (Fase 7.10)

### 15.4 Calidad de vida moderna

- [ ] **Acelerar el juego** (×2/×4 con una tecla: `Engine.time_scale`).
- [ ] Correr siempre como opción.
- [ ] Repartir Experiencia moderno.
- [ ] Efectividad visible en el menú de movimientos (opcional).
- [ ] Recordador de movimientos accesible.
- [ ] Repelente que pregunta si quieres usar otro cuando se acaba.
- [ ] PC desde el menú (desbloqueable) y autoguardado opcional.
- [ ] Indicador de "objeto nuevo" en la mochila.

### 15.5 Accesibilidad

- [ ] Tamaño de texto legible a la resolución base.
- [ ] No transmitir información **solo por color** (por ejemplo, la efectividad con texto además del color).
- [ ] Opción para reducir los destellos y temblores de pantalla.

✅ **Criterio de "hecho":** todas las pantallas funcionan solo con teclado y solo con mando, sin textos en inglés ni placeholders.

---

## Fase 16 — Audio

### 16.1 `AudioManager` y buses

- [ ] **Buses** (*Audio → Buses*): `Master`, `BGM`, `SE`, `ME`, `Cries`, `Ambient`, con volúmenes controlados desde las opciones.
- [ ] **BGM** con crossfade entre mapas y sin reiniciar si el mapa nuevo tiene la misma pista.
- [ ] **ME** (jingles): pausan la BGM, suenan y la reanudan donde estaba.
- [ ] **Bucles**: archivos `.ogg` con *loop* activado y **loop offset** en la importación (para intros que no se repiten).
- [ ] **Gritos** de Pokémon (por especie, al entrar en combate y en la Pokédex).

### 16.2 Lista de pistas

| Categoría | Pistas necesarias |
|-----------|-------------------|
| **BGM** | Título, intro del profesor, pueblo inicial, laboratorio, ciudades (o grupos), rutas (3–5), cueva, bosque, mar/surf, bici, Centro Pokémon, Tienda, gimnasio, guarida villana, Liga, Hall de la Fama, créditos y **tema de Panchito** |
| **Combate** | Salvaje, entrenador, **entrenador Panchito** (opcional), rival, líder, villanos, jefe villano, legendario, Alto Mando, Campeón y las victorias |
| **ME** | Curar, objeto, objeto clave, medalla, evolución, captura, subir de nivel, eclosión |
| **SE** | Menú (mover, aceptar, cancelar, error), puertas, choque, salto, hierba, golpes (normal, poco eficaz, supereficaz), PS bajos, Poké Ball |
| **Intro de entrenador** | Por clase o género, por ejemplo una melodía "sospechosa" para el Robasientos |
| **Ambiente** | Lluvia, viento, mar, cueva y ciudad |

### 16.3 Origen y licencias

- [ ] Remixes de la comunidad **con permiso** y crédito.
- [ ] Música propia, aunque sea solo un **tema de Panchito** que identifique el juego.
- [ ] Volumen **normalizado** entre pistas.
- [ ] Todo en `CREDITOS.md`.

✅ **Criterio de "hecho":** ningún mapa ni combate sin música, volúmenes equilibrados y créditos completos.

---

## Fase 17 — Producción de contenido por tramos (8 gimnasios)

**Objetivo:** construir el juego **tramo a tramo**. Un tramo = todo lo que hay entre dos medallas. Repite esta plantilla 8 veces.

### 17.1 Plantilla de tramo

**A. Diseño (en el GDD)**
- [ ] Mapas del tramo: rutas, ciudad y mazmorra.
- [ ] Especies nuevas (3–5 por ruta) y su reparto por hora.
- [ ] Entrenadores del tramo: 4–8 por ruta, **con clases Panchito variadas** y acordes a la zona.
- [ ] Objetos del tramo, incluido **algún objeto Panchito**.
- [ ] Evento de historia del tramo (rival o villano).
- [ ] Líder: tipo, puzle, equipo, medalla, MT y desbloqueo.

**B. Construcción**
- [ ] Mapas pintados y conectados.
- [ ] Encuentros (`data/encounters/*.json`).
- [ ] Entrenadores (`data/trainers/*.json` + `TrainerNPC` en los mapas).
- [ ] Objetos colocados.
- [ ] NPCs de ciudad (5–10 con pistas, humor o lore).
- [ ] Centro Pokémon y Tienda con el catálogo actualizado.
- [ ] Eventos de historia.
- [ ] Movimientos y habilidades que aparecen por primera vez, **implementados** (el validador lo comprueba).

**C. Gimnasio**
- [ ] Puzle (interruptores, laberinto, preguntas, teletransportes, oscuridad, hielo...).
- [ ] 2–4 entrenadores de gimnasio.
- [ ] "Guía del gimnasio" en la entrada (puede ser otra clase Panchito con consejos absurdos).
- [ ] Líder: diálogo antes y después, IA nivel 3+, **un "as"** que obligue a pensar y música propia.
- [ ] Medalla, MT y desbloqueo.
- [ ] Revancha para el postgame.

**D. Verificación**
- [ ] Partida del tramo **sin Debug**, partiendo del guardado del tramo anterior.
- [ ] Nivel del equipo al llegar al líder ≈ curva de la Fase 2.5.
- [ ] Dinero suficiente para curarse.
- [ ] Sin bloqueos (Fase 13.5).
- [ ] Guarda la partida de final de tramo en `tests/saves/tramoN.json` (sirve para probar los siguientes).
- [ ] Validador y tests en verde → merge a `main` → tag si cierra un hito.

### 17.2 Tramos

- [ ] **Tramo 1**: → Gimnasio 1 → **`v0.3` demo pública**
- [ ] **Tramo 2**: → Gimnasio 2
- [ ] **Tramo 3**: → Gimnasio 3 (Surf: el mundo se abre)
- [ ] **Tramo 4**: → Gimnasio 4 + guarida villana → **`v0.5`**
- [ ] **Tramo 5**: → Gimnasio 5
- [ ] **Tramo 6**: → Gimnasio 6
- [ ] **Tramo 7**: → Gimnasio 7 + clímax villano y legendario
- [ ] **Tramo 8**: → Gimnasio 8 → **`v0.8`**

> 💡 Tras la demo (`v0.3`), **recoge feedback** antes de seguir: ritmo, dificultad, qué chistes funcionan y cuáles no. Corregir el rumbo en el tramo 2 es mucho más barato que en el 7.

✅ **Criterio de "hecho":** los 8 tramos pasan la verificación D.

---

## Fase 18 — Liga Pokémon y postgame

### 18.1 Calle Victoria

- [ ] Mazmorra larga que exige varios movimientos de campo.
- [ ] Entrenadores fuertes, con versiones "veteranas" de las clases Panchito.
- [ ] Guardia que comprueba las 8 medallas.

### 18.2 Liga

- [ ] Recepción con Centro Pokémon y tienda.
- [ ] **Alto Mando** (4 salas en orden), sin poder salir y con curación solo con objetos.
- [ ] **Campeón** con música, sala y diálogo propios.
- [ ] **Hall de la Fama**: registro del equipo, que se guarda.
- [ ] **Créditos** con todos los colaboradores y recursos de `CREDITOS.md`.
- [ ] Vuelta a casa y desbloqueo del postgame.

### 18.3 Postgame

- [ ] Nuevas zonas: islas, montaña, zonas secretas Panchito...
- [ ] Legendarios del postgame.
- [ ] **Revanchas** de líderes y del Alto Mando.
- [ ] Pokédex Nacional (si se decidió) y evaluación de la Pokédex.
- [ ] Amuleto Iris.
- [ ] Tienda competitiva (mentas, Parches Habilidad, Caramelos Exp.).
- [ ] Gimmicks del postgame (Tera, Dinamax o Z, según la Fase 2.7).
- [ ] Epílogo de la historia.

✅ **Criterio de "hecho" (hito `v1.0` junto con las Fases 20–21):** se puede llegar a los créditos y el postgame tiene al menos 3–5 horas de contenido.

---

## Fase 19 — Contenido secundario, competitivo y online

Cada punto es independiente. Elige los que quieras y en el orden que quieras.

### 19.1 Misiones secundarias

- [ ] Sistema de misiones: estado por misión en `GameState` + pantalla de registro en el menú.
- [ ] 15–30 misiones con humor Panchito: recuperar el bocata del repartidor, encontrar al jubilado perdido en las obras, ayudar al opositor a estudiar (minijuego de preguntas)...
- [ ] Intercambios con NPCs (Pokémon con mote gracioso).

### 19.2 Minijuegos

- [ ] Zona Safari (combate especial con cebo y roca).
- [ ] Concurso de captura de bichos.
- [ ] Sala de juegos (Voltorb Flip o similar).
- [ ] Minijuegos Panchito: carrera para sentarse en el metro, quiz del opositor, regateo en el mercadillo...

### 19.3 Competitivo

- [ ] **Torre o Frente de Batalla**: combates seguidos a nivel 50, rachas, puntos y premios. El motor ya soporta reglas de nivel fijo (Fase 9.8).
- [ ] Juez de IVs, entrenador de EVs (¿el **Crossfitero de EVs**?) y tienda de naturalezas.
- [ ] Exportar o importar equipos en **formato Showdown** (texto). Muy útil para probar y para compartir.

### 19.4 Coleccionables y logros

- [ ] Coleccionables Panchito (cromos, chapas...) con recompensas.
- [ ] Logros internos y estadísticas (pasos, capturas, combates ganados...).

### 19.5 Online (opcional, avanzado)

Godot trae red de serie (`ENetMultiplayerPeer`, `WebSocketMultiplayerPeer`), así que es **viable**:

- [ ] **Intercambio** entre amigos: conectar por IP o código → enseñar el Pokémon ofrecido → confirmar los dos → intercambiar. Valida los datos recibidos (nada de Pokémon imposibles).
- [ ] **Combate entre amigos**: gracias al motor determinista (Fase 7.1), cada cliente solo envía **acciones** y ambos simulan con la misma semilla.
- [ ] Problemas reales: NAT o puertos (requiere abrir puertos, una VPN tipo LAN virtual o un servidor relay) y trampas.
- [ ] **Regalo misterioso** por código: mucho más sencillo y sin servidor. Ideal para eventos entre amigos.

---

## Fase 20 — Balanceo, QA y testing

### 20.1 Tests automáticos

- [ ] **Motor de combate**: daño, orden, estados, efectos, gimmicks y combates completos con semilla.
- [ ] **Datos**: validador (Fase 4.6).
- [ ] **Guardado**: guardar → cargar → comparar.
- [ ] **Smoke test**: arrancar el juego en modo `--headless` y cargar cada mapa sin errores.
- [ ] *(Opcional)* **GitHub Actions** que ejecuta los tests en cada pull request (con Godot en modo headless).

### 20.2 Balanceo

- [ ] Hoja de cálculo con **el nivel de cada entrenador obligatorio** en orden frente a la curva teórica. Busca picos.
- [ ] **Experiencia**: ¿se llega al nivel esperado sin grindear si combates con todos?
- [ ] **Economía** por tramo.
- [ ] **Partida con cada inicial**: ningún gimnasio debe ser un muro con uno ni un paseo con otro.
- [ ] **Diversidad de equipos** y cobertura de tipos antes de cada gimnasio.
- [ ] Herramienta de **simulación en masa**: enfrentar el equipo "esperado" contra cada líder 1000 veces con la IA y medir el porcentaje de victorias. Es fácil gracias al motor sin presentación.

### 20.3 Testing manual

- [ ] **Checklist de regresión** (`docs/qa_checklist.md`) antes de cada versión:
  - [ ] Nueva partida → primer Centro Pokémon
  - [ ] Guardar y cargar en cada tramo
  - [ ] Cada movimiento de campo
  - [ ] Cada tienda
  - [ ] Cada líder da medalla y MT
  - [ ] Cada objeto Panchito
  - [ ] Liga → créditos → postgame
  - [ ] Opciones (volumen, velocidad, pantalla completa)
  - [ ] Teclado **y** mando
- [ ] **Testers externos**: míralos jugar sin ayudar; donde se atascan hay un problema de diseño.
- [ ] **GitHub Issues** con plantilla de bug (qué pasó, qué esperabas, pasos, captura, log y partida guardada).
- [ ] **Revisión de textos**: ortografía, tildes, ¿¡, nombres consistentes y que nada se salga del cuadro.
- [ ] **Partidas antiguas**: migración de `save_version` probada.

### 20.4 Rendimiento

- [ ] Profiler de Godot en mapas grandes y en combate.
- [ ] Carga de mapas < 0,5 s (precarga de los vecinos si hace falta).
- [ ] Probar en un PC modesto y, si se publica, en Android.

✅ **Criterio de "hecho":** tests en verde, checklist superada, cero bugs bloqueantes y al menos 3 testers externos han terminado el juego.

---

## Fase 21 — Exportación, publicación y mantenimiento

### 21.1 Exportación

- [ ] Instala las **export templates** de tu versión exacta de Godot (*Editor → Gestionar plantillas de exportación*).
- [ ] Presets en *Proyecto → Exportar*: **Windows** (principal), **Linux**, **macOS** (necesita firma para evitar avisos) y **Android** (necesita SDK y keystore). Ojo con **Web**: es cómoda, pero hace el fangame más visible.
- [ ] Icono del ejecutable, nombre y versión (`application/config/version`).
- [ ] Excluye del export: `tests/`, `tools/`, `docs/` y la sala de pruebas.
- [ ] Desactiva el Debug: `OS.is_debug_build()` es `false` en las exportaciones *release*.
- [ ] *(Opcional)* **Cifrado del .pck**: requiere compilar las plantillas de exportación con una clave. Solo frena a curiosos; no es imprescindible.
- [ ] Prueba la build en **otro PC sin Godot**.

### 21.2 Distribución

- [ ] **GitHub Releases** del repo `Pokemon-Panchito` con el `.zip` de cada plataforma, `LEEME.txt` (controles, instalación, aviso legal) y `CREDITOS.txt`.
- [ ] *(Opcional)* itch.io **gratis, sin donaciones**.
- [ ] Aviso legal visible: *"Pokémon Panchito es un fangame sin ánimo de lucro. Pokémon y todos sus personajes son propiedad de Nintendo, Game Freak y The Pokémon Company. No está afiliado a ellos."*

> ⚠️ **Realidad legal:** Nintendo y The Pokémon Company cierran fangames con regularidad, sobre todo los que se hacen populares o se monetizan. Para reducir el riesgo: nada de dinero, perfil bajo y **copia de seguridad del proyecto fuera de GitHub** por si el repo recibe una retirada por DMCA.
>
> 💡 **Ventaja de haberlo hecho desde cero:** todo el código, el motor y las clases Panchito son **tuyos**. Si algún día quisieras un juego original, bastaría con cambiar los datos y los gráficos de los Pokémon por criaturas propias.

### 21.3 Mantenimiento

- [ ] `CHANGELOG.md` por versión.
- [ ] Versionado: `vX.Y.Z` (Z = parches, Y = contenido).
- [ ] **Compatibilidad de partidas** entre versiones (migraciones de `save_version`).
- [ ] Actualiza Godot **solo entre hitos** y con todos los tests pasando.

---

## Apéndices

### Apéndice A — Recursos y referencias

| Recurso | Para qué |
|---------|----------|
| **Documentación oficial de Godot** (docs.godotengine.org) | Nodos, GDScript, TileMapLayer, exportación |
| **Pokémon Showdown** (código en GitHub, `smogon/pokemon-showdown`) | Datos y **la referencia de cómo funciona cada mecánica** (`sim/`, `data/`) |
| **Calculadora de daño de Showdown** | Verificar la fórmula de daño en los tests |
| **PokeAPI** (repo con los CSV) | Nombres y descripciones en español, Pokédex, tablas de experiencia |
| **Bulbapedia** / **WikiDex** | Fórmulas (experiencia, captura, crianza) y comportamiento de movimientos |
| **Pokémon Añil** (jugarlo) | Referencia de ritmo, dobles, calidad de vida y estilo |
| **Comunidades de fangames** (Relic Castle, Eevee Expo) | Recursos gráficos con permiso de uso: tilesets, sprites del mapa, sprites de seguimiento |

> La mayoría de los tutoriales de Godot de internet son de **Godot 3**, que no es compatible con Godot 4 (`TileMap` frente a `TileMapLayer`, `yield` frente a `await`, `KinematicBody2D` frente a `CharacterBody2D`...). Comprueba siempre la versión.

### Apéndice B — Fórmulas (resumen)

| Cálculo | Fórmula |
|---------|---------|
| PS | `floor((2B + IV + floor(EV/4)) · L / 100) + L + 10` |
| Otras estadísticas | `floor((floor((2B + IV + floor(EV/4)) · L / 100) + 5) · Nat)` |
| Nivel de estadística | `max(2, 2+n) / max(2, 2−n)` |
| Nivel de precisión o evasión | `max(3, 3+n) / max(3, 3−n)` |
| Daño base | `floor(floor(floor(2L/5 + 2) · P · A/D) / 50) + 2` |
| Modificadores de daño | objetivos × clima × crítico (1,5) × aleatorio (0,85–1) × STAB × tipo × quemadura × otros |
| Crítico | nivel 0: 1/24 · +1: 1/8 · +2: 1/2 · +3: 100 % |
| Captura (`a`) | `((3·PSmáx − 2·PS) · ratio · ball / (3·PSmáx)) · estado` |
| Sacudida (`b`) | `65536 / (255/a)^0,1875`, con 4 comprobaciones |
| Dinero al ganar | `dinero_base_clase × nivel del último Pokémon` |

> Verifica cada fórmula con tests y casos conocidos. Los detalles de redondeo importan.

### Apéndice C — Plantilla de `docs/flags.md`

```markdown
## Flags
| Clave | Se activa en | Efecto |
|-------|--------------|--------|
| got_pokedex | Laboratorio, al hablar con el profesor | Habilita la Pokédex en el menú |
| trainer_defeated:ruta3_paco | Al ganar a Paco | Ya no te ve |

## Variables
| Clave | Valores | Notas |
|-------|---------|-------|
| starter | 1 Planta / 2 Fuego / 3 Agua | Decide el equipo del rival |
| story_progress | ver tabla | |
```

### Apéndice D — Plantilla de ficha de entrenador Panchito

```markdown
### Robasientos del metro Paco
- **ID:** ruta3_paco (clase: robasientos)
- **Mapa:** Ruta 3 (estación abandonada)
- **Visión:** 4 casillas
- **Equipo:** Ninjask Nv14, Pikachu Nv15 (Baya Aranja)
- **Al verte:** "¡Eh, tú! Ese sitio del vagón es mío."
- **Derrota:** "Ese asiento estaba libre, te lo juro."
- **Después:** "Mañana vuelvo a pillarlo, que lo sepas."
- **Revancha:** ruta3_paco_2 (Nv35, por teléfono)
- **Sprite:** ✅ combate / ⏳ mapa
```

### Apéndice E — Plantilla de ficha de objeto especial Panchito

```markdown
### <Nombre del objeto>
- **ID:** 
- **Bolsillo:** 
- **Precio:** 
- **Uso:** campo / combate / equipable / clave
- **Efecto:** 
- **Implementación:** solo JSON (efecto existente) / script propio en src/items/effects/panchito/
- **Dónde se consigue:** 
- **Icono:** ⏳
- **Probado:** [ ] campo [ ] combate [ ] equipado [ ] venta
```

### Apéndice F — Errores típicos (y su solución)

| Síntoma | Causa habitual | Solución |
|---------|----------------|----------|
| El pixel art se ve borroso | Filtro de textura lineal | `default_texture_filter = Nearest` (Fase 3.2) |
| Líneas o huecos entre tiles al moverse | Posiciones con decimales | `snap_2d_transforms_to_pixel`, cámara en posiciones enteras |
| El jugador atraviesa paredes | El tile no tiene forma en la physics layer, o el RayCast tiene otra máscara | Revisa la física del TileSet y la `collision_mask` del RayCast |
| El jugador se queda "a medio paso" | Se movió durante un `await` o se cambió de mapa a mitad del tween | Bloquea el input durante las transiciones y espera al `tween.finished` |
| Error "Invalid get index" con datos | ID mal escrito en un JSON | Haz que `DataDB` diga **qué ID** falta y pasa el validador |
| El daño no coincide con Showdown | Redondeo de los modificadores | Imita el redondeo en base 4096 (Fase 7.4) |
| Conflicto de Git en un `.tscn` de mapa | Dos personas pintaron el mismo mapa | Quédate con una versión y repinta los cambios de la otra; reserva los mapas |
| Una partida antigua no carga | Cambió la estructura de `GameState` | Sube `save_version` y escribe la migración |
| Las cinemáticas se rompen al abrir el menú | Input no bloqueado | `Cutscene.lock_player()` al principio de cada evento |

---

## Resumen del orden

```
F1  Entorno + repo
F2  Diseño (GDD)
F3  Arquitectura base (autoloads, resolución, input, debug)
F4  Pipeline de datos (Showdown + PokeAPI → JSON en español) ── v0.0
F5  Movimiento, mapas, diálogo, encuentros
F6  Modelo de Pokémon, equipo y PC
F7  Motor de combate (núcleo)
F8  MVP jugable ───────────────────────────────────────────────── v0.1
F9  Combate avanzado (efectos, dobles, Mega, Z, Dinamax, Tera, IA)
F10 Entrenadores Panchito
F11 Objetos (+ especiales Panchito) ───────────────────────────── v0.2
F12 Región, mapas y navegación
F13 Historia y cinemáticas
F14 Mundo vivo (día/noche, clima, crianza, seguimiento...)
F15 UI
F16 Audio
F17 Tramo 1 ───────────────────────────────────────────────────── v0.3 (demo)
F17 Tramos 2–4 ────────────────────────────────────────────────── v0.5
F17 Tramos 5–8 ────────────────────────────────────────────────── v0.8
F18 Liga + postgame
F20 QA y balanceo
F21 Exportación y publicación ─────────────────────────────────── v1.0
F19 Secundario, competitivo y online ──────────────────────────── v1.x
```

¡A por ello! 🍭🎶🚇
