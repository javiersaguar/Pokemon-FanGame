# Composición de rutas y ciudades · guía de Javier del 2026-10-15

**Nueva prioridad de Javier:** las rutas y ciudades deben alcanzar la composición, densidad y claridad de las [13 referencias de Añil](../arte/referencias/javier_2026-10-15/README.md). Hay que delimitar el espacio, hacer intuitivo el recorrido y colocar pasos por hierba que tengan una función. Mantener la esencia española, los lugares reales, monumentos y personajes; rediseñar las fachadas que no convencen con entrada y salida jugables e interior personalizado y proporcionado, con varias salas cuando lo merezcan. Esta orden amplía las decisiones del 13 y 14 de octubre; no cambia líderes, conexiones regionales ni reglas de progreso.

Las pautas numéricas siguientes son **criterios de trabajo propuestos para aplicar el encargo**, no decisiones numéricas atribuidas a Javier. El arte sigue provisional hasta su revisión. No se cambia `docs/DIRECTRICES.md`.

## Estado comprobado y alcance

Base publicada examinada: `343a0332` (sin incluir trabajo sin commit de otros worktrees). Auditoría física reproducible de **36 exteriores: las 26 rutas numeradas, las dos rutas iniciales y ocho mapas de pueblos/ciudades**. [JSON completo con SHA-256 de cada escena](../arte/comparativas/auditoria_anil_2026-10-15/metricas.json). [Capturas nuevas nativas de 512×384](../arte/comparativas/auditoria_anil_2026-10-15/README.md). Se revisan también las comparativas de tejido urbano publicadas el 14 de octubre; las capturas del encargo son solo referencia, nunca se presentan como resultado de Spain.

**Resultado principal: 25 de las 26 rutas numeradas permiten ir entre sus conexiones sin pisar ninguna casilla de encuentro. La excepción es Ruta 3: su mínimo es 26 casillas.** Se probaron las parejas de bordes en ambos sentidos, caminando con física real, sin Surf, saltos, eventos ni abandonar el mapa. Tener rectángulos de hierba grandes no garantiza un paso por ella: el jugador puede rodearlos por el lateral.

Los 36 exteriores contienen **293 puertas de catálogo y las 293 tienen Warp**. Esto acredita un enlace, no un interior apropiado: persisten muchas salas genéricas. La conexión marítima de Ibiza no tiene paso a pie; no es un fallo de esta medición, necesita Surf o transporte. Las escenas y funciones incorporadas por otros agentes después de la base deben volver a medirse.

## Diferencias con las referencias y cambio que toca hacer

| Aspecto | Qué muestran las referencias | Qué ocurre en Spain | Corrección concreta |
|---|---|---|---|
| Contorno y recorrido | Bosques, cantiles, orillas y parcelas forman límites continuos; claros y escaleras conectan sectores | Muchos prados y pavimentos se atraviesan por casi cualquier punto; no se distingue la intención del camino | Dibujar primero la red de pasos y destinos; cerrar sus laterales con masas continuas propias del lugar y comprobar los huecos con física |
| Jerarquía | Eje principal visible, accesos a puertas y pequeñas bifurcaciones con destino | Senderos de otro color dentro de una superficie igualmente transitable | Hacer que calle y sendero comuniquen lugares; delimitar aceras, parcelas, patios y plazas sin impedir llegar a las puertas |
| Hierba | Forma parte de pasos, desvíos y recompensas, encajada entre obstáculos | 25/26 rutas con rodeo seguro completo; la Ruta 8 coloca tres islas bajo un eje recto | En cada ruta terrestre que deba tener encuentros, un paso breve por hierba cerrando todo su ancho; después, zona segura y desvíos opcionales. Probar que no hay flanco de una casilla |
| Ritmo y escala | Alternancia de tramos contenidos, claros, curvas, puentes y cambios de cota | Rutas 7, 21, 24 y 26 tienen más del 90 % de casillas libres; grandes tramos sin decisiones | Reducir la explanada con bosque, roca, agua o parcelas; distribuir sectores y descansos alrededor de hitos, evitando laberintos y relleno ornamental |
| Ciudad | Manzanas, fachadas alineadas, plazas delimitadas y edificios que enmarcan las calles | Ibiza y Málaga siguen leyendo como una explanada con piezas separadas pese a tener más casas | Formar frentes de manzana y patios; calles que lleguen a rutas y puertas; una plaza con borde y función, no pavimento sobrante |
| Identidad | Pueblo del río/molinos, ciudad moderna, montaña y nieve usan estructuras diferentes | El adoquín, la hierba rectangular y la casa de pack se repiten en contextos diferentes | Componer con río/molinos, murallas, patios, costa, mercado o arquitectura propia de cada lugar; preservar todos los hitos reconocibles |
| Monumentos | Se integran con aproximación, explanada, sombras y proporción | Las piezas planas provisionales no guardan siempre escala, profundidad o detalle coherentes con casas/personajes | Rediseñar un edificio a la vez desde referencias reales; silueta reconocible, puerta legible, misma luz/perspectiva y tamaño revisado con su entorno |
| Interiores | La entrada corresponde a la función y escala del exterior | Un enlace puede desembocar en una habitación genérica con mobiliario ajeno al uso del monumento | Plano propio por edificio; sala, mobiliario y actividades coherentes; edificios grandes con varias salas conectadas y retorno a la calle |

## Hallazgos concretos para empezar

| Mapa | Hallazgo | Acción de composición |
|---|---|---|
| `ruta_2/exterior` | Paso norte-sur seguro completo y borde sur con 36 casillas transitables | Encajar el acceso de salida en un cuello claro; la banda de hierba del bosque debe cruzar el recorrido. Respetar el acueducto y el pequeño núcleo habitado |
| `ruta_5/exterior` | Atraviesa de oeste a este por un eje recto; hierba lateral y monumentos alineados sobre espacio libre | Sectores del Henares con parcelas, arbolado y accesos al Infantado y la Universidad; el eje debe encadenar destinos y un paso por hierba |
| `ruta_8/exterior` | Isla de Montserrat y tres parches de hierba al lado del eje horizontal | Separar aproximación a Montserrat, collado y salida hacia Barcelona; relieve continuo y un paso terrestre con encuentro |
| `ruta_21/exterior` | 91,3 % libre y cuadrado sin obstáculos ni encuentros de 18×18 | Prioridad alta fuera de las reservas actuales: resolver valles y pasos del Ebro sin convertir el río/hitos en adornos aislados |
| `ruta_26/exterior` | 95,1 % libre; la caliza no contiene el trayecto | Hacer del Torcal una secuencia de pasos entre formaciones, conservar el dolmen y su acceso; no dispersar piedras como única solución |
| `pozuelo/exterior` | Pequeño y ya más legible, pero parcelas y espacios verdes aún permiten cruzar casi por cualquier sitio | Alinear calles y entradas, patios y jardines cerrados. Mantener llegada segura, casa del jugador y camino al laboratorio |
| `ibiza/exterior` | Gran suelo adoquinado; muralla, costa, servicios y casas no forman una red de calles clara | Calle del puerto → servicios → subida a Dalt Vila/catedral, barrios contenidos y playa separada; preservar ferris, Surf, puertas y reserva de casas |
| `malaga/exterior` | Cuadrado libre de 18×18 y 71,5 % libre en el exterior de 96×80 | Definir centro histórico, ribera y paseo litoral como sectores conectados; enmarcar catedral, gimnasio y accesos a Torcal/transportes |
| `valencia/ciutat_vella` | 78,3 % libre | Alinear Lonja, mercado y catedral con calles y plazas reconocibles; patios, manzanas y frentes construidos para orientar |

El porcentaje mide **espacio físicamente transitable, no «cantidad de arte»**. El cuadrado libre no demuestra por sí solo un defecto: puede ser una plaza legítima si tiene borde, función y destinos. Sirven para localizar zonas que revisar visualmente, no para exigir llenar cada casilla.

### Tres piezas que exceden el rectángulo del mapa

El diagnóstico compara el tamaño completo de las piezas del catálogo con `Ground`; las capturas sirven para confirmar la apariencia antes de mover nada.

| Mapa | Pieza y ancla actual | Rectángulo visual de catálogo | Problema |
|---|---|---|---|
| `ruta_2/exterior` | `casa_madera` en (32,62) | x=32…36, y=57…62 en mapa de ancho 36 | Una columna queda fuera por la derecha |
| `bilbao/exterior` | `casa_tejado_rojo` en (68,49) | x=68…72, y=43…49 en mapa de ancho 72 | Una columna queda fuera por la derecha |
| `ruta_19/exterior` | `faro` en (30,9) | x=30…37, y=−2…9 | La pieza se extiende por encima del borde norte; revisar el encuadre y la aproximación |

Corregir mediante traslado completo del conjunto **pieza + puerta + Warp + aparición de retorno + cartel/colisiones relacionados** o ampliación planificada de ese sector. No mover solo el PNG ni tapar el corte con árboles. Volver a medir alcance desde cada entrada; preservar IDs de mapas, NPCs, recompensas, zonas y funciones.

## Pautas de composición para aplicar mapa a mapa

1. Reservar el mapa; inventariar conexiones, llegadas, puertas, personajes, objetos, zonas Locke, gimnasios y transportes antes de editar. Partir de la escena existente. **No repintar un exterior con puertas enlazadas desde `pintar_*.gd`.**
2. Bosquejar sobre cuadrícula el inicio, salida, recorrido principal, servicios, hitos y desvíos. En rutas, una secuencia de sectores pequeños con destino a la vista; en ciudad, calles y manzanas. Orientar por paisaje y arquitectura antes de añadir carteles.
3. Usar como pauta pasos de 2–4 casillas y accesos peatonales de 1–2; ampliar donde la escena lo requiera. No conservar una avenida de diez casillas sin función por inercia. Dejar espacio para NPC, seguidor y jugador en cruces y puertas.
4. Construir bordes continuos con el bioma correcto. Bosque como masa con bordes irregulares; laderas con coronación, cara y escaleras; costa con orilla; ciudad con fachadas, patios, muros, setos o jardines. No cubrir todas las ciudades españolas con el mismo bosque.
5. En las rutas con encuentros terrestres y equipo apto, diseñar un cruce breve de hierba dentro del recorrido principal, sin rodeo abierto. No exigir encuentros antes de obtener el primer Pokémon ni dentro del trayecto seguro entre casa, laboratorio y hospital. No se obliga a que aparezca un combate: el encuentro sigue siendo aleatorio y el Repelente sigue funcionando. No cambiar tablas, probabilidades o reglas Locke para ocultar un problema de composición.
6. Añadir desvíos con un motivo existente: edificio, entrenador, objeto, mirador o regreso. Los atajos de retorno deben usar reglas ya acordadas; no inventar bloqueos de historia, MO o recompensas. Si la decisión falta, **PENDIENTE JAVIER** en ESTADO y seguir con otra parte.
7. Diseñar ciudades por frentes y parcelas. Conectar el camino al umbral de cada puerta, hospital, Mercadona, estanco, gimnasio y ruta. Las plazas se enmarcan con edificios, vegetación, mobiliario o agua y tienen una función legible; evitar espejos vacíos a ambos lados de una vía.
8. Conservar geografía y monumentos, mejorar su dibujo y escala e integrarlos con el recorrido. [Listado de 76 entradas de edificios](../arte/edificios/redisenio_2026-10-14.md): fachada terminada, acceso visible, puerta funcional y plano interior coherente se entregan juntos por edificio. Una casa pequeña admite recibidor/dormitorio; iglesia, mercado, teatro, estadio, palacio o museo necesitan su organización propia. No reutilizar el mismo salón genérico con otro nombre. Arcos y pasos, estatuas y elementos naturales no se fuerzan a tener una habitación; se respetan las excepciones expresas del listado.
9. Rematar bordes de caminos, encuentros entre materiales, sombras, tejados y vegetación; variar detalles con intención y mantener perspectiva/luz. El arte nuevo de fachada se realiza con el mismo proceso visual de los personajes; no dibujar sus píxeles por código. Sí se pueden colocar y componer recursos existentes en mapas.
10. Recorrer en juego desde todas las llegadas, entrar y salir de cada edificio afectado, explorar cada sala y volver. Revisar a 512×384 además del mapa completo: el jugador debe poder orientarse en una pantalla. Repetir con la posición de una partida guardada si se ha reducido o reordenado un interior.

## Reparto para los cinco agentes en curso

Se mantiene lo que cada uno ya está trabajando. No es una autorización para pisarse mapas ni para rehacer trabajo sin revisar el estado compartido. Reservar antes, integrar una tarea coherente cada vez y continuar la siguiente.

| Responsable actual | Aplicación inmediata |
|---|---|
| Agente 1 · interiores | Revisar el trabajo existente de las casas ibicencas en su worktree antes de tocarlo; terminar acceso, recibidor y dormitorio, comprobar muebles interactivos y retorno. Continuar los interiores del listado por función/tamaño, preservando servicios, NPCs y guardados. Coordinar cada puerta con el exterior; no dar por terminado un interior por tener Warp |
| Agente 2 · personajes | Terminar y verificar su cobertura sin duplicar los 28 diseños ya publicados. Mantener `art_id`, orientación, colisiones e interacciones al mover personajes con los responsables de los mapas. Ubicaciones y guion sin decidir siguen en Preguntas para Javier |
| Agente 3 · gimnasios | Aplicar el nivel de detalle y la proporción a sus 32 salas y a Quirón/ático reservados. Diferenciar salas, circulación, obstáculos y puzle por gimnasio; conservar la obligación de superar entrenadores antes del líder. Comprobar ida y vuelta desde la nueva fachada y el hospital, sin deshacer el progreso |
| Agente 4 · accesos y viajes | Verificar que un límite bonito coincide con su colisión y que los nuevos pasos no rompen Surf, ferris, avión, Metro, F9 ni guardados. Al cerrar sus salas huérfanas, revisar retornos y la integridad de interiores; no confundir una conexión de agua con un fallo de acceso a pie |
| Agente 5 · exteriores | Aplicar primero a sus reservas `ruta_5`, `ruta_6`, `ruta_7`, `ruta_8` y `ruta_16`: estructura y paso por hierba antes de decoración. Después priorizar rutas muy abiertas (26, 21, 7, 24), las piezas fuera de límites y manzanas de ciudades, reservando cada una. Conservar monumentos, puertas y enlaces actuales |

**Fachadas:** la coordinación visual continúa el rediseño de edificios después de los personajes ya publicados. Nadie sustituye ni borra los monumentos para llenar un vacío: se mejora cada pieza y se acuerda su umbral y su volumen con quien lleva el interior. No tocar la reserva de Ibiza de otro responsable sin relevo explícito.

### Comprobación mínima de cada entrega

- Comparativa «antes / después» del mismo mapa y encuadre; vista general y al menos una captura real a 512×384; señalar referencia usada y qué recorrido mejoró. Las nuevas referencias se enlazan, no se vuelven a copiar dentro de cada entrega.
- Alcance con física desde cada llegada, todas las puertas/retornos y servicios accesibles, fachadas completas dentro de límites y ausencia de colisiones invisibles. Los servicios y el tutorial mantienen sus restricciones de historia.
- Para el tramo de hierba acordado: coste mínimo de casillas de encuentro **mayor que cero** entre las conexiones terrestres principales, sin exigir una cifra común para todas las rutas ni extender la regla a ciudades/agua. Comprobar rodeos por los dos flancos y ambos sentidos. Ruta 3 ya exige hierba: no alargar su exposición por una regla mecánica.
- Suite completa, validador de arte y de datos en verde; rebase con `main`, merge fast-forward en el repositorio compartido y `git push origin main`. Actualizar la sección propia en ESTADO y liberar su reserva.

## Reproducir la auditoría

```bash
export XDG_DATA_HOME=/tmp/xdg-agenteA
godot --headless --path . -s res://tools/mundo/auditar_composicion.gd -- /tmp/composicion.json ruta_2/exterior ruta_8/exterior ruta_21/exterior malaga/exterior
godot --headless --path . -s res://maps/_tools/alcance.gd -- ruta_2/exterior from_route_1
godot --path . --rendering-driver opengl3 --audio-driver Dummy -s res://tools/arte/capturar_composicion.gd -- ruta_2/exterior 20 17 /tmp/ruta_2_512.png
```

La auditoría no mueve mapas, no añade encuentros ni certifica calidad visual. El JSON registra el commit y el hash de cada escena. El recorrido local se calcula con máscara física 1|2|8 y cuatro direcciones; sin saltos ni Surf. No sustituye el recorrido real, los saltos unidireccionales, los eventos ni la prueba del transporte. Las alertas de borde usan el tamaño de catálogo y requieren confirmación visual, especialmente en recursos con margen transparente.

## Métricas de la base publicada

| Mapa | Casillas | Libre a pie | Casillas de encuentro transitables | Cuadrado libre máximo | Mínimo de hierba entre bordes |
|---|---|---|---|---|---|
| `ruta_1/exterior` | 36×64 | 59.7 % | 338 | 6×6 | 0 |
| `ruta_2/exterior` | 36×72 | 66.4 % | 173 | 10×10 | 0 |
| `ruta_3/exterior` | 36×80 | 60.6 % | 777 | 10×10 | 26 |
| `ruta_4/exterior` | 52×46 | 65.0 % | 170 | 9×9 | 0 |
| `ruta_5/exterior` | 72×32 | 69.7 % | 220 | 8×8 | 0 |
| `ruta_6/exterior` | 72×34 | 84.1 % | 280 | 12×12 | 0 |
| `ruta_7/exterior` | 72×34 | 91.3 % | 268 | 12×12 | 0 |
| `ruta_8/exterior` | 72×40 | 72.8 % | 292 | 11×11 | 0 |
| `ruta_9/exterior` | 48×76 | 57.1 % | 287 | 9×9 | 0 |
| `ruta_10/exterior` | 60×64 | 52.9 % | 280 | 13×13 | 0 |
| `ruta_11/exterior` | 76×34 | 87.7 % | 525 | 9×9 | 0 |
| `ruta_12/exterior` | 72×40 | 63.7 % | 681 | 11×11 | 0 |
| `ruta_13/exterior` | 76×46 | 58.2 % | 112 | 13×13 | 0 |
| `ruta_14/exterior` | 72×40 | 56.5 % | 206 | 10×10 | 0 |
| `ruta_15/exterior` | 36×72 | 67.9 % | 274 | 11×11 | 0 |
| `ruta_16/exterior` | 36×52 | 71.9 % | 305 | 10×10 | 0 |
| `ruta_17/exterior` | 64×40 | 68.4 % | 303 | 10×10 | 0 |
| `ruta_18/exterior` | 72×40 | 45.6 % | 352 | 10×10 | 0 |
| `ruta_19/exterior` | 56×36 | 56.9 % | 256 | 10×10 | 0 |
| `ruta_20/exterior` | 48×56 | 56.9 % | 329 | 8×8 | 0 |
| `ruta_21/exterior` | 48×64 | 91.3 % | 140 | 18×18 | 0 |
| `ruta_22/exterior` | 48×64 | 75.7 % | 160 | 15×15 | 0 |
| `ruta_23/exterior` | 64×40 | 48.9 % | 91 | 10×10 | 0 |
| `ruta_24/exterior` | 48×64 | 90.5 % | 135 | 13×13 | 0 |
| `ruta_25/exterior` | 48×64 | 85.0 % | 129 | 15×15 | 0 |
| `ruta_26/exterior` | 48×64 | 95.1 % | 135 | 14×14 | 0 |
| `casa_de_campo/exterior` | 40×36 | 58.8 % | 148 | 10×10 | 0 |
| `madrid_rio/exterior` | 36×40 | 58.5 % | 152 | 6×6 | 0 |
| `pozuelo/exterior` | 44×36 | 58.7 % | 0 | 8×8 | No aplica |
| `orcasitas/exterior` | 44×36 | 67.2 % | 0 | 10×10 | No aplica |
| `ibiza/exterior` | 64×56 | 56.3 % | 176 | 8×8 | No aplica |
| `malaga/exterior` | 96×80 | 71.5 % | 111 | 18×18 | No aplica |
| `madrid/centro` | 72×56 | 65.1 % | 0 | 10×10 | 0 |
| `valencia/ciutat_vella` | 64×56 | 78.3 % | 0 | 10×10 | No aplica |
| `santander/exterior` | 64×48 | 55.6 % | 60 | 8×8 | 0 |
| `bilbao/exterior` | 72×56 | 59.5 % | 224 | 8×8 | 0 |
