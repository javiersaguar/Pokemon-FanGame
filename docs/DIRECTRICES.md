# Directrices de Javier

> **Este documento manda.** Si algo de aquí choca con `GUIA_DESARROLLO.md`, `docs/contratos.md` o cualquier otro documento, gana lo que dice aquí. Solo lo modifica Javier.
>
> Última actualización: 2026-10-04

---

## 1. Diseño gráfico de nivel profesional

- El apartado gráfico tiene que ser **de nivel profesional**, aunque lleve mucho esfuerzo.
- Las cosas se hacen **una a una**: un asset se termina, se integra y se revisa antes de pasar al siguiente.
- Estándar completo: **Fase A** de la guía (biblia de arte, paleta, tamaños canónicos, proceso, pulido de movimiento, checklist y seguimiento).
- **Un asset solo es "final" cuando lo aprueba Javier** (columna en `docs/arte/seguimiento.md`).
- Desde la demo `v0.3` no puede quedar **ningún placeholder** a la vista.

**Acciones inmediatas**
| Agente | Acción |
|--------|--------|
| 3 | Redactar `docs/arte/BIBLIA.md` (A.2) y crear `docs/arte/seguimiento.md` (A.7) y `docs/arte/licencias.md` **antes** de producir más arte. Proponer el set de sprites de Pokémon (A.3) en "Preguntas para Javier". |
| 1 | Tilesets y personajes del mapa siguiendo la biblia en cuanto exista. El tileset provisional se registra como placeholder en el seguimiento. |
| 3 | Validador de arte en `tools/arte/` y galería de assets (A.8). |

## 2. Varias partidas y modo RandomLocke

- En el **modo normal** se pueden tener **varias partidas guardadas** a la vez (mínimo 8 ranuras, con resumen y miniatura). Ver **Fase 8.7**.
- Además existe el **modo RandomLocke**: Pokémon salvajes, iniciales, entrenadores, movimientos aprendidos y más **aleatorizados**, con reglas Nuzlocke. **Antes de empezar cada partida se genera aleatoriamente su "ROM"** con un **motor de aleatorización propio**. Diseño completo en la **Fase R** de la guía.
- ⚠️ **Regla que se aplica YA (Fase R.2):** ningún evento escribe a mano especies, objetos, movimientos ni equipos. Todo se pide por ID a `DataDB` (`starters.json`, `gifts.json`, `statics.json`, `trades.json`...), y los textos que nombran Pokémon usan marcadores. **Afecta al MVP**: el evento de elegir inicial y los del rival se tienen que hacer así desde el principio.

**Reparto:** tabla de la **Fase R.10**. Resumen:
| Agente | Parte |
|--------|-------|
| 1 | Ranuras múltiples (8+, miniatura, modo), `GameState.mode`, parche guardado con la ranura, `zone_id` y reglas Locke del mundo, flujo de nueva partida, regla R.2 en todos los eventos |
| 2 | `src/randomizer/` (motor puro y determinista), `RomPatch`, `DataDB.apply_patch()`, validación de la ROM, códigos de semilla, tests de determinismo y robustez, evento `pokemon_died` |
| 3 | Pantallas de modo, ajustes, "Generando la ROM...", resumen, indicadores de zona, Cementerio y game over; marcadores de texto en `Dialogue`; `starters.json`, `gifts.json`, `statics.json` y `trades.json` |

**Calendario:** motor sin interfaz para `v0.2`; interfaz y reglas Locke para la demo `v0.3`.

## 3. Estadísticas de los Pokémon

- Las estadísticas se pueden tomar de **WikiDex** y se pueden **copiar las de Pokémon Añil**.
- En la práctica (**Fase 4.1**): la importación de Showdown + PokeAPI es la base; **WikiDex** se usa para verificar las estadísticas y completar nombres en español; los **retoques de Añil** van a `data/species_overrides.json` con `"fuente": "Añil"` y se acreditan en `CREDITOS.md`.
- Responsable: **Agente 2**.

## 4. Menú inicial muy currado, "Realizado por Javier Saguar"

- Secuencia completa en la **Fase 15.2**: splash **"Javier Saguar presenta"**, aviso de fangame, intro animada, título con parallax y logo animado, y menú principal (Continuar / Nueva partida / Cargar / Opciones / Créditos / Salir).
- **"Realizado por Javier Saguar"** aparece **siempre visible** en el pie de la pantalla de título, junto a la versión. En los créditos, la primera línea es **"Juego realizado por Javier Saguar"**.
- Lo aprueba Javier antes de la demo.
- Responsable: **Agente 3** (pantallas) con el **Agente 1** (flujo en `SceneManager`).

## 5. Autoría: solo Javier Saguar

- **Todos los commits los firma Javier Saguar** (`user.name = Javier Saguar`, `user.email = javisaguarantona@gmail.com`).
- **Sin coautores**: ninguna línea `Co-Authored-By`, ni "Generated with", ni ninguna otra atribución en los mensajes de commit, en las PR, en el código, en la documentación ni en los créditos.
- **Obligatorio en cada copia del repo** (clon o worktree), una sola vez:

  ```bash
  git config user.name "Javier Saguar"
  git config user.email "javisaguarantona@gmail.com"
  git config core.hooksPath .githooks
  ```

  El hook `.githooks/commit-msg` **rechaza** el commit si el autor no es Javier Saguar o si el mensaje lleva coautores. Además, el workflow `.github/workflows/autoria.yml` lo revisa en GitHub en cada push.
- Si un commit se cuela con coautores, **no se reescribe la historia de `main` por tu cuenta**: avisa en "Preguntas para Javier".

## 6. Nueva propiedad de carpetas

Se añade al reparto de `docs/ESTADO.md`:

| Carpeta o archivo | Agente |
|-------------------|--------|
| `src/randomizer/`, `tests/randomizer/` | 2 |
| `docs/arte/`, `assets/arte/`, `assets/_fuentes/`, `tools/arte/` | 3 |
| `data/starters.json`, `data/gifts.json`, `data/statics.json`, `data/trades.json` | 3 |
| `docs/DIRECTRICES.md`, `.githooks/`, `.github/` | Javier |
