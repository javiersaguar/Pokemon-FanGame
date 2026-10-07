# Diferencias con Pokémon Showdown

Resultados de la comparación turno a turno del combate con el simulador de Pokémon Showdown 0.11.11 (herramienta y método: [`tools/showdown_diff/README.md`](../../tools/showdown_diff/README.md)). Combates individuales, equipos de 3, con las especies, habilidades y movimientos que tiene implementados nuestro motor.

## Evolución

| Fecha | Combates | Idénticos a Showdown | Distintos | Empate de Velocidad |
|-------|----------|----------------------|-----------|---------------------|
| 2026-10-07, primera pasada | 200 | 146 (73 %) | 53 | 1 |
| 2026-10-07, tras la 1.ª tanda de correcciones | 400 | 379 (95 %) | 17 | 4 |
| 2026-10-07, tras la 2.ª tanda (semillas 1, 2 y 3) | 1.200 | 1.111 + 70 hasta el límite de 60 turnos (98,4 %; 99,4 % sin contar el límite) | 7 | 12 |

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
| Respiro | `Pokemon.types()` devuelve la lista de la especie y `Battler.types()` la modificaba: **Respiro le quitaba el tipo Volador a la especie entera** para el resto de la partida | `Battler.types()` trabaja sobre una copia |
| Contoneo, Camelo… | Si la confusión fallaba (ya confuso, Campo de Niebla), fallaba todo y no subía el Ataque | Mismo orden que Showdown: características, curación, estado y confusión; que falle una parte no anula las otras |
| Polvo Escudo | Bloqueaba también las mejoras del propio atacante (Nitrocarga, Abrecaminos) | Solo bloquea lo que afecta al objetivo |
| Parálisis con Viento Afín | La parálisis se aplicaba antes que los multiplicadores (149 → 74 → 148) | Va la última, como en Showdown (149 → 298 → 149) |
| Movimientos de dos turnos | Si no podía moverse (sueño, parálisis, retroceso, enamoramiento…) conservaba la carga: seguía en el aire con Vuelo o lanzaba el Rayo Solar a la fuerza al despertar | Pierde la carga (`onMoveAborted` de Showdown) |
| Saña, Enfado, Golpe | Si Protección paraba el último golpe, el arrebato acababa sin confusión | Confunde al acabar igual; dormido, se acaba sin confusión |
| Protección seguidas | Retroceder o no poder moverse no reiniciaba la cuenta | Si pasa un turno sin usarla, la cuenta vuelve a empezar (el volátil `stall` dura 2 turnos) |
| Síntesis, Sol Matinal, Luz Lunar | Redondeaban las mitades hacia arriba y con sol curaban 2/3 exactos | Mismo redondeo y factores que Showdown (`this.modify(maxhp, 0,5 / 0,667 / 0,25)`) |

## Diferencias pendientes de investigar

De los lotes de 400 con semillas 1 y 3 (la 2 no tiene ninguna). Para reproducirlas: `node tools/showdown_diff/index.mjs --n=400 --seed=1` y buscar el combate en `tools/cache/showdown_diff/informe.md`.

| Combate | Primera diferencia | Pista |
|---------|--------------------|-------|
| c1-244, c3-70 | Al final, Defensa −2 y Velocidad +2 en nuestro motor (−1 y +1 en Showdown) | Algún efecto que se aplica dos veces en el último golpe |
| c1-203, c1-305 | Showdown termina antes | Por mirar |
| c3-62 | PS distintos al final | Por mirar |
| c3-84, c3-319 | PS distintos (y sueño en c3-319) | Por mirar |

## Muestra fija en la suite

`tests/combate/test_showdown_muestra.gd` juega 30 combates que coinciden con Showdown (`tests/combate/showdown_muestra.json`, con las fotos de Showdown guardadas) y falla si alguno deja de coincidir. No necesita Node. Se rehace con `node tools/showdown_diff/make_fixture.mjs` cuando el cambio es intencionado. Los fallos ya corregidos tienen además su test en `tests/combate/test_regresiones_showdown.gd`.

## Diferencias intencionadas

Ninguna por ahora.
