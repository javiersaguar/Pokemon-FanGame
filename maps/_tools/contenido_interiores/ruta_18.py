# Interiores de la Ruta 18 (Picos de Europa y el pueblo de la sidrería). Propuesta provisional.
# La basílica y la cueva de Covadonga tienen sus salas propias (maps/_pintura/pintar_salas_hitos.gd) y no están aquí.
SALAS = {
    "ruta_18/sala_calle_21_18": {
        "tipo": "tienda", "nombre": "Quesería de Cabrales",
        "gente": [
            ("Quesera", "npc_woman", "tras_mostrador", [
                "El Cabrales madura en cuevas de los Picos, con leche cruda de vaca, oveja y cabra. Si huele fuerte, es que está bueno.",
                "Hubo un año que se pagaron más de veinte mil euros por un queso en subasta. El mío te lo dejo a precio de cuñado."]),
            ("Cliente", "turista", "cliente", ["Me he llevado medio queso. Lo he metido en la maleta. Mi maleta ya es de Cabrales."]),
        ],
    },
    "ruta_18/sala_calle_27_18": {
        "tipo": "bar", "nombre": "Sidrería del pueblo",
        "gente": [
            ("Escanciadora", "camarero", "tras_mostrador", [
                "La sidra se escancia para que rompa contra el vaso y coja aire. Un culín se bebe de un trago; lo que sobra, al suelo.",
                "Las paredes de una buena sidrería huelen a manzana y el suelo es de serrín. Si brilla, no es una sidrería."]),
            ("Cliente", "npc_old_man", "cliente", [
                "Cachopo para dos, fabada para dos y arroz con leche para dos. Somos uno, pero con hambre de dos."]),
        ],
    },
    "ruta_18/sala_calle_45_18": {
        "tipo": "rural", "nombre": "Casa de la vaqueira",
        "gente": [
            ("Vaqueira", "npc_woman", "libre", [
                "Los vaqueiros de alzada subíamos con el ganado a los puertos en verano y bajábamos en invierno. Media vida en cada sitio.",
                "En los lagos ya no se sube en coche. Las vacas siguen subiendo andando. Ellas no necesitan autobús."]),
            ("Su padre", "npc_old_man", "tele", ["Asturias tiene más vacas que turistas. En agosto, casi empate."]),
        ],
    },
}
