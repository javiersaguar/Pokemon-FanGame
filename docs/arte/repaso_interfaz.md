# Repaso de interfaz — Agente 3, 2026-10-07

Revisión de las pantallas publicadas a 512×384. Capturas del juego con Godot 4.7.2, sin dibujar ni alterar recursos de arte. Teclado físico y mando ejercitados mediante InputMap; guardados, configuración y capturas usan directorios temporales separados de la partida de Javier.

## Defectos encontrados y corregidos

| Defecto | Corrección y comprobación |
| --- | --- |
| Correr siempre elegido desde el título se perdía al iniciar. | Se aplica al crear partida; continuar conserva el valor guardado. Prueba de crear, guardar y cargar con valores de dispositivo distintos. |
| Textos de teclas y buses aparecían en inglés o con códigos internos. | Flechas/Intro/Espacio/Mayús y música/efectos/melodías/gritos/ambiente en español, conservando los nombres impresos de botones del mando. |
| Opciones no enseñaba los controles reales. | Pantalla Controles desde Opciones; teclas/botones leídos de InputMap, ayuda de nombres. Navegación y retorno desde el menú anidado con teclado/mando. |
| Ficha: valores largos podían invadir el borde y faltaban movimientos/cintas. | Columnas acotadas, nombre dentro del marco; C/Start abre textos completos, descripción y PP de movimientos y cintas guardadas. El menú superior bloquea navegación de la ficha inferior. |
| Paisaje de la ficha sobrepasaba su ventana. | Recorte del recurso original al tamaño de la ventana, manteniendo píxeles nativos. |
| Sexo, shiny y nivel podían solaparse con nombres largos en combate. | Nombre acotado; indicadores y nivel tienen espacio reservado. El nombre completo permanece en mensajes y ficha. Prueba con mote de 12 letras, shiny, sexo y nivel 100. |
| Resumen del menú inicial invadía la firma inferior. | Cuatro líneas acotadas (nombre, modo/medallas, lugar, tiempo); firma siempre visible. |
| Ayuda de Créditos quedaba debajo del borde. | Ayuda fuera del panel y sobre la firma; panel ajustado. Prueba de límites. |
| Bienvenida del profesor se salía del panel. | Configuración de ajuste/recorte antes de asignar texto, evitando el ancho mínimo calculado con texto sin envolver. Prueba de límites. |
| Generación de ROM también podía sobrepasar su panel. | Etiqueta configurada vacía antes de asignar la explicación; ajuste de línea y prueba de límites. |
| Final de Locke tenía el mismo riesgo con el texto inicial. | Etiqueta vacía configurada antes del contenido, ajuste por palabras y prueba de límites. |
| Aviso de correr se superponía a «Opciones». | Aviso alineado a la derecha de la cabecera, con espacio separado y prueba de límites. |
| La Pokédex no explicaba cómo desplazar descripción ni reproducir grito. | Ayuda incluye Arr/Ab y A junto a forma, color y área. |
| Las MT aparecían en la mochila, pero Usar no enseñaba movimientos. | Delegación a MoveLessons; confirmación y sustitución. Solo se consume al aprender; cancelar/repetir conserva inventario y movimientos. Recordador y tutor tienen entradas para el mundo. |
| Exportar spoilers usaba un archivo único. | API de A2: archivo por código, con confirmación previa. |
| Prueba de cancelar código fallaba ejecutada sola. | Espera de frames de proceso fuera del frame protegido de apertura, sin debilitar la guarda. Repro aislado antes fallaba; después pasa. Petición 60/68. |
| Capturas rápidas terminaban antes de liberar reproducción de audio. | La herramienta libera la escena antes de detener streams y deja completar la limpieza. No cambia reproducción en el juego. |

## Cobertura y resultados

Galería completa en [comparativa del repaso](comparativas/a3_repaso_interfaz.md). Incluye secuencia de arranque/tres logos, título reducido, menú inicial, Créditos, Opciones y sus tres páginas/marcos, Controles, nombres, ranuras, pausa, ficha/detalles, equipo, mochila/objetos/MT, tienda/cantidad, PC, Pokédex/formas/área/shiny, tarjeta, destinos, aprender/recordar/tutor, evolución, introducción, diálogos/elecciones, dobles/objetivos/nombres largos, mecánicas, transiciones/efectos, guardería/eclosión y RandomLocke completo.

`tests/ui/test_ui_audit.gd` comprueba teclado físico y botones reales del mando, menús anidados, bloqueo de nombres obligatorios, cancelación opcional, guardado de correr, límites de texto, confirmación/cancelación de MT y recordador. Se conservan los tests de UI/combate/flujo ya existentes y la cobertura de accesibilidad. Las descripciones largas se recortan por el contenedor desplazable y siguen accesibles con C/Start o Arr/Ab según pantalla; no se reducen sprites para ocultar desbordamientos.

76 capturas revisadas; comprobación de límites de etiquetas sin desbordamientos fuera de pantalla (los textos largos dentro de ScrollContainer conservan desplazamiento).

Validación final, tras integrar las últimas correcciones de A5: **452/452 tests, 8649 aserciones, 122,0 s**. Sin errores de script ni fugas al cerrar la suite. Validador: **10585 PNG, 0 errores y 0 avisos**.

## Pendientes externos

- PENDIENTE JAVIER: aprobación visual final, logo/identidad y música (preguntas 5, 27 y 29). Referencias de Añil se mantienen en la comparativa; este repaso no concede esa aprobación.
- Mapa regional dibujado y ocho medallas propios: pregunta 30 y petición 65. Destinos es una lista de los datos publicados, no el mapa gráfico terminado.
- Guardería persistente/huevos/pasos: petición 66 a A2; presentación lista, entrada de producción pendiente para no perder Pokémon al cargar.
- Torre, regalo misterioso, misiones, logros/estadísticas y modo difícil: petición 67. No se crean pantallas de sistemas cuya API y guardado aún no están publicados.
- Ubicación/catálogo/precios de recordador/tutor (pregunta 31) y disponibilidad de MT: mundo/diseño. Solo la mochila y las entradas con catálogo recibido están conectadas. Cintas se leen por ID guardado hasta que exista catálogo de nombres/arte (petición 69); no se inventan.
- Milcery/sabor: petición 58 de A2 y decisión de Javier; la interfaz no decide un resultado de evolución.

Se conserva la distinción entre pantallas revisadas, integración pendiente y arte pendiente de aprobación; no se declara cerrada v0.1.
