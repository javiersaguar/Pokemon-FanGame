# Interiores de Vigo. Propuesta provisional: nombres, gente y frases pendientes de Javier.
SALAS = {
    "vigo/casa_1": {
        "tipo": "casa", "nombre": "Casa de la mariscadora de Bouzas",
        "gente": [
            ("Mariscadora", "npc_old_woman", "regalo:cocina", [
                "Marisco a pie en la ría con marea baja: almeja, berberecho y navaja. Con el rastro y la espalda doblada.",
                "Toma, mi niño, que en Galicia nadie sale de casa sin comer. Y si sales, vuelves."]),
            ("Nieto", "npc_boy", "tele", ["Mi abuela sabe cuándo baja la marea sin mirar el móvil. Lo nota en las rodillas."]),
        ],
    },
    "vigo/casa_2": {
        "tipo": "casa", "nombre": "Casa del trabajador de los astilleros",
        "gente": [
            ("Soldador", "jubiladoobras", "tele", [
                "En los astilleros de Vigo se hacen barcos para medio mundo. Pesqueros, ferris y algún barco de investigación.",
                "Mi abuelo hacía barcos de madera, mi padre de hierro y yo de acero. Mi hijo los dibuja en el ordenador."]),
            ("Mujer", "npc_woman", "cocina", ["Empanada de zamburiñas. La masa la hago yo; las zamburiñas las pesca mi cuñado."]),
        ],
    },
    "vigo/casa_3": {
        "tipo": "taller", "nombre": "Taller del conservero",
        "gente": [
            ("Conservero", "npc_man", "mesa", [
                "Vigo es la capital de la conserva. Mejillones en escabeche, berberechos y sardinillas. La lata es tecnología gallega.",
                "Una buena lata de berberechos cuesta más que un menú del día. Y la abres con una mano."]),
            ("Aprendiz", "npc_youngster", "libre", ["Mi trabajo es poner las etiquetas bonitas. Las latas feas no las compra nadie."]),
        ],
        "carteles": [("estanteria", ["Latas de conserva en escabeche, en aceite y al natural. Ordenadas por año. Como el vino."])],
    },
    "vigo/casa_4": {
        "tipo": "casa", "nombre": "Casa del vecino de Teis",
        "gente": [
            ("Vecino", "npc_old_man", "libre", [
                "Vigo tiene cuestas que son paredes. Para subir a casa necesito dos bocadillos y un rosario.",
                "El ascensor de la Gran Vía es de 2023. Antes subíamos como cabras. Ahora subimos como cabras con ascensor."]),
            ("Hija", "npc_lass", "tele", ["Mi padre se queja de las cuestas, pero tiene las piernas como un ciclista."]),
        ],
    },
    "vigo/sala_calle_11_7": {
        "tipo": "casa", "nombre": "Casa de la pulpeira",
        "gente": [
            ("Pulpeira", "npc_old_woman", "cocina", [
                "Al pulpo se le «asusta» tres veces en el agua hirviendo antes de cocerlo. Para que no se encoja.",
                "Pulpo á feira: en plato de madera, con sal gorda, pimentón y aceite. Con palillos, que el tenedor es de turistas."]),
            ("Marido", "npc_old_man", "tele", ["Llevo cuarenta años comiendo pulpo. No me he cansado. El pulpo, a lo mejor sí."]),
        ],
    },
    "vigo/sala_calle_16_8": {
        "tipo": "casa", "nombre": "Casa de la gaiteira",
        "gente": [
            ("Gaiteira", "flautista_f", "libre", [
                "Toco la gaita en la banda del barrio. En las fiestas tocamos hasta que la gente se cansa. La gente no se cansa.",
                "La gaita gallega tiene un solo roncón. La escocesa tres. Nosotros con uno hacemos más ruido."]),
            ("Vecino", "npc_man", "libre", ["Vivo en el piso de abajo. Me sé todas las muiñeiras de memoria, quiera o no."]),
        ],
    },
    "vigo/sala_calle_17_29": {
        "tipo": "taberna", "nombre": "Ostrería de la calle de A Pedra",
        "gente": [
            ("Ostrera", "npc_old_woman", "dependiente", [
                "Las ostreras de A Pedra abren las ostras en la calle desde hace un siglo. Con limón y un albariño, y se acabó la discusión.",
                "Una docena de ostras para la mesa del fondo. No preguntes de dónde son: son de la ría, y ya está."]),
            ("Cliente", "tertuliano", "cliente", ["Me tomo seis ostras cada domingo. Es mi misa."]),
        ],
    },
    "vigo/sala_calle_33_18": {
        "tipo": "gimnasio", "nombre": "Basic-Fit de Vigo",
        "gente": [
            ("Monitor", "crossfitero", "libre", [
                "Aquí la gente entrena para subir las cuestas de Vigo. Las máquinas de escaleras son las más usadas.",
                "Cuando llueve, el gimnasio se llena. Llueve casi siempre. Somos un negocio redondo."]),
            ("Socia", "crossfitero_f", "libre", ["Corro por la Castrelos los fines de semana. Bueno, corro hasta que llueve. Luego, aquí."]),
        ],
    },
    "vigo/sala_calle_3_6": {
        "tipo": "casa", "nombre": "Casa del aficionado del Celta",
        "gente": [
            ("Celtista", "npc_man", "tele", [
                "Afouteza e corazón. El Celta es de Vigo y Balaídos es nuestra casa. Lo demás, ya se verá.",
                "Cuando el Celta gana al Deportivo, la ciudad hace fiesta. Cuando pierde, decimos que el árbitro era de Coruña."]),
            ("Hijo", "npc_boy", "libre", ["Mi padre me puso de nombre Iago por Iago Aspas. Mi hermana se llama Celta. No es broma."]),
        ],
    },
    "vigo/sala_calle_42_18": {
        "tipo": "portal", "nombre": "Portal de la calle Príncipe",
        "gente": [("Portera", "npc_old_woman", "libre", [
            "La calle Príncipe es la de las tiendas. En Navidad se llena de luces y de gente mirando las luces.",
            "En diciembre no puedo salir del portal: hay cola para hacerse fotos con el árbol de enfrente."])],
    },
    "vigo/sala_calle_42_32": {
        "tipo": "ayuntamiento", "nombre": "Concello de Vigo",
        "gente": [
            ("Técnico de alumbrado", "npc_man", "mesa", [
                "Encendemos las luces de Navidad en noviembre y las apagamos en enero. El año que viene, a lo mejor, en octubre.",
                "Once millones de luces LED. El alcalde quiere que se vean desde Nueva York. Hemos mirado y desde Nueva York no se ven."]),
            ("Concejala", "npc_woman", "dependiente", ["Las luces atraen a medio millón de visitantes. Los hoteles nos dan las gracias. Los vecinos, no tanto."]),
        ],
        "carteles": [("pared", ["CONTADOR DE LUCES DE NAVIDAD: 11.000.000 y subiendo. Próximo objetivo: que se vean desde la Luna."])],
    },
    "vigo/sala_calle_49_31": {
        "tipo": "piso", "nombre": "Piso con vistas a las islas Cíes",
        "gente": [
            ("Vecina", "npc_woman", "tele", [
                "Desde la ventana se ven las Cíes. Dicen que la playa de Rodas es la mejor del mundo. Lo dijo un periódico inglés y aquí lo repetimos siempre.",
                "Para ir a las Cíes hay que pedir permiso a la Xunta. Para volver, pedir que no llueva."]),
            ("Hijo", "npc_youngster", "libre", ["Fui de acampada a las Cíes. Me comieron los mosquitos y las gaviotas me robaron un bocadillo."]),
        ],
    },
}
