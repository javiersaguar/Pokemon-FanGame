# Pokémon Panchito

Fangame **sin ánimo de lucro** al estilo de *Pokémon Añil*, programado desde cero en **Godot 4 con GDScript**.

> Pokémon Panchito es un fangame sin ánimo de lucro. Pokémon y todos sus personajes son propiedad de Nintendo, Game Freak y The Pokémon Company. No está afiliado a ellos.

- Plan de desarrollo: [`GUIA_DESARROLLO.md`](GUIA_DESARROLLO.md)
- Interfaces entre módulos: [`docs/contratos.md`](docs/contratos.md)
- Estado y coordinación: [`docs/ESTADO.md`](docs/ESTADO.md)
- Créditos: [`CREDITOS.md`](CREDITOS.md)

## Requisitos

| Software | Versión |
|----------|---------|
| **Godot** | **4.7.2-stable**, edición estándar (no la .NET). **Todo el grupo con esta versión exacta.** |
| Git | Cualquiera reciente (sin Git LFS: el audio y los gráficos van como binarios normales) |

## Abrir y ejecutar

1. `git clone https://github.com/javiersaguar/Pokemon-Panchito.git`.
2. Godot 4.7.2 → **Importar** → elige `project.godot`.
3. **F5** ejecuta el juego. **F9** abre el menú de depuración (solo en builds de debug).

Desde la línea de comandos (con `godot` en el PATH):

```bash
godot --path .                                   # juego normal
godot --path . -- --map=test/test_outdoor        # partida nueva en un mapa concreto
godot --path . -- --load=1                       # carga la ranura 1
```

## Tests

Se usan con [GUT](https://github.com/bitwes/Gut) 9.7.1 (`addons/gut`). Los tests van en `tests/` (`test_*.gd`).

```bash
godot --headless --path . --import                   # la primera vez y tras añadir recursos
godot --headless --path . -s addons/gut/gut_cmdln.gd # todos los tests (config: .gutconfig.json)
```

En el editor: panel **GUT** (abajo) → *Run All*.

**Antes de mergear a `main`:** el proyecto abre sin errores (`--import` y F5 limpios) y los tests pasan.

## Controles

| Acción | Teclado | Mando |
|--------|---------|-------|
| Moverse | Flechas / WASD | Cruceta / stick |
| Aceptar | Z / Enter / Espacio | A |
| Cancelar | X / Escape / Retroceso | B |
| Menú | C / Enter | Start |
| Correr | Shift (mantener) | B (mantener) |
| Acelerar | Tab | — |
| Debug | F9 | — |

## Trabajo en equipo

> **Directrices obligatorias de Javier:** [`docs/DIRECTRICES.md`](docs/DIRECTRICES.md). Mandan sobre el resto de documentos.

- **Autoría:** todos los commits los firma **Javier Saguar**, sin coautores. En cada copia nueva del repo, una sola vez:

  ```bash
  git config user.name "Javier Saguar"
  git config user.email "javisaguarantona@gmail.com"
  git config core.hooksPath .githooks
  ```

  El hook `.githooks/commit-msg` rechaza los commits con otro autor o con coautores, y el workflow `Autoría` lo comprueba en GitHub.
- Cada persona o agente trabaja en **su propia copia** (`git worktree` o clon aparte) y en ramas `feat/<agente>-<tarea>` (por ejemplo, `feat/agente2-datadb`).

  ```bash
  git worktree add -b feat/agente2-datadb ../pokemon-panchito-agente2 main
  ```

- Commits pequeños, en español y descriptivos. Rebase sobre `main` a menudo.
- **Quien mergea a `main` lo sube a GitHub en el momento** (`git push origin main`). Antes, `git fetch` y, si GitHub tiene commits nuevos, se integran en `main` con un merge (no con rebase: `main` tiene merges de todos).
- **Nadie edita lo que no es suyo**: la propiedad de cada carpeta está en `docs/ESTADO.md`. Los cambios en lo de otro se piden en "Peticiones".
- Antes de pintar un mapa, resérvalo en `docs/mapas/reservas.md`: **un mapa = una persona a la vez**.

## Estructura

```
addons/      Plugins del editor (GUT)
assets/      Gráficos, audio y fuentes
data/        Datos del juego en JSON (data/generated/ no se edita a mano)
docs/        Contratos, estado, flags, GDD, guion...
maps/        Una escena .tscn por mapa (maps/test/ = sala de pruebas)
src/         Código (autoload/, main/, overworld/, battle/, pokemon/, ui/, items/, events/, util/)
tests/       Tests automáticos (GUT)
tools/       Scripts de importación y validación de datos
```

### Tileset y personajes del mapa

**No hay arte generado por código.** El tileset de exteriores y los personajes del mapa se copian de los packs de terceros que Javier tiene fuera del repo (`docs/arte/recursos_terceros.md`; créditos en `CREDITOS.md`). Para regenerarlos:

```bash
# Personajes, Poké Ball del suelo y efectos (pack 05)
godot --headless --path . -s res://assets/sprites/characters/import_characters.gd
# Tileset de exteriores (packs 01, 02, 03 y 04): PNG, importar y TileSet
godot --headless --path . -s res://assets/tilesets/exterior/build_exterior.gd -- --paso=png
godot --headless --path . --import
godot --headless --path . -s res://assets/tilesets/exterior/build_exterior.gd -- --paso=tileset
```

Si los packs están en otra carpeta: `-- --recursos=<ruta>` (en `--paso=png` y en el de personajes).

Mapas generados por script (pisan los cambios hechos a mano, por eso piden `-- --force`): la sala de pruebas (`maps/test/build_test_maps.gd`) y los mapas de muestra de la prueba de nivel gráfico (`maps/_tools/build_muestras.gd`). Al tocar objetos del suelo: `godot --headless --path . -s res://maps/_tools/build_item_placements.gd`.

## Arte (Fase A)

*(Sección del Agente 3.)* Normas en [`docs/arte/BIBLIA.md`](docs/arte/BIBLIA.md); estado de cada asset en [`docs/arte/seguimiento.md`](docs/arte/seguimiento.md).

```bash
godot --headless --path . -s res://tools/arte/validar.gd   # tamaños canónicos y paleta (falla con código 1)
godot --headless --path . -s res://tools/arte/paleta.gd    # regenera assets/arte/paleta.gpl y .png desde paleta.json
```

Pásalo antes de mergear cualquier arte. Las reglas de tamaño por carpeta están en `tools/arte/reglas.json`.

## Datos (Fase 4)

Los datos oficiales (especies, movimientos, objetos, tipos, learnsets...) **no se escriben a mano**: los genera `tools/import_data` a partir de Pokémon Showdown y PokeAPI, con versiones fijadas y nombres y descripciones en español. Requiere **Node.js 18+** (sin `npm install`):

```bash
node tools/import_data/index.mjs            # regenera data/generated/*.json
node tools/import_data/index.mjs --offline  # sin descargar (usa tools/cache/)
```

- `data/generated/` **no se edita a mano**. Los cambios propios van en `data/species_overrides.json` (por ejemplo, las evoluciones por intercambio sustituidas) y en los demás JSON de `data/`.
- Detalles (fuentes, versiones, cómo actualizarlas): [`tools/README.md`](tools/README.md). Formato de los datos y API de `DataDB`: [`docs/contratos.md`](docs/contratos.md) §8.
