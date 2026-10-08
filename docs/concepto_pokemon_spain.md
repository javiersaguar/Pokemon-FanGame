# Pokémon Spain — Concepto

> Decidido por Javier el 2026-10-08: el proyecto pasa a llamarse **Pokémon Spain** (antes, *Pokémon Panchito*). Es un fangame sin ánimo de lucro emparentado con **Pokémon Iberia**, pero puesto al día: **humor negro sobre la situación actual de España**.
> Lo que hay en este documento es la **orientación** y una lista de **ideas de partida**. Cada idea concreta sigue siendo **PENDIENTE JAVIER** hasta que la confirme en el [GDD](GDD.md).

## 1. Qué es

Una aventura Pokémon clásica (al estilo de *Pokémon Añil*, programada desde cero en Godot 4) en una región inspirada en la **España de hoy**: el alquiler, la precariedad, la burocracia, los trenes que no llegan, el turismo masivo y los demás absurdos cotidianos, contados con humor negro. Los entrenadores son los personajes que te cruzas en la calle, en el metro y en la cola del paro.

**Pitch de una frase (propuesta):** *"Hazte con todos… si te llega el sueldo."*

## 2. La referencia: Pokémon Iberia

[Pokémon Iberia](https://backloggd.com/games/pokemon-iberia/) es el fangame español más conocido. Lo hizo **Eric Lostie** con RPG Maker XP y Pokémon Essentials, y se publicó gratis para PC. Ocurre en una versión Pokémon de la península ibérica y se ríe de todos los tópicos de España, con mucho humor adulto y negro.

Javier tiene el juego completo (**V2.10**) en `C:\Users\Javier\Downloads\IBERIA V2.10.zip`, **fuera del repo y solo como referencia**: sirve para inspirarse, no se copian sus archivos al proyecto. Lo legible está en `PBS/*.txt` (clases, entrenadores, objetos, mapa, especies); los diálogos y mapas van dentro de `Data/*.rxdata` (RPG Maker XP). El detalle está en el §5.

Lo que nos sirve de él como referencia de tono y estructura:

| En Pokémon Iberia | Qué nos inspira |
|-------------------|-----------------|
| La región es la península, con ciudades reales (Madrid, Barcelona, Valencia, Sevilla, Ibiza…) parodiadas; el "Pueblo Paleta" es Albacete | Región basada en la España real, con lugares reconocibles |
| La Poké Ball es la **Hacendado Ball**; aparecen Mercadona, el pescaíto frito, Desatranques Jaén | Objetos y tiendas que parodian marcas y costumbres cotidianas |
| El profesor es **Félix Rodríguez de la Fuente** y salen famosos del momento | Personajes públicos y populares como base de NPC |
| **Formas ibéricas** de Pokémon (Ludicolo con paella en vez de piña, Bisharp inspirado en los tercios…) | Formas regionales con chiste |
| 8 gimnasios homologados y un **9.º no homologado** en Lisboa; la Liga en un lugar emblemático | Gimnasios con chiste propio y lugares simbólicos |
| Humor de tópicos, adulto y muy negro | El tono general |

## 3. Lo que actualizamos: la España de ahora

Temas de los que se ríe el juego (ideas de partida, **PENDIENTE JAVIER** cuáles entran y cómo):

- **Vivienda:** alquileres imposibles, pisos turísticos, habitaciones de 8 m² a precio de piso, compartir piso a los 35, la fianza de tres meses, fondos que compran edificios enteros.
- **Trabajo:** sueldos que no llegan a fin de mes, becarios sin sueldo, contratos de una semana, el eterno **opositor**, riders.
- **Burocracia:** la **cita previa** para todo, el formulario que pide otro formulario, la ventanilla que cierra a las 14:00.
- **Transporte:** trenes de Cercanías y Rodalies con retraso, obras eternas, el abono que sube.
- **El apagón:** una zona o una cueva entera sin luz.
- **Turismo masivo:** cruceros, patinetes, "aquí antes vivía gente".
- **España vaciada:** pueblos sin cobertura, sin autobús y sin médico.
- **Precios:** el aceite de oliva como objeto de lujo, la cesta de la compra.
- **Sanidad y listas de espera:** el Centro Pokémon con número y lista de espera (sin que afecte a la jugabilidad: es solo el chiste).
- **Política y tertulias:** políticos, partidos, tertulianos, youtubers y famosos del momento, como hacía Iberia con los de 2019.

### Ideas de contenido (todas PENDIENTE JAVIER)

| Tipo | Ideas |
|------|-------|
| Equipo villano | Un **fondo de inversión** que compra toda la región para convertirla en pisos turísticos ("Equipo Buitre") |
| Pueblo inicial | Un pueblo de la España vaciada: sin cobertura, con un bar y un autobús a la semana |
| Clases de entrenador (además de las que ya hay) | Opositor eterno, Rider, Casero, Agente inmobiliario, Becario, Influencer, Turista de crucero, Revisor de Cercanías, Tertuliano, Jubilado de obras |
| Objetos | Ball Marca Blanca, Cita Previa (objeto clave), Abono Transporte, Tupper de mamá, Aceite de oliva (objeto caro), Fianza |
| Lugares | Estación de Cercanías como mazmorra, urbanización a medio construir, oficina de empleo, piso compartido |
| Formas regionales | Pokémon adaptados a la España de ahora (por definir con el arte) |

## 4. Límites del humor

**No hay líneas rojas** (decisión de Javier, 2026-10-08): es humor y es un proyecto personal. Se puede parodiar a cualquiera, con nombre real si se quiere, como en Iberia. Lo único que se mantiene es lo legal de cualquier fangame: **sin ánimo de lucro** y con el aviso de Nintendo, Game Freak y The Pokémon Company.

## 5. Qué hay en Pokémon Iberia V2.10 (para inspirarse)

Resumen de los datos de texto del juego (`PBS/`). Es **su** contenido: sirve para ver qué funcionó y ponerlo al día, no para copiarlo tal cual.

**Región y recorrido** (`townmap.txt`): región *Iberia*. Se empieza en **Albacete** (laboratorio del profesor Félix) y las rutas llevan nombres de zona: Ruta Manchega, Murciana, Andaluza, Levante, Balear, Catalana, Castellana, Vasca, Cántabra, Gallega, Leonesa, Lusa, Extremeña y Toledana. Lugares con chiste: Aeropuerto de Castellón (con fantasmas), Desierto de Tabernas, Doñana, Cueva de Altamira, Torre de Hércules y la Liga en el **Valle de los Caídos**, cerca de Madrid. Andorra tiene la "Casa de Habilidades" y Gibraltar es una ciudad aparte.

**Gimnasios y niveles de los líderes:** Murcia (16), Sevilla (26), Valencia (34), Barcelona (43), Valladolid (45, dos líderes), Bilbao (49), Santiago de Compostela (55) y Mérida (62). El 9.º, sin homologar, en Lisboa. **Alto Mando:** Cervantes, Agustina de Aragón, Blas de Lezo y Mariana Pineda; también salen Fernando VII y Felipe VI.

**Equipos villanos** (parodias de partidos y movimientos de 2019): *Equipo Talante* (base en Sevilla, jefe González), *Equipo Gaviota* (comandante Rita, jefe Rajoy), *Equip Imparapla* (comandante Artur, "Molt Honorapla" Puigdemont y Pujol), *Comandante Caja* (Abascal) y una **Logia** con maestros y miembros.

**Clases de entrenador** (`trainertypes.txt`): Cani, Choni, Perroflauta, Internauta, Mantero, Guardia Civil, Guiri (y guiris playeros), Pueblerino, Señora, Jornalero, Espetero, Legionario, Influencer, Siestero, Bailaora flamenca, Bético y Sevillista, Nazareno, Niño rata, Cuñao, Hombres de negro, Pandilla de San Fermín, Jubilado, Aizkolari, Peregrino, Abuela, Porquero, Torero, Estudiante y más. Muchos famosos con su nombre real: futbolistas (Iniesta, Xavi, Messi, Cristiano), youtubers (Rubius, Willyrex, TheGrefg, Lolito, Ibai), Íker Jiménez de ufólogo, Torrente de agente, Fernando Alonso de "Pokepiloto", Rafa Nadal, los Gasol, Bunbury, Robe, Nino Bravo, Ibáñez, Don Pelayo, el Quijote y Sancho…

**Objetos propios** (`items.txt`): **Hacendado Ball**, Prototipo Iberoball, Cruzcampo, Rioja y Rioja Extra, Chistorra, Navaja Toledana, Andaluflauta, Estrella Levante, Tabaco (3 tipos), Power Balance, Llave del Congreso, Carné Ciudadano y megapiedras de sus fakemon (Cervantrita, Luxpiravita, Bogaleonita).

**Formas Iberia** (`Typing Formas Iberia.txt`): Entei (Fuego), Gogoat (Planta/Lucha), Alakazam (Psíquico/Siniestro), Jynx (Psíquico/Hada), Ludicolo (Fuego/Acero, con paella), Bisharp (Acero/Lucha, los tercios), Braviary (Volador/Roca), Luxray (Eléctrico/Tierra), Quagsire (Dragón/Agua), Conkeldurr (Lucha/Siniestro), Electrode (Normal/Fuego), Exeggutor (Planta/Hada), Unfezant (Volador/Hada), Probopass (Roca/Fantasma) y Accelgor (Bicho/Lucha). Las entradas de la Pokédex mezclan historia y chiste (el Quagsire que trajo Augusto de Egipto, el de Coria del Río que trajeron los japoneses en 1614…).

**Fakemon:** Racoichi, Calfite, Bullmor → Moltaurus, Babyss → Seadness, Marcifer, Polekin, Fungorse, Cervantrier, Lugnis → Luravit → Luxpiravit, Quisquite, Gambarrel, Bogaleon y Urobos, además de un Unown propio.

### Cómo lo ponemos al día (ideas, todas PENDIENTE JAVIER)

- **Equipos villanos de 2026:** el mismo esquema que Iberia (un equipo por partido o movimiento, con su jefe), pero con la política de ahora, y además el **fondo buitre** que compra la región entera.
- **Famosos de ahora:** los youtubers, streamers, futbolistas, cantantes y tertulianos que estén de moda en 2026 en lugar de los de 2019.
- **Clases nuevas** que Iberia no tenía porque no existían o no eran tema: Rider, Casero, Opositor eterno, Becario, Turista de crucero, Revisor de Cercanías, Agente inmobiliario, Tertuliano.
- **Objetos al día:** la Hacendado Ball como guiño (o una Ball Marca Blanca) más Cita Previa, Abono Transporte, Aceite de oliva a precio de oro, Fianza, Tupper de mamá…
- **Formas regionales y fakemon propios**, con entradas de Pokédex que mezclen historia de España y chiste, como hacía Iberia.

## 6. Nota técnica

Por ahora solo ha cambiado la **documentación**. Algunos identificadores del código conservan el nombre antiguo para no romper partidas, semillas ni herramientas: `data/items_panchito.json`, el prefijo `PANCHITO-` de los códigos de semilla del RandomLocke, las variables `PANCHITO_*` y las rutas de las carpetas (`pokemon-panchito*`, `Pokemon-Panchito-recursos`). Renombrarlos, junto con el título del juego en la pantalla de inicio y en `project.godot`, es una tarea de código aparte.
