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
| Efectos de los movimientos (`BattleFx`) | Animación de combate | A3 | placeholder | Dibujados por código | — | Estallido, proyectil y destellos por tipo. Falta un pack de efectos (pregunta en `docs/ESTADO.md`) |
| Sprite de Pokémon de reserva (`PlaceholderArt.pokemon`) | Pokémon en combate | A3 | placeholder | Generado por código | — | **Solo** si a una especie le falta el sprite; con el Generation 9 Pack no sale ninguno |
| Protagonista provisional (Ethan y Lyra del pack 05) | Personaje en el mapa | A4 | integrado | PurpleZaffre, pack 05 | — | Provisional hasta el diseño del protagonista de Panchito (pack 11) |

Ya **no** se ven: las siluetas de entrenador (no se muestra ningún entrenador hasta tener su sprite) ni el fondo dibujado por código.

## Assets de terceros

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|-------|------|-------|--------|-------------------|---------------------|-------|
| Tileset de exteriores (`assets/tilesets/exterior/`: hierba, bosque, caminos, hierba alta, estanque, meseta, bordillo, adoquines, adornos) | Tileset | A4 | integrado | Packs 02 (×2 tal cual) y 01, 03 y 04 (×2 duplicando píxeles); ver CREDITOS.md | ⏳ | Prueba de nivel gráfico: `docs/arte/comparativas/` |
| Casas de HGSS (`casas.png`) | Edificio | A4 | retirado del pueblo | SirMalo, pack 01 | — | Javier: tejados verdeazulados que no encajan con DPPt (respuesta 17). Sustituidas por las casas de DPPt |
| Casas de DPPt (`casas_dppt.png`: roja, azul, azul pequeña, naranja y la de tejado rojo grande) | Edificio | A4 | integrado | Pack 02 | ⏳ | Completas, con su sombra. En el pueblo de muestra v2 |
| Calle de baldosas en espiga (`gen4.png`, filas 27–29) | Tileset | A4 | integrado | Pack 02 | ⏳ | Sustituye a la plaza de círculos y a los adoquines con grietas repetidas |
| Valla de madera (`vallas.png`) | Objeto del mapa | A4 | integrado | SirMalo, pack 01 (×2) | ⏳ | Tramos horizontales; las puntas tapan a quien está detrás |
| Retoque de los verdes de los packs 02, 03 y 04 | Tileset | A4 | integrado | `GREEN_RETOUCH` en `build_exterior.gd` | ⏳ | Hierba con el tono y la viveza de la de Añil (de 85° a 105°, más saturada) |
| Sombra de los personajes y de los Pokémon que te siguen (`effects/sombra.png`) | Efecto | A4 | integrado | Propia, dibujada a mano (`assets/_fuentes/mundo/sombra.px2`) | ⏳ | Elipse de 14×5 píxeles del arte en dos tonos fríos semitransparentes; la integra el Agente 1 |
| Pueblo de muestra v2 (`maps/muestras/pueblo.tscn`) | Mapa | A4 | revisado | Tileset de exteriores | ⏳ | Comparativas `docs/arte/comparativas/pueblo_v2_*.png` |
| Ruta de muestra v2 (`maps/muestras/ruta.tscn`) | Mapa | A4 | revisado | Tileset de exteriores | ⏳ | Tres niveles con escaleras; comparativas `docs/arte/comparativas/ruta_v2_*.png` |
| Vendedor de Chupachups (`trainers/vendedorchupachups.png` 160×160 y `characters/vendedorchupachups.png`) | Entrenador | A4 | integrado | Poltergeist, pack 11 (capas en `assets/sprites/trainers/recetas.json`) | ⏳ | Sombrero de paja, camisa de rayas, pantalón pirata y bolsa. Comparativas `entrenador_vendedorchupachups_*.png` |
| Rival, chico y chica (`trainers/rival.png`, `rival_f.png` y `characters/rival.png`, `rival_f.png`) | Entrenador | A4 | integrado (mapa) | Poltergeist, pack 11 | ⏳ | Provisional hasta que Javier decida el GDD; el rojo es su color. El de combate espera a la petición 41 |
| Profesor (`trainers/profesor.png` y `characters/profesor.png`) | Personaje | A4 | integrado (mapa) | Poltergeist, pack 11 | ⏳ | Provisional: pelo blanco, gafas y gabardina clara como bata. El de combate (para la intro) espera a la petición 41 |
| Clases Panchito, tanda 1: tuno, abuela, jubilado mirando obras, repartidor en bici, turista con chanclas y camarero (`characters/<clase>.png`; combate en `trainers/<clase>.png`) | Entrenador | A4 | integrado (mapa) | Poltergeist, pack 11 | ⏳ | Comparativa `entrenadores_clases_1.png`. Los de combate esperan a la petición 41 |
| Clases Panchito, tanda 2: flautista (chico y chica), peruana de 1,50, robasientos, cuñado, influencer de LinkedIn (chico y chica), estudiante de Ingeniería (chico y chica), opositor (chico y chica), patinetero, tertuliano, revisor del Cercanías (chico y chica), domador de palomas, crossfitero (chico y chica), turista con chanclas (chica) y padre con la tarjeta (`characters/<clase>[_f].png`; combate en `trainers/`) | Entrenador | A4 | integrado (mapa) | Poltergeist, pack 11 | ⏳ | Comparativa `entrenadores_clases_2.png`. Los de combate esperan a la petición 41 |
| Fondo de combate de hierba y bosque (`ui/battle/backgrounds/forest.png`) | Fondo de combate | A4 | integrado | Fondo *Field* del pack 10 (PhoenixOfLight92 y LackDeJurane) + árboles y arbustos del pack 03 (AnonAlpaca) a ×1, con el retoque de verdes; `build_fondos.gd` | ⏳ | Linde de bosque detrás del rival, como el de Añil. Comparativa `combate_fondo_bosque_vs_anil.png`. Faltan las bases de verdad (las de EBDX son suelos enteros, no óvalos) y la versión de noche |
| Árboles y flora (`arboles.png`, `flora.png`) | Tileset | A4 | integrado | AnonAlpaca (+ Magiscarf), packs 03 y 04 | ⏳ | Mayor densidad de detalle que el pack 02 |
| Flores animadas y brillo del agua (`animados.png`) | Tileset animado | A4 | integrado | Pack 02 | ⏳ | 4 y 2 cuadros |
| Personajes del mapa (`assets/sprites/characters/*.png`) | Personaje en el mapa | A4 | integrado | PurpleZaffre, pack 05 | ⏳ | Rival, profesor, enfermera, dependiente y vecinos. Giro al hablar: comparativa `comparativas/npc_interaccion.md` (2026-10-05), pendiente de revisión |
| Efectos del mapa (`assets/sprites/characters/effects/`) | Efecto | A4 | integrado | PurpleZaffre, pack 05 | ⏳ | "!", hierba al pisarla, polvo al saltar, brillo shiny |
| Sombras de los personajes | Efecto | A4 arte / A1 integración | integrado | Dibujada a mano por A4, `sombra.px2` | pendiente revisión | `comparativas/sombras_personajes.md`; Character la hereda también en Follower, queda en el suelo al saltar |
| **Generation 9 Resource Pack v3.3.8** (`assets/sprites/pokemon/`: `front`, `front_shiny` 192×192; `back`, `back_shiny` 288×288; `icons`, `icons_shiny` 128×64; `followers`, `followers_shiny` 256×256) | Pokémon (combate, iconos y seguidores) | A2 | integrado | Recopilado por Caruban; autores en `CREDITOS.md` ("Pokémon") | ⏳ | **Set oficial del proyecto** (DIRECTRICES §7.1). Los importa `tools/sprites/` solo de las especies en uso, sin reescalar. Shiny oficiales |
| Objeto Poké Ball (`assets/sprites/items/pokeball.png`, 48×48) | Objeto | A3 | integrado | Generation 9 Pack (`Graphics/Items`) | ⏳ | En la ficha del Pokémon (la Ball en la que se capturó) |
| Sombras de Pokémon (`assets/sprites/ui/battle/shadows/`) | Combate | A3 | integrado | Generation 9 Pack (`Graphics/Pokemon/Shadow`) | ⏳ | Encima de la base, bajo el rival y en la ficha |
| Fondos de combate del pack 10 (`backgrounds/`: field, forest, cave, city, water, indoor_a, snow, sand) | Fondo de combate | A4 (carpeta) / A3 (escena) | integrado | PhoenixOfLight92 y LackDeJurane | ⏳ | ×2 exacto, aprobado por Javier (respuesta 14). La hierba usa *forest*. Sin árboles: los pone EBDX |
| Iconos de tipo en español (`assets/sprites/ui/icons/types_spanish.png`, 64×532) | Icono de tipo | A3 | integrado | *Loaky's Modern Type Icons*: Loaky | ⏳ | En los botones de movimiento y en la ficha, a 1:1 |
| *Truth and Ideals* (`assets/fonts/truth_and_ideals/`) | Fuente | A3 | integrado | *Gen 5 Font – Truth and Ideals*: bonzairob | ⏳ | Tamaño 10 en el UiCanvas (= 20 px en pantalla, píxel de 2×2). Tiene ñ, tildes, ü, ¿¡, ♂, ♀ y ★; le faltan €, — y · |
| Pixel Operator (`assets/fonts/`) | Fuente | A3 | sustituido | Jayvee Enaguas, CC0 1.0 | — | Ya no la usa el Theme; se borrará si Javier aprueba *Truth and Ideals* |

## Integraciones de mundo (A1)

| Comportamiento | Dueño | Estado | Comparativa | Aprobado por Javier |
|---|---|---|---|---|
| Hojas bici/Surf/pesca del pack 05, comportamiento en Player/FieldEncounters | A4 arte / A1 integración | integrado; objeto de Surf pendiente | `comparativas/transporte.md` | pendiente revisión de integración |
| Tinte día/noche del canvas del mundo, Clock real | A1 | integrado, colores provisionales | `comparativas/dia_noche.md` | pendiente revisión; luces/clima esperan arte/audio |
| Alternar carrera con R/Y, hoja de correr pack 05 existente | A1 | integrado | `comparativas/correr_alternar.md` | orden 1b; aviso/opción pendientes A3 |
| Flujo inicial/ranuras/pausa y entrada de nombres con Theme/cuadro A3 existentes | A1 | placeholder de integración | `comparativas/flujo_provisional.md` | pendiente; lo sustituye A3 |
| Recompensa profesor (5 Poké Balls), nombres POR DEFINIR centralizados; usa cuadro de diálogo A3 | A1 | integrado | `comparativas/recompensa_profesor.md` | Cantidad: respuesta 18 del 2026-10-05; captura pendiente |

## Arte propio

Dibujado a mano píxel a píxel con la paleta maestra en archivos de texto (`assets/_fuentes/ui/*.px`) y exportado con `tools/arte/exportar.gd`. Se dibuja a 1× y se ve a ×2 en un `UiCanvas` (escala entera, vecino más próximo), que en pantalla es lo mismo que exportarlo a ×2.

| Asset | Tipo | Dueño | Estado | Fuente / licencia | Aprobado por Javier | Notas |
|-------|------|-------|--------|-------------------|---------------------|-------|
| Botones Luchar / Mochila / Pokémon / Huir y de movimiento (`ui/battle/button_*.png`) | UI de combate | A3 | animado | Propio | ⏳ | Respuesta 12: borde oscuro, luz arriba a la izquierda y sombra de 2 px abajo. Foco que parpadea y se hunde al pulsar |
| Base provisional de combate (`ui/battle/bases/default.png`) | Base de combate | A3 | integrado | Propio | ⏳ | Óvalo de hierba. El Agente 4 la sustituye con `bases/<entorno>.png` cuando llegue EBDX |
| Caja de datos (`ui/battle/databox.png`), marco de la barra de PS (`hp_frame.png`) y etiqueta PS (`tag_ps.png`) | UI de combate | A3 | integrado | Propio | ⏳ | El relleno de las barras de PS (verde, amarillo, rojo, "barra fantasma") y experiencia se pinta con colores de la paleta |
| Panel de mensajes (`ui/battle/panel_message.png`) | UI | A3 | integrado | Propio | ⏳ | También en la cabecera y la banda del equipo de la ficha |
| Iconos de estado en español (`ui/icons/status/*.png`) | Icono de estado | A3 | integrado | Propio | ⏳ | El Generation 9 Pack los trae en inglés (SLP, PSN...) |
| Iconos de sexo y estrella de shiny (`ui/icons/`) | Icono | A3 | integrado | Propio | ⏳ | |
| Destello de shiny (`ui/battle/shiny_sparkle.png`, 3 frames) | Animación de combate | A3 | animado | Propio | ⏳ | DIRECTRICES §8. El sonido `shiny` falta (no hay pack de sonidos) |
| Poké Ball de la captura (`ui/battle/ball.png`) | Combate | A3 | integrado | Propio | ⏳ | La sacudida es un movimiento de 1 píxel, sin rotar |
| Cursor y flecha de continuar (`ui/cursor_*.png`) | UI | A3 | animado | Propio | ⏳ | |
| Ficha del Pokémon: ventana, fondo saturado, cabeceras amarillas e iconos de pestaña (`ui/summary/`) | UI | A3 | integrado | Propio | ⏳ | Respuesta de Javier: sin gris dominante, sprite más grande, encuentro, naturaleza y carácter. Comparativa `datos_lado_a_lado.png` |
| Símbolo del dinero `₽` (`assets/fonts/pokedolar/`, fuentes `assets/_fuentes/fuentes/pokedolar*.px`) | Glifo de fuente | A3 | integrado | Propio | ⏳ | *Truth and Ideals* no lo trae (petición 11). Una P con dos barras en el palo, con el trazo de 1 px y la altura de las mayúsculas de cada fuente (6×10 la normal, 4×7 la pequeña). Va como fuente de respaldo del Theme, así que sale en cualquier texto con `₽` |

| 2026-10-05 | A1 | Flujo provisional RandomLocke y zona/mote con Theme/Dialogue existentes | `comparativas/randomlocke_flujo.md` | Pendiente revisión; A3 sustituye pantallas |
