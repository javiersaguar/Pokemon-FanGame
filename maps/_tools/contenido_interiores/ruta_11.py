# Interiores de la Ruta 11 (Orihuela, la Vega Baja, Elche y su Palmeral). Propuesta provisional.
SALAS = {
    "ruta_11/sala_calle_11_27": {
        "tipo": "casa", "nombre": "Casa de la profesora de Orihuela",
        "gente": [
            ("Profesora de Literatura", "profesor", "estanteria", [
                "Miguel Hernández aprendió a leer guardando cabras y escribió «Nanas de la cebolla» en la cárcel, para su hijo.",
                "Cada curso mis alumnos se aprenden un poema suyo. Cada curso alguno llora. Ese aprueba."]),
            ("Alumno", "npc_youngster", "mesa", ["La profe dice que Miguel Hernández era pastor y poeta. Yo soy jugador de Pokémon y poeta. Bueno, jugador."]),
        ],
        "carteles": [("estanteria", ["«Viento del pueblo», «El rayo que no cesa» y un cuaderno de clase con una cebolla dibujada en la tapa."])],
    },
    "ruta_11/sala_calle_17_27": {
        "tipo": "casa", "nombre": "Casa del huertano de la Vega Baja",
        "gente": [
            ("Huertano", "huertano", "libre", [
                "En 2019 la gota fría dejó la Vega Baja bajo el agua. Mi casa tuvo un metro y medio de río dentro. La marca sigue en la pared.",
                "La alcachofa de la Vega se recoge de noviembre a abril. Del resto del año se encargan las riadas y la sequía, por turnos."]),
            ("Su madre", "npc_old_woman", "cocina", ["Mi hijo habla de agua todo el día: si falta, si sobra, si llega. Aquí el tiempo no es conversación, es la cosecha."]),
        ],
        "carteles": [("pared", ["Una línea de lápiz en la pared, a la altura del pecho, con una fecha: «septiembre de 2019»."])],
    },
    "ruta_11/sala_calle_23_27": {
        "tipo": "casa", "nombre": "Casa de la familia del calzado",
        "gente": [
            ("Diseñadora de zapatos", "npc_woman", "mesa", [
                "Diseño zapatos para marcas que dicen que son italianas. Lo son: el dibujo lo hago en Elche y el nombre lo ponen en Milán.",
                "Mi abuela cosía en casa, mi madre en un taller y yo en el ordenador. Los pies siguen siendo los mismos."]),
            ("Abuela", "abuela", "tele", ["Tengo cien pares de zapatos y todos los he hecho yo. Y me pongo siempre las zapatillas de casa."]),
        ],
    },
    "ruta_11/sala_calle_35_28": {
        "tipo": "basilica", "nombre": "Basílica de Santa María de Elche",
        "gente": [
            ("Cantor del Misteri", "npc_old_man", "cura", [
                "El Misteri d'Elx cuenta la muerte y la subida al cielo de la Virgen. Se canta en valenciano antiguo cada agosto, desde hace seis siglos.",
                "Los cantores son vecinos de Elche, todos hombres y niños, también los papeles de mujer. Es patrimonio de la humanidad; las tradiciones, a veces, van despacio."]),
            ("Tramoyista", "npc_man", "libre", ["Yo bajo la granada del cielo desde la cúpula, con cuerdas y una manivela. Aquí la tramoya tiene seiscientos años y ninguna avería."]),
        ],
        "dentro": {
            "ruta_11/sala_calle_35_28_tramoya": {
                "tipo": "torre", "nombre": "Tramoya del Misteri",
                "gente": [("Maestro de tramoya", "npc_old_man", "libre", [
                    "Desde aquí arriba se maneja el «cielo»: una lona pintada que se abre para que bajen la granada dorada y el araceli con los ángeles.",
                    "El torno es de madera y las cuerdas se revisan cada año. Abajo hay un niño cantando colgado a veinte metros: aquí no se improvisa."])],
                "carteles": [("pared", ["Un torno de madera con una cuerda gruesa que se pierde por un agujero del suelo. Una etiqueta: «No tocar en agosto»."])],
            },
        },
    },
    "ruta_11/sala_calle_44_27": {
        "tipo": "casa", "nombre": "Casa del palmerero",
        "gente": [
            ("Mujer del palmerero", "npc_woman", "libre", [
                "Mi marido ata las hojas de las palmeras en verano para que no les dé el sol. En abril son palma blanca para el Domingo de Ramos.",
                "Las palmas trenzadas de Elche van al Vaticano. El Papa bendice nuestra palma y nosotros no salimos ni en la foto."]),
            ("Hija", "npc_girl", "mesa", ["Estoy trenzando una palma para mi abuela. Llevo dos horas y tengo una cosa que parece una escoba."]),
        ],
    },
}
