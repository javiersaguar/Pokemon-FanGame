# Pokémon Panchito — Documento de diseño (GDD)

> **Estado: borrador.** Sigue la Fase 2 de `GUIA_DESARROLLO.md`.
> Todo lo marcado **PENDIENTE JAVIER** es una decisión de diseño que falta por tomar. Las opciones que aparecen al lado son **sugerencias de la guía**, no decisiones.
> Cuando se decida algo: sustituye la marca por la decisión y apúntalo en el [registro de decisiones](#10-registro-de-decisiones).

---

## Índice

- [0. Decisiones que bloquean el MVP (v0.1)](#0-decisiones-que-bloquean-el-mvp-v01)
- [1. Identidad del juego](#1-identidad-del-juego)
- [2. La región](#2-la-región)
- [3. Gimnasios y Liga](#3-gimnasios-y-liga)
- [4. Pokédex regional](#4-pokédex-regional)
- [5. Curva de niveles y economía](#5-curva-de-niveles-y-economía)
- [6. Historia (esqueleto)](#6-historia-esqueleto)
- [7. Alcance de mecánicas](#7-alcance-de-mecánicas)
- [8. Contenido Panchito](#8-contenido-panchito)
- [9. Listas maestras](#9-listas-maestras)
- [10. Registro de decisiones](#10-registro-de-decisiones)

---

## 0. Decisiones que bloquean el MVP (v0.1)

Sin estas respuestas se puede programar con valores provisionales, pero el MVP no se puede cerrar.

| # | Decisión | A quién afecta | Opciones / sugerencia de la guía | Estado |
|---|----------|----------------|-----------------------------------|--------|
| 1 | Resolución base | `project.godot`, toda la UI y el combate | **320×180** (16:9, recomendada) o 256×192 (4:3, la de DS y Añil) | **PENDIENTE JAVIER** |
| 2 | ¿Quién o qué es Panchito? | Logo, título, intro y trama | Protagonista, profesor, mascota, villano o región | **PENDIENTE JAVIER** |
| 3 | Nombres de la región, del pueblo inicial y de la ciudad 2 | Mapas, carteles y diálogos | Puede parodiar un lugar real | **PENDIENTE JAVIER** |
| 4 | Los 3 iniciales | Laboratorio, equipos del rival y datos | Triángulo Planta / Fuego / Agua (variable `starter` = 1 / 2 / 3, Apéndice C) | **PENDIENTE JAVIER** |
| 5 | Profesor y rival: nombre, personalidad y nombre por defecto del rival | Intro y primer combate | — | **PENDIENTE JAVIER** |
| 6 | Especies salvajes de la Ruta 1 (día y noche) | `data/encounters/` | La guía usa de ejemplo Pidgey, Rattata, Sentret, Hoppip / Hoothoot, Spinarak | **PENDIENTE JAVIER** |
| 7 | Chico / chica: aspecto y nombres por defecto | Intro y teclado de nombres | — | **PENDIENTE JAVIER** |
| 8 | Tono general | Todos los textos | ¿Parodia total o aventura seria con chistes? | **PENDIENTE JAVIER** |
| 9 | Reloj real o interno (acelerado) | `Clock`, encuentros de día y de noche | Fase 14.1 | **PENDIENTE JAVIER** |

---

## 1. Identidad del juego

| Campo | Valor |
|-------|-------|
| **Título** | Pokémon Panchito |
| **Tipo** | Fangame **sin ánimo de lucro**, al estilo de *Pokémon Añil*, programado desde cero en Godot 4 con GDScript |
| **Idioma** | Español (textos preparados para traducción con `tr()`) |
| **Monetización** | Ninguna: ni ventas, ni donaciones a cambio de builds, ni anuncios (regla de oro 6) |
| **Tono** | **PENDIENTE JAVIER.** Punto de partida de la guía: humor absurdo y costumbrista español (clases de entrenador y objetos de broma) con una aventura que se toma en serio lo justo |
| **Pitch de una frase** | **PENDIENTE JAVIER.** Ejemplo de la guía: *"Una aventura Pokémon clásica en una región donde los entrenadores son los personajes de tu barrio."* |
| **Panchito** | **PENDIENTE JAVIER** (ver decisión 2) |
| **Público** | **PENDIENTE JAVIER.** El humor debe funcionar para la gente a la que va dirigido |

### 1.1 Estilo visual

| Campo | Valor |
|-------|-------|
| Tamaño de tile | 16×16 px (Fase 3.2) |
| Resolución base | **PENDIENTE JAVIER** (ver decisión 1) |
| Estilo de tileset | **PENDIENTE JAVIER.** Sugerencia: 4.ª o 5.ª generación, con aire de Añil, de recursos con permiso de uso |
| Sprites de Pokémon | **PENDIENTE JAVIER.** Sugerencia: los de 5.ª generación, como Añil |
| Logo | Tipografía propia parecida a la oficial (Fase 15.2) |
| Paleta y marcos de la UI | **PENDIENTE JAVIER.** El jugador podrá elegir el marco en las opciones |

---

## 2. La región

| Campo | Valor |
|-------|-------|
| **Nombre** | **PENDIENTE JAVIER** |
| **Inspiración** | **PENDIENTE JAVIER.** Ideas de la guía: barrios, metro, sierra, costa... |
| **Boceto del mapa mundial** | **PENDIENTE JAVIER.** Guardarlo en `docs/mapas/region.png` |

### 2.1 Lugares

| Lugar | Nombre | Bioma | Gimnasio | Notas |
|-------|--------|-------|----------|-------|
| Pueblo inicial | **PENDIENTE JAVIER** | | — | MVP: casa del jugador (2 plantas), casa del rival y laboratorio |
| Ruta 1 | — | Hierba | — | MVP: hierba alta, objetos y 1–2 entrenadores (Vendedor de Chupachups) |
| Ciudad 2 | **PENDIENTE JAVIER** | | **PENDIENTE JAVIER** (¿es la del gimnasio 1?) | MVP: al menos Centro Pokémon y Tienda |
| Ciudades con gimnasio (8) | **PENDIENTE JAVIER** | | 1–8 | Ver [tabla de gimnasios](#3-gimnasios-y-liga) |
| Pueblos sin gimnasio (2–4) | **PENDIENTE JAVIER** | | — | |
| Rutas (~20–25) | Numeradas | | — | 3–5 especies nuevas por ruta |
| Calle Victoria | | Cueva / montaña | — | Exige varios movimientos de campo |
| Liga | | | — | Recepción, 4 salas, Campeón y Hall de la Fama |
| Zonas de postgame | **PENDIENTE JAVIER** | | — | Ideas de la guía: islas, montaña, zonas secretas Panchito |

### 2.2 Biomas que deben aparecer

- [ ] Bosque
- [ ] Cueva
- [ ] Montaña
- [ ] Mar
- [ ] Volcán
- [ ] Nieve
- [ ] Ciudad
- [ ] Metro
- [ ] **Zonas Panchito** (ideas de la guía): estación de metro como mazmorra, mercadillo, fiestas del pueblo...

### 2.3 Bloqueos de progreso

| Bloqueo | Se supera con | Dónde |
|---------|---------------|-------|
| Árboles cortables | **PENDIENTE JAVIER** (MO clásica o sistema moderno, ver [§7.2](#72-otras-decisiones-de-sistemas)) | |
| Rocas rompibles / de fuerza | **PENDIENTE JAVIER** | |
| Agua y cascadas | **PENDIENTE JAVIER** | |
| "Asiento reservado del metro" (el Snorlax de Panchito, idea de la guía) | **PENDIENTE JAVIER** | |

- **Ruta crítica** y punto donde se abre el mundo: **PENDIENTE JAVIER.** La tabla de gimnasios de la guía sitúa Surf tras el gimnasio 3.

---

## 3. Gimnasios y Liga

Niveles y desbloqueos tomados de la guía. El resto, **PENDIENTE JAVIER**.

| # | Ciudad | Líder | Tipo | Nivel as | Medalla | MT premio | Puzle | Desbloquea |
|---|--------|-------|------|----------|---------|-----------|-------|------------|
| 1 | | | | 12–14 | | | | Corte |
| 2 | | | | 18–20 | | | | |
| 3 | | | | 24–26 | | | | Surf |
| 4 | | | | 29–31 | | | | |
| 5 | | | | 34–36 | | | | |
| 6 | | | | 39–41 | | | | |
| 7 | | | | 44–46 | | | | |
| 8 | | | | 48–50 | | | | Cascada |
| Alto Mando 1–4 | | | | 52–58 | | | | |
| Campeón | | | | 58–62 | | | | Postgame |

- **Regla:** los tipos de los gimnasios deben repartir ventajas y desventajas entre los 3 iniciales (ninguno debe ser un muro con un inicial ni un paseo con otro).
- Cada líder: presentación, combate, medalla, MT y desbloqueo (Fase 13.4). Diseño propio de las 8 medallas (Fase 15.3).
- ¿Humor Panchito también en los líderes? **PENDIENTE JAVIER.**

---

## 4. Pokédex regional

| Campo | Valor |
|-------|-------|
| **Tamaño** | **PENDIENTE JAVIER.** Guía: ~150–250 especies (cada especie extra = más sprites, balance y encuentros) |
| **Orden** | `data/regional_dex.json` |
| **Pokédex Nacional en el postgame** | **PENDIENTE JAVIER** |
| **Formas regionales Panchito** (opcional) | **PENDIENTE JAVIER** |

### 4.1 Iniciales

| `starter` | Tipo | Especie | Línea evolutiva |
|-----------|------|---------|-----------------|
| 1 | Planta | **PENDIENTE JAVIER** | |
| 2 | Fuego | **PENDIENTE JAVIER** | |
| 3 | Agua | **PENDIENTE JAVIER** | |

El rival elige siempre el inicial con **ventaja de tipo** sobre el tuyo (Fase 8.3).

### 4.2 Legendarios

| Papel | Especie | Dónde | Cuándo |
|-------|---------|-------|--------|
| Portada | **PENDIENTE JAVIER** | | Clímax del acto 3 |
| Trío | **PENDIENTE JAVIER** | | |
| Postgame | **PENDIENTE JAVIER** | | |

Si el legendario se debilita o el jugador huye, debe poder reintentarse (Fase 13.5).

### 4.3 Reparto por zonas

Reglas de la guía: 3–5 especies nuevas por ruta, con especies exclusivas de día o de noche.

| Tramo | Zonas | Especies nuevas | Tipos que cubre |
|-------|-------|-----------------|-----------------|
| 1 (→ gimnasio 1) | Ruta 1... | **PENDIENTE JAVIER** | |
| 2 (→ gimnasio 2) | | | |
| 3 (→ gimnasio 3) | | | |
| 4 (→ gimnasio 4) | | | |
| 5 (→ gimnasio 5) | | | |
| 6 (→ gimnasio 6) | | | |
| 7 (→ gimnasio 7) | | | |
| 8 (→ gimnasio 8) | | | |

---

## 5. Curva de niveles y economía

### 5.1 Curva de niveles

Reglas de la guía: los entrenadores de ruta van **2–4 niveles por debajo** del siguiente líder y los salvajes **5–8 por debajo**. La tabla aplica esas reglas al nivel del as de cada líder; es un **cálculo de partida** para el balanceo (Fase 20.2), no una decisión.

| Tramo | Nivel as del líder | Entrenadores de ruta | Salvajes |
|-------|--------------------|----------------------|----------|
| 1 | 12–14 | 8–12 | 4–9 |
| 2 | 18–20 | 14–18 | 10–15 |
| 3 | 24–26 | 20–24 | 16–21 |
| 4 | 29–31 | 25–29 | 21–26 |
| 5 | 34–36 | 30–34 | 26–31 |
| 6 | 39–41 | 35–39 | 31–36 |
| 7 | 44–46 | 40–44 | 36–41 |
| 8 | 48–50 | 44–48 | 40–45 |
| Liga | 52–62 | — | — |

> La Ruta 1 queda por debajo de la curva (el equipo empieza con un inicial de nivel bajo). Nivel del inicial: **PENDIENTE JAVIER** (en los juegos oficiales, 5).

### 5.2 Economía

| Concepto | Valor |
|----------|-------|
| Dinero al ganar a un entrenador | `base_money` de la clase × nivel del último Pokémon (Fase 7.8) |
| Dinero inicial | **PENDIENTE JAVIER** |
| Dinero perdido al ser derrotado | **PENDIENTE JAVIER** |
| Precios de la tienda | **PENDIENTE JAVIER.** Regla de la guía: que el jugador pueda curarse pero tenga que elegir |
| Catálogo por ciudad | Crece con las medallas (Fase 11.5), en `data/shops.json` |
| Tienda Panchito | Kiosko de chuches, bar o mercadillo (idea de la guía). **PENDIENTE JAVIER** |

---

## 6. Historia (esqueleto)

### 6.1 Personajes principales

| Personaje | Nombre | Descripción | Estado |
|-----------|--------|-------------|--------|
| Protagonista | Lo elige el jugador | Chico o chica | Aspecto y nombres por defecto: **PENDIENTE JAVIER** |
| Rival | **PENDIENTE JAVIER** | **PENDIENTE JAVIER** | 5–7 combates; su inicial tiene ventaja sobre el tuyo |
| Profesor | **PENDIENTE JAVIER** | **PENDIENTE JAVIER** | Da la intro, el inicial, la Pokédex y las Poké Balls |
| Madre / familia | **PENDIENTE JAVIER** | | |

### 6.2 Equipo villano

| Campo | Valor |
|-------|-------|
| Nombre | **PENDIENTE JAVIER** |
| Motivación | **PENDIENTE JAVIER** |
| Reclutas | Otra clase Panchito: **PENDIENTE JAVIER** |
| Almirantes | **PENDIENTE JAVIER** |
| Jefe | **PENDIENTE JAVIER** |
| Guarida | **PENDIENTE JAVIER** (con puzle, Fase 13.4) |

### 6.3 Estructura en 3 actos

| Acto | Gimnasios | Contenido | Detalle |
|------|-----------|-----------|---------|
| 1. Presentación | 1–3 | Inicio, rival, primera aparición del villano | **PENDIENTE JAVIER** |
| 2. Conflicto | 4–6 | Infiltración en la guarida (tramo 4) | **PENDIENTE JAVIER** |
| 3. Clímax | 7–8 | Legendario de portada y final del villano | **PENDIENTE JAVIER** |
| Liga y epílogo | — | Calle Victoria, Alto Mando, Campeón, créditos, postgame | **PENDIENTE JAVIER** |

### 6.4 Combates contra el rival

| # | Dónde | Cuándo | Notas |
|---|-------|--------|-------|
| 1 | Laboratorio | Tras elegir inicial | **Se puede perder** sin consecuencias. 3 versiones según tu inicial |
| 2–7 | **PENDIENTE JAVIER** | | |

### 6.5 Momentos clave (cinemáticas)

- [ ] Intro del profesor y elección de inicial (MVP)
- [ ] Combates contra el rival
- [ ] Primera aparición del equipo villano
- [ ] Infiltración en la guarida (reclutas, puzle y jefe)
- [ ] Combates de líder: presentación, combate, medalla, MT y desbloqueo
- [ ] Encuentro con el legendario de portada
- [ ] Final del villano
- [ ] Liga y créditos
- [ ] Desbloqueo del postgame

### 6.6 Intro del MVP (Fase 8.1)

Estructura fijada por la guía; los textos son **PENDIENTE JAVIER**:

1. Pantalla de título: logo, "Pulsa Enter", Nueva partida / Continuar.
2. El profesor presenta el mundo.
3. Elegir chico o chica.
4. Introducir el nombre (teclado en pantalla) y el nombre del rival.
5. El jugador aparece en su habitación.

El guion completo irá en `docs/guion/` (un archivo por capítulo, Fase 13.3).

---

## 7. Alcance de mecánicas

### 7.1 Mecánicas de combate por versión

Propuesta de la guía (Fase 2.7). **PENDIENTE JAVIER** confirmarla.

| Mecánica | MVP (v0.1) | v0.2 | v1.0 | Postgame / v1.x |
|----------|-----------|------|------|-----------------|
| Combate individual | ✅ | | | |
| Habilidades y objetos equipados | | ✅ | | |
| Clima, campos, trampas | | ✅ | | |
| Combates dobles | | ✅ | | |
| Megaevolución | | | ✅ | |
| Movimientos Z | | | | ✅ |
| Dinamax / Gigamax | | | | ✅ |
| Teracristalización | | | | ✅ |
| Crianza y huevos | | | ✅ | |
| Online | | | | ✅ (opcional) |

> Recomendación de la guía: Megas como gimmick principal de la historia, y Tera, Dinamax y Z en postgame, raids o contenido opcional.

### 7.2 Otras decisiones de sistemas

| Sistema | Opciones | Sugerencia de la guía | Estado |
|---------|----------|-----------------------|--------|
| Movimientos de campo | MO clásicas o sistema moderno (objetos o "Pokémon de montura") | Moderno | **PENDIENTE JAVIER** |
| Reloj | Real o interno acelerado | — | **PENDIENTE JAVIER** |
| Revanchas | Teléfono, Buscapelea (objeto clave) o automáticas por progreso | — | **PENDIENTE JAVIER** |
| Repartir Experiencia | Moderno (todo el equipo, desactivable) | Moderno | **PENDIENTE JAVIER** |
| Modo de combate | "Cambio" o "Fijo" como opción del jugador | Opción del jugador | **PENDIENTE JAVIER** |
| Modo difícil / Nuzlocke | Activable al empezar | Opcional | **PENDIENTE JAVIER** |
| Pokémon que te sigue | Sí o no | Opcional (Fase 14.5) | **PENDIENTE JAVIER** |
| Probabilidad de shiny | — | 1/4096 | **PENDIENTE JAVIER** |
| Bono de metro como viaje rápido | Sí o no | Opcional (Fase 12.5) | **PENDIENTE JAVIER** |

---

## 8. Contenido Panchito

### 8.1 Clases de entrenador

- Propuesta inicial: las **20 clases** de la tabla 10.2 de la guía, en `data/trainer_classes.json`. Ficha de cada entrenador concreto en `docs/entrenadores.md`.
- Objetivo: **25–40 clases** para 8 gimnasios. Las clases nuevas: **PENDIENTE JAVIER.**
- Reparto por zonas con sentido (guía): Robasientos y Revisor en el metro o la ciudad, Turista en la playa, Jubilado en zonas de obras...
- ¿Humor también en reclutas, rival y líderes? **PENDIENTE JAVIER.**
- El humor va sobre **situaciones y personajes cotidianos**.

### 8.2 Objetos especiales Panchito

- **Los define Javier.** Hasta entonces, solo placeholders marcados **"POR DEFINIR"**.
- Lista real en `docs/objetos_especiales.md`; datos en `data/items_panchito.json`.
- Las ideas de la Fase 11.4 (Bocata de calamares, Tupper de mamá, tortilla con o sin cebolla...) son solo inspiración.
- ¿Bolsillo propio "Cosas de Panchito" en la mochila? **PENDIENTE JAVIER.**

### 8.3 Música

- Al menos un **tema de Panchito** propio que identifique el juego (Fase 16.3).
- Intros de entrenador por clase (por ejemplo, una melodía "sospechosa" para el Robasientos).
- ¿Tema de combate propio para entrenadores Panchito? **PENDIENTE JAVIER.**

---

## 9. Listas maestras

| Archivo | Contenido | Fase |
|---------|-----------|------|
| `docs/entrenadores.md` | Clase, nombre, mapa, nivel medio, obligatorio sí/no y estado del sprite | 10.6 |
| `docs/objetos_especiales.md` | Objetos Panchito (los define Javier) | 11.4 |
| `docs/flags.md` | Registro de flags y variables de historia | 13.2 |
| `docs/mapas/lista.md` | Mapas y su estado (boceto → pintado → entidades → probado) | 12.2 |
| `docs/mapas/reservas.md` | Quién está pintando cada mapa | 1.5 |
| `docs/guion/` | Guion por capítulos | 13.3 |

---

## 10. Registro de decisiones

| Fecha | Decisión | Sección |
|-------|----------|---------|
| | | |
