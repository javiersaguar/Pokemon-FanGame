# Interiores de Zaragoza. Propuesta provisional: nombres, gente y frases pendientes de Javier.
SALAS = {
    "zaragoza/casa_1": {
        "tipo": "casa", "nombre": "Casa de la abuela del Tubo",
        "gente": [
            ("Abuela del Tubo", "npc_old_woman", "regalo:cocina", [
                "Vivo encima del Tubo desde el setenta. Huelo las bravas antes de que las pidas.",
                "Toma, que vas muy flaco. En Zaragoza nadie sale de casa sin merendar."]),
            ("Nieto opositor", "opositor", "mesa", [
                "Estoy opositando a la DGA. Mi abuela dice que ya soy funcionario de su cocina.",
                "Cada vez que sopla el cierzo se me vuelan los apuntes por la ventana."]),
        ],
    },
    "zaragoza/casa_2": {
        "tipo": "taberna", "nombre": "Taberna La Migueleta, en El Tubo",
        "gente": [
            ("Tabernero", "camarero", "dependiente", [
                "Tenemos madejas, ternasco y un champiñón a la plancha que hace llorar a los de Huesca.",
                "En El Tubo las calles son tan estrechas que si abres los brazos tocas dos bares."]),
            ("Cliente de vermú", "cunado", "cliente", [
                "Aquí se viene a por una caña y se sale a las tres con un amigo nuevo y sin cartera.",
                "Yo sé arreglar el Real Zaragoza en una tarde. Que me llamen."]),
        ],
        "carteles": [("pared", ["Se prohíbe hablar mal del Real Zaragoza dentro del local. Fuera, también."])],
    },
    "zaragoza/sala_calle_13_39": {
        "tipo": "casa", "nombre": "Casa del baturro de la jota",
        "gente": [
            ("Baturro", "baturro", "libre", [
                "¡Que si quieres bolsa! Ah, no, que esto es una casa. Pues pasa, maño.",
                "La jota se baila con las piernas y se canta con la garganta. Lo de los Pokémon, con paciencia."]),
            ("Hija jotera", "npc_lass", "tele", [
                "Mi padre me enseñó la jota antes que a andar. Ahora la bailo en TikTok y se enfada.",
                "En el Pilar canto en la ofrenda de flores. Hay tantas flores que no se ve a la Virgen."]),
        ],
    },
    "zaragoza/sala_calle_17_53": {
        "tipo": "casa", "nombre": "Casa de la familia del cierzo",
        "gente": [
            ("Madre", "npc_woman", "cocina", [
                "Aquí las ventanas se cierran con dos manos y una rodilla. El cierzo no pide permiso.",
                "Mi marido salió a tender la ropa en 2019 y la sábana todavía está en Teruel."]),
            ("Hijo", "npc_boy", "tele", ["Con cierzo el balón llega solo a la portería. El problema es volver a por él."]),
        ],
    },
    "zaragoza/sala_calle_23_53": {
        "tipo": "pasteleria", "nombre": "Confitería de frutas de Aragón",
        "gente": [
            ("Confitera", "npc_old_woman", "dependiente", [
                "Frutas de Aragón: fruta escarchada bañada en chocolate. Se inventaron aquí y se regalan en toda España.",
                "Los adoquines del Pilar son caramelos tan duros que traen un chiste dentro para que te distraigas."]),
            ("Turista", "turista_f", "cliente", ["Me he comprado un adoquín de caramelo. He leído el chiste de dentro. Sigo sin entenderlo."]),
        ],
        "carteles": [("vitrina", ["ADOQUÍN DEL PILAR. Un kilo de caramelo. Recomendado por los dentistas de Zaragoza (por motivos económicos)."])],
    },
    "zaragoza/sala_calle_24_29": {
        "tipo": "basilica", "nombre": "Basílica del Pilar",
        "gente": [
            ("Sacristán", "npc_old_man", "cura", [
                "Esta basílica tiene once cúpulas y cuatro torres. Y una cola para besar el Pilar que da la vuelta a la plaza.",
                "En la guerra cayeron aquí dos bombas que no explotaron. Están colgadas en la pared, por si alguien duda."]),
            ("Peregrina", "npc_old_woman", "publico", ["He venido andando desde Calatayud. Me duelen los pies, pero la Pilarica lo vale."]),
            ("Infantico", "npc_boy", "libre", ["Soy de los Infanticos del Pilar, el coro. Cantamos todos los días. Los Pokémon de tipo Hada se ponen contentos."]),
        ],
        "carteles": [("pared", ["Dos bombas lanzadas en 1936 que no llegaron a estallar. Unos lo llaman milagro; los artificieros, mala espoleta."])],
        "dentro": {
            "zaragoza/sala_calle_24_29_capilla": {
                "tipo": "iglesia", "nombre": "Santa Capilla del Pilar",
                "gente": [("Devota", "npc_woman", "publico", [
                    "La columna se besa por detrás, por un agujerito. Hay tantos besos que el mármol está gastado.",
                    "Cada día le cambian el manto a la Virgen. Tiene más ropa que yo."])],
                "carteles": [("pared", ["EL PILAR. Según la tradición, la columna sobre la que se apareció la Virgen en el año 40. La cola, según la experiencia, de hora y media."])],
            },
        },
    },
    "zaragoza/sala_calle_28_53": {
        "tipo": "bodega", "nombre": "Bodega de vino de Cariñena",
        "gente": [
            ("Bodeguero", "vendimiador", "dependiente", [
                "Garnacha de Cariñena y de Borja. Aquí el vino tiene más grados que la temperatura en agosto.",
                "Mi abuelo vendía el vino a granel en garrafa. Ahora lo vendo yo en botella con dibujo y cuesta el triple."]),
            ("Catador", "tertuliano", "cliente", ["Notas de frutos rojos, regaliz y un poco de cierzo. Lo del cierzo lo noto en todo."]),
        ],
    },
    "zaragoza/sala_calle_33_43": {
        "tipo": "taberna", "nombre": "Tasca de las madejas",
        "gente": [
            ("Cocinera", "npc_woman", "cocina", [
                "Las madejas son tripas de cordero trenzadas. Antes de probarlas, no preguntes. Después, tampoco.",
                "Aquí no hay carta. Hay lo que haya, y lo que haya está bueno."]),
            ("Universitario", "estudianteinge", "cliente", ["Vengo a estudiar al bar porque en la biblioteca no hay madejas."]),
        ],
    },
    "zaragoza/sala_calle_33_53": {
        "tipo": "piso", "nombre": "Piso de estudiantes de la Universidad",
        "gente": [
            ("Estudiante de Medicina", "estudianteinge_f", "mesa", [
                "Somos cuatro en un piso para dos. El casero dice que es «convivencia intensa».",
                "Zaragoza es barata para estudiar. Lo que es caro es salir de fiesta por la Zona."]),
            ("Compañero de piso", "npc_youngster", "tele", ["Llevo tres años en primero. Dicen que es por la Expo. Yo no estuve en la Expo."]),
        ],
    },
    "zaragoza/sala_calle_38_29": {
        "tipo": "ayuntamiento", "nombre": "Ayuntamiento de Zaragoza",
        "gente": [
            ("Concejala", "influencerlinkedin_f", "mesa", [
                "Tenemos tranvía desde 2011 y todavía hay quien lo espera en la parada del autobús.",
                "El pabellón puente de la Expo costó un dineral. Ahora es muy bonito para verlo desde fuera."]),
            ("Funcionario", "padretarjeta", "dependiente", ["Para empadronarse, pida cita. Para pedir cita, empadrónese."]),
        ],
        "carteles": [("pared", ["EXPO ZARAGOZA 2008. «Agua y desarrollo sostenible». La mascota se llamaba Fluvi. Nadie se acuerda de Fluvi."])],
    },
    "zaragoza/sala_calle_38_43": {
        "tipo": "casa", "nombre": "Casa de la Dolores",
        "gente": [
            ("Dolores", "npc_old_woman", "tele", [
                "Me llamo Dolores y soy de Calatayud. Sí, ya lo sé, la copla. No me la cantes.",
                "Me vine a Zaragoza para que dejaran de cantármela. Aquí me la cantan más."]),
            ("Vecino", "npc_old_man", "libre", ["Si vas a ir a Calatayud, pregunta por la Dolores. Ella te dirá que no vayas."]),
        ],
    },
    "zaragoza/sala_calle_38_53": {
        "tipo": "taller", "nombre": "Taller de los gigantes y cabezudos",
        "gente": [
            ("Artesano", "jubiladoobras", "mesa", [
                "Aquí arreglamos las cabezas de cartón piedra. El Robaculeros pierde la nariz todos los Pilares.",
                "Los cabezudos persiguen a los niños con una vara. Es tradición. Si lo hicieras tú, sería delito."]),
            ("Niño asustado", "npc_boy", "libre", ["El Forano me pegó con la vara el año pasado. Este año vengo con un Pokémon."]),
        ],
        "carteles": [("estanteria", ["Cabezas de cabezudos en reparación: el Tuerto, el Forano, la Pilara y el Robaculeros. No las mires a los ojos."])],
    },
    "zaragoza/sala_calle_39_21": {
        "tipo": "casa", "nombre": "Casa del barquero del Ebro",
        "gente": [
            ("Barquero", "piraguista", "libre", [
                "El Ebro baja con fuerza. Si te caes en marzo, apareces en Tortosa en mayo.",
                "Desde aquí se ve el Puente de Piedra. Lleva en pie desde el siglo XV. Mi barca, desde el lunes."]),
            ("Mujer del barquero", "npc_woman", "cocina", ["Mi marido dice que el río es su vida. Yo le digo que la cena también."]),
        ],
    },
    "zaragoza/sala_calle_3_36": {
        "tipo": "casa", "nombre": "Casa de la familia de la Expo",
        "gente": [
            ("Padre", "npc_man", "tele", [
                "En 2008 trabajé de voluntario en la Expo. Me quedé la gorra de Fluvi. Es lo único que queda.",
                "Aquí cerca está la Torre del Agua. Dentro hay una escultura de un chorro. Pagamos todos el chorro."]),
            ("Abuela", "npc_old_woman", "cocina", ["El ternasco se asa con patatas a lo pobre y con paciencia. Sin prisas, como el AVE de antes."]),
        ],
    },
    "zaragoza/sala_calle_49_31": {
        "tipo": "catedral", "nombre": "Catedral del Salvador, La Seo",
        "gente": [
            ("Canónigo", "npc_old_man", "cura", [
                "La Seo tiene un poco de todo: románico, gótico, mudéjar, barroco… Es la catedral más indecisa de España.",
                "Zaragoza tiene dos catedrales. Una para los turistas y la otra para los de aquí. Adivina cuál es cuál."]),
            ("Guía", "npc_lass", "libre", ["La pared mudéjar de la parroquieta es Patrimonio de la Humanidad. La cola para verla, también."]),
        ],
        "dentro": {
            "zaragoza/sala_calle_49_31_tapices": {
                "tipo": "museo", "nombre": "Museo de Tapices de La Seo",
                "gente": [("Vigilante", "npc_man", "vitrina", ["Tapices flamencos de los siglos XV y XVI. No se tocan. Ni con la mirada, a ser posible."])],
                "carteles": [("pared", ["Una de las mejores colecciones de tapices góticos del mundo. Bordados a mano durante años. Sin tele, sin Pokémon."])],
            },
        },
    },
    "zaragoza/sala_calle_4_46": {
        "tipo": "portal", "nombre": "Portal de la calle Alfonso",
        "gente": [("Portera", "npc_old_woman", "libre", [
            "La calle Alfonso va del Pilar al Coso. Es la calle de pasear y de mirar quién pasea.",
            "En este portal vivió un tenor que cantaba en el ascensor. El ascensor sigue sin arreglar."])],
    },
    "zaragoza/sala_calle_4_56": {
        "tipo": "oficina", "nombre": "Oficina de logística de Plaza",
        "gente": [
            ("Jefa de almacén", "influencerlinkedin_f", "mesa", [
                "Plaza es la plataforma logística más grande de Europa. Si lo has comprado por internet, ha pasado por aquí.",
                "Aquí el cierzo es un empleado más: empuja los camiones hacia Barcelona gratis."]),
            ("Camionero", "cunado", "libre", ["Llevo ocho horas de ruta y me queda la vuelta. El Monegros de noche parece la Luna."]),
        ],
    },
    "zaragoza/sala_calle_58_22": {
        "tipo": "casa", "nombre": "Casa del aficionado del Real Zaragoza",
        "gente": [
            ("Aficionado", "npc_old_man", "tele", [
                "Fui a París en 1995 a ver la Recopa. El gol de Nayim desde medio campo lo cuento en todas las bodas.",
                "Ahora estamos en Segunda. Pero en Segunda se sufre más, y eso al aragonés le gusta."]),
            ("Nieta", "npc_girl", "libre", ["Mi abuelo me ha enseñado a decir «Nayim» antes que «mamá»."]),
        ],
        "carteles": [("pared", ["Bufanda de la Recopa de 1995, enmarcada. Huele a puro y a gloria."])],
    },
    "zaragoza/sala_calle_62_46": {
        "tipo": "portal", "nombre": "Portal del barrio de la Magdalena",
        "gente": [("Vecino joven", "perroflauta", "libre", [
            "La Magdalena es el barrio con más bares por metro cuadrado. Lo he medido yo, empíricamente.",
            "Aquí cerca está el Teatro Romano. Los romanos también salían de fiesta por esta zona."])],
    },
    "zaragoza/sala_calle_65_30": {
        "tipo": "gimnasio", "nombre": "Basic-Fit de Zaragoza",
        "gente": [
            ("Monitor", "crossfitero", "libre", [
                "El mejor ejercicio en Zaragoza es caminar contra el cierzo. Es cardio y es gratis.",
                "Tenemos cincuenta socios apuntados en enero. En febrero vienen tres."]),
            ("Socia", "crossfitero_f", "libre", ["Me he apuntado para el Pilar. Para la ofrenda de flores hay que estar en forma."]),
        ],
    },
    "zaragoza/sala_calle_65_56": {
        "tipo": "piso", "nombre": "Piso de la familia del Actur",
        "gente": [
            ("Madre teletrabajadora", "npc_woman", "mesa", [
                "Vivimos en el Actur, al otro lado del río. Hay más rotondas que vecinos.",
                "Desde la ventana se ve la Torre del Agua. Bonita es. Para qué sirve, ya es otra cosa."]),
            ("Hija", "npc_girl", "tele", ["En las fiestas del Pilar me disfrazo de baturra y me hacen fotos los japoneses."]),
        ],
    },
    "zaragoza/sala_calle_7_20": {
        "tipo": "casa", "nombre": "Casa del jubilado del Puente de Piedra",
        "gente": [
            ("Jubilado", "jubiladoobras", "libre", [
                "Llevo cuarenta años mirando el Ebro desde esta ventana. Ha crecido, ha bajado y ha vuelto a crecer.",
                "Los leones del Puente de Piedra son de 1991. Antes estaban los de verdad, de piedra vieja. Bueno, eso dicen."]),
            ("Mujer", "npc_old_woman", "cocina", ["Aquí se merienda pan con vino y azúcar. Eso dicen los de antes. Yo prefiero las frutas de Aragón."]),
        ],
    },
}
