# Cobertura de habilidades y movimientos · 2026-10-12

## Actualización · 2026-10-20 (combate fiel a la 9.ª generación)

- **Habilidades con efecto: 206** (eran 29). Todas las de las especies de `data/species_in_use.json` tienen efecto; `tests/combate/test_habilidades.gd` lo comprueba y prueba una de cada familia (absorción e inmunidades, estados, Intimidación, características y potencia, contacto, entrada, final del turno, prioridad, críticos, niveles, formas, Rompemoldes y Gas Reactivo, Muro Mágico y Regeneración). Código: `src/battle/effects/ability_families.gd`.
- **Objetos equipados**: además de los de antes, potenciadores de tipo y tablas, Cinta Fuerte, Gafas Especiales, Cinta Experto, Metrónomo, Mineral Evolutivo, Bola Férrea, Lupa, Telescopio, Polvo Brillo, Periscopio, Garra Afilada, Garra Rápida, Cola Plúmbea, Roca del Rey, Colmillo Agudo, Cascabel Concha, Seguro Debilidad, Tarjeta Roja, Botón Escape, Globo Helio, bayas Biglia, Maranga, Jaboca, Magua, Enigma, Lichi, Gonlan, Aslac, Yapati, Albaricoque, Arabol, Zonlan, Lagro, Chiri y Zanama, Toxisfera, Llamasfera, Lodo Negro, Hierba Blanca, Hierba Mental, Hierba Única, Mochila Escape, Espray Bucal, Seguro Fallo, Servicio Habitación, Capa Furtiva, Amuleto Claro, Energía Potenciadora, Refleluz, las cuatro rocas, Cubrecampos, Raíz Grande, Dado Trucado, Garra Garfio, Banda Atadura y las semillas de campo. Tests: `tests/combate/test_objetos_equipados.gd`. Código: `src/battle/effects/item_families.gd`.
- **Simplificaciones de la petición 81 corregidas** (`tests/combate/test_simplificaciones.gd`): Cede Paso y Último Lugar reordenan (también en dobles), Premonición calcula el daño al golpear, Mimético dura hasta retirarse, Plegaria Vital deja elegir, Gravedad sube la precisión ×5/3, Fijar Blanco alcanza a los semiinvulnerables, Dracoflechas reparte en dobles, el daño al Sustituto cuenta para retroceso y drenaje, y Metrónomo usa la lista de la 9.ª generación.
- **Movimientos normales que nadie usaba: hechos** (84 de 85; Forcejeo lo resuelve el motor). Test: `tests/combate/test_movimientos_sin_uso.gd`.
- Del catálogo entero siguen **169 movimientos** sin script: Forcejeo (lo resuelve el motor) y 168 fuera de la 9.ª generación (72 de otras generaciones, 35 Z, 33 Gigamax, 19 Dinamax, 7 de Let's Go y 2 no disponibles). Simplificaciones y pendientes, en `docs/ESTADO.md`.

## Actualización · 2026-10-19 (petición 81)

- **Movimientos en uso sin script: 0** (eran 177). El validador ya no avisa. Se hicieron por orden de uso: primero los que usan los entrenadores colocados (sus movimientos salen del nivel si no los tienen escritos), luego los de las especies de `data/species_in_use.json`.
- Del catálogo entero quedan **253** que piden script sin tenerlo: los Z, Dinamax y de otras generaciones marcados como no estándar, y **85 normales que nadie usa en el juego** (ninguna especie en uso los aprende y ningún entrenador los lleva). Se harán cuando entren en uso: alluringvoice, aurawheel, barbbarrage, bleakwindstorm, bodypress, burningbulwark, burningjealousy, ceaselessedge, celebrate, chloroblast, clangoroussoul, collisioncourse, crushgrip, darkvoid, diamondstorm, direclaw, dragoncheer, eeriespell, electrodrift, electroshot, expandingforce, ficklebeam, filletaway, firepledge, forestscurse, freezeshock, fusionbolt, fusionflare, grasspledge, grassyglide, gravapple, happyhour, hardpress, heartswap, hyperspacefury, iceburn, infernalparade, instruct, ivycudgel, judgment, junglehealing, lashout, lastrespects, lunarblessing, meteorbeam, mistyexplosion, mortalspin, orderup, photongeyser, pollenpuff, poltergeist, populationbomb, present, prismaticlaser, psyblade, psychicnoise, psystrike, relicsong, risingvoltage, roaroftime, ruination, saltcure, sandsearstorm, secretsword, shadowforce, shellsidearm, sketch, snipeshot, spiritshackle, steelbeam, steelroller, stoneaxe, struggle (lo resuelve el motor), supercellslam, syrupbomb, takeheart, terablast, terastarstorm, thunderclap, tidyup, transform, upperhand, waterpledge, watershuriken y wildboltstorm.
- Tests: `tests/combate/test_efectos_movimientos.gd` y `test_efectos_movimientos_2.gd` (64 casos). Mecánicas contrastadas con Showdown y Bulbapedia; las simplificaciones están en `docs/ESTADO.md`, sección del agente de combate.


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
3. **A3, presentación:** continuar por índice las secuencias propias, probar ambos lados/modo reducido/limpieza, capturar comparación y mantener F9 como revisión. **Todos los movimientos tienen animación propia (2026-10-14)**: 38 a mano, 457 traducidas de las originales de Elite Battle DX y 456 armadas con sus datos; ver [la comparativa](../comparativas/movimientos_2026-10-14.md). Lo siguiente es pasar a mano las más vistas que no están en EBDX e importar sus sonidos.
4. Aprendizaje por especie y acceso a movimientos especiales se mantienen conforme a sus datos/reglas; añadir un movimiento al catálogo no lo concede indiscriminadamente.

Entrega de esta sesión: Destructor, Golpe Karate, Doble Bofetón, Puño Cometa, Megapuño, Día de Pago, Corte y Tornado. Se conservan los 30 anteriores. Próximos índices sin secuencia: Fuerza de Garra (11), Guillotina (12), Viento Cortante (13), Ataque Ala (17), Remolino (18), Vuelo (19) y Atadura (20). Sus mecánicas de KO, carga, retirada y daño persistente se comprueban con el motor antes de presentar sus fases como resueltas. [Comparativas](../comparativas/a3_movimientos_por_indice.md).

Validación de esta entrega: **508/508 tests, 32.113 aserciones, 721,27 s**, más las 3 pruebas del contraste WikiDex. Arte: 10.951 PNG, 0 errores/avisos; datos: 0 errores y 3 avisos previos. Capturas y 16 reproducciones de las nuevas secuencias desde ambos lados revisadas.
