# Interiores de la Ruta 20 (Sierra de Aralar: el santuario y la borda de los pastores). Propuesta provisional.
SALAS = {
    "ruta_20/sala_calle_18_28": {
        "tipo": "rural", "nombre": "Borda del pastor",
        "gente": [
            ("Pastora", "pastor", "libre", [
                "En la borda hacemos el queso como siempre: leche cruda de latxa, cuajo y paciencia. El ahumado le da el humo de la chimenea.",
                "En verano vivo aquí arriba con las ovejas. No hay cobertura. Las ovejas no me preguntan si he visto el último mensaje."]),
            ("Aizkolari", "npc_man", "libre", ["Entreno cortando troncos para la plaza del pueblo. Mi mujer dice que en casa no corto ni el pan."]),
        ],
    },
    "ruta_20/sala_calle_20_5": {
        "tipo": "ermita", "nombre": "Santuario de San Miguel de Aralar",
        "gente": [
            ("Guardés del santuario", "npc_old_man", "cura", [
                "Cuenta la leyenda que el caballero Teodosio de Goñi pasó años aquí atado con cadenas, de penitencia, y que un dragón le salió al paso.",
                "San Miguel bajó del cielo y mató al dragón. Las cadenas siguen colgadas en la pared, por si alguien no se lo cree."]),
            ("Montañera", "montanera", "visitante", ["He subido desde Uharte-Arakil por el camino viejo. Tres horas. El dragón lo habría hecho en diez minutos."]),
        ],
        "carteles": [("pared", ["Unas cadenas de hierro colgadas en la pared. Las de Teodosio, dicen. Están frías aunque sea agosto."])],
        "dentro": {
            "ruta_20/sala_calle_20_5_frontal": {
                "tipo": "museo", "nombre": "Frontal esmaltado de Aralar",
                "gente": [("Guía del santuario", "profesor", "libre", [
                    "El frontal del altar es de cobre esmaltado del siglo XII, una de las grandes joyas del románico europeo.",
                    "En 1979 lo robó un ladrón de arte famoso, Erik el Belga. Se recuperó casi todo; dos esmaltes siguen sin aparecer."])],
                "carteles": [("vitrina", ["El frontal de esmalte azul, verde y oro: la Virgen con el Niño en el centro y los apóstoles alrededor. Los huecos de los dos esmaltes perdidos siguen vacíos."])],
            },
        },
    },
}
