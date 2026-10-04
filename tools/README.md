# Herramientas de datos

## `import_data`: importación de datos oficiales (Fase 4.2)

Genera `data/generated/*.json` a partir de dos fuentes con versión **fijada** (ver `import_data/config.mjs`):

| Fuente | Versión | Qué aporta |
|--------|---------|------------|
| Pokémon Showdown (paquete npm `pokemon-showdown`, carpeta `dist/data`) | `0.11.11` (verificada con sha512) | Especies, formas, movimientos, habilidades, objetos de combate, tabla de tipos, learnsets y naturalezas |
| PokeAPI (`data/v2/csv`) | commit `a003ae375b69a99907ec273fe100d97e7f36321c` | Nombres y descripciones en español (idioma 7), Pokédex, grupos de experiencia, ratio de captura, EVs, precios y bolsillos |

### Uso

Requisito: **Node.js 18 o superior**. No hace falta `npm install`: el script no tiene dependencias.

```bash
node tools/import_data/index.mjs            # descarga (la primera vez) y genera
node tools/import_data/index.mjs --offline  # usa solo lo que hay en tools/cache/
node tools/import_data/index.mjs --verbose  # lista también todos los avisos
```

Las descargas se guardan en `tools/cache/` (no se versiona). Al terminar muestra cuántos registros hay
y cuáles no tienen nombre o descripción en español; el detalle completo queda en `tools/cache/import_report.json`.

> `data/generated/` **no se edita nunca a mano**: se regenera con este script.
> Los cambios propios van en `data/species_overrides.json` y en los demás JSON de `data/`.

### Archivos generados

| Archivo | Contenido |
|---------|-----------|
| `species.json` | Especies y formas (`raichualola`, `charizardmegax`...). Las formas llevan `base_species`, `forme` y `form_name` |
| `moves.json` | Movimientos con sus efectos "por datos" y `needs_script` si necesitan código propio (Fase 9.2) |
| `abilities.json` | Habilidades (`needs_script` casi siempre a `true`) |
| `items.json` | Objetos (PokeAPI + Showdown + `import_data/extra/item_effects.json`) |
| `types.json` | Tabla de tipos 18×18 e inmunidades a estados por tipo |
| `learnsets.json` | Movimientos por nivel, MT, tutor y huevo (generación más reciente con datos) |
| `exp_tables.json` | Experiencia total por nivel de los 6 grupos de crecimiento |
| `natures.json` | Las 25 naturalezas |
| `meta.json` | Versiones de las fuentes y recuento de registros |

El formato de cada campo está en `docs/contratos.md` (sección DataDB).

### Actualizar las fuentes

1. Cambia la versión y el hash `integrity` de Showdown (`npm view pokemon-showdown@<versión> dist.integrity`)
   o el commit de PokeAPI en `import_data/config.mjs`. Usa versiones con al menos una semana de antigüedad.
2. Regenera y revisa el diff de `data/generated/` antes de hacer commit.
3. Ejecuta el validador y los tests.

### Efectos de los objetos estándar

`import_data/extra/item_effects.json` contiene, a mano, el efecto de uso de los objetos estándar
(Poción = curar 20 PS, Super Ball = ×1,5...), con los valores oficiales de la 7.ª generación en adelante.
Es un archivo de datos: los números del juego no van en los `.gd`.

## `sprites`: gráficos y gritos de los Pokémon (DIRECTRICES §7.1 y §7.2)

Copia de los packs que ha descargado Javier (fuera del repo, en `/mnt/c/Users/Javier/Pokemon-Panchito-recursos/`),
byte a byte, **sin reescalar ni convertir**, porque ya vienen a la escala de
512×384 (frente 192×192, espalda 288×288, iconos 128×64 = 2 cuadros de 64, Pokémon que te siguen 256×256 = 4×4
cuadros de 64). Set oficial: `06_generation9_pack`; `07_generation8_pack` solo si falta algo. No descarga nada
de internet ni modifica la carpeta de recursos.

```bash
node tools/sprites/import_pokemon_assets.mjs --all              # lo habitual: todas las especies del pack
node tools/sprites/import_pokemon_assets.mjs                    # solo las especies del juego
node tools/sprites/import_pokemon_assets.mjs --species pikachu
godot --headless --path . --import                              # después, para crear los .import
```

- **Decisión de Javier (pregunta 11): en el repo están los de TODAS las especies del pack** (≈ 1.370 especies y formas;
  unos 36 MB de PNG y 18 MB de gritos). Lo que no deba salir en RandomLocke se excluye desde sus ajustes, nunca
  quitando sprites. Los gritos van como archivos normales (sin Git LFS).

- **Especies del juego:** `data/regional_dex.json` + `data/species_in_use.json` (lista inicial: el MVP) + las que
  salen en `data/encounters/`, `data/trainers/`, `starters.json`, `gifts.json`, `statics.json` y `trades.json`, con
  sus familias evolutivas. El validador usa la misma definición.
- **Destino**, con nuestros ids: `assets/sprites/pokemon/{front,front_shiny,back,back_shiny,icons,icons_shiny,followers,followers_shiny}/<id>.png`
  (más `<id>_female.png` donde el pack tiene diferencias por sexo) y `assets/audio/cries/<id>.ogg`.
- Las formas (`raichualola`...) se buscan en `pokemon_forms.txt` del pack; las que no tienen equivalente se listan.
- Opciones: `--source <carpeta>` (o `PANCHITO_RECURSOS`) y `--dry-run`. Nunca borra nada del repo.
- Resumen (qué archivo viene de qué pack, qué falta, formas sin equivalente y formas emparejadas por aproximación): `data/generated/pokemon_assets.json`. Sale con código 1 si falta algo (con `--all` siempre faltan los Pokémon que te siguen de las megas y otras formas de combate, que el pack no trae).
- El validador da **error** si a una especie usada le falta alguna versión (normal o shiny) o el grito.

## `wikidex`: verificación de estadísticas (DIRECTRICES §3)

Compara las estadísticas base y los EVs de `data/generated/species.json` (con los overrides aplicados) con la
plantilla `{{Características}}` vigente de cada página de WikiDex. Usa la API de MediaWiki por lotes de 20, con
pausas (1,5 s) y caché en `tools/cache/wikidex/`.

```bash
node tools/wikidex/verify_stats.mjs                 # Pokédex regional + especies del juego + muestra de 150
node tools/wikidex/verify_stats.mjs --sample 400    # muestra más amplia
node tools/wikidex/verify_stats.mjs --species pikachu,garchomp
```

- Escribe `data/generated/wikidex_check.json`, que lee el validador (avisa de diferencias y de especies del juego
  sin comprobar). Sale con código 1 si hay diferencias.
- Cada diferencia se revisa a mano. Si WikiDex tiene razón, se corrige en `data/species_overrides.json` con
  `"fuente": "WikiDex"` (los retoques de Añil, con `"fuente": "Añil"`).

## `validate`: validador de datos (Fase 4.6)

```bash
godot --headless --path . -s res://tools/validate/validate.gd   # sale con código 1 si hay errores
```
