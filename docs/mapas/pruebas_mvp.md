# Guion del MVP en la sala de pruebas (bloque I)

No añade mapas ni pantallas nuevos. Ejecutar F5: se sigue entrando en `test/test_room`.

1. Hablar con el profesor delante del punto de entrada. Elegir chico/chica. La sala suministra los nombres **POR DEFINIR** explícitamente; el evento definitivo, sin esos parámetros, espera las señales del teclado de A3. El profesor se llama POR DEFINIR (decisión GDD pendiente).
2. La intro coloca al jugador en el spawn `bedroom` de la misma sala. Pisar la casilla (10,6): evento de salir de la habitación y traslado al spawn `laboratory`, aún en la sala. El evento de entrada presenta los tres iniciales y habilita sus Poké Balls. Son puntos de prueba del guion, no interiores aprobados.
3. Interactuar con una de las tres Poké Balls (casillas 3–5,3). La especie/nivel vienen de DataDB.starter_spec(). Las tres desaparecen al incorporar el inicial. En RandomLocke con mote obligatorio espera al teclado (petición 32); nunca se inventa mote para continuar.
4. Hablar con el rival en (7,4). Su trainer_id viene de `world.mvp_story.rival_by_starter`; equipos de DataDB, tutorial con can_lose y reglas de muerte excluidas. Ganar o perder permite avanzar y cura el equipo.
5. Volver al profesor: activa got_pokedex y entrega el regalo una sola vez. Cantidad en `world.mvp_story.reward.quantity`, pendiente de Javier (pregunta 18); mientras no esté decidida no da una cantidad inventada ni marca story_rewards_done. El ID temporal del regalo se resuelve mediante DataDB.item_placements()/placed_item() y reaprovecha el ID de Balls existente de la sala exterior; se sustituirá al crear las colocaciones de los mapas reales.
6. Enfermera en (15,3): evento común de curación y punto de reaparición. Dependiente en (9,7): abre `ShopScreen.open("tienda_ciudad2")` cuando A3 entregue la pantalla; el catálogo ya está en DataDB. Las compras/ventas pertenecen a la pantalla, no se simulan en el evento.
7. Una derrota fuera del tutorial vuelve al punto de curación. En RandomLocke retira muertos y verifica PC/Cementerio/game over antes de curar.

Configuración de guion en `data/world.json.mvp_story`; flags en docs/flags.md. Al crear los mapas reales se cambian los destinos, sin escribir equipos/especies/objetos en los eventos.

Pruebas: `tests/mundo/test_mvp_story.gd` usa eventos y motor reales, sustituye solo presentación para el guion y prueba también teletransporte, evento ON_ENTER, derrota y enfermera en la escena de sala real. `test_locke_world.gd` prueba la integración Locke. El cierre completo v0.1 sin Debug sigue en bloque II, después de aprobación gráfica.

Decisión 2026-10-05: el profesor entrega **5 Poké Balls**, una sola vez. Reloj real y dinero inicial 3000. Nombres de diseño en `world.names`, marcadores `{world:clave}`; siguen POR DEFINIR. Las referencias anteriores a cantidad pendiente quedan supersedidas por la respuesta de Javier.
