# Comparación del combate con Pokémon Showdown

Juega **los mismos combates** (mismos equipos, mismas decisiones y **la misma suerte**) en el simulador de Pokémon Showdown y en nuestro `BattleEngine`, y compara el estado al empezar cada turno: PS, estado alterado, quién está en el campo, cambios de características, Velocidad efectiva y clima. Es la forma de comprobar que nuestro combate es fiel al oficial. Resultados y fallos encontrados: [`docs/combate/diferencias_showdown.md`](../../docs/combate/diferencias_showdown.md).

## Uso

```bash
node tools/showdown_diff/index.mjs --n=400 --seed=1
```

| Opción | Qué hace |
|--------|----------|
| `--n=200` | Número de combates |
| `--seed=1` | Semilla del lote (mismo valor = mismos combates) |
| `--team=3` | Pokémon por equipo |
| `--items` | Da objetos (solo los que tiene implementados nuestro motor) |
| `--all-abilities` / `--all-moves` | Usa también habilidades y movimientos **no implementados** (para medir la cobertura) |
| `--out=<carpeta>` | Dónde dejar los resultados (por defecto `tools/cache/showdown_diff/`, que no se sube) |
| `--max-diff=N` | Sale con código 1 si hay más de N combates distintos |

Deja en la carpeta de salida `informe.md` (cada combate distinto, con el turno, la diferencia y el registro de ese turno en los dos motores), `resultado.json`, los combates (`combates.json`) y los resultados de cada motor.

**Requisitos:** Node 18+, Godot 4.7.2 (`$GODOT` o `godot` en el PATH) y el paquete `pokemon-showdown` **0.11.11** (el mismo de `tools/import_data`) descomprimido en `~/.cache/panchito/showdown-0.11.11/package` (o en `$PANCHITO_SHOWDOWN`):

```bash
mkdir -p ~/.cache/panchito/showdown-0.11.11
tar -xzf tools/cache/pokemon-showdown-0.11.11.tgz -C ~/.cache/panchito/showdown-0.11.11
```

(El `.tgz` lo descarga y verifica `node tools/import_data/index.mjs`.) No hace falta `npm install`: la única dependencia que pide el simulador (`ts-chacha20`, su generador aleatorio) se sustituye por `lib/ts-chacha20-stub.cjs`, porque el arnés le pasa su propio generador.

## Cómo funciona

1. **`run_ours.gd --capabilities`** lista los movimientos, habilidades y objetos que tiene implementados nuestro motor.
2. **`gen_specs.mjs`** genera combates aleatorios pero reproducibles con esas piezas: especies, nivel 50–100, naturaleza, IVs, EVs y 4 movimientos. Todas las Velocidades son distintas.
3. **La suerte es un oráculo común** (`lib/oracle.mjs`, copiado en `ours_runner.gd`). Cada tirada tiene una **etiqueta** (`accuracy`, `crit`, `damage_roll`, `secondary`, `par`, `slp_turns`, `confusion_hit`…) y su resultado depende solo de la semilla del combate, la etiqueta y el turno. Por eso los dos motores reciben la misma suerte aunque pidan las tiradas en distinto orden. La mitad de los combates fijan la suerte de algunas etiquetas (siempre acierta, nunca hay crítico…) para recorrer ramas concretas.
   - En **nuestro motor**, todas las tiradas pasan por `BattleEngine.rand_int()` / `rand_chance()`. Sin oráculo consumen el generador igual que antes; con `BattleSetup.rng_oracle`, contestan con el oráculo.
   - En **Showdown**, el arnés le pasa su propio generador (`options.prng`), que deduce la etiqueta de la tirada por la función que la pide (`getDamage` → `crit`, `randomizer` → `damage_roll`…) o, para los efectos de `data/`, por el archivo y la línea del manejador.
4. **Las decisiones** son las mismas en los dos: cada turno, un movimiento elegido con el hash de (semilla, bando, turno), saltando los que no se pueden usar. Tras un debilitado entra el primero que queda, en el orden del equipo. Los PP van al máximo (como Showdown, con 3 Más PP).
5. **`compare.mjs`** compara las fotos turno a turno. Si hay un **empate de Velocidad real**, Showdown lo resuelve con su propio azar y solo se comparan los turnos anteriores.

## Para añadir una tirada nueva

Si el motor pide azar en un sitio nuevo, usa `rand_int(&"etiqueta", ...)` o `rand_chance(&"etiqueta", ...)` y añade la etiqueta en Showdown, en `CORE` o en `HANDLERS` de `run_showdown.mjs`. Una tirada de Showdown sin etiqueta sale como `other` en el informe.
