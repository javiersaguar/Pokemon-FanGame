# Cobertura de habilidades y movimientos · 2026-10-12

Inventario reproducible de los datos y registros actuales, sin parche RandomLocke. Fuente de catálogo: datos locales importados; [WikiDex](https://www.wikidex.net/wiki/Lista_de_habilidades) sirve para contrastar nombres y comportamiento. [Showdown](https://github.com/smogon/pokemon-showdown/blob/master/data/abilities.ts) es la referencia técnica del motor.

| Comprobación | Resultado |
|---|---:|
| Habilidades en el catálogo | 316 |
| Habilidades con script registrado | 29 |
| Habilidades sin descripción | 49 |
| Movimientos en el catálogo | 951 |
| Movimientos que requieren script y no lo tienen registrado | 441 |
| Movimientos con secuencia visual propia | 38 |

`habilidades.csv` recoge ID, número, nombre español/inglés, registro del efecto, necesidad de script, presencia de descripción y especies asociadas. `movimientos.csv` distingue efecto y presentación. `estado.json` contiene ambos y el resumen. Orden alfabético estable por ID; regenerar con:

```bash
godot --headless --path . -s tools/arte/auditar_combate.gd
```

Se puede pasar un directorio de salida como argumento después de `--`. El informe consulta `DataDB`, `Effects` y `BattleMoveAnimation`: no deduce que una habilidad esté completa solo por tener un archivo. Parte de las reglas puede estar en el motor general, y un script puede cubrir solo algunos casos. Tampoco confunde una animación con el efecto del movimiento. Los 441 pendientes corresponden al catálogo completo, no solo a los movimientos usados por el MVP.

Orden de implementación del motor para A5/A2: contrastar primero habilidades de especies ya usadas y las que ofrece F9, identificar reglas directas del motor, cubrir casos con combates comparados frente a Showdown y completar las 49 descripciones vacías. La presentación de A3 deja escoger habilidades legales (incluidas las ocultas) sin prometer que todos sus efectos estén implementados.

## Encargo completo de Javier · 2026-10-12

**Objetivo: todos los movimientos y todas las habilidades de las listas de WikiDex**, incluidos los de generaciones anteriores, Z, Dinamax y Gigamax, con nombre español, datos, comportamiento comprobado y presentación. El MVP y las especies usadas sirven para ordenar las entregas; **no limitan el alcance final**. Estar en el catálogo, tener un script y tener animación son comprobaciones separadas.

Contraste con [movimientos](https://www.wikidex.net/wiki/Lista_de_movimientos) y [habilidades](https://www.wikidex.net/wiki/Lista_de_habilidades), tablas consultadas el 2026-10-12:

| Revisión por identificador | Resultado |
|---|---|
| Movimientos de WikiDex | 935 / 935 presentes |
| Diferencia respecto a los 951 registros locales | 16 variantes tipadas de Poder Oculto |
| Z físico/especial | Se agrupan los dos índices del mismo nombre; no son 18 ausencias |
| Habilidades de la tabla actual | 317, contando las 2 Unidad Ecuestre y las 4 Evocarrecuerdos |
| Habilidades presentes | 316; falta Aura Protectora (`auraguard`, 319) |
| Nombres aún en inglés | 34 movimientos (33 Gigamax y Luz Devastadora), 2 habilidades (Impulso Anguila y Crin de Fuego) |
| Índices locales discrepantes | Abalorio Debacle 284 → 287; Tablilla Debacle 284 → 286 |
| Habilidad obsoleta nunca utilizada | Cacofonía: inventariada aparte; no se ofrece como habilidad legal |

El texto introductorio de habilidades todavía dice 316, pero la tabla incluye Aura Protectora y contiene 317 entradas utilizables. Se cuenta la tabla por ID. Mandíbula Dragón carece de nombre inglés en esa tabla: se resuelve por su índice conocido 263. Showdown identifica Aura Protectora como `Future`; no se inventan especies, aprendizaje ni efectos a partir de su presencia en la lista.

`wikidex_referencia.json` guarda solo nombres e índices de las tablas, fuente, fecha y variantes; **sin copiar descripciones**. `wikidex_estado.json` lista las ausencias y diferencias concretas. `wikidex_moves.csv` y `wikidex_abilities.csv` permiten seguir cada entrada por índice, catálogo, nombre y animación. La referencia permanece fija hasta una actualización explícita, y el contraste puede repetirse sin red:

```bash
python3 tools/arte/auditar_wikidex.py
python3 -B -m unittest discover -s tools/arte -p test_auditar_wikidex.py
# Volver a descargar las tablas, revisar el diff y después regenerar:
python3 tools/arte/auditar_wikidex.py --actualizar
```

Reparto y cierre pendiente:

1. **A2, datos/importador:** completar Aura Protectora y los 36 nombres; corregir los dos índices mediante una fuente u override reproducible, conservando IDs, ROM y aprendices. No editar a mano JSON generado. Petición 84.
2. **A5/A2, motor:** continuar los 441 movimientos con script sin registrar y la revisión de habilidades de la petición 81, hasta cobertura de **todo el catálogo**. Comprobar mecánicas y casos límite contra Showdown; un archivo por sí solo no certifica el efecto.
3. **A3, presentación:** continuar por índice las secuencias propias, probar ambos lados/modo reducido/limpieza, capturar comparación y mantener F9 como revisión. **38 / 935 nombres canónicos con animación propia**; quedan 897 con presentación por tipo/categoría. Las variantes de Poder Oculto conservan la genérica.
4. Aprendizaje por especie y acceso a movimientos especiales se mantienen conforme a sus datos/reglas; añadir un movimiento al catálogo no lo concede indiscriminadamente.

Entrega de esta sesión: Destructor, Golpe Karate, Doble Bofetón, Puño Cometa, Megapuño, Día de Pago, Corte y Tornado. Se conservan los 30 anteriores. Próximos índices sin secuencia: Fuerza de Garra (11), Guillotina (12), Viento Cortante (13), Ataque Ala (17), Remolino (18), Vuelo (19) y Atadura (20). Sus mecánicas de KO, carga, retirada y daño persistente se comprueban con el motor antes de presentar sus fases como resueltas. [Comparativas](../comparativas/a3_movimientos_por_indice.md).

Validación de esta entrega: **508/508 tests, 32.113 aserciones, 721,27 s**, más las 3 pruebas del contraste WikiDex. Arte: 10.951 PNG, 0 errores/avisos; datos: 0 errores y 3 avisos previos. Capturas y 16 reproducciones de las nuevas secuencias desde ambos lados revisadas.
