# Interiores de la Ruta 21 (viñedos de La Rioja y Logroño). Propuesta provisional.
SALAS = {
    "ruta_21/casa_1": {
        "tipo": "casa", "nombre": "Casa del viticultor riojano",
        "gente": [
            ("Viticultor", "vendimiador", "regalo:libre", [
                "Tempranillo, garnacha, graciano y mazuelo. Con eso se hace el Rioja. Y con mucha paciencia en barrica.",
                "Toma, para el camino, que de aquí a Burgos hay viñas y poco más."]),
            ("Mujer", "npc_woman", "cocina", ["Patatas a la riojana con chorizo. En vendimia se comen tres platos y se trabaja doce horas."]),
        ],
    },
    "ruta_21/casa_2": {
        "tipo": "taberna", "nombre": "Bar de pinchos de la calle Laurel",
        "gente": [
            ("Camarero", "camarero", "dependiente", [
                "En la Laurel cada bar tiene su pincho: champiñones, oreja, zapatillas. Se toma uno en cada sitio y se sigue.",
                "El champiñón con gamba encima se come de un bocado. Si lo partes, te mira todo el bar."]),
            ("Cuadrilla de despedida", "cunado", "cliente", ["Venimos de despedida de soltero. Llevamos once bares. El novio ya no sabe ni cómo se llama."]),
        ],
    },
    "ruta_21/sala_calle_10_38": {
        "tipo": "bodega", "nombre": "Calado de la bodega familiar",
        "gente": [
            ("Bodeguera", "npc_old_woman", "dependiente", [
                "Los calados son túneles excavados bajo tierra para guardar el vino. Aquí abajo siempre hay doce grados.",
                "Mi bisabuelo cavó este calado con pico. Tardó tres inviernos. El vino lo agradece cada año."]),
            ("Enólogo", "tertuliano", "mesa", ["Crianza, reserva y gran reserva. La diferencia es el tiempo en barrica y en botella. Y el precio."]),
        ],
        "carteles": [("pared", ["Barricas de roble americano y francés. El vino respira por la madera mientras duerme."])],
    },
    "ruta_21/sala_calle_33_38": {
        "tipo": "casa", "nombre": "Casa de la Batalla del Vino",
        "gente": [
            ("Mozo de Haro", "npc_youngster", "libre", [
                "En Haro, el 29 de junio, hacemos la Batalla del Vino: miles de litros tirados con botas, cubos y pistolas de agua. Acabas morado.",
                "La ropa blanca de la batalla no se vuelve a lavar. Se guarda morada, como trofeo."]),
            ("Madre", "npc_woman", "tele", ["Mi hijo vuelve de la Batalla del Vino con olor a vendimia hasta en las orejas. Una semana."]),
        ],
    },
}
