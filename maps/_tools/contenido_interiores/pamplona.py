# Interiores de Pamplona (el Café Iruña tiene interior propio en pintar_salas_hitos.gd). Propuesta provisional.
SALAS = {
    "pamplona/sala_calle_25_36": {
        "tipo": "casa", "nombre": "Casa del corredor del encierro",
        "gente": [
            ("Corredor veterano", "npc_man", "libre", [
                "Llevo treinta San Fermines corriendo el encierro. Tengo un cuerno de recuerdo en la pierna y otro en la memoria.",
                "Antes de correr se le canta a San Fermín en la cuesta de Santo Domingo, tres veces. Con el periódico enrollado en la mano."]),
            ("Mujer", "npc_woman", "cocina", ["Cada 7 de julio a las ocho menos cinco rezo. A las ocho y tres, respiro."]),
        ],
    },
    "pamplona/sala_calle_26_17": {
        "tipo": "gimnasio", "nombre": "Basic-Fit de Pamplona",
        "gente": [
            ("Monitora", "crossfitero_f", "libre", [
                "En junio entrenan los que van a correr el encierro. Hacen series de ochocientos metros, que es lo que dura.",
                "El que mejor corre es un abuelo de setenta años. Lleva cincuenta encierros y ninguna cogida."]),
            ("Socio", "crossfitero", "libre", ["Entreno para correr delante de los toros. Mi madre cree que es para un maratón."]),
        ],
    },
    "pamplona/sala_calle_40_17": {
        "tipo": "ayuntamiento", "nombre": "Ayuntamiento de Pamplona",
        "gente": [
            ("Concejal", "npc_man", "mesa", [
                "Del balcón de este ayuntamiento sale el chupinazo el 6 de julio a mediodía. Abajo, cincuenta mil personas con el pañuelo en alto.",
                "«¡Pamploneses, irunshemes, viva San Fermín, gora San Fermín!» Y nueve días sin dormir."]),
            ("Ordenanza", "npc_old_man", "dependiente", ["El cohete lo prende cada año alguien distinto. Yo solo lo guardo el resto del año en un cajón."]),
        ],
        "carteles": [("pared", ["Fachada barroca del siglo XVIII. Desde el balcón se lanza el chupinazo. El balcón se queda solo los otros 364 días."])],
    },
    "pamplona/sala_calle_50_17": {
        "tipo": "catedral", "nombre": "Catedral de Santa María la Real",
        "gente": [
            ("Sacristán", "npc_old_man", "cura", [
                "Por fuera neoclásica y por dentro gótica. El claustro es de los más bonitos de Europa. Victor Hugo lo dijo, o algo así.",
                "En la torre está la campana María, de doce toneladas. Cuando suena, se entera hasta Logroño."]),
            ("Peregrino", "montanera", "publico", ["Llevo seis días de Camino desde Roncesvalles. Esta es la primera catedral grande. Me he sentado y no me levanto."]),
        ],
        "dentro": {
            "pamplona/sala_calle_50_17_claustro": {
                "tipo": "museo", "nombre": "Claustro gótico de la catedral",
                "gente": [("Guía", "npc_lass", "libre", [
                    "La Puerta Preciosa tiene la vida de la Virgen tallada en piedra. Se llama así porque, sencillamente, lo es.",
                    "En la Sala Capitular se reunían las Cortes de Navarra. Ahora se reúnen los turistas con la audioguía."])],
                "carteles": [("pared", ["Claustro de la catedral (siglos XIV–XV). Silencio, piedra y Pokémon de tipo Roca dormidos en los rincones."])],
            },
        },
    },
    "pamplona/sala_calle_50_44": {
        "tipo": "museo", "nombre": "Plaza de toros de Pamplona",
        "gente": [
            ("Pastor del encierro", "pastor", "libre", [
                "Los pastores llevan una vara y van detrás de la manada. Nuestro trabajo es que nadie se quede atrás, ni toro ni mozo.",
                "El encierro termina aquí, en la plaza. Después sueltan las vaquillas y los mozos saltan por encima. Valientes o algo."]),
            ("Mozo de blanco", "tuno", "libre", ["Llevo el pañuelo rojo desde el chupinazo. Me lo quitaré en el Pobre de mí, el 14 a medianoche."]),
        ],
        "carteles": [("pared", ["Plaza de toros (1922), al final de la calle Estafeta. Junto a la puerta, el busto de Hemingway, que la hizo famosa."])],
    },
    "pamplona/sala_calle_53_29": {
        "tipo": "pasteleria", "nombre": "Pastelería de los garroticos",
        "gente": [
            ("Pastelera", "npc_old_woman", "dependiente", [
                "Garroticos: hojaldre con chocolate. Los de Pamplona los comemos en el almuerzo de las once, como en la tienda.",
                "En San Fermín vendemos más pastas que en todo el invierno. Los corredores tienen hambre después del susto."]),
            ("Niña", "npc_girl", "cliente", ["Un garrotico y un rosco de San Blas. El de San Blas es para el resfriado de mi abuelo."]),
        ],
    },
    "pamplona/sala_calle_55_39": {
        "tipo": "casa", "nombre": "Casa de la peña sanferminera",
        "gente": [
            ("Socio de la peña", "npc_man", "tele", [
                "Las peñas tocamos la charanga en la plaza de toros durante la corrida. Nadie mira al toro; todos miran a la peña.",
                "Mi peña tiene cien años. Yo, cuarenta en ella. Mi garganta, diez de vida útil."]),
            ("Mujer", "npc_woman", "cocina", ["En julio la casa se llena de amigos de la peña. En agosto, de botellas vacías."]),
        ],
    },
    "pamplona/sala_calle_58_17": {
        "tipo": "casa", "nombre": "Casa del cocinero de la txistorra",
        "gente": [
            ("Cocinero", "camarero", "cocina", [
                "La txistorra navarra es fina y roja. Se fríe sin aceite, con su propia grasa, y se come con pan y vino.",
                "Espárragos de Navarra, pimientos del piquillo y alcachofas de Tudela. La huerta de Navarra no tiene rival."]),
            ("Hija", "npc_lass", "libre", ["En casa comemos menestra de verduras todas las semanas. En el colegio me llaman la Huerta."]),
        ],
    },
    "pamplona/sala_calle_59_29": {
        "tipo": "casa", "nombre": "Casa del aficionado de Osasuna",
        "gente": [
            ("Aficionado rojillo", "npc_old_man", "tele", [
                "Osasuna significa «salud». En El Sadar se canta tan alto que los rivales piden salud al salir.",
                "Llegamos a una final de Copa en 2023. Perdimos, pero Pamplona salió entera a la calle. Así somos."]),
            ("Nieto", "npc_boy", "libre", ["Mi abuelo tiene un cántico para cada jugador desde 1960. Algunos los inventa."]),
        ],
    },
}
