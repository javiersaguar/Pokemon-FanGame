# Interiores de la Ruta 4 (El Escorial, la urbanización de Galapagar y la A-6). Propuesta provisional.
# El «chalet de la colina» (sala_calle_38_28) queda sin dueño: quién vive ahí lo decide Javier.
SALAS = {
    "ruta_4/casa_1": {
        "tipo": "taberna", "nombre": "Venta de la carretera del Escorial",
        "gente": [
            ("Ventero", "camarero", "regalo:tras_mostrador", [
                "Esta venta da de comer a los arrieros desde antes de que hubiera monasterio. Ahora, a los ciclistas de los domingos.",
                "Toma, invita la casa. Que con la cuesta que te queda hasta Madrid, vas a necesitar algo más que un café."]),
            ("Ciclista", "crossfitero", "cliente", [
                "Salgo de Madrid a las siete, subo a Abantos y bajo a desayunar aquí. Gasto en bici lo que un coche y en lycra lo que un traje."]),
        ],
    },
    "ruta_4/casa_2": {
        "tipo": "casa", "nombre": "Casa del guía del Monasterio",
        "gente": [
            ("Guía del Monasterio", "profesor", "mesa", [
                "En el Panteón de Reyes hay sitio contado: los reyes y las madres de reyes. El resto de la familia, al de Infantes, que es como el trastero.",
                "Felipe II gobernaba medio mundo desde una celda pequeña con una ventana que daba al altar. Teletrabajo del siglo XVI."]),
            ("Hija opositora", "opositor_f", "estanteria", ["Oposito a archivera. Mi padre dice que el Monasterio tiene cuarenta mil libros. Yo ya me he leído el temario, que es más largo."]),
        ],
    },
    "ruta_4/sala_calle_34_14": {
        "tipo": "casa", "nombre": "Casa del restaurador jubilado",
        "gente": [
            ("Restaurador jubilado", "jubiladoobras", "tele", [
                "Treinta años restaurando frescos en la Biblioteca del Monasterio. Ahora restauro el sofá: también tiene grietas.",
                "Los libros de esa biblioteca están colocados con el lomo hacia dentro, para que respiren. Ojalá me hubieran colocado así a mí."]),
        ],
    },
    "ruta_4/sala_calle_29_27": {
        "tipo": "chalet", "nombre": "Chalet de la presidenta de la comunidad",
        "gente": [
            ("Presidenta de la comunidad", "npc_woman", "mesa", [
                "Soy presidenta de la urbanización desde 2009. No me ha votado nadie: no se presenta nadie más.",
                "Orden del día de la próxima junta: el seto del 14, el perro del 21 y los periodistas que se asoman a la colina."]),
            ("Marido", "padretarjeta", "sofa", ["Yo voy a las juntas a callarme. Es la única reunión en la que no tengo que pagar yo."]),
        ],
    },
    "ruta_4/sala_calle_38_28": {
        "tipo": "chalet", "nombre": "Chalet de la colina",
        "gente": [
            ("Guardia civil de la puerta", "policia", "libre", [
                "Los dueños no están. Quiénes son, no te lo puedo decir. Tampoco te lo preguntaría yo, que es tu primer día por aquí.",
                "Tiene piscina, barbacoa y dieciséis cámaras. Una de ellas te está grabando ahora. Saluda."]),
        ],
        "carteles": [("pared", ["Cajas de la mudanza, todavía cerradas. En la de arriba alguien ha escrito «LIBROS» y ha tachado «MUCHOS»."])],
    },
    "ruta_4/sala_calle_45_28": {
        "tipo": "chalet", "nombre": "Chalet de la teletrabajadora",
        "gente": [
            ("Teletrabajadora", "influencerlinkedin_f", "mesa", [
                "Me vine a la sierra para teletrabajar con vistas. Ahora la empresa nos obliga a ir a la oficina tres días: hora y media de A-6.",
                "Mi perfil dice «Remote first». Mi coche dice ciento veinte mil kilómetros."]),
        ],
    },
    "ruta_4/sala_calle_30_38": {
        "tipo": "chalet", "nombre": "Chalet del tertuliano",
        "gente": [
            ("Tertuliano", "tertuliano", "tele", [
                "Por la mañana opino de economía, por la tarde de vulcanología y por la noche de fútbol. De todo con la misma seguridad.",
                "Me compré el chalet con lo que cobro por gritar. Aquí no grito: los vecinos me denunciarían."]),
            ("Su mujer", "npc_lass", "cocina", ["En casa le tengo prohibido opinar. Se pone tan nervioso que tiene que encender la tele para que le lleven la contraria."]),
        ],
    },
    "ruta_4/sala_calle_38_39": {
        "tipo": "chalet", "nombre": "Chalet de la familia del pádel",
        "gente": [
            ("Jugadora de pádel", "crossfitero_f", "libre", [
                "En la urbanización hay tres pistas de pádel y ninguna biblioteca. Las pistas están siempre llenas.",
                "Juego los martes con la del 14 y los jueves contra ella. Los martes somos amigas."]),
            ("Hijo", "npc_youngster", "tele", ["Mis padres juegan al pádel, mis tíos juegan al pádel y el perro persigue las pelotas de pádel. Yo juego a Pokémon."]),
        ],
    },
    "ruta_4/sala_calle_44_39": {
        "tipo": "chalet", "nombre": "Chalet de la familia del repartidor",
        "gente": [
            ("Repartidor", "repartidorbici", "libre", [
                "En esta urbanización no hay números en las casas: hay nombres. «Villa Paquita», «El Refugio», «Casa Dani». El GPS se pone a llorar.",
                "Vivo aquí con mis suegros. Reparto en los chalets de los demás y vuelvo al mío, que es el garaje."]),
            ("Suegra", "mom", "cocina", ["Mi yerno es muy trabajador. Lo sé porque viene a comer a las cinco y se vuelve a ir a las cinco y diez."]),
        ],
    },
    "ruta_4/sala_calle_9_24": {
        "tipo": "monasterio", "nombre": "Real Monasterio de San Lorenzo de El Escorial",
        "gente": [
            ("Fraile agustino", "npc_old_man", "cura", [
                "Este monasterio es a la vez basílica, palacio, biblioteca, panteón y colegio. Felipe II no quería mudarse cinco veces.",
                "En la biblioteca hay libros en árabe, hebreo y griego. Algunos llevan aquí más tiempo que la orden."]),
            ("Turista", "turista_f", "visitante", [
                "Me he perdido entre el palacio y la basílica. Un señor muy amable me ha dicho que eso le pasaba también al rey."]),
        ],
    },
}
