# Interiores de la Ruta 2 (Tierra de Pinares, Cantalejo y el Azoguejo de Segovia). Propuesta provisional.
SALAS = {
    "ruta_2/casa_1": {
        "tipo": "casa", "nombre": "Casa del resinero de Cantalejo",
        "gente": [
            ("Resinero", "resinero", "regalo:libre", [
                "Le hago una herida al pino, le pongo un pote y en un mes tengo resina. El pino no se queja; mi espalda, sí.",
                "Toma, para las heridas del camino. Las de los pinos se curan solas; las tuyas, con esto."]),
            ("Mujer del resinero", "npc_woman", "cocina", [
                "Todo en esta casa huele a trementina: la ropa, el pan y el perro. Te acostumbras a los veinte años, más o menos."]),
        ],
    },
    "ruta_2/casa_2": {
        "tipo": "casa", "nombre": "Casa de la trillera",
        "gente": [
            ("Abuela trillera", "abuela", "tele", [
                "Mi padre clavaba las lascas de sílex en los trillos con un martillo pequeño. Diez mil piedras por trillo.",
                "Ahora los compran para colgarlos en la pared del salón. A mí me parece bien: por fin descansan."]),
            ("Nieto", "npc_boy", "libre", [
                "Mi abuela dice que con un trillo se separa el grano de la paja. Yo con el móvil separo los vídeos buenos de los malos."]),
        ],
        "carteles": [("pared", ["Un trillo colgado de la pared, con una etiqueta: «No es una mesa. No apoyes el vaso»."])],
    },
    "ruta_2/sala_calle_2_51": {
        "tipo": "casa", "nombre": "Casa del pastor de la cañada",
        "gente": [
            ("Pastor trashumante", "pastor", "libre", [
                "Por aquí pasa la Cañada Real Soriana. En otoño bajamos las merinas hasta Extremadura, a pie, como hace quinientos años.",
                "Una vez al año cruzamos el centro de Madrid hasta Cibeles con dos mil ovejas. Es el único día que allí no hay atasco: somos el atasco."]),
        ],
    },
    "ruta_2/sala_calle_27_51": {
        "tipo": "restaurante", "nombre": "Mesón del cochinillo",
        "gente": [
            ("Camarera", "camarero", "tras_mostrador", [
                "Cochinillo de menos de tres semanas, cordero lechal y judiones de La Granja. De postre, ponche segoviano.",
                "¿Algo vegetariano? Los judiones. Bueno, llevan chorizo, oreja y morro. Pero el judión es vegetal."]),
            ("Turista japonés", "turista", "mesa", [
                "Vine por el Acueducto y me quedo por el cochinillo. En mi país esto saldría en la tele todos los días."]),
            ("Comensal", "cunado", "cliente", [
                "Yo el cochinillo lo corto con la mano, que el plato ya lo rompe el mesonero. Y luego se lo cobra a otro."]),
        ],
    },
    "ruta_2/sala_calle_2_61": {
        "tipo": "panaderia", "nombre": "Pastelería del ponche segoviano",
        "gente": [
            ("Pastelera", "npc_woman", "tras_mostrador", [
                "Ponche segoviano: bizcocho, crema, mazapán y azúcar quemada en rombos. Un pedazo y no comes hasta el lunes.",
                "Lo inventó un pastelero de Segovia en los años veinte. Desde entonces los dentistas de la ciudad viven muy bien."]),
            ("Clienta", "npc_old_woman", "cliente", ["Vengo a por una tarta para mi nieto. Y a por otra para mí, que nadie se entera."]),
        ],
    },
    "ruta_2/sala_calle_9_61": {
        "tipo": "casa", "nombre": "Casa del cantero",
        "gente": [
            ("Cantero jubilado", "npc_old_man", "tele", [
                "Los romanos pusieron veinte mil sillares sin una gota de argamasa. Yo puse un bordillo con cemento y se cayó en dos años.",
                "Cuando paso por debajo del Acueducto le hago una reverencia. Es lo que se hace con un compañero mayor."]),
            ("Hija", "npc_lass", "libre", ["Mi padre lleva cuarenta años diciendo que el Acueducto lo hicieron sin grúa. Ni sin grúa ni sin seguro, papá."]),
        ],
    },
    "ruta_2/sala_calle_14_61": {
        "tipo": "casa", "nombre": "Piso de estudiantes del Azoguejo",
        "gente": [
            ("Estudiante de Empresariales", "influencerlinkedin", "mesa", [
                "Estudio en la universidad privada del convento. Pago lo de un piso en Madrid por vivir con vistas a un acueducto.",
                "Mis padres creen que estudio. Yo creo que estoy haciendo contactos. El Acueducto cree que esto ya lo ha visto antes."]),
            ("Compañera de piso", "estudianteinge_f", "libre", ["Hay calefacción, pero el casero la apaga en abril. En Segovia, en abril, nieva."]),
        ],
    },
    "ruta_2/sala_calle_27_61": {
        "tipo": "casa", "nombre": "Casa de los madrileños del fin de semana",
        "gente": [
            ("Padre de Madrid", "padretarjeta", "sofa", [
                "Nos compramos la casa para desconectar. Nos pasamos el sábado poniendo la fibra y el domingo en el atasco de vuelta.",
                "Los vecinos nos llaman «los de Madrid». Llevamos quince años viniendo. Seremos «los de Madrid» hasta que nos muramos."]),
            ("Vecina de toda la vida", "npc_old_woman", "libre", ["Vienen el viernes, se van el domingo y el resto de la semana la casa ladra. Tienen un perro de alarma."]),
        ],
    },
    "ruta_2/sala_calle_33_61": {
        "tipo": "casa", "nombre": "Casa del guía del Acueducto",
        "gente": [
            ("Guía turístico", "profesor", "estanteria", [
                "La leyenda dice que el diablo construyó el Acueducto en una noche para ganarse el alma de una aguadora.",
                "Le faltó una piedra antes de que cantara el gallo. Desde entonces, en Segovia todas las obras acaban con una piedra de menos."]),
        ],
        "carteles": [("estanteria", ["Libros sobre el Acueducto, la Catedral y el Alcázar. Uno se titula «Cómo explicar a un turista que el Alcázar no es de Disney»."])],
    },
}
