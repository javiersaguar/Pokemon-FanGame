# Segunda pasada a nivel Añil (2026-10-20, rama `feat/rutas-anil-3`)

Capturas de antes y después de todas las rutas y de las 22 ciudades con más huecos o bordes rectos, a 0,35 de su tamaño. Referencias de calidad: [ruta de Añil](../../referencias/anil_ruta.png) y [pueblo de Añil](../../referencias/anil_pueblo.png). Todo es provisional hasta que Javier lo apruebe.

## Qué se ha medido y qué se ha cambiado

`maps/_tools/huecos.gd` mide en cada exterior:

- **hueco**: lado del cuadrado más grande de casillas que se pisan y están lisas, sin hierba alta, camino, flores, adornos ni dibujo de objetos. En Añil no suele pasar de 4 o 5.
- **vacío**: porcentaje de casillas lisas entre las que se pisan.
- **recta**: tramo recto más largo de borde de bosque.

La receta común `maps/_pintura/vestir/_anil_3.gd` hace dos cosas:

- Rompe los bordes rectos de bosque de más de 10 casillas con un árbol suelto cada 5 a 7 casillas, o una mata alta si no cabe.
- Llena los huecos de más de 5 casillas de lado. En el centro de cada uno pone un árbol en la hierba, una palmera en la arena, un pino en la nieve, o un alcorque con árbol o una jardinera en el empedrado. Alrededor siembra matas, piedras y flores.

Nada se planta si corta un paso de una casilla, tapa algo protegido o pisa el dibujo de otro objeto. Ninguna puerta se mueve. `vestir_exterior.gd` comprueba el alcance de todo y la hierba obligada de las rutas antes de guardar.

## Rutas

| Mapa | Antes | Después | Hueco | Vacío | Recta |
|---|---|---|---|---|---|
| `ruta_1` | ![antes](ruta_1_antes.png) | ![después](ruta_1_despues.png) | 3 → 3 | 33% → 33% | 10 → 10 |
| `ruta_2` | ![antes](ruta_2_antes.png) | ![después](ruta_2_despues.png) | 8 → 5 | 45% → 43% | 12 → 12 |
| `ruta_3` | ![antes](ruta_3_antes.png) | ![después](ruta_3_despues.png) | 8 → 5 | 76% → 70% | 20 → 12 |
| `ruta_4` | ![antes](ruta_4_antes.png) | ![después](ruta_4_despues.png) | 6 → 5 | 47% → 45% | 14 → 14 |
| `ruta_5` | ![antes](ruta_5_antes.png) | ![después](ruta_5_despues.png) | 8 → 5 | 49% → 48% | 11 → 11 |
| `ruta_6` | ![antes](ruta_6_antes.png) | ![después](ruta_6_despues.png) | 6 → 5 | 50% → 50% | 6 → 6 |
| `ruta_7` | ![antes](ruta_7_antes.png) | ![después](ruta_7_despues.png) | 6 → 5 | 63% → 62% | 0 → 0 |
| `ruta_8` | ![antes](ruta_8_antes.png) | ![después](ruta_8_despues.png) | 5 → 5 | 34% → 34% | 8 → 8 |
| `ruta_9` | ![antes](ruta_9_antes.png) | ![después](ruta_9_despues.png) | 6 → 5 | 49% → 48% | 14 → 14 |
| `ruta_10` | ![antes](ruta_10_antes.png) | ![después](ruta_10_despues.png) | 8 → 5 | 55% → 54% | 29 → 24 |
| `ruta_11` | ![antes](ruta_11_antes.png) | ![después](ruta_11_despues.png) | 5 → 5 | 37% → 37% | 0 → 0 |
| `ruta_12` | ![antes](ruta_12_antes.png) | ![después](ruta_12_despues.png) | 7 → 5 | 55% → 52% | 18 → 16 |
| `ruta_13` | ![antes](ruta_13_antes.png) | ![después](ruta_13_despues.png) | 8 → 5 | 57% → 55% | 72 → 72 |
| `ruta_14` | ![antes](ruta_14_antes.png) | ![después](ruta_14_despues.png) | 6 → 5 | 50% → 48% | 14 → 14 |
| `ruta_15` | ![antes](ruta_15_antes.png) | ![después](ruta_15_despues.png) | 8 → 5 | 42% → 39% | 24 → 24 |
| `ruta_16` | ![antes](ruta_16_antes.png) | ![después](ruta_16_despues.png) | 4 → 4 | 35% → 34% | 17 → 14 |
| `ruta_17` | ![antes](ruta_17_antes.png) | ![después](ruta_17_despues.png) | 3 → 3 | 39% → 39% | 14 → 14 |
| `ruta_18` | ![antes](ruta_18_antes.png) | ![después](ruta_18_despues.png) | 5 → 5 | 33% → 33% | 21 → 21 |
| `ruta_19` | ![antes](ruta_19_antes.png) | ![después](ruta_19_despues.png) | 4 → 4 | 35% → 35% | 17 → 17 |
| `ruta_20` | ![antes](ruta_20_antes.png) | ![después](ruta_20_despues.png) | 4 → 4 | 37% → 35% | 19 → 12 |
| `ruta_21` | ![antes](ruta_21_antes.png) | ![después](ruta_21_despues.png) | 3 → 3 | 28% → 28% | 14 → 14 |
| `ruta_22` | ![antes](ruta_22_antes.png) | ![después](ruta_22_despues.png) | 6 → 5 | 52% → 51% | 10 → 10 |
| `ruta_23` | ![antes](ruta_23_antes.png) | ![después](ruta_23_despues.png) | 6 → 5 | 46% → 44% | 29 → 29 |
| `ruta_24` | ![antes](ruta_24_antes.png) | ![después](ruta_24_despues.png) | 7 → 5 | 51% → 50% | 0 → 0 |
| `ruta_25` | ![antes](ruta_25_antes.png) | ![después](ruta_25_despues.png) | 5 → 5 | 50% → 49% | 22 → 12 |
| `ruta_26` | ![antes](ruta_26_antes.png) | ![después](ruta_26_despues.png) | 7 → 5 | 66% → 65% | 10 → 10 |

Referencia: ![Añil](../../referencias/anil_ruta.png)

## Ciudades

| Mapa | Antes | Después | Hueco | Vacío | Recta |
|---|---|---|---|---|---|
| `alicante` | ![antes](alicante_antes.png) | ![después](alicante_despues.png) | 6 → 5 | 62% → 62% | 0 → 0 |
| `bilbao` | ![antes](bilbao_antes.png) | ![después](bilbao_despues.png) | 6 → 5 | 60% → 60% | 22 → 22 |
| `huelva` | ![antes](huelva_antes.png) | ![después](huelva_despues.png) | 6 → 5 | 68% → 67% | 0 → 0 |
| `ibiza` | ![antes](ibiza_antes.png) | ![después](ibiza_despues.png) | 7 → 6 | 63% → 61% | 0 → 0 |
| `las_palmas_vegueta_triana` | ![antes](las_palmas_vegueta_triana_antes.png) | ![después](las_palmas_vegueta_triana_despues.png) | 7 → 5 | 69% → 68% | 0 → 0 |
| `madrid_bernabeu` | ![antes](madrid_bernabeu_antes.png) | ![después](madrid_bernabeu_despues.png) | 6 → 5 | 83% → 82% | 0 → 0 |
| `madrid_chamberi` | ![antes](madrid_chamberi_antes.png) | ![después](madrid_chamberi_despues.png) | 6 → 5 | 70% → 69% | 0 → 0 |
| `madrid_moncloa` | ![antes](madrid_moncloa_antes.png) | ![después](madrid_moncloa_despues.png) | 6 → 5 | 61% → 60% | 21 → 21 |
| `madrid_palacio_real` | ![antes](madrid_palacio_real_antes.png) | ![después](madrid_palacio_real_despues.png) | 4 → 4 | 47% → 47% | 16 → 10 |
| `madrid_retiro` | ![antes](madrid_retiro_antes.png) | ![después](madrid_retiro_despues.png) | 6 → 5 | 56% → 56% | 20 → 11 |
| `malaga` | ![antes](malaga_antes.png) | ![después](malaga_despues.png) | 6 → 6 | 53% → 53% | 0 → 0 |
| `murcia` | ![antes](murcia_antes.png) | ![después](murcia_despues.png) | 6 → 5 | 69% → 69% | 0 → 0 |
| `orcasitas` | ![antes](orcasitas_antes.png) | ![después](orcasitas_despues.png) | 8 → 6 | 78% → 75% | 27 → 22 |
| `palma` | ![antes](palma_antes.png) | ![después](palma_despues.png) | 6 → 5 | 67% → 66% | 12 → 12 |
| `pamplona` | ![antes](pamplona_antes.png) | ![después](pamplona_despues.png) | 7 → 5 | 72% → 71% | 3 → 3 |
| `playa_del_ingles` | ![antes](playa_del_ingles_antes.png) | ![después](playa_del_ingles_despues.png) | 10 → 6 | 76% → 64% | 0 → 0 |
| `pozuelo` | ![antes](pozuelo_antes.png) | ![después](pozuelo_despues.png) | 5 → 5 | 60% → 60% | 15 → 15 |
| `santander` | ![antes](santander_antes.png) | ![después](santander_despues.png) | 6 → 5 | 67% → 67% | 18 → 18 |
| `sevilla_centro` | ![antes](sevilla_centro_antes.png) | ![después](sevilla_centro_despues.png) | 8 → 5 | 70% → 69% | 0 → 0 |
| `soto_del_real` | ![antes](soto_del_real_antes.png) | ![después](soto_del_real_despues.png) | 4 → 4 | 52% → 47% | 30 → 30 |
| `valladolid` | ![antes](valladolid_antes.png) | ![después](valladolid_despues.png) | 7 → 5 | 71% → 70% | 0 → 0 |
| `vigo` | ![antes](vigo_antes.png) | ![después](vigo_despues.png) | 7 → 5 | 70% → 70% | 0 → 0 |

Referencia: ![Añil](../../referencias/anil_pueblo.png)

## Otras capturas de esta rama

- Ruta marítima 1, corrientes y escollos: [antes](maritima_1_antes.png) · [después](maritima_1_despues.png).
- Ruta 1, cancela de atajo y arbolillo de Corte: [antes](ruta_1_atajo_antes.png) · [después](ruta_1_atajo_despues.png).
- Ruta 7, roca de Fuerza en la escalera del cerro: [antes](ruta_7_fuerza_antes.png) · [después](ruta_7_fuerza_despues.png).
- Ruta 5, entrenadores en el camino de la ribera: [antes](ruta_5_entrenadores_antes.png) · [después](ruta_5_entrenadores_despues.png).

