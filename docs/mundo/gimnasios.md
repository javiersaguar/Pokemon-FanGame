# Gimnasios de Pokémon Spain

> **Decisión de Javier:** los ocho líderes, su orden y su sitio (`data/region.json`). **Propuesta** (todo lo demás, para que Javier lo retoque): tipo, medalla, entrenadores, reto del interior y premio.
>
> Datos: `data/gimnasios.json` (gimnasio, medalla, nivel tope y entrenadores), `data/trainers/liga.json` (líderes) y `data/trainers/gimnasios.json` (entrenadores). Dónde está cada uno: `data/personajes_en_el_mapa.json`. Los diálogos para retocar, en [`guion.md`](guion.md).

## Cómo funciona ya en el juego

- **El líder entrega la medalla** al ganarle (`src/events/gym_leader_event.gd`): suena el jingle, sale "¡Has conseguido la Medalla X del gimnasio de Y!" y la medalla se guarda en la partida (`GameState.add_badge`). El estuche de la ficha de entrenador ya enseña su nombre.
- **Mientras no haya interiores**, cada líder espera **a la puerta de su gimnasio** y sus tres entrenadores, delante, en fila (te ven a 3 casillas). Cuando el interior esté hecho, basta con cambiar su `mapa` y su `cerca` en `data/personajes_en_el_mapa.json` y pasar `maps/_tools/colocar_personajes.gd`.
- Las puertas y los interiores los hace quien lleva los interiores; aquí va el diseño de cada uno para cuando se pinte.

## Resumen

| # | Ciudad | Sitio | Líder | Tipo | Medalla | Nivel tope | Dónde está ahora |
|---|--------|-------|-------|------|---------|------------|------------------|
| 1 | Madrid | Real Casa de Correos (Sol), con el ático de Ayuso | Isabel Díaz Ayuso | Fuego | **Medalla Libertad** | 15 | `madrid/centro`, a la puerta de Correos |
| 2 | Barcelona | Spotify Camp Nou (en obras) | Joan Laporta | Acero | **Medalla Palanca** | 22 | `barcelona/les_corts`, delante del estadio |
| 3 | Valencia | Discoteca Akuarela Playa | Labrador | Lucha | **Medalla Tirantes** | 28 | `valencia/malvarrosa`, a la puerta de Akuarela |
| 4 | Sevilla | El club de la comedia (Triana) | Joaquín Sánchez | Planta | **Medalla Arte** | 34 | `sevilla/rio`, a la puerta del club |
| 5 | Las Palmas | Concierto en la playa (Playa del Inglés) | Quevedo | Agua | **Medalla Quédate** | 40 | `playa_del_ingles/exterior`, delante del escenario |
| 6 | Bilbao | San Mamés | La chica del *Aupa Athletic* | Lucha/Fuego | **Medalla Txapela** | 45 | pendiente: Bilbao sin pintar |
| 7 | Valladolid | Plaza Mayor | Juanmi Latasa | Hielo | **Medalla Pucela** | 49 | `valladolid/exterior`, en el centro de la plaza |
| 8 | Málaga | El rodaje de otra película | Antonio Banderas | Siniestro | **Medalla Zorro** | 54 | `malaga/exterior`, en el rodaje |

## 1 · Madrid — Ayuso (Fuego) · Medalla Libertad

- **El interior:** la Real Casa de Correos por dentro, con el ático de Ayuso arriba del todo. **Reto:** tres salas-terraza; en cada una hay que "pagar la caña" (hablar con el camarero) para que se abra la siguiente puerta. Si te sientas en una mesa sin pedir, el camarero te echa a la entrada. El reloj de las campanadas marca cuánto falta para que se cierre la terraza (decorativo).
- **Entrenadores:** Borja (padre con la tarjeta: Growlithe y Houndour), Paco (camarero: Litleo y Ponyta) y Cayetana (influencer de LinkedIn: Fletchling y Charcadet).
- **Líder:** Growlithe, Litleo y **Arcanine** (14).
- **Premio propuesto:** la MT de Ascuas o de Colmillo Ígneo, y que las tiendas de Madrid vendan sin IVA (broma: el precio sube igual).

## 2 · Barcelona — Laporta (Acero) · Medalla Palanca

- **El interior:** el Spotify Camp Nou en obras: andamios, grúas y medio graderío. **Reto:** "las palancas": cada palanca que activas abre un tramo de pasarela y cierra otro (y en la pantalla del videomarcador se lee cuánto dinero se ha "vendido" del futuro). Si las activas todas, el estadio queda abierto… al 40 % de aforo.
- **Entrenadores:** Jordi (tertuliano culé: Magnemite y Bronzor), Pau (carterista de la Rambla: Pawniard y Klink) y Montse (revisora de Rodalies: Tinkatink y Klefki).
- **Líder:** Magnemite, Bronzor, Klefki y **Copperajah** (21).
- **Premio propuesto:** la MT de Cabeza de Hierro; y Laporta te ofrece "un contrato a diez años, pagado en 2040".

## 3 · Valencia — Labrador (Lucha) · Medalla Tirantes

- **El interior:** la pista de Akuarela Playa: focos, luces de colores y una piscina. **Reto:** el suelo de la pista se ilumina a ritmo; solo se puede pisar la baldosa encendida (un puzle de casillas que cambian con cada paso). Al fondo, el reservado VIP con Labrador haciendo flexiones.
- **Entrenadores:** Vicent (crossfitero: Machop y Timburr), Rubén (tronista: Mankey y Makuhita) y Nerea (raver: Pawmo y Riolu).
- **Líder:** Mankey, Hariyama, Pawmot y **Machamp** (27).
- **Premio propuesto:** la MT de Demolición; y un bono de 10 sesiones de bronceado.

## 4 · Sevilla — Joaquín (Planta) · Medalla Arte

- **El interior:** un club de la comedia con escenario, mesas y un micrófono. **Reto:** antes de cada entrenador, un monologuista cuenta un chiste y te pregunta si te ha hecho gracia; si contestas "no", el público te abuchea y combates igual; si contestas "sí", te deja pasar por el atajo. Joaquín sale al escenario cuando llegas al final.
- **Entrenadores:** Manolo (cuñado: Gloom y Steenee), Lola (flamenca: Sunflora y Dolliv) y Curro (costalero: Skiddo y Petilil).
- **Líder:** Sunflora, Lilligant, Tsareena y **Meowscarada** (33).
- **Premio propuesto:** la MT de Gigadrenado; y un chiste del Betis cada vez que vuelvas.

## 5 · Las Palmas — Quevedo (Agua) · Medalla Quédate

- **El interior (o el exterior, de noche):** el concierto en la arena de Playa del Inglés, con el escenario, la fila de fans y el mar. **Reto:** llegar a primera fila entre el público; los fans se mueven cuando cambia la canción y hay que esperar el hueco. Las olas tapan parte del camino con la marea (dos estados del mapa).
- **Entrenadores:** Saray (fan de Quevedo: Pelipper y Mantine), Yeray (surfista: Floatzel y Wishiwashi) y Airam (nadador: Lanturn y Barraskewda).
- **Líder:** Wishiwashi, Lanturn, Barraskewda y **Palafin** (39).
- **Premio propuesto:** la MT de Hidropulso; y una entrada de pista para el siguiente concierto (agotada).

## 6 · Bilbao — La chica del *Aupa Athletic* (Lucha/Fuego) · Medalla Txapela

- **Pendiente de Javier:** quién es exactamente. Bilbao aún no está pintado (Agente 2).
- **El interior:** San Mamés, con el césped y la grada. **Reto:** "herri kirolak" (deporte rural): mover piedras (Fuerza) para abrir paso, como un *harrijasotzaile*. Antes de la líder, Nico e Iñaki Williams desafían en combate doble.
- **Entrenadores:** Aitor (crossfitero: Hawlucha y Scrafty), Iñaki (tertuliano: Emboar y Machoke) y Josu (camarero de pintxos: Blaziken y Lucario).
- **Líder:** Pignite, Hawlucha, Blaziken e **Infernape** (44).
- **Premio propuesto:** la MT de A Bocajarro; y una txapela (objeto clave decorativo).

## 7 · Valladolid — Latasa (Hielo) · Medalla Pucela

- **El interior:** la propia Plaza Mayor, de noche y helada (el gimnasio es al aire libre). **Reto:** el suelo de la plaza es hielo: patinas hasta chocar con una farola, un banco o un entrenador. Las tres estatuas te dicen qué columna de soportales lleva a Latasa.
- **Entrenadores:** Álvaro (esquiador: Glalie y Piloswine), Sergio (opositor eterno: Cetitan y Arctibax) y Elena (montañera: Abomasnow y Avalugg).
- **Líder:** Cetitan, Glalie, Avalugg y **Baxcalibur** (48).
- **Premio propuesto:** la MT de Rayo Hielo; y un lechazo para el camino (cura como una Hiperpoción).

## 8 · Málaga — Banderas (Siniestro) · Medalla Zorro

- **El interior:** el plató del rodaje: decorados de cartón, focos, la claqueta y el camerino. **Reto:** escenas: cada sala es un decorado distinto (el Oeste, la Semana Santa, un palacio) y hay que entrar por la puerta que dice el guion (que cambia cada vez que un extra se equivoca). Mario Casas está en el rodaje y combate si le hablas.
- **Entrenadores:** Brian (turista extra: Mightyena y Liepard), Marta (productora: Honchkrow y Krookodile) y Antonio (catering: Weavile y Bisharp).
- **Líder:** Sneasel, Absol, Hydreigon y **Zoroark** (53).
- **Premio propuesto:** la MT de Juego Sucio; y una capa del Zorro (decorativa).

## Personajes en su sitio

Están en `data/personajes_en_el_mapa.json` ("colocados", con su casilla) y salen al cargar el mapa (`CharacterPlacements`, sin tocar los mapas pintados). Los que van en pareja combaten en doble (`pareja`). Los que no se pueden colocar todavía están en "pendientes" con el motivo: Bilbao (la líder 6, los Williams y sus entrenadores), la Ruta 17 (ElXokas, Amancio Ortega), la Ruta 18 (Melendi), Alicante (Topuria) y la historia (Pedro Sánchez, Ábalos, Koldo, Leire Díez, la Liga, Felipe VI y los reclutas del Clan).

Para mover a alguien: cambia su `mapa` o su `cerca` y pasa `godot --headless --path . -s res://maps/_tools/colocar_personajes.gd`, que busca la casilla libre y alcanzable más cercana sin tapar puertas, pasarelas ni pasillos.
