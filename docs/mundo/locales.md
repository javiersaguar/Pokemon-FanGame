# Locales de las ciudades

> **Decisión de Javier:** en las ciudades hay **Mercadona**, **Estanco** y **Basic Fit**. Qué hace cada uno en el juego es **propuesta**.

Los planos de `planos/` marcan con un cuadrado de color **dónde están de verdad** los Mercadona (verde), estancos (amarillo) y Basic-Fit (naranja) de cada ciudad, según OpenStreetMap; sirven para colocarlos en la calle correcta.

| Local | Qué es en el juego (propuesta) | Cómo se ve | Detalles con humor |
|-------|--------------------------------|------------|--------------------|
| **Centro Pokémon** | Lo de siempre: curar, PC y guardar (se mantiene para que el juego se entienda) | Edificio de Centro Pokémon del pack 01 | Cola con número ("Turno 487") como en el centro de salud, pero sin esperar de verdad; la enfermera pregunta "¿tiene cita previa?" |
| **Mercadona** | **La tienda** (la Poké Mart): Poké Balls, pociones, curas de estado, repelentes. Todo de marca **Hacendado** (nombres de objetos iguales; en el cartel, "Hacendado") | Fachada verde y blanca con el cartel; dentro, estanterías y cajas | Cola en la caja, el "¿quiere bolsa?", la sección de horno, la música de hilo musical. En Valencia está el **Mercadona central** con **Juan Roig** |
| **Estanco** | **Objetos de combate y especiales**: Ataque X, Defensa X..., **sellos**, y la **lotería**: un **boleto diario** que se rasca y da un premio al azar (con el Gordo de Navidad el 22 de diciembre, con el reloj real) | Escaparate pequeño con el letrero granate de "Tabacos" | El estanquero que lo sabe todo del barrio; "¿tiene sellos?"; en Canarias, todo más barato |
| **Basic Fit** | **Gimnasio de entrenamiento** (no confundir con los gimnasios Pokémon): sube los **puntos de esfuerzo** pagando sesiones (vitaminas en forma de "sesión de pesas") y tiene una **máquina de entrenamiento** para combatir sin consecuencias | Fachada naranja con cristaleras; dentro, máquinas y espejos | Gente haciéndose fotos en el espejo, el que no suelta la máquina, la cuota que te cobran aunque no vayas |

## Qué hay en cada sitio (propuesta)

| Ciudad | Centro Pokémon | Mercadona | Estanco | Basic Fit |
|--------|----------------|-----------|---------|-----------|
| San Miguel de Bernuy | No (cura la madre; el médico viene los martes) | No ("hay que ir a Cuéllar") | No | No |
| Madrid | Sol y Atocha | Argüelles y Lavapiés | Plaza Mayor (lotería de Navidad) | Gran Vía |
| Getafe, Leganés y Móstoles | Uno por pueblo | Uno por pueblo | Uno por pueblo | Getafe |
| Zaragoza | Plaza del Pilar | Sí | El Tubo | Sí |
| Barcelona | Plaça de Catalunya y Barceloneta | Eixample | La Rambla | Les Corts |
| Palma | Sí | Sí | Sí | Sí |
| Ibiza | Sí (con suplemento de temporada alta) | Sí | Sí | — |
| Valencia | Plaza del Ayuntamiento y Malvarrosa | **Mercadona central** (Juan Roig) | Sí | Paseo marítimo |
| Alicante, Murcia, Sevilla, Las Palmas, Vigo, Santander, Bilbao, Pamplona, Valladolid, Puertollano, Málaga | Sí | Sí | Sí | Sí |

## Datos para el juego

- Tiendas en `data/shops.json`: `mercadona_<ciudad>` (stock por medallas, como `tienda_ciudad2`), `estanco_<ciudad>` (objetos de combate) y `basicfit` (servicio de entrenamiento, no es tienda: necesita un evento propio).
- La lotería del Estanco y el servicio de Basic Fit son mecánicas nuevas: van a la lista de tareas de `README.md`.
