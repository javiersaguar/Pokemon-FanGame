# Pokémon Spain — Concepto

> Decidido por Javier el 2026-10-08: el proyecto pasa a llamarse **Pokémon Spain** (antes, *Pokémon Panchito*). Es un fangame sin ánimo de lucro emparentado con **Pokémon Iberia**, pero puesto al día: **humor negro sobre la situación actual de España**.
> Lo que hay en este documento es la **orientación** y una lista de **ideas de partida**. Cada idea concreta sigue siendo **PENDIENTE JAVIER** hasta que la confirme en el [GDD](GDD.md).

## 1. Qué es

Una aventura Pokémon clásica (al estilo de *Pokémon Añil*, programada desde cero en Godot 4) en una región inspirada en la **España de hoy**: el alquiler, la precariedad, la burocracia, los trenes que no llegan, el turismo masivo y los demás absurdos cotidianos, contados con humor negro. Los entrenadores son los personajes que te cruzas en la calle, en el metro y en la cola del paro.

**Pitch de una frase (propuesta):** *"Hazte con todos… si te llega el sueldo."*

## 2. La referencia: Pokémon Iberia

[Pokémon Iberia](https://backloggd.com/games/pokemon-iberia/) es el fangame español más conocido. Lo hizo **Eric Lostie** con RPG Maker XP y Pokémon Essentials, y se publicó gratis para PC. Ocurre en una versión Pokémon de la península ibérica y se ríe de todos los tópicos de España, con mucho humor adulto y negro.

Lo que nos sirve de él **como referencia de tono y estructura** (no copiamos textos, mapas, gráficos ni personajes suyos):

| En Pokémon Iberia | Qué nos inspira |
|-------------------|-----------------|
| La región es la península, con ciudades reales (Madrid, Barcelona, Valencia, Sevilla, Ibiza…) parodiadas; el "Pueblo Paleta" es Albacete | Región basada en la España real, con lugares reconocibles |
| La Poké Ball es la **Hacendado Ball**; aparecen Mercadona, el pescaíto frito, Desatranques Jaén | Objetos y tiendas que parodian marcas y costumbres cotidianas |
| El profesor es **Félix Rodríguez de la Fuente** y salen famosos del momento | Personajes públicos y populares como base de NPC |
| **Formas ibéricas** de Pokémon (Ludicolo con paella en vez de piña, Bisharp inspirado en los tercios…) | Formas regionales con chiste |
| 8 gimnasios homologados y un **9.º no homologado** en Lisboa; la Liga en un lugar emblemático | Gimnasios con chiste propio y lugares simbólicos |
| Humor de tópicos, adulto y muy negro | El tono general |

**Lo que no repetimos:** parte del humor de Iberia se apoyaba en estereotipos de colectivos (etnia, sexo…) y le costó polémicas y cambios de chistes. En Pokémon Spain el humor negro apunta a **situaciones, instituciones y poderosos**, no a colectivos (ver §4).

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
- **Política y tertulias:** siempre como parodia genérica de cargos, partidos y tertulianos.

### Ideas de contenido (todas PENDIENTE JAVIER)

| Tipo | Ideas |
|------|-------|
| Equipo villano | Un **fondo de inversión** que compra toda la región para convertirla en pisos turísticos ("Equipo Buitre") |
| Pueblo inicial | Un pueblo de la España vaciada: sin cobertura, con un bar y un autobús a la semana |
| Clases de entrenador (además de las que ya hay) | Opositor eterno, Rider, Casero, Agente inmobiliario, Becario, Influencer, Turista de crucero, Revisor de Cercanías, Tertuliano, Jubilado de obras |
| Objetos | Ball Marca Blanca, Cita Previa (objeto clave), Abono Transporte, Tupper de mamá, Aceite de oliva (objeto caro), Fianza |
| Lugares | Estación de Cercanías como mazmorra, urbanización a medio construir, oficina de empleo, piso compartido |
| Formas regionales | Pokémon adaptados a la España de ahora (por definir con el arte) |

## 4. Líneas rojas (propuesta para que la confirme Javier)

1. El humor negro va contra **situaciones, instituciones y poderosos**, no contra colectivos por su origen, etnia, religión, sexo, orientación o identidad.
2. **No se burla de las víctimas** de tragedias reales recientes (DANA, incendios, accidentes): se puede satirizar la gestión, no a quien lo sufrió.
3. **Nada de personas privadas reales.** Los personajes públicos, mejor como **parodia con otro nombre** (**PENDIENTE JAVIER**: ¿nombres reales como en Iberia o parodias?).
4. Sigue siendo un **fangame sin ánimo de lucro**, con el aviso legal de Nintendo, Game Freak y The Pokémon Company.

## 5. Nota técnica

Por ahora solo ha cambiado la **documentación**. Algunos identificadores del código conservan el nombre antiguo para no romper partidas, semillas ni herramientas: `data/items_panchito.json`, el prefijo `PANCHITO-` de los códigos de semilla del RandomLocke, las variables `PANCHITO_*` y las rutas de las carpetas (`pokemon-panchito*`, `Pokemon-Panchito-recursos`). Renombrarlos, junto con el título del juego en la pantalla de inicio y en `project.godot`, es una tarea de código aparte.
