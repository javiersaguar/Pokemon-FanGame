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
