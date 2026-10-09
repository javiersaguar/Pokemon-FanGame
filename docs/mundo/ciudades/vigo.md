# Vigo

> **Decisión de Javier:** ciudad que aparece (sin gimnasio). Lo demás es **propuesta**.
>
> Plano real: [`../planos/vigo.svg`](../planos/vigo.svg) (casilla = 25 m).

## Lugares reales y cómo se ven

| Lugar | Qué es | En el juego | Arte |
|-------|--------|-------------|------|
| **Luces de Navidad de Abel Caballero** | 12 millones de luces LED en unas 500 calles; el montaje empieza **en julio**; el encendido, en noviembre, en la Porta do Sol, con un árbol enorme | **La seña de la ciudad:** las calles tienen luces de Navidad **todo el año** (se montan en julio). En diciembre (reloj real) se encienden con un evento | Luces: dibujar como adornos animados; árbol gigante: dibujar |
| **Porta do Sol** | Plaza del centro con la estatua del Sireno | Plaza principal con el árbol de Navidad | Componer |
| **Monte O Castro** | Parque en lo alto con el **Castillo de San Sebastián** y vistas a la ría | Colina con el castillo y mirador | Muros del pack 01 |
| **Casco Vello y Colegiata de Santa María** | Calles de piedra, plaza de la Constitución con el Ayuntamiento | Barrio antiguo | Granito: componer |
| **Rúa das Ostras** | Calle de las ostreras del puerto | Tienda de marisco (objetos curativos) | |
| **Puerto de Vigo** | Puerto pesquero y de cruceros, con la Estación Marítima | Muelles con barcos de pesca; **salida a las Islas Cíes** | Barcos del pack 01 |
| **Islas Cíes** | Parque Nacional de las Islas Atlánticas; playa de Rodas; con cupo de visitantes | Zona opcional en barco (pide un **permiso**, como en la realidad) | Playa y acantilados |
| **Playa de Samil** | La playa urbana más grande, con vistas a las Cíes | Playa al suroeste | Pack 02 |
| **Balaídos** | Estadio del Celta (1928), a orillas del río Lagares | Estadio opcional | Pack 01 |
| **Parque de Castrelos** | Parque con lago y pazo | Hierba alta | Packs 03 y 04 |

## Personajes (propuesta)

| Quién | Dónde |
|-------|-------|
| **Abel Caballero** (no está en la lista de Javier: **propuesta** de NPC) | Encendiendo las luces; cameo sin combate o combate de tipo Eléctrico |
| **Pereira7** | Un directo en una cafetería del centro (es de A Coruña); o en la Ruta 17 |
| **Amancio Ortega** | **Ruta 17**, en la sede de Inditex de Arteixo (A Coruña), o en una tienda de ropa del centro de Vigo |
| **El rey emérito Juan Carlos I** | **Ruta 16**, en las **regatas de Sanxenxo** (va de verdad a regatear allí) |

## Locales

**Centro Pokémon**, **Mercadona**, **Estanco** y **Basic Fit**.

## Pokémon de la zona (propuesta)

Ría: Shellos (oeste), Mareep (en el monte), Clauncher, Wailmer; Cíes: Pelipper, Wingull, Lapras (raro); Castro: Rattata, Pidgey.

## Conexiones

- **Aeropuerto de Peinador:** llegada del avión desde Gran Canaria.
- **Norte:** Ruta 16 (Rías Baixas) → Ruta 17 → Ruta 18 → Santander.
- **Puerto:** barco a las Islas Cíes (opcional).

## Estado (2026-10-09)

- **`vigo/exterior` pintado** (`maps/_pintura/pintar_vigo.gd`, 56×46): ciudad pavimentada. Centro con el **árbol de Navidad** y el **Sireno** (dibujados a mano, fuentes 250 y 251). Casco Vello al suroeste (casas de DPPt). Centro Pokémon, Mercadona (`tienda_verde`), estanco (`tienda_morada`) y Basic-Fit (`tienda_azul`). Al sur, la ría y un muelle. Al este, el aeropuerto de Peinador.
- **Llegada en avión:** spawn `from_avion` en la columna **50**, fila **34** (casilla libre junto al mostrador). La pasarela la une el Agente 5; aquí no hay warp al vuelo.
- **Norte:** `connect_edge` a `ruta_16/exterior` en las columnas **24–29** (fila 0). Spawn `from_ruta_16` en la columna **26**, fila **1**.
- Entrenadores en `data/trainers/vigo.json` (Uxío, regatista; Sabela, nadadora). Encuentros en `data/encounters/vigo.json` (propuesta: Shellos, Mareep, ría con Wailmer y Clauncher, Lapras raro). Abel Caballero, Pereira7 y Amancio no están en el mapa: como mucho, el cartel de la Porta do Sol.
- **Pendiente:** Islas Cíes, Samil, Balaídos, Castrelos y el castillo de O Castro. Interiores bloqueados.

## Fuentes

- Luces: [El Debate (julio de 2026)](https://www.eldebate.com/espana/galicia/20260729/abel-caballero-comienza-montaje-luces-navidad-plena-ola-calor_444868.html) · [Moncloa.com](https://www.moncloa.com/2026/07/31/navidad-vigo-luces-led-julio-3408645/) · [Xataka](https://www.xataka.com/magnet/plena-ola-calor-vacaciones-verano-vigo-tiene-clara-su-prioridad-ha-empezado-a-montar-su-navidad)
- Islas Cíes: [Xunta de Galicia](https://www.xunta.gal/notas-de-prensa/-/nova/020245/cerca-500-000-personas-visitaron-ano-pasado-parque-nacional-las-islas-atlanticas) · Balaídos: [Taquilla](https://www.taquilla.com/entradas/tour-abanca-balaidos)
- Plano: © colaboradores de OpenStreetMap (ODbL).
