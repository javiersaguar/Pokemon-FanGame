# Clases de los gimnasios · Entrega 14

Diez clases ficticias con retrato de combate y poses de mapa. Los datos actuales contienen **45 entrenadores** de estas clases; el listado de Javier indicaba 54. Se resuelven por clase: los futuros entrenadores que la usen también tendrán el arte. No se crean entrenadores ni se cambian sus equipos. Personajes con identidad propia tienen prioridad sobre la clase. Arte provisional hasta revisión de Javier.

| Clase | Entrenadores actuales | Ejemplo capturado | Antes | Entrada propia | Galería |
| --- | ---: | --- | --- | --- | --- |
| Concejal del PP (`concejal`) | 6 | `gym1_concejal_1` | [Antes](personaje_concejal_antes_entrada.png) | [Después](personaje_concejal_entrada.png) | [Mapa](personaje_concejal.png) |
| Culé (`cule`) | 6 | `gym2_cule_1` | [Antes](personaje_cule_antes_entrada.png) | [Después](personaje_cule_entrada.png) | [Mapa](personaje_cule.png) |
| Alcohólico (`alcoholico`) | 2 | `gym3_alcoholico_1` | [Antes](personaje_alcoholico_antes_entrada.png) | [Después](personaje_alcoholico_entrada.png) | [Mapa](personaje_alcoholico.png) |
| Porreta (`porreta`) | 3 | `gym3_porreta_1` | [Antes](personaje_porreta_antes_entrada.png) | [Después](personaje_porreta_entrada.png) | [Mapa](personaje_porreta.png) |
| Cocainómano (`cocainomano`) | 3 | `gym3_cocainomano_1` | [Antes](personaje_cocainomano_antes_entrada.png) | [Después](personaje_cocainomano_entrada.png) | [Mapa](personaje_cocainomano.png) |
| Flamenco de traje (`flamenco_traje`) | 2 | `gym4_flamenco_1` | [Antes](personaje_flamenco_traje_antes_entrada.png) | [Después](personaje_flamenco_traje_entrada.png) | [Mapa](personaje_flamenco_traje.png) |
| Quesito en bikini (`quesito`) | 6 | `gym5_quesito_1` | [Antes](personaje_quesito_antes_entrada.png) | [Después](personaje_quesito_entrada.png) | [Mapa](personaje_quesito.png) |
| Etarra (`etarra`) | 6 | `gym6_etarra_1` | [Antes](personaje_etarra_antes_entrada.png) | [Después](personaje_etarra_entrada.png) | [Mapa](personaje_etarra.png) |
| Cayetano de pelo casco (`cayetano_casco`) | 7 | `gym7_cayetano_1` | [Antes](personaje_cayetano_casco_antes_entrada.png) | [Después](personaje_cayetano_casco_entrada.png) | [Mapa](personaje_cayetano_casco.png) |
| Actor de reparto (`actor_reparto`) | 4 | `gym8_actor_1` | [Antes](personaje_actor_reparto_antes_entrada.png) | [Después](personaje_actor_reparto_entrada.png) | [Mapa](personaje_actor_reparto.png) |

La clase quesito representa una mujer adulta. El actor de reparto reutiliza su pose quieta izquierda correcta en los dos frames de reposo; la pose dibujada mirando a la derecha en esa fila queda fuera de las regiones usadas. Los PNG se conservan intactos. Porreta usa retrato y hoja de mapa separados; se corrigió el tamaño de las poses de espalda para evitar que el escalado entero hiciera pequeños todos sus sprites. La hoja de mapa original se registra con su tamaño de 1254×1254.

## Abuela de Lamine en Rocafonda

[Antes, clase genérica](abuela_lamine_mapa_antes.png) · [Después, identidad propia](abuela_lamine_mapa.png). El NPC conserva posición, tres frases e interacción; la opción `NPC.art_id` selecciona el atlas. Su retrato ya estaba en la entrega 13.

## Integración y validación

Al cambiar el script del sprite, se perdía la orientación inicial: corregido conservando `facing` en NPC y TrainerNPC. La regresión sobre las 45 instancias fallaba antes y pasa después. Pruebas específicas **9/9**, **4.469 aserciones**; suite completa **556/556**, **51.804 aserciones**, 523,216 s. Arte: **11.110 PNG, 0 errores, 0 avisos**. Datos: **0 errores, 2 avisos previos**. Una ejecución concurrente excedió los límites de tiempo de Ibiza y ROM; repetición completa en verde sin modificar las pruebas. Tras integrar los nuevos hitos y animaciones de main: **9/9** específicas, **4.469 aserciones**; arte **11.389 PNG, 0 errores/avisos** y datos **0 errores, 2 avisos previos**. Publicado en `1569f8e2`.
