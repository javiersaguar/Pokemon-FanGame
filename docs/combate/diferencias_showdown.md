# Diferencias con Pokémon Showdown

Resultados de la comparación turno a turno del combate con el simulador de Pokémon Showdown 0.11.11 (herramienta y método: [`tools/showdown_diff/README.md`](../../tools/showdown_diff/README.md)). Combates individuales, equipos de 3, con las especies, habilidades y movimientos que tiene implementados nuestro motor.

## Evolución

| Fecha | Combates | Idénticos a Showdown | Distintos | Empate de Velocidad |
|-------|----------|----------------------|-----------|---------------------|
| 2026-10-07, primera pasada | 200 | 146 (73 %) | 53 | 1 |
| 2026-10-07, tras la 1.ª tanda de correcciones | 400 | 379 (95 %) | 17 | 4 |

## Fallos de nuestro motor corregidos

| Fallo | Qué pasaba | Corrección |
|-------|------------|------------|
| Intimidación al empezar el combate | El rival salía primero y su habilidad de entrada se activaba antes de que hubiera un Pokémon nuestro en el campo: no bajaba nada | Al empezar, los efectos de entrada esperan a que salgan todos y van por orden de Velocidad (`_flush_intro_switch_ins`) |
| Clorofila, Nado Rápido, Liviano… | `_speed()` aplicaba dos veces la habilidad y el objeto: ×4 en vez de ×2 | Se aplican una sola vez |
| Francotirador, Cromolente y Vidasfera **del que recibe el golpe** | El cálculo de daño recorría las condiciones del objetivo **con su habilidad y su objeto**: un Pokémon con Vidasfera recibía ×1,3 de daño | Los modificadores ofensivos solo valen para el atacante |
| Mar Llamas, Espesura, Torrente, Enjambre | Subían la potencia ×1,5 (3.ª–4.ª generación) | Suben el Ataque o Ataque Especial ×1,5 (5.ª en adelante), con su redondeo (gancho nuevo `move_stat_modifier`) |
| Autoestima | Se activaba aunque el KO acabara el combate | No se activa si al rival no le quedan Pokémon |
| Nerviosismo | No reaccionaba a la Intimidación | +1 de Velocidad al recibir Intimidación (8.ª generación en adelante) |
| Despejar | No bajaba la Evasión (está en el script de Showdown, no en sus datos) | Baja la Evasión en un nivel |
| Motivación, Niebla Aromática, Refuerzo… | Sin aliado se aplicaban al propio usuario | Con objetivo "aliado adyacente" y sin aliado, fallan. "allies" incluye al usuario: Aullido y Rocío Vital siguen funcionando en individuales |
| Tóxico | Podía fallar usado por un Pokémon de tipo Veneno | No falla nunca (6.ª generación en adelante) |
| Síntesis, Sol Matinal, Luz Lunar | Redondeaban las mitades hacia arriba y con sol curaban 2/3 exactos | Mismo redondeo y factores que Showdown (`this.modify(maxhp, 0,5 / 0,667 / 0,25)`) |

## Diferencias pendientes de investigar

Del lote de 400 (semilla 1). Para reproducirlas: `node tools/showdown_diff/index.mjs --n=400 --seed=1` y buscar el combate en `tools/cache/showdown_diff/informe.md`.

| Combate | Primera diferencia | Pista |
|---------|--------------------|-------|
| c1-135 | Sunkern elige Rayo Solar en un motor y Crecimiento en el otro | Rayo Solar cargándose + sueño: el estado de "cargando" se trata distinto |
| c1-160, c1-209, c1-321, c1-327, c1-366, c1-369, c1-178, c1-199 | PS distintos | Por mirar uno a uno |
| c1-168, c1-339, c1-355, c1-361 | Ataque +2 de menos en nuestro motor | ¿Autoestima en cadena o Danza Espada? |
| c1-176 | Lluvia en Showdown y no en el nuestro, y un KO | Duración del clima |
| c1-244 | Velocidad y cambios dobles en nuestro motor | ¿Un cambio de característica aplicado dos veces? |
| c1-305 | Showdown termina antes | Por mirar |
| c1-385 | Precisión −1 en nuestro motor | Algún movimiento baja la precisión y en Showdown no |

## Diferencias intencionadas

Ninguna por ahora.
