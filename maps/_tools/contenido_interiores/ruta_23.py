# Interiores de la Ruta 23 (Cuéllar y la Tierra de Pinares). Propuesta provisional.
# Nada de aquí toca el lore de San Miguel de Bernuy ni la casa de Javier: eso lo decide Javier.
SALAS = {
    "ruta_23/casa_1": {
        "tipo": "casa", "nombre": "Casa del caballista de los encierros",
        "gente": [
            ("Caballista", "npc_man", "regalo:libre", [
                "En Cuéllar los toros vienen del campo hasta el pueblo guiados por caballos. Dicen que son los encierros más antiguos de España.",
                "Toma, que yo de esto entiendo: cuando corres delante de algo grande, conviene llevar algo para después."]),
            ("Su hija", "npc_girl", "libre", ["Mi padre lleva el caballo al encierro y yo llevo el bocadillo. Los dos somos imprescindibles."]),
        ],
    },
    "ruta_23/casa_2": {
        "tipo": "casa", "nombre": "Casa de la piñonera",
        "gente": [
            ("Piñonera", "npc_old_woman", "cocina", [
                "En estos pinares hay pino resinero y pino piñonero. El primero da resina; el segundo, piñones a precio de joya.",
                "Los piñones se sacan de la piña al sol del verano y se parten uno a uno. Por eso valen lo que valen: por la paciencia."]),
            ("Nieto", "npc_youngster", "tele", ["Mi abuela me da piñones de merienda. En el colegio me dicen que soy rico."]),
        ],
    },
    "ruta_23/sala_calle_12_11": {
        "tipo": "castillo", "nombre": "Castillo de los Duques de Alburquerque",
        "gente": [
            ("Guía del castillo", "profesor", "libre", [
                "Aquí vivió Beltrán de la Cueva, el favorito de Enrique IV. Los enemigos del rey decían que la princesa Juana era hija suya.",
                "Por eso la llamaron «la Beltraneja». Un mote así cambió la historia de Castilla. Cuidado con lo que se cuenta en los pasillos."]),
            ("Estudiante", "npc_youngster", "libre", ["Mi instituto está dentro del castillo. Hay almenas, foso y examen de Matemáticas el lunes. Sigue siendo un instituto."]),
        ],
    },
    "ruta_23/sala_calle_22_11": {
        "tipo": "iglesia", "nombre": "Iglesia de San Miguel de Cuéllar",
        "gente": [
            ("Sacristán", "npc_old_man", "cura", [
                "Cuéllar está llena de iglesias de ladrillo mudéjar. Son de ladrillo porque en la Tierra de Pinares la piedra está lejos.",
                "Los mismos maestros que hacían mezquitas hacían iglesias. El ladrillo no pregunta a quién se reza."]),
            ("Vecina", "npc_old_woman", "visitante", ["Vengo a misa de once y a limpiar los bancos. Los bancos están más limpios que mi casa."]),
        ],
    },
}
