# Interiores de Murcia. Propuesta provisional: nombres, gente y frases pendientes de Javier.
SALAS = {
    "murcia/sala_calle_11_12": {
        "tipo": "teatro", "nombre": "Teatro Romea",
        "gente": [
            ("Tramoyista", "jubiladoobras", "libre", [
                "El Romea se ha quemado dos veces. Dicen que hay una maldición: que arderá tres veces. Yo no fumo dentro.",
                "Aquí han actuado todos los grandes. El aire acondicionado, no tanto."]),
            ("Actor", "npc_man", "artista", ["Esta noche hago de Don Juan Tenorio. En Murcia, en julio, con capa. Soy un héroe."]),
        ],
    },
    "murcia/sala_calle_12_25": {
        "tipo": "kiosco", "nombre": "Puesto de la plaza de las Flores",
        "gente": [("Floristera", "npc_old_woman", "dependiente", [
            "La plaza de las Flores se llama así por los puestos de flores. Ahora la mitad son de tapas. Las flores aguantan.",
            "Un ramo de claveles para la Fuensanta. La patrona se lo merece y tú vas a quedar bien."])],
    },
    "murcia/sala_calle_13_53": {
        "tipo": "casa", "nombre": "Casa del huertano de la Vega",
        "gente": [
            ("Huertano", "huertano", "libre", [
                "La huerta de Murcia se regaba con acequias árabes. Algunas siguen funcionando. Mi tractor, no.",
                "Pimientos, alcachofas, limones y lechugas. Aquí plantas una piedra y sale una berenjena."]),
            ("Huertana", "npc_old_woman", "cocina", ["Zarangollo: calabacín, cebolla y huevo. Pocas cosas, mucho cariño y un poquito de aceite."]),
        ],
    },
    "murcia/sala_calle_20_54": {
        "tipo": "portal", "nombre": "Portal del barrio del Carmen",
        "gente": [("Vecino", "npc_old_man", "libre", [
            "El Carmen está al otro lado del Puente Viejo. Antes era el barrio de los ferroviarios. Ahora es el de los bares.",
            "En verano la gente sale a la calle con la silla a tomar el fresco. El fresco no viene, pero la charla sí."])],
    },
    "murcia/sala_calle_23_11": {
        "tipo": "universidad", "nombre": "Universidad de Murcia, aula del Convento de la Merced",
        "gente": [
            ("Profesora", "npc_woman", "dependiente", [
                "La universidad nació en 1272 con Alfonso X. Luego cerró, volvió a abrir y aquí seguimos, entre exámenes.",
                "En junio hacemos exámenes a cuarenta grados. Es un examen de conocimientos y de resistencia."]),
            ("Estudiante", "estudianteinge", "publico", ["Tengo examen de Derecho Romano. Los romanos, al menos, tenían termas."]),
        ],
    },
    "murcia/sala_calle_25_25": {
        "tipo": "casino", "nombre": "Real Casino de Murcia",
        "gente": [
            ("Socio del Casino", "tertuliano", "tele", [
                "El patio árabe imita a la Alhambra, el salón de baile es versallesco y el tocador de señoras tiene un techo pintado de ángeles.",
                "Aquí se juega al dominó desde el siglo XIX. La partida de las cuatro aún no ha terminado."]),
            ("Camarero", "camarero", "dependiente", ["Café asiático: café, leche condensada, licor 43, coñac y canela, en copa de cristal. Es de Cartagena, pero lo servimos con orgullo."]),
        ],
        "carteles": [("pared", ["Salón de baile del Real Casino (1847). Lámparas de cristal, espejos y un suelo donde se ha bailado de todo menos reguetón."])],
    },
    "murcia/sala_calle_25_35": {
        "tipo": "piso", "nombre": "Piso con vistas al río Segura",
        "gente": [
            ("Vecina", "npc_woman", "tele", [
                "El Segura es el río más castigado de España: tiene más bancos de barro que agua.",
                "Cuando llueve fuerte, una vez cada diez años, el río se acuerda de que es un río."]),
            ("Hija", "npc_lass", "libre", ["Desde la ventana veo el Malecón. Allí paseo al perro y al novio, en ese orden."]),
        ],
    },
    "murcia/sala_calle_28_54": {
        "tipo": "pasteleria", "nombre": "Pastelería de los paparajotes",
        "gente": [
            ("Pastelera", "npc_old_woman", "dependiente", [
                "El paparajote es una hoja de limonero rebozada, frita y con azúcar. La hoja no se come. Todos los turistas se la comen.",
                "El pastel de carne lleva carne, huevo y chorizo dentro de un hojaldre. Aquí lo comemos de merienda. Y de almuerzo. Y de cena."]),
            ("Turista", "turista_f", "cliente", ["Me he comido la hoja del paparajote. Me han mirado como si hubiera matado a alguien."]),
        ],
        "carteles": [("vitrina", ["Paparajotes: la hoja es para dar sabor, NO SE COME. (Este cartel existe porque se la come todo el mundo.)"])],
    },
    "murcia/sala_calle_32_25": {
        "tipo": "puesto", "nombre": "Puesto de limones de la plaza",
        "gente": [("Limonero", "aceitunero", "dependiente", [
            "Limón verna y limón fino. Murcia es la huerta de Europa: si en Alemania hay limón, es de aquí.",
            "Un kilo de limones por un euro. En Berlín, el mismo limón vale tres. Y está triste."])],
    },
    "murcia/sala_calle_40_30": {
        "tipo": "catedral", "nombre": "Catedral de Santa María de Murcia",
        "gente": [
            ("Sacristán", "npc_old_man", "cura", [
                "La fachada barroca parece un retablo de piedra. La torre tardó doscientos años en hacerse. Paciencia murciana.",
                "Dentro está el corazón de Alfonso X. Literalmente. Lo pidió en su testamento."]),
            ("Nazareno", "costalero", "publico", ["En Semana Santa sacamos los pasos de Salzillo. En la procesión de los Salzillos se reparten caramelos y huevos duros."]),
        ],
        "dentro": {
            "murcia/sala_calle_40_30_salzillo": {
                "tipo": "museo", "nombre": "Sala de los Salzillos",
                "gente": [("Guía", "npc_lass", "vitrina", [
                    "Francisco Salzillo talló las imágenes de la Semana Santa murciana en el siglo XVIII. La Oración en el Huerto tiene un ángel que parece moverse.",
                    "En el belén de Salzillo hay más de quinientas figuras. Hay hasta un pastor durmiendo la siesta."])],
                "carteles": [("pared", ["La Dolorosa de Salzillo, 1755. Cada Viernes Santo sale a la calle y Murcia entera se pone de pie."])],
            },
        },
    },
    "murcia/sala_calle_41_11": {
        "tipo": "piso", "nombre": "Piso de la familia de la plaza Circular",
        "gente": [
            ("Madre", "npc_woman", "cocina", [
                "Aquí se dice «acho» para todo. Acho, ven; acho, para; acho, qué calor. Es como una coma, pero con cariño.",
                "En el Bando de la Huerta todos nos vestimos de huertanos y salimos a la calle a comer. Aquí la fiesta es comer."]),
            ("Hijo", "npc_youngster", "tele", ["Mis amigos de Madrid me imitan el acento. Yo les digo «acho, pijo» y ya no saben qué decir."]),
        ],
    },
    "murcia/sala_calle_48_35": {
        "tipo": "ayuntamiento", "nombre": "Edificio Moneo del Ayuntamiento",
        "gente": [
            ("Arquitecta en visita", "npc_woman", "libre", [
                "Moneo diseñó la fachada como un retablo sin santos, para no competir con la catedral. Y aún así hubo polémica.",
                "Los huecos de la fachada siguen una partitura. Unos dicen que es música; otros, que son ventanas."]),
            ("Funcionario", "padretarjeta", "dependiente", ["Le atendemos de ocho a tres. Después, de nada: el sol también es funcionario."]),
        ],
    },
    "murcia/sala_calle_4_12": {
        "tipo": "portal", "nombre": "Portal de la Gran Vía",
        "gente": [("Portero", "npc_old_man", "libre", [
            "Aquí al lado está el termómetro de la Gran Vía. Marca cuarenta y cinco. En agosto, más, pero se rompe.",
            "En este portal los vecinos se saludan con un «qué calor» por la mañana y un «qué calor» por la noche."])],
    },
    "murcia/sala_calle_58_12": {
        "tipo": "piso", "nombre": "Piso del estudiante de Cartagena",
        "gente": [
            ("Estudiante cartagenero", "npc_youngster", "mesa", [
                "Soy de Cartagena. Murcia no es mi capital, es mi vecina. Esto en Cartagena se discute con fuerza.",
                "En Cartagena tenemos puerto, teatro romano y submarino. En Murcia tienen huerta. Ya está."]),
            ("Compañero murciano", "npc_boy", "tele", ["Cada día me dice lo del submarino. Cada día le digo que el submarino no navega."]),
        ],
    },
    "murcia/sala_calle_58_26": {
        "tipo": "gimnasio", "nombre": "Basic-Fit de Murcia",
        "gente": [
            ("Monitor", "crossfitero", "libre", [
                "Abrimos a las seis de la mañana porque a las doce ya hace demasiado calor para salir de casa.",
                "En agosto la sala de máquinas parece una sauna. Por eso no cobramos la sauna."]),
            ("Socio", "tronista", "libre", ["Me estoy poniendo fuerte para el Entierro de la Sardina. Hay que llevar las sardinas a la hoguera."]),
        ],
    },
    "murcia/sala_calle_59_34": {
        "tipo": "barraca", "nombre": "Barraca huertana",
        "gente": [
            ("Abuelo huertano", "huertano", "libre", [
                "La barraca se hacía con barro, caña y paja. Fresquita en verano y caliente en invierno. Mejor que algunos pisos.",
                "Esta la conservo para el Bando de la Huerta. El resto del año, la usan los gatos."]),
            ("Nieta", "npc_girl", "libre", ["Mi abuelo dice que las lechugas le hablan. Yo creo que son los Bulbasaur."]),
        ],
    },
    "murcia/sala_calle_59_53": {
        "tipo": "casa", "nombre": "Casa de la familia de la Fuensanta",
        "gente": [
            ("Abuela devota", "npc_old_woman", "tele", [
                "La Virgen de la Fuensanta baja a la ciudad dos veces al año. Y sube en romería hasta el santuario con medio Murcia detrás.",
                "Le he prometido ir andando al santuario si me toca la lotería. Juego poco, por si acaso."]),
            ("Nieto", "npc_boy", "libre", ["La romería es de seis kilómetros. Mi abuela la hace más rápido que yo."]),
        ],
    },
    "murcia/sala_calle_5_26": {
        "tipo": "floristeria", "nombre": "Floristería de la Vega",
        "gente": [
            ("Florista", "npc_lass", "dependiente", [
                "En la Batalla de las Flores se lanzan ramos desde las carrozas. Es la única batalla en la que nadie pierde.",
                "Las flores de la huerta duran poco con este calor. Hay que regalarlas rápido."]),
            ("Novio nervioso", "npc_man", "cliente", ["Necesito un ramo para pedir matrimonio. Que no sea de limón, por favor."]),
        ],
    },
    "murcia/sala_calle_63_25": {
        "tipo": "casa", "nombre": "Casa del cocinero del michirones",
        "gente": [
            ("Cocinero", "camarero", "cocina", [
                "Michirones: habas secas, chorizo, jamón y guindilla. Se cocinan toda la noche. Como mi suegra.",
                "La ensalada murciana lleva tomate, atún, huevo y aceitunas. No lleva lechuga. El que le pone lechuga, se va."]),
            ("Hija", "npc_lass", "tele", ["Mi padre ha salido en la tele local con sus michirones. Desde entonces firma los tápers."]),
        ],
    },
    "murcia/sala_calle_65_11": {
        "tipo": "casa", "nombre": "Casa de la familia del Entierro de la Sardina",
        "gente": [
            ("Sardinero", "npc_man", "libre", [
                "En el Entierro de la Sardina se tiran juguetes desde las carrozas. Después se quema una sardina gigante. Tiene sentido, más o menos.",
                "Soy de la peña sardinera desde hace treinta años. Llevo treinta años quemando la misma sardina."]),
            ("Mujer", "npc_woman", "cocina", ["Mi marido guarda en el trastero todos los juguetes que ha pillado en treinta años. No caben."]),
        ],
    },
    "murcia/sala_calle_65_34": {
        "tipo": "casa", "nombre": "Casa del agricultor del trasvase",
        "gente": [
            ("Agricultor", "huertano", "tele", [
                "Agua para todos, pone en las pancartas. El agua viene del Tajo por el trasvase. Y la discusión, de Toledo.",
                "Sin agua no hay huerta, y sin huerta no hay ensalada en media Europa. Que lo sepa el que decide."]),
            ("Hijo ingeniero", "estudianteinge", "mesa", ["Estoy estudiando el riego por goteo. Mi padre dice que el goteo es para los grifos."]),
        ],
    },
    "murcia/sala_calle_65_53": {
        "tipo": "casa", "nombre": "Casa de la bordadora de huertanos",
        "gente": [
            ("Bordadora", "npc_old_woman", "mesa", [
                "Bordo los refajos y los chalecos de huertano para el Bando. Tardo tres meses en cada uno. Se pone un día.",
                "Antes los bordaban todas las madres. Ahora los encargan por internet. A mí."]),
            ("Clienta", "npc_woman", "libre", ["He venido a recoger el refajo de mi hija. Le queda pequeño: ha crecido mientras lo bordaban."]),
        ],
    },
}
