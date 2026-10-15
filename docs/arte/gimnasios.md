# Gimnasios por dentro · tileset y pintor (2026-10-15, Agente 3)

Encargo: que cada uno de los ocho gimnasios se vea como su tema (despachos y plenos en Madrid, gradas y vestuarios en Barcelona, discoteca en Valencia…), con el puzle de siempre: hay que ganar a todos los entrenadores de una sala para pasar a la siguiente y al líder. Todo el arte es **PROVISIONAL** hasta que lo apruebe Javier. Comparativas: [`comparativas/gimnasios_2026-10-15.md`](comparativas/gimnasios_2026-10-15.md).

## Tileset: `assets/tilesets/interior/gimnasios/`

`gimnasios.tres` lo monta `build_gimnasios.gd`. **No cambia `interior.tres`** (los interiores de casas y edificios siguen igual).

| Fuente | Archivo | De dónde sale | Se pisa |
|---|---|---|---|
| 0–3 | `../suelos.png`, `../paredes.png`, `../muebles.png`, `../mostradores.png` | Los mismos recortes de `interior.tres` (mismas casillas) | suelos sí; el resto no (los mostradores, terreno `counter`) |
| 4 | `suelos_2.png` | Akizakura16, filas 2048–4447 del PNG original: más suelos y emblemas | sí |
| 5 | `paredes_2.png` | Akizakura16, filas 7008–10239: más paredes (telón, disco, hielo, ladrillo…) y adornos de pared (ventanas, vidriera, pizarras, cuadros, mapas) | no |
| 6 | `alfombras.png` | Akizakura16, filas 10240–12287: alfombras, flechas, baldosas de teletransporte, puertas, escaleras mecánicas, pantallas; postes con cordón y mamparas (filas 48–63) | sí, salvo filas 48–63 |
| 7 | `maquinas.png` | Akizakura16, filas 13440–14335: ordenadores, televisores, máquinas | no |
| 8 | `mesas.png` | Akizakura16, filas 16384–17055: mesas de nueve trozos, manteles, escritorio | no |
| 20… | `propios/<nombre>.png` | **Dibujadas a mano** en `assets/_fuentes/mundo/gim_<nombre>.px2` con la paleta maestra (las exporta `exportar_mundo.gd` a ×2). Número fijo en `propios.json` | choca lo que tiene dibujo, salvo `"pasable": true` |

Mismo PNG público de Akizakura16 que ya usaba el juego (`docs/arte/interiores.md`, SHA-256 comprobado por el script). Recortes a escala original, sin reescalar ni dibujar.

```sh
godot --headless --path . -s res://assets/tilesets/interior/gimnasios/build_gimnasios.gd -- --png=<akizakura16.png>
godot --headless --path . -s res://assets/_fuentes/mundo/exportar_mundo.gd
godot --headless --path . --import
godot --headless --path . -s res://assets/tilesets/interior/gimnasios/build_gimnasios.gd
godot --headless --path . -s res://maps/_pintura/pintar_gimnasios.gd -- <ciudad>
```

Las paredes de Akizakura van en bloques de 8×5 casillas: las tres primeras filas son el borde negro con su reborde (para los lados y el fondo de la sala) y las dos últimas, la cara de la pared con su zócalo. El pintor elige solo la pieza de cada casilla de pared.

## Piezas dibujadas a mano

| Fuente | Pieza | Tamaño | Para |
|---|---|---|---|
| 20 | `rotulo_madrid` | 3×1 (izquierda, centro que se repite, derecha) | placa dorada del rótulo de las salas de Madrid |
| 21 | `bandera_espana` | 1×2 | bandera de España con mástil y peana |
| 22 | `bandera_madrid` | 1×2 | bandera de la Comunidad de Madrid (siete estrellas) |
| 23 | `retrato_rey` | 2×2 | retrato oficial en marco dorado |
| 24 | `retrato_ayuso` | 2×2 | retrato de la presidenta, en su despacho |
| 25 | `escanos` | 3×2 (fila) | pupitre corrido con micrófonos y respaldos rojos |
| 26 | `atril` | 1×2 | atril con micrófono y escudo |
| 27 | `titulo_enmarcado` | 1×1 | título con sello, para la pared del archivo |
| 28 | `trituradora` | 1×1 | trituradora con la papelera llena |
| 29 | `rotulo_barcelona` | 3×1 | placa azul con borde granate (Barcelona) |
| 30 | `taquillas` | 3×2 (fila) | taquillas azules en mueble granate |
| 31 | `banco_vestuario` | 3×1 (fila) | banco corrido de listones |
| 32 | `butacas_cule` | 1×1 (se repite) | dos butacas de grada, azul y granate |
| 33 | `valla_obra` | 2×2 (dos paneles de 1×2) | valla de obra lisa y con cartel de peligro |
| 34 | `palanca` | 1×2 | palanca con su caja de mandos |
| 35 | `escudo_barca` | 2×2 | escudo del club, simplificado |
| 36 | `copa` | 1×1 | copa dorada de asas grandes |
| 37 | `cono` | 1×1 | cono de obra |
| 38 | `andamio` | 2×3 | andamio con dos plataformas |
| 39 | `rotulo_valencia` | 3×1 | placa de neón rosa sobre morado (Valencia) |
| 40 | `pista_luces` | 2×2 (se pisa, se repite) | cuatro baldosas de luz de la pista |
| 41 | `altavoz` | 1×2 | altavoz de discoteca o de concierto |
| 42 | `bola_disco` | 1×1 (por encima) | bola de espejos colgada |
| 43 | `cubata` | 1×1 (encima) | cubata con pajita y limón |
| 44 | `mesa_dj` | 3×2 | cabina del DJ con platos y mesa de mezclas |
| 45 | `tumbona` | 1×2 | tumbona de rayas |
| 46 | `piscina` | 3×3 (recuadro que se estira) | piscina con borde de piedra |
| 47 | `rotulo_sevilla` | 3×1 | placa de terciopelo granate (Sevilla) |
| 48 | `butacas_teatro` | 1×1 (se repite) | dos butacas de teatro rojas |
| 49 | `micro_pie` | 1×2 | micrófono de pie de monologuista |
| 50 | `foco` | 1×2 | foco de escenario en trípode |
| 51 | `guitarra` | 1×2 | guitarra flamenca en su soporte |
| 52 | `espejo_camerino` | 2×2 | espejo de camerino con bombillas |
| 53 | `burro_vestidos` | 2×2 | burro con trajes de flamenca |
| 54 | `cajas_atrezo` | 2×2 | baúles de gira y caja de madera |
| 55 | `borde_escenario` | 3×1 (fila) | borde delantero del escenario |
| 56 | `rotulo_playa` | 3×1 | placa turquesa (Playa del Inglés) |
| 57 | `valla_concierto` | 1×2 (se repite) | valla de seguridad de concierto |
| 58 | `sombrilla_playa` | 2×2 | sombrilla de playa de gajos |
| 59 | `tabla_surf` | 1×2 | tabla de surf de pie |
| 60 | `nevera` | 1×1 | nevera de playa |
| 61 | `bateria` | 2×2 | batería de concierto |
| 62 | `rotulo_bilbao` | 3×1 | placa roja con canto blanco (Bilbao) |
| 63 | `taquillas_athletic` | 3×2 (fila) | taquillas rojas en mueble blanco |
| 64 | `butacas_athletic` | 1×1 (se repite) | butacas de grada roja y blanca |
| 65 | `escudo_athletic` | 2×2 | escudo del club, simplificado |
| 66 | `cesped` | 2×1 (se pisa, se repite) | césped segado a franjas |
| 67 | `porteria` | 3×2 | portería con su red |
| 68 | `rotulo_valladolid` | 3×1 | placa morada (Valladolid) |
| 69 | `columna` | 1×2 | columna de piedra de soportal |
| 70 | `lampara_arana` | 2×1 (por encima) | lámpara de araña dorada |
| 71 | `barandilla_dorada` | 3×1 (fila) | barandilla dorada de palco |
| 72 | `estufa` | 1×1 | estufa de butano |

## Pintor: `maps/_pintura/pintar_gimnasios.gd`

Cada sala de `maps/_pintura/gimnasios_salas.json` lleva tres rejillas del mismo tamaño:

- **`plano`**: `#` pared, `.` suelo del gimnasio, `S` puerta de arriba a la sala siguiente (en la cara de la pared), `E` felpudo de la salida; otras letras, suelos o alfombras de la leyenda.
- **`muebles`**: letras de la leyenda (una pieza de varias casillas se escribe en todas sus casillas; si el bloque es mayor, se repite). Tipos: `pieza`, `nueve` (recuadro estirado), `fila` (izquierda, centro y derecha), `columna`, `baldosa`, `objeto` (del tileset de exteriores) y `propia` (pieza dibujada a mano). `arriba: n` = sus n primeras filas se pintan por encima de los personajes y se pisan (la tapa de un mostrador, la copa de una planta).
- **`encima`** (opcional): lo que va sobre otro mueble (una copa en una vitrina o en una mesa), por encima y sin chocar.
- **`personas`**: `1`–`9` entrenadores (en el orden de la lista), `g h i j` vigilantes y `G H I J` dónde se quedan al apartarse, `n`–`r` personajes que hablan, `x y z` carteles y `@` el líder.

La sala del líder va en `sala_lider`. Cada vigilante tapa el paso hasta que ganas a su entrenador (`hidden_if_flag`); entonces aparece a un lado (`visible_if_flag`) con otra frase. `tests/mundo/test_gimnasios_salas.gd` lo comprueba paso a paso en las 32 salas.

Para revisar una sala con `maps/_tools/alcance.gd` hay que dar por ganados sus entrenadores (`--ganados`; en Madrid, también `--flag=quiron_superado`): sin eso, los vigilantes tapan el paso a propósito.
