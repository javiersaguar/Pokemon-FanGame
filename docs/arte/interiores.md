# Interiores de servicios · 2026-10-10

Javier autoriza interiores de Mercadona y estancos, y hospitales en las ocho ciudades con gimnasio, en sustitución del Centro Pokémon. Primer conjunto: Málaga. Hospital: curación, PC y punto de regreso tras derrota; Mercadona: catálogo progresivo existente; estanco: objetos X con precios de DataDB. Lotería, sellos y entrenamiento de Basic-Fit siguen pendientes; no se añaden reglas propias.

## Recurso y reproducción

[Akizakura16, 4th gen Indoor Tileset](https://www.deviantart.com/akizakura16/art/4th-gen-Indoor-Tileset-624832808), [publicado por la autora](https://eeveeexpo.com/resources/15/). La autora pide crédito y explica que las imágenes se guardan directamente. PNG original 256×17056; recortes en `assets/tilesets/interior/origen.json`, con SHA-256. Tamaño nativo 32 px, sin reescalado ni dibujo procedural. Solo se copian los cuatro fragmentos usados.

```sh
godot --headless --path . -s assets/tilesets/interior/build_interiores.gd -- /ruta/akizakura16.png
godot --headless --editor --path . --import
godot --headless --path . -s maps/_pintura/pintar_locales.gd
```

Mapas 16×12, cámara fija a 512×384, sin bicicleta, carrera, seguidores ni encuentros. Paredes/muebles sólidos; mostradores marcados `counter` para interactuar con el dependiente desde dos casillas. Salida en (8,11), llegada (8,10); recuperación (8,5). Las llegadas exteriores quedan delante de la puerta, evitando reentrada inmediata. F9 los descubre automáticamente.

Hospital: fachada urbana genérica del pack HGSS, rótulo Hospital; pendiente edificio sanitario propio y aprobación gráfica. No se presenta como réplica de un hospital real elegido por Javier. Los personajes famosos ya tienen datos/sprites; ubicaciones y guion no se inventan.

## Extensión a las siete ciudades pintadas

`maps/_pintura/locales.json` conserva ciudad, barrio y anclaje del edificio de cada servicio. Constructor: `godot --headless --path . -s maps/_pintura/pintar_locales.gd -- --all`. Cada exterior incorpora `servicios_locales.gd` antes de guardar; reemplaza el Centro de ese conjunto por edificio urbano con rótulo Hospital y conecta sus tres servicios. Las Palmas respeta Vegueta/Triana y Canteras. Los Centros/tiendas adicionales de otros barrios esperan interiores; hay un conjunto abierto por ciudad.

Bilbao no tiene exterior todavía. No se publican puertas hacia un mapa inexistente. Las fachadas siguen provisionales y los nombres reales esperan la decisión de Javier.

## Localidades del tramo centro y sur

Getafe, Leganés, Móstoles y Puertollano tienen tres interiores cada una: Centro Pokémon, Mercadona y estanco. Fuera de las ciudades con gimnasio se conserva la fachada del Centro Pokémon. Los Centros ofrecen los mismos servicios de curación, PC y recuperación que los hospitales; el nombre del diálogo sigue siendo Centro Pokémon.

El manifiesto admite `centro` o `hospital` además de las tiendas. Para reconstruir solo este tramo:

```sh
godot --headless --path . -s maps/_pintura/pintar_locales.gd -- --all getafe leganes mostoles puertollano
```

Las doce puertas y sus salidas se comprueban junto con las 21 anteriores. Los cuatro Centros se prueban con interacción real desde el mostrador, PS/estado/PP, derrota y PC. Las ocho tiendas usan datos propios en `shops.json`, heredando el catálogo existente sin nuevas reglas. Rótulos de estos locales desplazados dentro de la cabecera para que el aviso F9 no tape el nombre en sesiones de pruebas. Comparativas por localidad en `docs/arte/comparativas/*_locales.md`.

## Entradas adicionales (2026-10-12)

Veintiocho salas nuevas conectadas a trece exteriores ya pintados; **61 servicios** en total. Los namespaces de barrio (`madrid/sol/hospital`, etc.) evitan sustituir escenas exteriores y conservan la identidad de captura de la ciudad. Constructor del exterior: `servicios_locales.apply_all(p,map_id)`; interiores: `pintar_locales.gd -- --all <claves del manifiesto>`. Campos opcionales `zone` y `heading_y` conservan valores anteriores cuando faltan. Stock/precios ya existentes en 19 nuevas tiendas. [Comparativas y alcance](../mundo/auditoria_locales.md).

Todos los interiores alcanzables; Palma/Ibiza requieren Surf en la salida exterior marítima. El fundido visual del motor común de Warp se conserva. El SE `door` sigue sin archivo; no se sustituye por un sonido ajeno. Casas/gimnasios y edificios especiales: [inventario](../mundo/puertas_pendientes.md) y contenido pendiente de Javier.
