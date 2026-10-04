# Seguimiento de arte

Estado de **cada asset visible** del juego (Fase A.7 de la guía). Dueño del archivo: Agente 3; cada agente añade y actualiza las filas de sus assets.

- **Estados:** `placeholder → encargo → silueta → color → animado → integrado → revisado → ✅ final`.
- Un asset solo pasa a **✅ final** con la aprobación de Javier (columna "Aprobado por Javier").
- Los **placeholders** están permitidos durante el desarrollo **solo si están en esta tabla**. Desde la demo `v0.3` no puede quedar ninguno a la vista.
- Licencias de los assets de terceros: `docs/arte/licencias.md`. Créditos: `CREDITOS.md`. Packs descargados: `docs/arte/recursos_terceros.md`.

## Placeholders a la vista

Relleno técnico temporal que hay que sustituir. **Ninguno es arte del juego.**

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|-------|------|-------|--------|-------------------|---------------------|-------|
| Tileset provisional (`assets/tilesets/placeholder/`) | Tileset | A1 | placeholder | Generado por script | — | Se sustituye por los packs 01–04 en los mapas de muestra |
| Personajes y objetos del mapa provisionales (`assets/sprites/characters/placeholder/`) | Personaje en el mapa | A1 | placeholder | Generados por script | — | Se sustituyen por los packs 05 y 13 |
| Efectos de los movimientos (`BattleFx`) | Animación de combate | A3 | placeholder | Dibujados por código | — | Estallido, proyectil y destellos por tipo. Falta un pack de efectos (pregunta en `docs/ESTADO.md`) |
| Sprite de Pokémon de reserva (`PlaceholderArt.pokemon`) | Pokémon en combate | A3 | placeholder | Generado por código | — | **Solo** si a una especie le falta el sprite; con el Generation 9 Pack no sale ninguno |

Ya **no** se ven: las siluetas de entrenador (no se muestra ningún entrenador hasta tener su sprite) ni el fondo dibujado por código.

## Assets de terceros

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|-------|------|-------|--------|-------------------|---------------------|-------|
| **Generation 9 Resource Pack v3.3.8** (`assets/sprites/pokemon/`: `front`, `front_shiny` 192×192; `back`, `back_shiny` 288×288; `icons`, `icons_shiny` 128×64; `followers`, `followers_shiny` 256×256) | Pokémon (combate, iconos y seguidores) | A2 | integrado | Recopilado por Caruban; autores en `CREDITOS.md` ("Pokémon") | ⏳ | **Set oficial del proyecto** (DIRECTRICES §7.1). Los importa `tools/sprites/` solo de las especies en uso, sin reescalar. Shiny oficiales |
| Objeto Poké Ball (`assets/sprites/items/pokeball.png`, 48×48) | Objeto | A3 | integrado | Generation 9 Pack (`Graphics/Items`) | ⏳ | En la ficha del Pokémon (la Ball en la que se capturó) |
| Sombras de Pokémon (`assets/sprites/ui/battle/shadows/`) | Combate | A3 | integrado | Generation 9 Pack (`Graphics/Pokemon/Shadow`) | ⏳ | Bajo el Pokémon rival y en la ficha. Sustituyen a las bases hasta tenerlas |
| Fondo de combate "Field" (`assets/sprites/ui/battle/backgrounds/field.png`, 384×308) | Fondo de combate | A3 | integrado | *ORAS/XY themed battle backgrounds for EBDX*: PhoenixOfLight92 y LackDeJurane | ⏳ | Es un fondo de EBDX (allí se ve ampliado a ×2,25). Aquí, ×2 exacto y encuadrado: **pendiente de Javier** (pregunta). Sin bases |
| Iconos de tipo en español (`assets/sprites/ui/icons/types_spanish.png`, 64×532) | Icono de tipo | A3 | integrado | *Loaky's Modern Type Icons*: Loaky | ⏳ | En los botones de movimiento y en la ficha, a 1:1 |
| *Truth and Ideals* (`assets/fonts/truth_and_ideals/`) | Fuente | A3 | integrado | *Gen 5 Font – Truth and Ideals*: bonzairob | ⏳ | Tamaño 10 en el UiCanvas (= 20 px en pantalla, píxel de 2×2). Tiene ñ, tildes, ü, ¿¡, ♂, ♀ y ★; le faltan €, — y · |
| Pixel Operator (`assets/fonts/`) | Fuente | A3 | sustituido | Jayvee Enaguas, CC0 1.0 | — | Ya no la usa el Theme; se borrará si Javier aprueba *Truth and Ideals* |

## Arte propio

Dibujado a mano píxel a píxel con la paleta maestra en archivos de texto (`assets/_fuentes/ui/*.px`) y exportado con `tools/arte/exportar.gd`. Se dibuja a 1× y se ve a ×2 en un `UiCanvas` (escala entera, vecino más próximo), que en pantalla es lo mismo que exportarlo a ×2.

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|-------|------|-------|--------|-------------------|---------------------|-------|
| Botones Luchar / Mochila / Pokémon / Huir y de movimiento (`ui/battle/button_*.png`) | UI de combate | A3 | animado | Propio | ⏳ | Rojo, amarillo, verde, azul, claro y gris. Foco con contorno que parpadea (blanco/amarillo), sube 1 píxel y se hunde al pulsar |
| Caja de datos (`ui/battle/databox.png`), marco de la barra de PS (`hp_frame.png`) y etiqueta PS (`tag_ps.png`) | UI de combate | A3 | integrado | Propio | ⏳ | El relleno de las barras de PS (verde, amarillo, rojo, "barra fantasma") y experiencia se pinta con colores de la paleta |
| Panel de mensajes (`ui/battle/panel_message.png`) | UI | A3 | integrado | Propio | ⏳ | También en la cabecera y la banda del equipo de la ficha |
| Iconos de estado en español (`ui/icons/status/*.png`) | Icono de estado | A3 | integrado | Propio | ⏳ | El Generation 9 Pack los trae en inglés (SLP, PSN...) |
| Iconos de sexo y estrella de shiny (`ui/icons/`) | Icono | A3 | integrado | Propio | ⏳ | |
| Destello de shiny (`ui/battle/shiny_sparkle.png`, 3 frames) | Animación de combate | A3 | animado | Propio | ⏳ | DIRECTRICES §8. El sonido `shiny` falta (no hay pack de sonidos) |
| Poké Ball de la captura (`ui/battle/ball.png`) | Combate | A3 | integrado | Propio | ⏳ | La sacudida es un movimiento de 1 píxel, sin rotar |
| Cursor y flecha de continuar (`ui/cursor_*.png`) | UI | A3 | animado | Propio | ⏳ | |
| Ficha del Pokémon: ventana, fondo de rayas y cabeceras (`ui/summary/`) | UI | A3 | integrado | Propio | ⏳ | |
