# Cobertura de habilidades y movimientos · 2026-10-12

Inventario reproducible de los datos y registros actuales, sin parche RandomLocke. Fuente de catálogo: datos locales importados; [WikiDex](https://www.wikidex.net/wiki/Lista_de_habilidades) sirve para contrastar nombres y comportamiento. [Showdown](https://github.com/smogon/pokemon-showdown/blob/master/data/abilities.ts) es la referencia técnica del motor.

| Comprobación | Resultado |
|---|---:|
| Habilidades en el catálogo | 316 |
| Habilidades con script registrado | 29 |
| Habilidades sin descripción | 49 |
| Movimientos en el catálogo | 951 |
| Movimientos que requieren script y no lo tienen registrado | 441 |
| Movimientos con secuencia visual propia | 22 |

`habilidades.csv` recoge ID, número, nombre español/inglés, registro del efecto, necesidad de script, presencia de descripción y especies asociadas. `movimientos.csv` distingue efecto y presentación. `estado.json` contiene ambos y el resumen. Orden alfabético estable por ID; regenerar con:

```bash
godot --headless --path . -s tools/arte/auditar_combate.gd
```

Se puede pasar un directorio de salida como argumento después de `--`. El informe consulta `DataDB`, `Effects` y `BattleMoveAnimation`: no deduce que una habilidad esté completa solo por tener un archivo. Parte de las reglas puede estar en el motor general, y un script puede cubrir solo algunos casos. Tampoco confunde una animación con el efecto del movimiento. Los 441 pendientes corresponden al catálogo completo, no solo a los movimientos usados por el MVP.

Prioridad de motor para A5/A2: contrastar primero habilidades de especies ya usadas y las que ofrece F9, identificar reglas directas del motor, cubrir casos con combates comparados frente a Showdown y completar las 49 descripciones vacías. La presentación de A3 deja escoger habilidades legales (incluidas las ocultas) sin prometer que todos sus efectos estén implementados.
