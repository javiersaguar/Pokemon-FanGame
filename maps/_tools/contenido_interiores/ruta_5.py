# Interiores de la Ruta 5 (Corredor del Henares: Alcalá y Guadalajara). Propuesta provisional.
SALAS = {
    "ruta_5/casa_1": {
        "tipo": "casa", "nombre": "Casa del mozo de almacén",
        "gente": [
            ("Mozo de almacén", "jubiladoobras", "regalo:tele", [
                "En el Corredor del Henares hay más naves que pueblos. Si has comprado algo por internet, ha pasado por mis manos.",
                "Toma, que hoy sobraban cajas. Una sí, una no, como en la cinta."]),
            ("Mujer", "npc_woman", "cocina", ["Mi marido trabaja de noche moviendo paquetes. De día no encuentra ni las llaves."]),
        ],
    },
    "ruta_5/casa_2": {
        "tipo": "casa", "nombre": "Casa del repartidor de la A-2",
        "gente": [
            ("Repartidor", "repartidorbici", "libre", [
                "Hago doscientas entregas al día. Si no estás en casa, el paquete se queda con la vecina. La vecina ya tiene un almacén.",
                "La A-2 a las ocho es un aparcamiento con carriles."]),
            ("Hija", "npc_girl", "tele", ["Mi padre me trae cajas de cartón vacías. Con ellas he construido un castillo en el salón."]),
        ],
    },
    "ruta_5/sala_calle_31_12": {
        "tipo": "universidad", "nombre": "Universidad de Alcalá, Colegio de San Ildefonso",
        "gente": [
            ("Profesora de Letras", "npc_woman", "dependiente", [
                "La fundó el cardenal Cisneros en 1499. Aquí el rey entrega cada abril el Premio Cervantes, en el Paraninfo.",
                "El patio trilingüe se llama así porque se enseñaba latín, griego y hebreo. Ahora, inglés y paciencia."]),
            ("Estudiante", "estudianteinge_f", "publico", ["Estudio Filología. Leo el Quijote por tercera vez. Esta vez, voluntariamente."]),
        ],
        "carteles": [("pared", ["Fachada plateresca de San Ildefonso (1543). Patrimonio de la Humanidad. Y de los estudiantes que hacen fotos de la orla."])],
    },
    "ruta_5/sala_calle_47_11": {
        "tipo": "casa", "nombre": "Casa natal de Cervantes",
        "gente": [
            ("Guía", "npc_lass", "libre", [
                "Miguel de Cervantes nació en Alcalá en 1547. En la puerta hay una estatua de don Quijote y Sancho sentados en un banco.",
                "Todo el mundo se hace la foto con Sancho. Don Quijote se queda solo, mirando a lo lejos. Como en el libro."]),
            ("Lector", "tertuliano", "libre", ["En un lugar de Alcalá, de cuyo nombre sí quiero acordarme… Así empiezo mis cartas."]),
        ],
        "carteles": [("pared", ["Cocina de una casa del siglo XVI: un fogón, un pozo y una mesa. Aquí comía la familia de Cervantes, más o menos."])],
    },
    "ruta_5/sala_calle_56_12": {
        "tipo": "palacio", "nombre": "Palacio del Infantado de Guadalajara",
        "gente": [
            ("Guía", "npc_lass", "libre", [
                "La fachada está llena de puntas de diamante, como un castillo de joyería. Es del siglo XV, de los Mendoza.",
                "Lo bombardearon en la guerra y se quemaron los frescos. El patio de los leones aguantó. Los leones son duros."]),
            ("Vigilante", "npc_man", "vitrina", ["Dentro está el museo de Guadalajara. Se viene por la fachada y se queda uno por el museo."]),
        ],
    },
    "ruta_5/sala_calle_58_27": {
        "tipo": "portal", "nombre": "Portal de Azuqueca de Henares",
        "gente": [("Vecina", "npc_old_woman", "libre", [
            "Azuqueca era un pueblo y ahora es una ciudad dormitorio. Duermen aquí y trabajan en Madrid. Algunos duermen en el tren.",
            "En este portal hay gente de veinte países. Las fiestas de la comunidad son las mejores de la provincia."])],
    },
    "ruta_5/sala_calle_65_11": {
        "tipo": "casa", "nombre": "Casa de las cigüeñas de Alcalá",
        "gente": [
            ("Ornitóloga", "ornitologa", "libre", [
                "Alcalá tiene más de cien nidos de cigüeña en los tejados. Es la ciudad de las cigüeñas. Ellas no pagan IBI.",
                "En febrero ya están aquí. Antes venían en primavera; ahora se adelantan, como las rebajas."]),
            ("Hijo", "npc_boy", "tele", ["Una cigüeña me ha mirado mal desde la torre. Creo que es la de los bebés y me ha reconocido."]),
        ],
    },
}
