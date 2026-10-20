# Interiores de la Ruta 17 (Galicia interior: Lugo y su muralla, las casas de labranza y Arteixo). Propuesta provisional.
# El hórreo tiene su sala propia (maps/_pintura/pintar_salas_hitos.gd) y no está aquí.
SALAS = {
    "ruta_17/sala_calle_27_12": {
        "tipo": "casa", "nombre": "Casa del vecino de la muralla",
        "gente": [
            ("Vecino de intramuros", "npc_old_man", "tele", [
                "Vivo dentro de la muralla desde que nací. Cada mañana doy la vuelta entera por arriba: dos kilómetros y setenta y una torres.",
                "Es la única muralla romana que se conserva entera en el mundo. Ya puede llover, que ésta no se cae."]),
            ("Su nieta", "npc_lass", "libre", ["Mi abuelo cuenta las torres cuando pasea. Le salen setenta y una. Un día le salieron setenta y dos y no durmió."]),
        ],
    },
    "ruta_17/sala_calle_32_7": {
        "tipo": "catedral", "nombre": "Catedral de Lugo",
        "gente": [
            ("Sacristán", "npc_old_man", "cura", [
                "En esta catedral el Santísimo está expuesto día y noche desde hace siglos. Por eso sale en el escudo de Lugo.",
                "Por aquí pasa el Camino Primitivo, el primero que hizo un rey asturiano hasta Santiago. A pie, sin aplicación."]),
            ("Peregrina", "montanera", "visitante", ["Salí de Oviedo hace diez días. Me quedan cuatro hasta Santiago y ninguna uña del pie."]),
        ],
        "dentro": {
            "ruta_17/sala_calle_32_7_capilla": {
                "tipo": "iglesia", "nombre": "Capilla de la Virgen de los Ojos Grandes",
                "gente": [("Devota", "npc_old_woman", "publico", [
                    "La Virgen de los Ojos Grandes es la patrona de Lugo. Dicen que te mira estés donde estés de la capilla.",
                    "Yo me pongo en la esquina para probarlo. Me sigue mirando. Ya no me pongo en la esquina."])],
                "carteles": [("pared", ["Una capilla barroca detrás del altar mayor, toda de piedra y oro, con una talla de la Virgen de ojos muy abiertos."])],
            },
        },
    },
    "ruta_17/sala_calle_37_13": {
        "tipo": "taberna", "nombre": "Taberna de las tapas de Lugo",
        "gente": [
            ("Tabernero", "camarero", "tras_mostrador", [
                "En octubre son las fiestas de San Froilán y el pulpo se come en casetas de madera. Este mes doy de comer a media Galicia.",
                "Aquí la tapa va con el vino y no se pide: llega. Si pides la tapa, te miro raro y te traigo dos."]),
            ("Cliente", "npc_man", "cliente", ["Llevo cuatro vinos y cuatro tapas. No he pedido comida y ya no tengo hambre. Esto en Madrid no pasa."]),
        ],
    },
    "ruta_17/sala_calle_47_37": {
        "tipo": "casa", "nombre": "Casa de la costurera de Arteixo",
        "gente": [
            ("Costurera", "npc_woman", "mesa", [
                "Antes de la gran tienda, en las aldeas de aquí cosíamos batas en casa para un taller de A Coruña. Así empezó todo.",
                "Ahora mi hija trabaja en la sede, diseñando. Yo le arreglo los bajos de los pantalones. Eso no lo hace ninguna máquina."]),
            ("Hija", "influencerlinkedin_f", "libre", ["En la oficina tenemos la ropa de la temporada que viene. En casa, la de mi madre de hace treinta años, que es la que me queda bien."]),
        ],
    },
    "ruta_17/sala_calle_5_24": {
        "tipo": "rural", "nombre": "Casa de labranza de la aldea",
        "gente": [
            ("Labrador", "pueblerino", "libre", [
                "Vacas, maíz, patatas y unos grelos. En el hórreo guardo el maíz; en la bodega, el vino; y en el banco, nada.",
                "Mis hijos se fueron a Barcelona. Vienen en agosto y en la matanza. A las vacas no las echan de menos; a mí, eso dicen."]),
            ("Abuela", "abuela", "cocina", [
                "Caldo gallego al fuego desde las seis de la mañana. Grelos, patata, unto y un hueso. Si no te lo comes, no te vas."]),
        ],
    },
}
