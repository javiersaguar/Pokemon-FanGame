# Calle de la Victoria · traspaso del Agente 3

Estado a 2026-10-10: **bloqueada, sin mapa jugable**. El encargo de esta sesión dice: «Los interiores están bloqueados (no hay tileset): las puertas todavía no llevan a ningún sitio». La ficha de rutas propone una calle corta en superficie y un recorrido largo bajo tierra, con cloacas y túneles del Metro; esa propuesta todavía necesita definición y recursos de interior.

Lo publicado establece Sol → Calle de la Victoria → Palacio Real, con ocho medallas para acceder a la Liga y niveles regionales 54–58. No se han publicado salas, puzzles, encuentros, entrenadores, recompensas ni condiciones de avance del recorrido.

## Exterior existente

- En `madrid/centro`, el cartel `CartelVictoria` está en (47, 36), junto a Sol. Señala la calle y las ocho medallas.
- En `madrid/palacio_real`, `CartelPalacio` está en (20, 32); los guardias de la fachada sur explican la llegada por la Calle de la Victoria.
- La conexión pública del Arenal ya une ambos barrios. Esa calle es un recorrido urbano y no implementa el acceso al interior de la Liga.
- No hay pasarelas ni destinos ficticios: no existe aún `maps/calle_victoria/`. F9 permite revisar los dos exteriores reales.

## Para continuar

1. Javier define o aprueba el recorrido subterráneo propuesto: salas, accesos, puzzles y encuentros. La duda queda en «Preguntas para Javier».
2. Disponer de tileset de interiores adecuado para el Metro/cloacas y documentar licencias/paleta. No sustituirlo por suelo de ciudad presentado como mazmorra terminada.
3. Reservar el mapa nuevo y los dos exteriores antes de tocarlos. La excepción de propiedad permite editar los pintores de Madrid centro y Palacio **solo para las bocas**.
4. Pintar el recorrido y registrar sus datos por ID en DataDB. Diseñar el control de ocho medallas junto al dueño del mundo; los carteles actuales no son una comprobación de acceso.
5. Conectar ambos extremos cuando existan: idas/vueltas y llegadas pisables, sin cerrar la calle pública del Arenal.
6. Validar alcance, datos, arte, suite completa y capturas reales 512×384 con comparativa; integrar y subir main.

No se han elegido ni colocado personajes famosos, ni se ha inventado un guion de la Liga.
