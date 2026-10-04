# Biblia de arte de Pokémon Panchito

> Fase A.2 de la guía. **Se cumple en todo lo que se ve en pantalla.** Si algo de aquí choca con `docs/DIRECTRICES.md`, manda la directriz.
> Estado: **propuesta del Agente 3, PENDIENTE de aprobación de Javier.** Lo marcado **PENDIENTE JAVIER** es una decisión suya; el resto es la propuesta por defecto mientras no diga otra cosa.

---

## 1. Norte de estilo

**Listón mínimo:** las 4 capturas de *Pokémon Añil* en `docs/arte/referencias/`. Cualquier pantalla se compara lado a lado con su referencia a la misma escala; si se ve peor, no está terminada (A.1).

| Referencia | Qué tomamos | Qué no |
|------------|-------------|--------|
| **Pokémon Negro/Blanco (5.ª gen)** | Perspectiva de los tiles (vista "de perfil", 3/4), densidad de detalle de 16×16, rampas de color de 4–6 tonos, contornos del color del objeto, sprites de combate de 96×96 animados, personajes del mapa de 32×32 | La UI de la pantalla táctil y su doble pantalla |
| **Pokémon Añil** | El **nivel de acabado**: mundo y sprites a ×2 sobre 512×384, flores y hierba animadas, sombras bajo los personajes, Pokémon que te sigue, fondos de combate con profundidad, cajas de datos con barras de PS y experiencia legibles, botones de acción con un color por opción, paneles con degradado y pestañas con iconos en la pantalla de datos | **Sus gráficos propios** (UI, logos, marcos): son obra de su equipo. Nuestra UI es de diseño propio |

**Personalidad Panchito** (para lo que es nuestro: UI, clases, objetos y logo): colores cálidos y saturados de barrio y verbena (naranjas, amarillos, rojos teja, azul cielo), formas redondeadas y algún detalle de humor en los iconos. **PENDIENTE JAVIER:** confirmar el tono visual o pedir otro.

---

## 2. Resolución y escalas (Fase 3.2)

- **Pantalla base: 512×384** (4:3), escalado entero ×2 = 1024×768 o ×3 = 1536×1152.
- **Mundo y sprites a ×2 exacto**: el arte se dibuja a 1× (tiles de 16×16, personajes de 32×32, Pokémon de 96×96) y se ve al doble. En pantalla, un píxel del arte = 2×2 píxeles. Posiciones del mundo y de los sprites siempre en múltiplos de 2 píxeles de pantalla.
- **Interfaz a 512×384 nativo, con "píxel de arte" de 2×2 por defecto**: los paneles, iconos y textos normales se diseñan como si fueran arte a 256×192 mostrado a ×2.
- **Detalle a 1×** (un píxel de pantalla) **solo** en: texto pequeño de datos secundarios, degradados de los paneles, brillo interior de las barras de PS y experiencia, y líneas de luz de 1 px en los bordes de los paneles. En ningún otro sitio.
- Dentro de una misma capa **no se mezclan escalas** (nada de un sprite a ×2 al lado de otro a ×3).

---

## 3. Reglas de píxel

- Sin escalados no enteros, **sin rotar pixel art**, sin antialiasing automático y sin desenfoques.
- Las animaciones que en los juegos oficiales "giran" o "encogen" algo (Poké Ball que se sacude, Pokémon que entra en la Ball) se hacen con **frames dibujados** o con efectos que respetan el píxel (destello blanco, silueta, mosaico, recorte), nunca con `rotation` o `scale` no enteros.
- Filtro de textura `Nearest` siempre. Semitransparencias solo donde sean intencionadas (sombras y destellos).
- **Luz** siempre desde **arriba a la izquierda**.
- **Contornos**: en personajes, objetos y Pokémon propios, contorno oscuro **del color del objeto** (*sel-out*), nunca negro puro. Los tiles de suelo no llevan contorno.
- **Sombras**: elipse bajo personajes y Pokémon que te siguen, de 2 tonos de la rampa del suelo (no negro con transparencia).

---

## 4. Paleta maestra

Archivos: `assets/arte/paleta.gpl` (para Aseprite, LibreSprite o GIMP) y `assets/arte/paleta.png` (muestrario). Se generan con `tools/arte/` a partir de `assets/arte/paleta.json`, que es la fuente.

- **64 colores en 11 rampas por material**, de oscuro a claro, con *hue shifting*: las sombras tiran a tonos fríos (azul o violeta) y las luces a cálidos (amarillo).
- Las clases Panchito, los objetos Panchito, la UI y cualquier tile o sprite propio salen **solo** de esta paleta.
- Los **sets de terceros** conservan su paleta, pero se comprueba que encajen al lado de la nuestra; el validador los trata aparte (sección 11).
- **PENDIENTE JAVIER:** aprobar la paleta propuesta o pedir cambios.

| Rampa | Uso |
|-------|-----|
| `hierba` | Césped, hierba alta, arbustos |
| `agua` | Mar, ríos, charcos, hielo (tonos claros) |
| `piedra` | Rocas, acantilados, cuevas, aceras |
| `tierra` | Caminos, arena, tierra |
| `madera` | Vallas, troncos, muebles, carteles |
| `teja` | Tejados rojos, ladrillo, toldos |
| `pizarra` | Tejados azules, cristales, metro |
| `piel` | Piel de personajes |
| `metal` | Metal, maquinaria, botones |
| `ui` | Neutros de la interfaz: fondos, bordes, texto y sombras |
| `acento` | Rojo, amarillo, verde y azul de los botones de combate y avisos |

---

## 5. Tamaños canónicos

Medidas **en píxeles del arte (1×)**. En pantalla se ven al doble salvo que se diga.

| Asset | Lienzo | Notas |
|-------|--------|-------|
| Tile | 16×16 | Autotiles con todas las variantes del terrain set |
| Personaje en el mapa | 32×32 por frame | Hoja de 4 direcciones × 4 frames (128×128). Variantes de correr, bici, surf y pesca |
| Pokémon en combate | 96×96 por frame | Frente y espalda, normal y shiny (colores oficiales). Si el set es animado, tira horizontal de frames cuadrados. **Un mismo set para todas las especies** |
| Icono de Pokémon | 32×32 por frame | 2 frames (64×32), también shiny |
| Pokémon que te sigue | 32×32 o 64×64 por frame | 4 direcciones × 4 frames, también shiny |
| Entrenador en combate | **80×80** | El estándar de 5.ª gen. Clases Panchito incluidas. Se ve a 160×160 |
| Objeto | 24×24 | |
| Icono de tipo | 32×14 | Texto del tipo en español sobre su color |
| Icono de estado | 24×8 | `PAR`, `QUE`, `ENV`, `DOR`, `CON` y `KO` |
| Icono de categoría | 28×12 | Físico, especial y estado |
| Icono de sexo | 6×8 | ♂ azul y ♀ rojo (la fuente no los tiene) |
| Fondo de combate | 256×192 + bases | Se ve a 512×384. Versión de día y de noche si es exterior |
| Base de combate | 128×32 (rival) y 160×40 (jugador) | |
| Retrato de diálogo | 64×64 | Solo personajes importantes |
| Panel 9-slice | Esquinas de 4×4 | Bordes y centro repetibles |

Si un set de terceros viene **ya ampliado a ×2** (muchos packs de Essentials lo están), se reduce **exactamente a la mitad** con vecino más próximo al importarlo, para volver a su tamaño original. Nunca otro factor.

---

## 6. Tipografía

- **Fuente principal: Pixel Operator** (CC0, ya en `assets/fonts/`): ñ, tildes, ü, ¿¡, «», € y …; **no** tiene º, ª, ♂ ni ♀ (los dos últimos son iconos, sección 5).
- **Dos tamaños como mucho**, siempre enteros:

| Uso | Fuente y tamaño en pantalla | Escala |
|-----|------------------------------|--------|
| Texto normal (diálogo, menús, nombres) | `PixelOperator.ttf` a **32 px** | ×2 (trazos de 2 px) |
| Texto pequeño (PS en número, nivel, datos secundarios) | `PixelOperator8.ttf` a **16 px** | ×2 |
| Detalle fino (pies de pantalla, versión, notas) | `PixelOperator.ttf` a **16 px** | ×1, solo donde lo permite la sección 2 |

- Colores: texto oscuro `ui_2` con sombra `ui_5` sobre paneles claros; texto claro `ui_6` con sombra `ui_2` sobre paneles oscuros. La sombra va 1 píxel de arte abajo a la derecha.
- **PENDIENTE JAVIER:** ¿Pixel Operator o una fuente con más aire "Pokémon"? Candidatas en la lista de recursos (`docs/arte/recursos.md`); hay que comprobar que tengan ñ, tildes y ¿¡ antes de elegir.

---

## 7. Interfaz: tokens

Todos viven en el `Theme` (`src/ui/theme/main_theme.tres`): **un solo sitio** para cambiar el aspecto de todo.

- **Colores con nombre**: los de la rampa `ui` (`ui_1` el más oscuro … `ui_6` el más claro; en todas las rampas el 1 es el más oscuro) y `acento` (`acento_rojo`, `acento_amarillo`, `acento_verde`, `acento_azul`). En el código nunca se escribe un color suelto.
- **Márgenes y separaciones** en múltiplos de 2 píxeles de arte (4 de pantalla).
- **Paneles 9-slice** (`StyleBoxTexture`) dibujados con la paleta: marco claro (diálogo y menús), marco oscuro translúcido (mensajes de combate) y panel con degradado (pantalla de datos).
- **Estados de botón** dibujados para normal, foco, pulsado y deshabilitado.
- **Colores de los botones de combate**: Luchar `acento_rojo`, Mochila `acento_amarillo`, Pokémon `acento_verde` y Huir `acento_azul` (la convención que reconoce el jugador). La forma y el marco son nuestros.
- **Iconos de tipo**: color de cada tipo en `src/ui/theme/type_colors.json`.

---

## 8. Animación y "juice" (A.5)

| Velocidad | Duración | Uso |
|-----------|----------|-----|
| Rápida | 0,08 s | Cursor, pulsar un botón |
| Normal | 0,15 s | Abrir o cerrar paneles y menús |
| Lenta | 0,3 s | Cambios de pantalla, entrada de cajas de datos |

- Entradas con *ease-out*, salidas con *ease-in*. Rebote leve **solo** en elementos de recompensa (medallas, objetos, captura).
- Ninguna animación bloquea al jugador más de 0,3 s, salvo las cinemáticas. Opción para reducir animaciones y destellos.
- **Combate**: reposo de 1 píxel de arte si el set no está animado, barra de PS con *easing* y "barra fantasma" del daño, destello blanco al recibir un golpe, sacudida en críticos y supereficaces, partículas por tipo hechas con sprites de la paleta, y transiciones de entrada únicas para líder, rival, legendario y Alto Mando.
- **Shiny** (`DIRECTRICES.md` §8): destellos y sonido al aparecer y estrella ★ junto al nombre en todas las pantallas. La ★ es un icono de 7×7 (la fuente no la tiene).

---

## 9. De dónde sale el arte (A.3)

1. **Sets completos y coherentes de la comunidad con permiso de uso.** Lista con enlace, autor y licencia en `docs/arte/recursos.md`; los descarga Javier en `assets/_terceros/` y se apuntan en `docs/arte/licencias.md` y `CREDITOS.md`.
2. **Arte propio hecho a mano** con esta biblia para lo que no existe: protagonistas, clases Panchito, logo, UI, medallas, objetos Panchito y lugares únicos. Fuentes (`.aseprite`, `.psd`) en `assets/_fuentes/`.
3. **Nunca**: mezclar sets de estilos distintos, reescalar sprites de otros juegos a otra resolución, ni usar arte generado por código o imágenes generadas automáticamente.

---

## 10. Proceso pieza a pieza (A.4) y checklist (A.6)

1. **Encargo**: fila en `docs/arte/seguimiento.md` (qué es, dónde se ve, tamaño, referencias y rampas).
2. **Silueta** en negro a 1×: si no se reconoce, no se sigue.
3. **Color** con la paleta.
4. **Animación** con los tiempos de la sección 8.
5. **Integración en el juego real**.
6. **Revisión** con la checklist A.6, a 1× y a la escala de juego, de día y de noche, sobre todos sus fondos y al lado de 3 assets finales vecinos.
7. **Aprobación de Javier** → `✅ final`.

---

## 11. Herramientas (A.8)

- **Validador** (`tools/arte/`): falla si un PNG de `assets/` tiene un **tamaño no canónico** (sección 5) o, si es arte propio, **colores fuera de la paleta**. Los sets de terceros se comprueban solo en tamaño. Se pasa antes de cada merge de arte.
- **Galería**: escena que muestra los assets juntos a escala real.
- **Comparativas**: capturas a la misma escala que las referencias, lado a lado, en `docs/arte/comparativas/`.

---

## 12. Decisiones pendientes de Javier

| # | Decisión | Propuesta |
|---|----------|-----------|
| 1 | Aprobar esta biblia | — |
| 2 | Paleta maestra | La de `assets/arte/paleta.json` |
| 3 | Fuente | Pixel Operator (sección 6) o una candidata de `docs/arte/recursos.md` |
| 4 | Set de sprites de Pokémon | `docs/arte/recursos.md`, sección "Pokémon en combate" |
| 5 | Tono visual de lo propio (UI, clases, logo) | Cálido y de verbena (sección 1) |
| 6 | Lienzo del entrenador en combate | 80×80 (5.ª gen) |
