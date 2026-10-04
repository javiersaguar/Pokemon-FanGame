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
| Git + Git LFS | Cualquiera reciente. `git lfs install` una vez por equipo |

## Abrir y ejecutar

1. `git clone https://github.com/javiersaguar/Pokemon-Panchito.git` y, dentro, `git lfs pull`.
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

### Tileset provisional

`assets/tilesets/placeholder/` se genera por script hasta que haya arte real:

```bash
godot --headless --path . -s res://assets/tilesets/placeholder/generate_png.gd
godot --headless --path . --import
godot --headless --path . -s res://assets/tilesets/placeholder/build_tileset.gd
```

## Datos (Fase 4)

*(Sección del Agente 2: cómo regenerar `data/generated/`.)*
