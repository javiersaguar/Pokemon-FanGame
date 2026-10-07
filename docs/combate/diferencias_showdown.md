# Diferencias con Pokémon Showdown

Resultados de la comparación turno a turno del combate con el simulador de Pokémon Showdown 0.11.11 (herramienta y método: [`tools/showdown_diff/README.md`](../../tools/showdown_diff/README.md)). Combates individuales, equipos de 3, con las especies, habilidades y movimientos que tiene implementados nuestro motor.

## Evolución

| Fecha | Combates | Idénticos a Showdown | Distintos | Empate de Velocidad |
|-------|----------|----------------------|-----------|---------------------|
| 2026-10-07, primera pasada | 200 | 146 (73 %) | 53 | 1 |
| 2026-10-07, tras la 1.ª tanda de correcciones | 400 | 379 (95 %) | 17 | 4 |
| 2026-10-07, tras la 2.ª tanda (semillas 1, 2 y 3) | 1.200 | 1.111 + 70 hasta el límite de 60 turnos (98,4 %; 99,4 % sin contar el límite) | 7 | 12 |
| 2026-10-07, tras la 3.ª tanda (semillas 1 a 5) | 2.000 | 1.882 + 103 hasta el límite de 60 turnos (**100 %**) | 0 | 15 |
| 2026-10-07, con objetos (`--items`, semillas 11 y 12), primera pasada | 800 | 600 + 23 hasta el límite (78 %) | 173 | 4 |
| 2026-10-07, con objetos tras la 4.ª tanda (semillas 11 a 16) | 2.400 | 2.276 + 101 hasta el límite (**100 %**) | 0 | 23 |

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
| Saña, Enfado, Danza Pétalo | Seguían el arrebato aunque un turno fallara, y la parálisis no lo descontaba | Igual que el `lockedmove` de Showdown: el volátil dura 2 turnos y cada golpe lo renueva mientras quede arrebato. Si un turno no golpea se acaba: con confusión si era el último y sin ella si no. Dormido, se acaba al final del turno sin confusión |
| Golpe Bajo | Funcionaba contra un rival que tenía que recargar (Hiperrayo) | Falla, como en Showdown |
| Ráfaga Escamas, Fragor Escamas | Con el golpe que acaba el combate, bajaba la Defensa y subía la Velocidad | Sus mejoras ("selfBoost") van después de procesar los KO: si el combate ha acabado, no llegan. A Bocajarro y el resto sí (son efecto del golpe) |
| Final del turno | Seguía aplicando efectos aunque un bando se quedara sin Pokémon (la quemadura del ganador lo podía debilitar) | Se corta en cuanto un bando se queda sin Pokémon |
| Veneno y quemadura | Iban con el mismo orden al final del turno: el más rápido primero | El veneno va antes (orden 9 y 10 en Showdown) |
| Mudar | Curaba con 1/3 | 33/100 |
| Nerviosismo, Casco Dentado | Se activaban una vez por movimiento y no con el golpe que debilita | Con cada golpe que hace daño, aunque debilite (`DamagingHit`) |
| Bayas Higog, Wiki, Ango, Guaya y Pabaya | Se comían a la mitad de los PS | A un cuarto (7.ª generación en adelante). Era la diferencia más frecuente con objetos: 150 de 173 combates |
| Baya Atania y Descanso | Descanso no la activaba (ponía el sueño sin pasar por las bayas) | Se la come y se despierta, como en Showdown |
| Chupavidas, Absorber… | Curaban al final del movimiento, después del Casco Dentado del rival | Curan con cada golpe, nada más hacer el daño |
| Bayas que reducen el daño (Chilan, Caoca…) | Reducían también el daño fijo (Superdiente) y se aplicaban después del daño, con su propio redondeo | Son un modificador más de la cadena del cálculo (con Reflejo, un solo redondeo) y no actúan con daño fijo |
| Picoteo y Picadura | Quitaban la baya sin efecto y no activaban el Liviano del rival; el dueño se la podía comer antes | Se la comen con su efecto, sin mirar los PS. Además, durante un golpe las bayas curativas esperan a que acaben sus efectos (`Update` de Showdown) |
| Pañuelo, Cinta y Gafas Elección | Bloqueaban al elegir el movimiento, aunque luego retrocediera o no pudiera moverse | Bloquean al usarlo |
| Púas, Trampa Rocas… | Fallaban si el rival acababa de caer ("no había ningún objetivo") | Van al campo rival igual |
| Nerviosismo con Intimidación | Subía la Velocidad aunque el Ataque no bajara (a −6) | Solo si le baja el Ataque |
| Doble KO | El nuestro entraba antes y su Intimidación no encontraba al nuevo rival | Tras los KO, salen todos y después van los efectos de entrada por Velocidad, como al empezar |
| Púas Tóxicas y Velo Sagrado | Envenenaban a través de Velo Sagrado (no tenían fuente) | La fuente es el rival que está en el campo, como en Showdown |
| Aguijón Letal | Subía el Ataque con el golpe que acaba el combate | No sube (va después de procesar los KO) |
| Tornado y Ciclón | Daño normal contra quien está en el aire | ×2 |
| Síntesis, Sol Matinal, Luz Lunar | Redondeaban las mitades hacia arriba y con sol curaban 2/3 exactos | Mismo redondeo y factores que Showdown (`this.modify(maxhp, 0,5 / 0,667 / 0,25)`) |

## Diferencias pendientes de investigar

Ninguna: 2.000 combates sin objetos (semillas 1 a 5) y 2.400 con objetos (`--items`, semillas 11 a 16) idénticos a Showdown. Lo siguiente es medir la cobertura con `--all-abilities` y `--all-moves` (habilidades y movimientos sin implementar) y los combates dobles.

## Muestra fija en la suite

`tests/combate/test_showdown_muestra.gd` juega 30 combates que coinciden con Showdown (`tests/combate/showdown_muestra.json`, con las fotos de Showdown guardadas) y falla si alguno deja de coincidir. No necesita Node. Se rehace con `node tools/showdown_diff/make_fixture.mjs` cuando el cambio es intencionado. Los fallos ya corregidos tienen además su test en `tests/combate/test_regresiones_showdown.gd`.

## Diferencias intencionadas

Ninguna por ahora.
