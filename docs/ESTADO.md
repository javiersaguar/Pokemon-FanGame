# Estado del proyecto

**Hito actual:** `v0.1` (MVP, Fase 8 de la guía).

**Último aviso (2026-10-04, Javier):** 🚨 **Los gráficos actuales no valen: el mínimo es el nivel de Pokémon Añil.** Leed `docs/DIRECTRICES.md` §0, §7 y §8 **antes de seguir**:
- Capturas de referencia en `docs/arte/referencias/` (combate, pueblo, datos del Pokémon y ruta).
- La resolución pasa a **512×384** con el mundo a ×2 (Fase 3.2). **Se acabó el arte generado por código.**
- **Prueba de nivel gráfico** (§7, pasos 1–6): mapas de muestra (A1), combate y pantalla de datos de muestra (A3), sprites reales de Pokémon (A2) y comparación lado a lado para que Javier la apruebe. Hasta la aprobación, el MVP no añade más pantallas ni mapas visibles.
- **Shiny**: 1/4096 de base (≈ 0,024 %) y sprites con los colores shiny oficiales, nunca generados por código (§8 y Fase 6.7).

**Aviso anterior (2026-10-04, Javier):** 📌 **Nuevas directrices obligatorias en [`docs/DIRECTRICES.md`](DIRECTRICES.md).** Leedlas antes de vuestra siguiente tarea. Resumen:
1. **Arte de nivel profesional**, pieza a pieza → nueva **Fase A** de la guía.
2. **Varias partidas** (8+ ranuras) y **modo RandomLocke** con motor de aleatorización propio → **Fase 8.7** y nueva **Fase R**. ⚠️ La **regla R.2** (todo por ID de datos, nada escrito a mano en los eventos) afecta **ya** al MVP.
3. **Estadísticas**: verificar con **WikiDex** y aplicar los retoques de **Pokémon Añil** como overrides → **Fase 4.1**.
4. **Menú inicial muy currado** con **"Realizado por Javier Saguar"** → **Fase 15.2**.
5. **Autoría**: solo Javier Saguar y sin coautores. **Ejecutad una vez en vuestra copia:** `git config core.hooksPath .githooks` (ver `DIRECTRICES.md` §5).

Hay carpetas nuevas en el reparto (`DIRECTRICES.md` §6). Cada agente: confirmad en vuestra sección que lo habéis leído y añadid las tareas nuevas a vuestro plan.

**Aviso anterior (2026-10-04, Agente 1):** ✅ **Esqueleto listo, podéis empezar.** Antes de nada, leed `docs/contratos.md` y `README.md` (worktree, tests y `--import`).

## Cómo se usa

- **Al empezar y al terminar cada tarea**, actualiza tu sección: en qué estás, qué has terminado y qué te bloquea.
- **Lee las secciones de los demás** antes de empezar.
- **Peticiones**: si necesitas un cambio en algo que no es tuyo, no lo edites; añade una fila en "Peticiones" indicando para qué agente es. El destinatario la marca como `hecha` o `rechazada` (con el motivo).
- **Cambios de contrato** (`docs/contratos.md`): avísalos en la sección del final.
- **Dudas de diseño**: van a "Preguntas para Javier". No se inventan.

### Propiedad de carpetas

| Agente | Rol | Es dueño de |
|--------|-----|-------------|
| 1 | Mundo y arquitectura | `project.godot`, `src/autoload/` (salvo `data_db.gd`, `dialogue.gd` y `audio_manager.gd`), `src/overworld/` (salvo `src/overworld/trainers/`), `src/events/`, `src/main/`, `src/util/`, `maps/`, `assets/tilesets/`, `assets/sprites/characters/`, `data/world.json`, `docs/flags.md`, `docs/mapas/` |
| 2 | Datos y motor de combate | `tools/`, `data/generated/`, `data/species_overrides.json`, `data/regional_dex.json`, `src/autoload/data_db.gd`, `src/pokemon/`, `src/battle/engine/`, `src/battle/effects/`, `src/battle/ai/`, `tests/` |
| 3 | Presentación, UI y contenido Panchito | `src/ui/`, `src/battle/scene/`, `src/items/`, `src/overworld/trainers/`, `src/autoload/dialogue.gd`, `src/autoload/audio_manager.gd`, `data/trainer_classes.json`, `data/trainers/`, `data/items_panchito.json`, `data/shops.json`, `data/encounters/`, `assets/` (salvo `tilesets/` y `sprites/characters/`), `docs/entrenadores.md`, `docs/objetos_especiales.md` |

- `src/main/`, `src/util/`, `data/world.json`, `docs/flags.md` y `docs/mapas/` no estaban en el reparto: los ha tomado el Agente 1 (arquitectura). Si alguien no está de acuerdo, que lo diga en "Peticiones".
- **Compartidos**: `README.md` y `CREDITOS.md` (cada agente edita solo su sección), `docs/ESTADO.md` (cada uno su sección y sus filas), `.gitignore`, `.gitattributes`, `.gutconfig.json` y `addons/` (los cambios se piden al Agente 1).
- `res://default_bus_layout.tres` (buses de audio, ruta por defecto de Godot): Agente 3.

---

## Agente 1 — Mundo y arquitectura

**En qué estoy:** Fase 5 (jugador, NPC base, warps, objetos del suelo, interacción y encuentros) en `feat/agente1-mundo`.

**Terminado:**
- Paso 0, el esqueleto (rama `feat/agente1-esqueleto`, mergeada en `main`):
  - Fase 1: proyecto de Godot 4.7.2 en la raíz, estructura de carpetas, `.gitignore`, `.gitattributes`, `README.md`, `CREDITOS.md` y GUT 9.7.1 en `addons/gut` (`.gutconfig.json` → `tests/`).
  - Fase 3: 320×180 con escalado entero y Nearest, snap a píxel, renderizador Compatibility, Input Map completo, aviso de declaraciones sin tipo y capas de física con nombre.
  - Escena `src/main/main.tscn` (World/Battle/UI/Transition) y autoloads en el orden de la guía: `DataDB`*, `EventBus`, `GameState`, `SaveManager`, `SceneManager`, `AudioManager`*, `Dialogue`*, `Clock` y `Debug`. (*) = stubs provisionales para sus dueños.
  - `GameState` (flags, vars, dinero, medallas, bloqueo de input y módulos) y `SaveManager` (JSON con `save_version`, `.tmp` → `.bak` → renombrar, y migraciones).
  - `SceneManager`: cambio de mapa con fundido, `start_battle()` con sustituto provisional, derrota → Centro Pokémon, pila de menús y flujo título/nueva partida/continuar.
  - `MapRoot` + `MapData`, `Grid`, tileset provisional con física y custom data, y la sala de pruebas (`test/test_room` y `test/test_outdoor`).
  - Menú Debug (F9): teletransporte, flags y vars, trucos (atravesar paredes, sin encuentros, hora), guardar y cargar, combate de prueba, consola y `Debug.register_command()` para los demás.
  - `docs/contratos.md` (secciones 0–7 rellenas y huecos para el Agente 2 y el Agente 3), `docs/flags.md` y `docs/mapas/reservas.md`.

**Bloqueos:** ninguno. Para la Fase 8 necesito las peticiones 1, 2 y 4 y las preguntas 1 y 2.

---

## Agente 2 — Datos y motor de combate

**En qué estoy:** (sin empezar)

**Terminado:**
- (nada todavía)

**Bloqueos:**

---

## Agente 3 — Presentación, UI y contenido Panchito

**En qué estoy:** (sin empezar)

**Terminado:**
- (nada todavía)

**Bloqueos:**

---

## Peticiones

| # | De → Para | Petición | Estado |
|---|-----------|----------|--------|
| 1 | A1 → A2 | `BattleSetup` con `can_lose: bool` y una forma de crear un combate **salvaje** (especie + nivel, o un `Pokemon`) y uno de **entrenador** (`trainer_id`). Propuesta: `BattleSetup.wild(species_id, level)` y `BattleSetup.trainer(trainer_id)`. Lo usan los encuentros (Fase 5) y los eventos (Fase 8). | pendiente |
| 2 | A1 → A2 | Clases `Party`, `PCStorage` y `Pokedex` con los requisitos de módulo de GameState (`contratos.md` §2). En `Party`, además: `heal_all()`, `is_all_fainted()` y el nivel del primer Pokémon no debilitado (para el Repelente). | pendiente |
| 3 | A1 → A2 | `tests/` es tuyo: ¿me cedes `tests/mundo/` para los tests de GameState, SaveManager y SceneManager? (Y quizá `tests/ui/` al Agente 3.) | pendiente |
| 4 | A1 → A3 | BattleScene en `res://src/battle/scene/battle_scene.tscn` con `run(setup) -> StringName`; título en `res://src/ui/title/title_screen.tscn`; menú de pausa en `res://src/ui/pause_menu/pause_menu.tscn` (`contratos.md` §4). Si preferís otras rutas, decídmelo. | pendiente |
| 5 | A1 → A3 | Formato de `data/encounters/<id>.json` (lo leerá el disparador de encuentros de la Fase 5). Propuesta: el de la guía (5.7), con `land.day`, `land.night`, `water`... Y una tabla de prueba `data/encounters/test_outdoor.json` para `test/test_outdoor`. | pendiente |
| 6 | A1 → A3 | Si queréis un Theme o una fuente por defecto global, pedidme `gui/theme/custom` en `project.godot`. Los stubs de Dialogue y Debug usan tamaño de fuente 8. | informativo |

---

## Preguntas para Javier

| # | Quién pregunta | Pregunta | Respuesta |
|---|----------------|----------|-----------|
| 1 | A1 | **Para el MVP (Fase 8):** ¿cuáles son los 3 iniciales? ¿Nombres del pueblo inicial, de la ciudad 2, del profesor y del rival por defecto? (La Fase 2 / GDD está sin hacer.) Mientras tanto uso nombres provisionales marcados "POR DEFINIR". | |
| 2 | A1 | **Reloj** (Fase 14.1): ¿hora real del sistema o reloj interno acelerado? Ahora mismo, real (`data/world.json` → `clock.mode`). | |
| 3 | A1 | **Dinero inicial**: 3000 provisional (`data/world.json` → `new_game.money`). ¿Vale? | |
| 4 | A1 | **Git LFS** no está instalado en el WSL: hace falta `sudo apt install git-lfs && git lfs install` antes de subir audio (`.ogg`, `.wav`...). | |

---

## Avisos de cambios de contrato

| Fecha | Agente | Cambio |
|-------|--------|--------|
