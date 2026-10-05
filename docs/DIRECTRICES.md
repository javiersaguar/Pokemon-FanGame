# Directrices de Javier

> **Este documento manda.** Si algo de aquí choca con `GUIA_DESARROLLO.md`, `docs/contratos.md` o cualquier otro documento, gana lo que dice aquí. Solo lo modifica Javier.
>
> Última actualización: 2026-10-05 (tarde): **4 agentes**. El motor del RandomLocke es del **Agente 2**, y el nuevo **Agente 4** se dedica al **arte del mundo y de los entrenadores** (tilesets, pintado de mapas, sombras, entrenadores Panchito y fondos de combate). La propiedad de carpetas está en `docs/ESTADO.md` y el plan, en «Próxima sesión».

---

## 0. ⚠️ PRIORIDAD ACTUAL: alcanzar el nivel gráfico de Pokémon Añil (sección 7)

**Actualización del 2026-10-05: aprobación parcial de la prueba de nivel gráfico** (detalle en `docs/ESTADO.md` → "Respuestas de Javier del 2026-10-05"). Combate y ruta, aprobados con cambios; ficha del Pokémon, con cambios; **pueblo rechazado**. Se abre el trabajo visible de interfaz, integración y motor, pero **los mapas reales del MVP esperan a que Javier apruebe el pueblo rehecho**. El arte del mundo y de los entrenadores tiene ahora un agente dedicado, el **Agente 4**. El listón sigue siendo Pokémon Añil.

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
| 2 | **Motor del RandomLocke** (heredado del Agente 4, ya terminado): `src/randomizer/`, `RomPatch`, ajustes y presets, validación, códigos de semilla, spoilers, tests y `LockeRules`. Además, `DataDB.apply_patch()` / `randomizer_input()` y las reglas Locke dentro del combate (`pokemon_died`, tope de experiencia, modo fijo, objetos) |
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
| `src/randomizer/`, `tests/randomizer/`, `data/randomizer/`, `data/randomizer.json`, `docs/randomlocke.md`, `docs/contratos.md` §10 | **2** (de nuevo, desde el 2026-10-05; lo hizo el Agente 4) |
| `docs/arte/`, `assets/arte/`, `assets/_fuentes/`, `tools/arte/` | 3 |
| `data/starters.json`, `data/gifts.json`, `data/statics.json`, `data/trades.json` | 3 |
| `docs/DIRECTRICES.md`, `.githooks/`, `.github/`, `docs/arte/referencias/` | Javier |
| `C:\Users\Javier\Pokemon-Panchito-recursos\` = `/mnt/c/Users/Javier/Pokemon-Panchito-recursos/` desde WSL (packs descargados por Javier, **fuera del repo**, sin modificar) | Javier (los agentes solo leen y copian de aquí) |
| `docs/arte/recursos_terceros.md` (índice de esos packs: origen, créditos y notas técnicas) | Javier |

## 7. Nivel gráfico mínimo: Pokémon Añil

**El listón son las 4 capturas de `docs/arte/referencias/`** (combate, pueblo con Pokémon que te sigue, pantalla de datos y ruta). Todo lo que se vea en el juego tiene que estar **a ese nivel o por encima**. Se mantiene Godot: el aspecto de Añil sale de sus **recursos gráficos y su resolución**, no del motor, y Godot puede mostrar eso y más.

**Por qué ahora se ve cutre y qué cambia:**
| Problema | Cambio |
|----------|--------|
| Resolución 320×180, demasiado pequeña | **512×384** (la de Añil), con el mundo a ×2 (casillas de 32 px en pantalla) y la UI a 512×384 nativo. Detalles en la **Fase 3.2** de la guía |
| Tileset dibujado por código | **Prohibido el arte generado por código** para el juego. Tiles, personajes y sprites salen de packs de la comunidad con permiso o de arte hecho a mano (**Fase A.3**) |
| Sin sprites de Pokémon reales | **Generation 9 Pack**: generaciones 1 a 9, frente, espalda, iconos y Pokémon que te sigue, normales y **shiny oficiales** |

### 7.1 ✅ Recursos ya descargados (2026-10-04)

Javier ya ha descargado los packs. Están **fuera del repo** en:

- Windows: `C:\Users\Javier\Pokemon-Panchito-recursos\`
- WSL: `/mnt/c/Users/Javier/Pokemon-Panchito-recursos/`

**Índice completo** (qué hay en cada carpeta, de dónde sale, a quién acreditar y tamaños): `docs/arte/recursos_terceros.md`.

Reglas de uso:
- **No se modifica nada en esa carpeta.** Se copian al repo **solo los archivos que se usen** (por ejemplo, solo las especies del MVP, no los 1500 sprites), en su carpeta de `assets/` y con el crédito en `CREDITOS.md`.
- **Escala: los packs ya vienen preparados para 512×384** (tiles de 32 px, cuadros de 64 px, Pokémon de frente a 192 px, de espalda a 288 px). **Se usan tal cual, sin reescalar** (Fase 3.2).
- **Set de Pokémon oficial del proyecto: `06_generation9_pack`** (generaciones 1 a 9, con shiny en todas las vistas). `07_generation8_pack` solo como reserva si falta algo.
- **No hay que crear `assets/_terceros/`** dentro del repo. Si alguien la creó, se elimina.

**Prueba de nivel gráfico (hacer YA, en este orden):**
1. ~~**Agente 3**: lista de recursos a descargar.~~ **Hecho por Javier** (ver §7.1). El Agente 3 revisa `docs/arte/recursos_terceros.md` y, si echa en falta algo para igualar a Añil (interiores, cuevas, efectos...), lo pide en "Preguntas para Javier" con su enlace.
2. **Agente 2**: ~~script de descarga de sprites~~ → **importador** en `tools/` que copia del `06_generation9_pack` a `assets/sprites/pokemon/` (`front`, `front_shiny`, `back`, `back_shiny`, `icons`, `icons_shiny`) y a los Pokémon que te siguen **solo las especies que usa el juego** (Pokédex regional + MVP), con nombres en minúsculas según nuestros IDs, y gritos a `assets/audio/cries/`. Además, un validador que comprueba que cada especie usada tiene **todas sus versiones normal y shiny**.
3. **Agente 1**: pasar el proyecto a **512×384** (casillas de 32 px, cámara del mundo con `zoom = 1` porque los tiles ya vienen al doble, UI sin zoom) y montar con los recursos reales **dos mapas de muestra**: `maps/test/muestra_ruta.tscn` (al nivel de `anil_ruta.png`) y `maps/test/muestra_pueblo.tscn` (al nivel de `anil_pueblo.png`, con NPCs, flores y hierba animadas, sombras y el Pokémon que te sigue).
4. **Agente 3**: **pantalla de combate de muestra** (al nivel de `anil_combate.png`: fondo y bases, sprites a ×2, cajas de datos con barras de PS y experiencia, iconos de estado y género, y botones Luchar / Mochila / Pokémon / Huir con su animación) y **pantalla de datos del Pokémon de muestra** (al nivel de `anil_datos_pokemon.png`). Diseño **propio**, no una copia de la UI de Añil.
5. **Todos**: capturas del juego **a la misma escala** que las referencias, puestas **lado a lado** en `docs/arte/comparativas/`. Se avisa a Javier en "Preguntas para Javier".
6. **Javier aprueba** (o pide cambios). Hasta entonces, el MVP no añade más pantallas ni mapas visibles; el trabajo de motor, datos y lógica sigue con normalidad.

## 8. Shiny: probabilidad y diseño fiel

- **Probabilidad base: 1/4096 (≈ 0,024 %)**. Con Amuleto Iris, 3/4096; Masuda, 6/4096; ambos, 8/4096. Se configura en `data/world.json` → `shiny`; en RandomLocke se puede subir en los ajustes. Tabla completa en la **Fase 6.7** de la guía.
- **Diseño fiel:** cada especie tiene su sprite shiny **con los colores shiny oficiales** (frente, espalda, icono y Pokémon que te sigue), del mismo set que el normal. **Prohibido generar shinies cambiando el tono por código.**
- Presentación: destellos y sonido al aparecer, estrella ★ en todas las pantallas, y registro en la Pokédex.
- Reparto: **Agente 2** (probabilidad en `Pokemon`, test estadístico y validador de las 4 versiones shiny), **Agente 3** (destellos, sonido y estrellas en la UI), **Agente 1** (`data/world.json` → `shiny` y brillo del Pokémon que te sigue).
