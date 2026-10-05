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
- **Los packs ya vienen preparados para 512×384** (`docs/arte/recursos_terceros.md`): un píxel de su arte son 2×2 píxeles de pantalla. **Se usan a 1:1, sin reescalar**: tiles de 32, personajes en cuadros de 64, Pokémon de frente a 192 y de espalda a 288 (más grandes a propósito, por la perspectiva).
- **El arte propio se dibuja a la mitad** (a 16 px por casilla, con la paleta maestra) para que su píxel sea igual de gordo que el de los packs:
  - Tiles y personajes propios: se **exportan a ×2** con vecino más próximo (así lo pide la guía).
  - Interfaz propia (paneles, botones, iconos): se maqueta en un **`UiCanvas`** de 256×192 que se ve a ×2 (escala entera, vecino más próximo). En pantalla es idéntico a exportarla a ×2, y permite maquetar en píxeles del arte.
- **Detalle a 1×** (un píxel de pantalla) **solo** en: la línea de luz de las barras de PS y experiencia y, si hace falta, textos muy pequeños. En ningún otro sitio.
- Dentro de una misma capa **no se mezclan escalas**: lo de los packs va a 1:1 en la capa del mundo o con escala 0,5 dentro del `UiCanvas` (iconos de tipo, Poké Ball, sombras, sprites de la ficha); lo propio va en el `UiCanvas`.
- Las posiciones del arte de los packs se redondean a **píxeles pares** de pantalla (su píxel es de 2×2).

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

**Tamaños de archivo tal como vienen los packs** (Fase A.2 de la guía), en píxeles de pantalla. Los comprueba `tools/arte/validar.gd` (`tools/arte/reglas.json`).

| Asset | Tamaño del archivo | De dónde sale |
|-------|--------------------|---------------|
| Tile | 32×32 (hojas en múltiplos de 32) | Packs 01–04 |
| Personaje en el mapa | Hoja de 256×256 = 4×4 cuadros de 64 | Packs 05, 11 y 13 |
| Efecto del mapa ("!", hierba, polvo, destellos) y objetos del suelo | Cuadros de 32×32 | Pack 05 |
| Pokémon de frente | 192×192 (normal, shiny y `_female` donde exista) | Generation 9 Pack |
| Pokémon de espalda | 288×288 (ídem) | Generation 9 Pack |
| Icono de Pokémon | 128×64 = 2 cuadros de 64 (normal y shiny); los Pokémon grandes, 2 cuadros cuadrados mayores (160×80) | Generation 9 Pack |
| Pokémon que te sigue | Hoja de 256×256 = 4×4 cuadros de 64 (normal y shiny); los Pokémon grandes, 4×4 cuadros mayores (280, 320 o 512 de lado) | Generation 9 Pack |
| Entrenador en combate | **Frente 160×160**; espalda en tira de cuadros de 175×196 (lanzamiento) | Pack 11 (clases Panchito montadas con sus piezas) |
| Objeto | **48×48** | Generation 9 Pack y pack 15 |
| Iconos de tipo | 64×28 cada uno, en la tira `types_spanish.png` (64×532) | Pack 09 (Loaky, en español) |
| Iconos de estado | Propios: cápsula de 22×9 con la abreviatura en español (`PAR`, `QUE`, `ENV`, `DOR`, `CON`), a ×2 | Los del Generation 9 Pack están en inglés |
| Fondo de combate | 384×308 (fondos de EBDX) | Pack 10. Ver §5.1 |
| Sombra de Pokémon | 72×16, 100×20 o 136×24 | Generation 9 Pack |
| Retrato de diálogo | 128×128 (64×64 de arte a ×2) | Propio, solo personajes importantes |

### 5.1 Fondos de combate

Los fondos del pack 10 miden 384×308. Javier (respuesta 14) aceptó verlos a **×2 exacto** y encuadrados en el horizonte hasta que llegue *Elite Battle: DX* completo. El pack no trae árboles ni bases: la hierba usa el fondo *Forest* (el verde más cercano a Añil) y, debajo de cada Pokémon, un óvalo propio provisional (`assets/sprites/ui/battle/bases/default.png`). Las bases de EBDX las deja el Agente 4 en esa carpeta, con el nombre del entorno (`forest.png`, `cave.png`...): si el archivo existe, sustituye a la provisional sin tocar la escena.

---

## 6. Tipografía

- **Fuente: *Truth and Ideals*** (pack 08, la de Negro/Blanco), sin antialiasing: su píxel es de 1 px a tamaño 10.
- Tamaños fijos, dentro del `UiCanvas` (se ven al doble):

| Uso | Archivo y tamaño | En pantalla |
|-----|------------------|-------------|
| Texto normal (diálogo, menús, nombres) | `TruthAndIdeals-Normal.ttf` a **10** | 20 px, píxel de 2×2 |
| Texto pequeño (nivel, PS en número, etiquetas) | `TruthAndIdeals-SmallTruths-Normal.ttf` a **10** | ídem |

- Tiene ñ, tildes, ü, ¿, ¡, «», º, ª, ♂, ♀ y ★. **Le faltan** €, — (raya) y · (punto medio): no se usan en los textos.
- **Dinero: `₽`.** La fuente tampoco lo trae: está dibujado a mano (`assets/_fuentes/fuentes/pokedolar*.px`, una P con dos barras en el palo) como fuente bitmap de respaldo del Theme (`assets/fonts/pokedolar/`). Se escribe `₽` en el texto y sale con el color y la sombra del resto. Captura: `docs/arte/comparativas/dinero_pokedolar.png`.
- Colores: texto oscuro `ui_2` con sombra `ui_5` sobre paneles claros; texto claro `ui_6` con sombra `ui_2` sobre paneles oscuros. La sombra va 1 píxel de arte abajo a la derecha.

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

1. **Packs de la comunidad ya descargados por Javier** (`docs/arte/recursos_terceros.md`), copiados al repo **solo** los archivos que se usan, sin reescalar, con su fila en `docs/arte/licencias.md` y `CREDITOS.md`. Set oficial de Pokémon: **Generation 9 Pack**.
2. **Arte propio hecho a mano** con esta biblia para lo que no existe: interfaz, protagonistas, **clases Panchito** (con las piezas editables del pack 11), logo, medallas, **objetos Panchito** y lugares únicos. Se dibuja píxel a píxel con la paleta; la interfaz, en archivos de texto `assets/_fuentes/ui/*.px` que exporta `tools/arte/exportar.gd` (cada píxel elegido a mano: no es arte generado por algoritmo).
3. **Nunca**: mezclar sets de estilos distintos, reescalar sprites de otros juegos, usar imágenes generadas automáticamente ni **generar shinies cambiando el tono**.

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

- **Validador** (`tools/arte/validar.gd`, reglas en `tools/arte/reglas.json`): falla si un PNG de `assets/` no tiene el **tamaño del pack** (§5) o, si es arte propio, usa **colores fuera de la paleta**. Los packs (tilesets, personajes del mapa, Pokémon, objetos, fondos y tipos) solo se comprueban en tamaño. Los archivos que el pack trae con un tamaño raro van en `pack_exceptions` con el motivo y solo avisan. Se pasa antes de cada merge de arte y además es un test (`tests/ui/test_arte.gd`): `main` tiene que quedar con **0 errores**.
- **Exportador** del arte propio (`tools/arte/exportar.gd`) y **paleta** (`tools/arte/paleta.gd`).
- **Comparativas**: capturas a 512×384, lado a lado con las referencias de Añil, en `docs/arte/comparativas/`.

---

## 12. Decisiones pendientes de Javier

| # | Decisión | Propuesta |
|---|----------|-----------|
| 1 | Aprobar esta biblia | — |
| 2 | Paleta maestra | La de `assets/arte/paleta.json` |
| 3 | Fuente | *Truth and Ideals* (§6) |
| 4 | Encuadre de los fondos de combate | ×2 exacto (§5.1) |
| 5 | Tono visual de lo propio (UI, clases, logo) | Cálido y de verbena (sección 1) |
| 6 | Lienzo del entrenador en combate | 160×160, el del pack 11 |
