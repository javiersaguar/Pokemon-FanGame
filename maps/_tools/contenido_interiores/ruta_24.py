# Interiores de la Ruta 24 (La Mancha: Consuegra y Campo de Criptana). Los molinos llevan nombres reales.
# Propuesta provisional, pendiente de Javier.
def molino(nombre, quien, aspecto, frases, cartel):
    return {"tipo": "molino", "nombre": nombre, "gente": [(quien, aspecto, "libre", frases)], "carteles": [("pared", cartel)]}


SALAS = {
    "ruta_24/casa_1": {
        "tipo": "casa", "nombre": "Casa del agricultor de la Mancha",
        "gente": [
            ("Agricultor manchego", "huertano", "regalo:libre", [
                "Aquí se siembra cereal, viña y azafrán. El azafrán se recoge flor a flor en otoño, de madrugada, antes de que abra.",
                "Toma, para el viaje. En La Mancha el horizonte está muy lejos y el bar más cercano, también."]),
            ("Mujer", "npc_woman", "cocina", ["Pisto manchego, gachas y queso. Lo que da la tierra, que no es poco."]),
        ],
    },
    "ruta_24/casa_2": {
        "tipo": "casa", "nombre": "Casa de la recolectora de azafrán",
        "gente": [
            ("Recolectora", "npc_old_woman", "mesa", [
                "Hacen falta unas ciento cincuenta mil flores para un kilo de azafrán. Por eso vale más que el oro.",
                "Desbriznar es sacar los tres estigmas rojos de cada flor. Toda la familia en la mesa de la cocina, una noche entera."]),
            ("Nieta", "npc_girl", "libre", ["Me han dejado desbriznar diez flores. He tardado una hora. Mi abuela hace cien en ese rato."]),
        ],
    },
    "ruta_24/sala_calle_3_10": molino("Molino Bolero", "Molinero", "npc_old_man",
        ["Este es el Bolero. Todos los molinos del cerro Calderico tienen nombre, como las personas.",
         "Cuando sopla el viento, las aspas giran y la piedra muele el trigo. Si no sopla, se espera. Aquí se espera mucho."],
        ["Molino Bolero. Muele de vez en cuando para los turistas, los días de la Fiesta de la Rosa del Azafrán."]),
    "ruta_24/sala_calle_7_10": molino("Molino Sancho", "Guía", "npc_lass",
        ["Se llama Sancho, por el escudero. El de al lado es Rucio, como su burro. En Consuegra todo es del Quijote.",
         "Desde aquí arriba se ve el castillo de la Muela y toda la llanura. Doce molinos en fila, mirando el viento."],
        ["Molino Sancho. Dentro, la escalera de caracol de madera que sube a la cámara de las piedras."]),
    "ruta_24/sala_calle_11_10": molino("Molino Rucio", "Turista japonés", "turista",
        ["I read Don Quixote in Japanese. Ahora entiendo por qué pensó que eran gigantes: son enormes.",
         "He subido el cerro andando. Mi Pokémon de tipo Volador ha subido volando. No me ha esperado."],
        ["Molino Rucio. Por la ventana de la cámara se ve el castillo de la Muela, de la Orden de San Juan."]),
    "ruta_24/sala_calle_15_10": molino("Molino del Verde Gabán", "Restaurador", "jubiladoobras",
        ["Cambio las velas de las aspas cada pocos años. El viento de la Mancha las deja como un trapo.",
         "La caperuza del molino gira para poner las aspas de cara al viento. Se mueve a mano, con un palo largo que se llama gobierno."],
        ["Molino del Caballero del Verde Gabán. Herramientas del molinero: martillo de picar la piedra, cedazo y saco."]),
    "ruta_24/sala_calle_19_10": molino("Molino Mambrino", "Molinera", "npc_old_woman",
        ["Mi abuelo molía aquí el trigo de todo el pueblo. Se cobraba con una parte de la harina: la maquila.",
         "El nombre viene del yelmo de Mambrino, que en el libro es una bacía de barbero. Don Quijote veía lo que quería ver."],
        ["Molino Mambrino. Las piedras: la solera abajo, quieta; la volandera arriba, girando. En medio, el trigo."]),
    "ruta_24/sala_calle_33_30": molino("Molino Burleta", "Guía de Criptana", "npc_lass",
        ["El Burleta es del siglo XVI y conserva la maquinaria original. Es uno de los tres molinos más antiguos de la sierra.",
         "Cervantes pudo ver estos mismos molinos. Por eso decimos que la batalla contra los gigantes fue aquí, no en Consuegra."],
        ["Molino Burleta (siglo XVI). Bien de Interés Cultural. Maquinaria original de madera, sin un clavo de hierro."]),
    "ruta_24/sala_calle_37_30": molino("Molino Infanto", "Aficionado al Quijote", "tertuliano",
        ["En Campo de Criptana y en Consuegra discutimos cuáles son los molinos del Quijote. Los dos tenemos razón, y ninguno.",
         "«Non fuyades, cobardes y viles criaturas…». Me lo sé de memoria. Los molinos, también: llevan oyéndolo cuatrocientos años."],
        ["Molino Infanto (siglo XVI). En sus muros firman los visitantes desde hace un siglo. Está prohibido, pero ahí están."]),
    "ruta_24/sala_calle_41_30": molino("Molino Sardinero", "Pintor de molinos", "npc_man",
        ["Pinto los molinos al atardecer. La luz de la Mancha es dorada y no hay montañas que la tapen.",
         "El Sardinero, el Burleta y el Infanto son los tres viejos. Los demás son jóvenes, de hace solo trescientos años."],
        ["Molino Sardinero (siglo XVI). En el piso alto, los engranajes de madera: la rueda catalina y la linterna."]),
    "ruta_24/sala_calle_35_40": {
        "tipo": "bodega", "nombre": "Cueva bodega de Campo de Criptana",
        "gente": [
            ("Bodeguero", "vendimiador", "dependiente", [
                "En Criptana hay cientos de cuevas excavadas en la roca para guardar el vino. Fresco en verano, templado en invierno.",
                "La Mancha es el viñedo más grande del mundo. Aquí no faltan uvas; falta que se beban despacio."]),
            ("Visitante", "turista_f", "cliente", ["He bajado a la cueva y hace un fresco buenísimo. Me quedo a vivir aquí."]),
        ],
    },
    "ruta_24/sala_calle_4_28": {
        "tipo": "casa", "nombre": "Casa del quesero manchego",
        "gente": [
            ("Quesero", "pastor", "libre", [
                "El queso manchego lleva la marca de la pleita en la corteza: el dibujo del esparto en zigzag. Si no la tiene, no es de aquí.",
                "Seis meses de curación para el semicurado, doce para el viejo. El viejo pica la lengua y alegra el alma."]),
            ("Mujer", "npc_woman", "cocina", ["Mi marido habla con las ovejas por la mañana y con los quesos por la tarde. Conmigo, en la cena."]),
        ],
    },
}
