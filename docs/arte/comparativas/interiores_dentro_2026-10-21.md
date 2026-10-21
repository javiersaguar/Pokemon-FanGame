# Salas de dentro de los monumentos · 2026-10-21

Los monumentos grandes de las ciudades que solo tenían una sala ganan **20 salas de dentro**, como ya tenían el Pilar, la Seo o la Catedral de Murcia. Se entra por un paso en la pared de arriba de la sala principal, que se redistribuye para abrirlo (conserva su gente, sus frases y su entrada). **Todo es provisional** y sin famosos.

Cómo se hace: `data/interiores/<ciudad>.json` con la sala hija (`padre`), `planificar_interiores.py <ciudad> --solo <madre>` y después la ciudad entera para las hijas; `pintar_interiores_datos.gd -- <ciudad> --solo <sala>`. En las ciudades con contenido escrito a mano, las mismas salas se añaden al final de `contenido_interiores/<ciudad>.py`, para que `rellenar_interiores.py` las vuelva a crear.

Retoque a mano: en la galería de la mina de Puertollano, el planificador ponía un águila de piedra; se cambia por un montón de cajas (en `data/interiores/puertollano.json`).

### Real Alcázar, apeadero

| ![Real Alcázar, apeadero](interiores_2026-10-21/sevilla/sevilla__sala_centro_24_51_despues.png) | ![Patio de las Doncellas](interiores_2026-10-21/sevilla/sevilla__sala_centro_24_51_doncellas_despues.png) | ![Salón de Embajadores](interiores_2026-10-21/sevilla/sevilla__sala_centro_24_51_embajadores_despues.png) |
|---|---|---|
| Real Alcázar, apeadero (madre, redistribuida) | Patio de las Doncellas | Salón de Embajadores |

### Archivo General de Indias

| ![Archivo General de Indias](interiores_2026-10-21/sevilla/sevilla__sala_centro_33_47_despues.png) | ![Galería de los legajos](interiores_2026-10-21/sevilla/sevilla__sala_centro_33_47_legajos_despues.png) |
|---|---|
| Archivo General de Indias (madre, redistribuida) | Galería de los legajos |

### Basílica de Montserrat

| ![Basílica de Montserrat](interiores_2026-10-21/ruta_8/ruta_8__sala_calle_36_10_despues.png) | ![Camarín de la Moreneta](interiores_2026-10-21/ruta_8/ruta_8__sala_calle_36_10_camarin_despues.png) | ![Escolanía de Montserrat](interiores_2026-10-21/ruta_8/ruta_8__sala_calle_36_10_escolania_despues.png) |
|---|---|---|
| Basílica de Montserrat (madre, redistribuida) | Camarín de la Moreneta | Escolanía de Montserrat |

### Alcazaba de Málaga

| ![Alcazaba de Málaga](interiores_2026-10-21/malaga/malaga__sala_calle_60_35_despues.png) | ![Patio de Armas de la Alcazaba](interiores_2026-10-21/malaga/malaga__sala_calle_60_35_patio_despues.png) |
|---|---|
| Alcazaba de Málaga (madre, redistribuida) | Patio de Armas de la Alcazaba |

### Castillo de Gibralfaro

| ![Castillo de Gibralfaro](interiores_2026-10-21/malaga/malaga__sala_calle_76_16_despues.png) | ![Paseo de ronda de Gibralfaro](interiores_2026-10-21/malaga/malaga__sala_calle_76_16_ronda_despues.png) |
|---|---|
| Castillo de Gibralfaro (madre, redistribuida) | Paseo de ronda de Gibralfaro |

### Catedral de la Encarnación, La Manquita

| ![Catedral de la Encarnación, La Manquita](interiores_2026-10-21/malaga/malaga__sala_calle_48_35_despues.png) | ![Cubiertas de la Catedral](interiores_2026-10-21/malaga/malaga__sala_calle_48_35_cubiertas_despues.png) |
|---|---|
| Catedral de la Encarnación, La Manquita (madre, redistribuida) | Cubiertas de la Catedral |

### Palacio de la Almudaina

| ![Palacio de la Almudaina](interiores_2026-10-21/palma/palma__sala_calle_32_40_despues.png) | ![Salón del Tinell](interiores_2026-10-21/palma/palma__sala_calle_32_40_tinell_despues.png) |
|---|---|
| Palacio de la Almudaina (madre, redistribuida) | Salón del Tinell |

### Castell de Bellver

| ![Castell de Bellver](interiores_2026-10-21/palma/palma__sala_calle_7_14_despues.png) | ![Patio circular de Bellver](interiores_2026-10-21/palma/palma__sala_calle_7_14_patio_despues.png) |
|---|---|
| Castell de Bellver (madre, redistribuida) | Patio circular de Bellver |

### Castillo de Santa Bárbara

| ![Castillo de Santa Bárbara](interiores_2026-10-21/alicante/alicante__sala_calle_58_12_despues.png) | ![Macho del castillo de Santa Bárbara](interiores_2026-10-21/alicante/alicante__sala_calle_58_12_macho_despues.png) |
|---|---|
| Castillo de Santa Bárbara (madre, redistribuida) | Macho del castillo de Santa Bárbara |

### Gran Teatre del Liceu

| ![Gran Teatre del Liceu](interiores_2026-10-21/barcelona/barcelona__sala_ciutat_vella_22_27_despues.png) | ![Salón de los Espejos del Liceu](interiores_2026-10-21/barcelona/barcelona__sala_ciutat_vella_22_27_espejos_despues.png) |
|---|---|
| Gran Teatre del Liceu (madre, redistribuida) | Salón de los Espejos del Liceu |

### Palacio de la Magdalena

| ![Palacio de la Magdalena](interiores_2026-10-21/santander/santander__sala_calle_58_29_despues.png) | ![Salón de baile de la Magdalena](interiores_2026-10-21/santander/santander__sala_calle_58_29_salon_despues.png) |
|---|---|
| Palacio de la Magdalena (madre, redistribuida) | Salón de baile de la Magdalena |

### Universidad de Alcalá, Colegio de San Ildefonso

| ![Universidad de Alcalá, Colegio de San Ildefonso](interiores_2026-10-21/ruta_5/ruta_5__sala_calle_31_12_despues.png) | ![Paraninfo de la Universidad de Alcalá](interiores_2026-10-21/ruta_5/ruta_5__sala_calle_31_12_paraninfo_despues.png) |
|---|---|
| Universidad de Alcalá, Colegio de San Ildefonso (madre, redistribuida) | Paraninfo de la Universidad de Alcalá |

### Palacio del Infantado de Guadalajara

| ![Palacio del Infantado de Guadalajara](interiores_2026-10-21/ruta_5/ruta_5__sala_calle_56_12_despues.png) | ![Patio de los Leones del Infantado](interiores_2026-10-21/ruta_5/ruta_5__sala_calle_56_12_patio_despues.png) |
|---|---|
| Palacio del Infantado de Guadalajara (madre, redistribuida) | Patio de los Leones del Infantado |

### Catedral de Valladolid

| ![Catedral de Valladolid](interiores_2026-10-21/valladolid/valladolid__sala_calle_59_16_despues.png) | ![Torre de la Catedral](interiores_2026-10-21/valladolid/valladolid__sala_calle_59_16_torre_despues.png) |
|---|---|
| Catedral de Valladolid (madre, redistribuida) | Torre de la Catedral |

### Museo de la Minería

| ![Museo de la Minería](interiores_2026-10-21/puertollano/puertollano__sala_calle_51_60_despues.png) | ![Galería de la mina](interiores_2026-10-21/puertollano/puertollano__sala_calle_51_60_galeria_despues.png) |
|---|---|
| Museo de la Minería (madre, redistribuida) | Galería de la mina |

### Centro de visitantes de Atapuerca

| ![Centro de visitantes de Atapuerca](interiores_2026-10-21/ruta_22/ruta_22__sala_calle_16_15_despues.png) | ![Réplica de la Sima de los Huesos](interiores_2026-10-21/ruta_22/ruta_22__sala_calle_16_15_sima_despues.png) |
|---|---|
| Centro de visitantes de Atapuerca (madre, redistribuida) | Réplica de la Sima de los Huesos |

### Castillo de la Luz

| ![Castillo de la Luz](interiores_2026-10-21/las_palmas/las_palmas__sala_canteras_43_15_despues.png) | ![Sala de esculturas del Castillo de la Luz](interiores_2026-10-21/las_palmas/las_palmas__sala_canteras_43_15_esculturas_despues.png) |
|---|---|
| Castillo de la Luz (madre, redistribuida) | Sala de esculturas del Castillo de la Luz |

### Catedral de Santiago

| ![Catedral de Santiago](interiores_2026-10-21/bilbao/bilbao__sala_calle_44_41_despues.png) | ![Claustro de la Catedral de Santiago](interiores_2026-10-21/bilbao/bilbao__sala_calle_44_41_claustro_despues.png) |
|---|---|
| Catedral de Santiago (madre, redistribuida) | Claustro de la Catedral de Santiago |
