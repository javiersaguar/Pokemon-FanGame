# Conexiones del mundo

> Generado con `python3 tools/mundo/grafo_mundo.py` a partir de los mapas pintados (`maps/**/*.tscn`). No se edita a mano: se vuelve a generar al pintar o unir mapas.

Bordes = `MapConnection` (se pasa andando, sin fundido; `span` = solo un tramo del borde). Pasarelas = `Warp` (ferris, avión, Cercanías). Los interiores aún no existen.

## Grupos de mapas unidos entre sí

- Se llega desde San Miguel de Bernuy (811 mapas): `alicante/centro`, `alicante/estanco`, `alicante/exterior`, `alicante/mercadona`, `alicante/sala_calle_12_9`, `alicante/sala_calle_19_32`, `alicante/sala_calle_20_43`, `alicante/sala_calle_22_9`, `alicante/sala_calle_24_20`, `alicante/sala_calle_28_33`, `alicante/sala_calle_29_20`, `alicante/sala_calle_31_8`, `alicante/sala_calle_32_12`, `alicante/sala_calle_42_19`, `alicante/sala_calle_42_42`, `alicante/sala_calle_42_8`, `alicante/sala_calle_44_32`, `alicante/sala_calle_4_9`, `alicante/sala_calle_50_26`, `alicante/sala_calle_50_31`, `alicante/sala_calle_51_43`, `alicante/sala_calle_55_26`, `alicante/sala_calle_55_31`, `alicante/sala_calle_56_42`, `alicante/sala_calle_58_12`, `alicante/sala_calle_68_36`, `alicante/sala_calle_6_19`, `alicante/sala_calle_7_43`, `barcelona/barceloneta/hospital`, `barcelona/ciutat_vella`, `barcelona/eixample`, `barcelona/estanco`, `barcelona/gimnasio_1`, `barcelona/gimnasio_2`, `barcelona/gimnasio_3`, `barcelona/gimnasio_lider`, `barcelona/hospital`, `barcelona/les_corts`, `barcelona/les_corts/mercadona`, `barcelona/mercadona`, `barcelona/sala_ciutat_vella_12_13`, `barcelona/sala_ciutat_vella_13_26`, `barcelona/sala_ciutat_vella_13_36`, `barcelona/sala_ciutat_vella_22_13`, `barcelona/sala_ciutat_vella_22_27`, `barcelona/sala_ciutat_vella_25_40`, `barcelona/sala_ciutat_vella_44_22`, `barcelona/sala_ciutat_vella_47_6`, `barcelona/sala_ciutat_vella_49_41`, `barcelona/sala_ciutat_vella_57_27`, `barcelona/sala_ciutat_vella_5_13`, `barcelona/sala_ciutat_vella_5_27`, `barcelona/sala_ciutat_vella_5_40`, `barcelona/sala_ciutat_vella_6_49`, `barcelona/sala_eixample_10_31`, `barcelona/sala_eixample_12_19`, `barcelona/sala_eixample_12_41`, `barcelona/sala_eixample_15_50`, `barcelona/sala_eixample_17_19`, `barcelona/sala_eixample_17_31`, `barcelona/sala_eixample_17_41`, `barcelona/sala_eixample_17_5`, `barcelona/sala_eixample_25_31`, `barcelona/sala_eixample_25_41`, `barcelona/sala_eixample_25_6`, `barcelona/sala_eixample_33_53`, `barcelona/sala_eixample_33_7`, `barcelona/sala_eixample_37_19`, `barcelona/sala_eixample_37_31`, `barcelona/sala_eixample_37_41`, `barcelona/sala_eixample_39_5`, `barcelona/sala_eixample_44_31`, `barcelona/sala_eixample_44_41`, `barcelona/sala_eixample_45_18`, `barcelona/sala_eixample_51_5`, `barcelona/sala_eixample_52_18`, `barcelona/sala_eixample_55_41`, `barcelona/sala_eixample_59_19`, `barcelona/sala_eixample_5_19`, `barcelona/sala_eixample_5_41`, `barcelona/sala_eixample_5_5`, `barcelona/sala_eixample_61_51`, `barcelona/sala_eixample_63_5`, `barcelona/sala_eixample_68_19`, `barcelona/sala_les_corts_13_12`, `barcelona/sala_les_corts_21_12`, `barcelona/sala_les_corts_21_23`, `barcelona/sala_les_corts_30_12`, `barcelona/sala_les_corts_38_13`, `barcelona/sala_les_corts_46_13`, `barcelona/sala_les_corts_47_29`, `barcelona/sala_les_corts_49_41`, `barcelona/sala_les_corts_4_13`, `barcelona/sala_les_corts_4_46`, `barcelona/sala_les_corts_53_22`, `barcelona/sala_les_corts_53_6`, `barcelona/sala_les_corts_55_30`, `barcelona/sala_les_corts_57_41`, `barcelona/sala_les_corts_60_13`, `casa_de_campo/exterior`, `getafe/casa_1`, `getafe/casa_2`, `getafe/casa_vecina`, `getafe/centro`, `getafe/estanco`, `getafe/exterior`, `getafe/mercadona`, `getafe/sala_calle_16_20`, `getafe/sala_calle_19_58`, `getafe/sala_calle_21_46`, `getafe/sala_calle_25_27`, `getafe/sala_calle_27_21`, `getafe/sala_calle_30_58`, `getafe/sala_calle_31_47`, `getafe/sala_calle_37_36`, `getafe/sala_calle_4_46`, `getafe/sala_calle_4_58`, `getafe/sala_calle_51_6`, `getafe/sala_calle_54_44`, `getafe/sala_calle_55_23`, `getafe/sala_calle_59_7`, `getafe/sala_calle_5_9`, `huelva/casa_1`, `huelva/casa_2`, `huelva/centro`, `huelva/estanco`, `huelva/exterior`, `huelva/mercadona`, `huelva/sala_calle_20_12`, `huelva/sala_calle_31_12`, `huelva/sala_calle_39_27`, `huelva/sala_calle_46_31`, `huelva/sala_calle_49_8`, `huelva/sala_calle_53_17`, `huelva/sala_calle_55_8`, `ibiza/casa_1`, `ibiza/casa_2`, `ibiza/centro`, `ibiza/estanco`, `ibiza/exterior`, `ibiza/mercadona`, `ibiza/sala_calle_11_38`, `ibiza/sala_calle_19_25`, `ibiza/sala_calle_19_47`, `ibiza/sala_calle_21_15`, `ibiza/sala_calle_27_38`, `ibiza/sala_calle_27_46`, `ibiza/sala_calle_32_15`, `ibiza/sala_calle_37_15`, `ibiza/sala_calle_37_25`, `ibiza/sala_calle_37_41`, `ibiza/sala_calle_3_25`, `ibiza/sala_calle_45_22`, `ibiza/sala_calle_48_33`, `ibiza/sala_calle_61_39`, `ibiza/sala_calle_6_38`, `ibiza/sala_calle_6_46`, `ibiza/sala_calle_8_25`, `las_palmas/canteras`, `las_palmas/estanco`, `las_palmas/hospital`, `las_palmas/mercadona`, `las_palmas/sala_canteras_24_46`, `las_palmas/sala_canteras_25_32`, `las_palmas/sala_canteras_26_19`, `las_palmas/sala_canteras_33_32`, `las_palmas/sala_canteras_39_21`, `las_palmas/sala_canteras_41_31`, `las_palmas/sala_canteras_41_46`, `las_palmas/sala_canteras_43_15`, `las_palmas/sala_vegueta_triana_11_8`, `las_palmas/sala_vegueta_triana_18_30`, `las_palmas/sala_vegueta_triana_18_8`, `las_palmas/sala_vegueta_triana_19_19`, `las_palmas/sala_vegueta_triana_21_38`, `las_palmas/sala_vegueta_triana_24_19`, `las_palmas/sala_vegueta_triana_25_8`, `las_palmas/sala_vegueta_triana_31_27`, `las_palmas/sala_vegueta_triana_31_37`, `las_palmas/sala_vegueta_triana_36_37`, `las_palmas/sala_vegueta_triana_37_46`, `las_palmas/sala_vegueta_triana_39_22`, `las_palmas/sala_vegueta_triana_3_35`, `las_palmas/sala_vegueta_triana_3_46`, `las_palmas/sala_vegueta_triana_42_37`, `las_palmas/sala_vegueta_triana_42_46`, `las_palmas/sala_vegueta_triana_4_8`, `las_palmas/sala_vegueta_triana_8_35`, `las_palmas/vegueta_triana`, `leganes/casa_1`, `leganes/casa_2`, `leganes/centro`, `leganes/estanco`, `leganes/exterior`, `leganes/mercadona`, `leganes/sala_calle_15_29`, `leganes/sala_calle_19_35`, `leganes/sala_calle_20_21`, `leganes/sala_calle_26_36`, `leganes/sala_calle_29_20`, `leganes/sala_calle_37_35`, `leganes/sala_calle_44_37`, `leganes/sala_calle_51_36`, `leganes/sala_calle_53_6`, `leganes/sala_calle_56_23`, `leganes/sala_calle_59_37`, `leganes/sala_calle_5_13`, `leganes/sala_calle_5_36`, `madrid/atico_ayuso`, `madrid/atocha/mercadona`, `madrid/bernabeu`, `madrid/centro`, `madrid/chamberi`, `madrid/chamberi/estanco`, `madrid/chamberi/mercadona`, `madrid/estanco`, `madrid/gimnasio_1`, `madrid/gimnasio_2`, `madrid/gimnasio_3`, `madrid/gimnasio_lider`, `madrid/hospital`, `madrid/laboratorio`, `madrid/mercadona`, `madrid/moncloa`, `madrid/palacio_real`, `madrid/quiron`, `madrid/retiro`, `madrid/sala_bernabeu_12_8`, `madrid/sala_bernabeu_34_26`, `madrid/sala_bernabeu_34_9`, `madrid/sala_bernabeu_4_26`, `madrid/sala_bernabeu_4_9`, `madrid/sala_centro_11_19`, `madrid/sala_centro_14_27`, `madrid/sala_centro_14_5`, `madrid/sala_centro_18_4`, `madrid/sala_centro_20_42`, `madrid/sala_centro_22_27`, `madrid/sala_centro_25_13`, `madrid/sala_centro_31_13`, `madrid/sala_centro_33_6`, `madrid/sala_centro_35_50`, `madrid/sala_centro_3_39`, `madrid/sala_centro_40_16`, `madrid/sala_centro_41_7`, `madrid/sala_centro_46_17`, `madrid/sala_centro_49_10`, `madrid/sala_centro_49_26`, `madrid/sala_centro_4_19`, `madrid/sala_centro_4_48`, `madrid/sala_centro_53_17`, `madrid/sala_centro_53_42`, `madrid/sala_centro_53_52`, `madrid/sala_centro_53_8`, `madrid/sala_centro_54_31`, `madrid/sala_centro_5_27`, `madrid/sala_centro_5_5`, `madrid/sala_centro_60_41`, `madrid/sala_centro_62_21`, `madrid/sala_centro_62_52`, `madrid/sala_centro_63_31`, `madrid/sala_centro_67_31`, `madrid/sala_centro_68_13`, `madrid/sala_centro_68_21`, `madrid/sala_centro_68_41`, `madrid/sala_chamberi_10_7`, `madrid/sala_chamberi_16_28`, `madrid/sala_chamberi_17_19`, `madrid/sala_chamberi_18_6`, `madrid/sala_chamberi_24_40`, `madrid/sala_chamberi_29_22`, `madrid/sala_chamberi_29_6`, `madrid/sala_chamberi_31_32`, `madrid/sala_chamberi_38_42`, `madrid/sala_chamberi_39_20`, `madrid/sala_chamberi_39_33`, `madrid/sala_chamberi_39_7`, `madrid/sala_chamberi_3_18`, `madrid/sala_chamberi_3_35`, `madrid/sala_chamberi_3_7`, `madrid/sala_chamberi_44_12`, `madrid/sala_chamberi_46_33`, `madrid/sala_chamberi_4_41`, `madrid/sala_moncloa_23_37`, `madrid/sala_moncloa_23_49`, `madrid/sala_moncloa_29_32`, `madrid/sala_moncloa_32_49`, `madrid/sala_moncloa_34_38`, `madrid/sala_moncloa_38_49`, `madrid/sala_moncloa_39_39`, `madrid/sala_moncloa_40_16`, `madrid/sala_moncloa_47_17`, `madrid/sala_moncloa_56_17`, `madrid/sala_moncloa_58_29`, `madrid/sala_moncloa_59_39`, `madrid/sala_moncloa_7_41`, `madrid/sala_palacio_real_23_30`, `madrid/sala_palacio_real_23_54`, `madrid/sala_palacio_real_46_11`, `madrid/sala_palacio_real_54_11`, `madrid/sala_palacio_real_59_25`, `madrid/sala_retiro_20_58`, `madrid/sala_retiro_23_31`, `madrid/sala_retiro_23_44`, `madrid/sala_retiro_28_13`, `madrid/sala_retiro_36_37`, `madrid/sala_retiro_39_13`, `madrid/sala_retiro_3_13`, `madrid/sala_retiro_3_47`, `madrid/sala_retiro_4_29`, `madrid/sala_retiro_55_47`, `madrid/sol/hospital`, `madrid_rio/exterior`, `malaga/casa_1`, `malaga/casa_2`, `malaga/estanco`, `malaga/exterior`, `malaga/gimnasio_1`, `malaga/gimnasio_2`, `malaga/gimnasio_3`, `malaga/gimnasio_lider`, `malaga/hospital`, `malaga/mercadona`, `malaga/sala_calle_23_39`, `malaga/sala_calle_25_54`, `malaga/sala_calle_29_39`, `malaga/sala_calle_31_7`, `malaga/sala_calle_35_39`, `malaga/sala_calle_3_6`, `malaga/sala_calle_48_35`, `malaga/sala_calle_50_42`, `malaga/sala_calle_58_10`, `malaga/sala_calle_5_13`, `malaga/sala_calle_5_57`, `malaga/sala_calle_60_35`, `malaga/sala_calle_67_70`, `malaga/sala_calle_72_8`, `malaga/sala_calle_76_16`, `malaga/sala_calle_77_65`, `malaga/sala_calle_80_9`, `malaga/sala_calle_83_64`, `malaga/sala_calle_87_8`, `maritima_1/exterior`, `mostoles/casa_1`, `mostoles/casa_2`, `mostoles/centro`, `mostoles/estanco`, `mostoles/exterior`, `mostoles/mercadona`, `mostoles/sala_calle_11_6`, `mostoles/sala_calle_20_20`, `mostoles/sala_calle_23_11`, `mostoles/sala_calle_24_29`, `mostoles/sala_calle_25_48`, `mostoles/sala_calle_30_20`, `mostoles/sala_calle_32_48`, `mostoles/sala_calle_39_19`, `mostoles/sala_calle_39_28`, `mostoles/sala_calle_41_49`, `mostoles/sala_calle_47_15`, `mostoles/sala_calle_53_48`, `mostoles/sala_calle_55_28`, `mostoles/sala_calle_56_37`, `mostoles/sala_calle_5_10`, `mostoles/sala_calle_5_23`, `mostoles/sala_calle_7_34`, `murcia/centro`, `murcia/estanco`, `murcia/exterior`, `murcia/mercadona`, `murcia/sala_calle_11_12`, `murcia/sala_calle_12_25`, `murcia/sala_calle_13_53`, `murcia/sala_calle_20_54`, `murcia/sala_calle_23_11`, `murcia/sala_calle_25_25`, `murcia/sala_calle_25_35`, `murcia/sala_calle_28_54`, `murcia/sala_calle_32_25`, `murcia/sala_calle_40_30`, `murcia/sala_calle_41_11`, `murcia/sala_calle_48_35`, `murcia/sala_calle_4_12`, `murcia/sala_calle_58_12`, `murcia/sala_calle_58_26`, `murcia/sala_calle_59_34`, `murcia/sala_calle_59_53`, `murcia/sala_calle_5_26`, `murcia/sala_calle_63_25`, `murcia/sala_calle_65_11`, `murcia/sala_calle_65_34`, `murcia/sala_calle_65_53`, `orcasitas/casa_jugador`, `orcasitas/casa_rival`, `orcasitas/exterior`, `orcasitas/sala_calle_28_12`, `orcasitas/sala_calle_29_20`, `orcasitas/sala_calle_36_9`, `orcasitas/sala_calle_5_32`, `palma/casa_1`, `palma/casa_2`, `palma/centro`, `palma/estanco`, `palma/exterior`, `palma/mercadona`, `palma/sala_calle_19_6`, `palma/sala_calle_21_27`, `palma/sala_calle_32_40`, `palma/sala_calle_3_38`, `palma/sala_calle_42_41`, `palma/sala_calle_44_12`, `palma/sala_calle_45_26`, `palma/sala_calle_54_30`, `palma/sala_calle_57_21`, `palma/sala_calle_59_43`, `palma/sala_calle_61_30`, `palma/sala_calle_66_43`, `palma/sala_calle_67_13`, `palma/sala_calle_67_29`, `palma/sala_calle_7_14`, `playa_del_ingles/estanco`, `playa_del_ingles/exterior`, `playa_del_ingles/gimnasio_1`, `playa_del_ingles/gimnasio_2`, `playa_del_ingles/gimnasio_3`, `playa_del_ingles/gimnasio_lider`, `playa_del_ingles/hospital`, `playa_del_ingles/mercadona`, `playa_del_ingles/sala_calle_16_18`, `playa_del_ingles/sala_calle_24_21`, `playa_del_ingles/sala_calle_33_20`, `playa_del_ingles/sala_calle_39_21`, `playa_del_ingles/sala_calle_41_7`, `playa_del_ingles/sala_calle_53_11`, `playa_del_ingles/sala_calle_5_20`, `playa_del_ingles/sala_calle_7_54`, `pozuelo/casa_jugador`, `pozuelo/casa_rival`, `pozuelo/exterior`, `pozuelo/sala_calle_13_29`, `pozuelo/sala_calle_17_23`, `pozuelo/sala_calle_21_11`, `pozuelo/sala_calle_22_29`, `pozuelo/sala_calle_31_29`, `pozuelo/sala_calle_37_12`, `pozuelo/sala_calle_7_30`, `pueblo_inicial/casa_1`, `pueblo_inicial/casa_2`, `pueblo_inicial/exterior`, `pueblo_inicial/sala_calle_12_28`, `pueblo_inicial/sala_calle_13_46`, `pueblo_inicial/sala_calle_19_14`, `pueblo_inicial/sala_calle_25_29`, `pueblo_inicial/sala_calle_25_39`, `pueblo_inicial/sala_calle_26_48`, `pueblo_inicial/sala_calle_30_21`, `pueblo_inicial/sala_calle_30_39`, `pueblo_inicial/sala_calle_31_29`, `pueblo_inicial/sala_calle_36_14`, `pueblo_inicial/sala_calle_36_29`, `pueblo_inicial/sala_calle_36_39`, `pueblo_inicial/sala_calle_38_21`, `puertollano/casa_1`, `puertollano/casa_2`, `puertollano/centro`, `puertollano/estanco`, `puertollano/exterior`, `puertollano/mercadona`, `puertollano/sala_calle_16_43`, `puertollano/sala_calle_19_24`, `puertollano/sala_calle_21_60`, `puertollano/sala_calle_22_42`, `puertollano/sala_calle_30_12`, `puertollano/sala_calle_37_21`, `puertollano/sala_calle_38_13`, `puertollano/sala_calle_44_35`, `puertollano/sala_calle_51_6`, `puertollano/sala_calle_51_60`, `puertollano/sala_calle_59_7`, `puertollano/sala_calle_61_16`, `puertollano/sala_calle_62_33`, `puertollano/sala_calle_64_8`, `puertollano/sala_calle_65_51`, `puertollano/sala_calle_6_23`, `puertollano/sala_calle_6_36`, `puertollano/sala_calle_7_61`, `ruta_1/exterior`, `ruta_10/exterior`, `ruta_10/sala_calle_10_23`, `ruta_10/sala_calle_10_40`, `ruta_10/sala_calle_11_59`, `ruta_10/sala_calle_15_40`, `ruta_10/sala_calle_16_20`, `ruta_10/sala_calle_16_50`, `ruta_10/sala_calle_17_59`, `ruta_10/sala_calle_18_24`, `ruta_10/sala_calle_20_40`, `ruta_10/sala_calle_22_50`, `ruta_10/sala_calle_23_60`, `ruta_10/sala_calle_31_13`, `ruta_10/sala_calle_31_8`, `ruta_10/sala_calle_32_51`, `ruta_10/sala_calle_35_8`, `ruta_10/sala_calle_41_27`, `ruta_10/sala_calle_6_40`, `ruta_10/sala_calle_7_60`, `ruta_10/sala_calle_9_50`, `ruta_11/exterior`, `ruta_11/sala_calle_11_27`, `ruta_11/sala_calle_17_27`, `ruta_11/sala_calle_23_27`, `ruta_11/sala_calle_35_28`, `ruta_11/sala_calle_44_27`, `ruta_12/casa_1`, `ruta_12/exterior`, `ruta_13/casa_1`, `ruta_13/casa_2`, `ruta_13/exterior`, `ruta_14/casa_1`, `ruta_14/casa_2`, `ruta_14/exterior`, `ruta_14/sala_calle_34_13`, `ruta_14/sala_calle_53_17`, `ruta_14/sala_calle_53_9`, `ruta_14/sala_calle_57_9`, `ruta_15/casa_1`, `ruta_15/casa_2`, `ruta_15/exterior`, `ruta_16/casa_1`, `ruta_16/casa_2`, `ruta_16/exterior`, `ruta_2/casa_1`, `ruta_2/casa_2`, `ruta_2/exterior`, `ruta_2/sala_calle_14_61`, `ruta_2/sala_calle_27_51`, `ruta_2/sala_calle_27_61`, `ruta_2/sala_calle_2_51`, `ruta_2/sala_calle_2_61`, `ruta_2/sala_calle_33_61`, `ruta_2/sala_calle_9_61`, `ruta_21/casa_1`, `ruta_21/casa_2`, `ruta_21/exterior`, `ruta_21/sala_calle_10_38`, `ruta_21/sala_calle_33_38`, `ruta_22/casa_1`, `ruta_22/casa_2`, `ruta_22/exterior`, `ruta_22/sala_calle_16_15`, `ruta_22/sala_calle_8_26`, `ruta_23/casa_1`, `ruta_23/casa_2`, `ruta_23/cuellar/mercadona`, `ruta_23/exterior`, `ruta_23/sala_calle_12_11`, `ruta_23/sala_calle_22_11`, `ruta_24/casa_1`, `ruta_24/casa_2`, `ruta_24/exterior`, `ruta_24/sala_calle_11_10`, `ruta_24/sala_calle_15_10`, `ruta_24/sala_calle_19_10`, `ruta_24/sala_calle_33_30`, `ruta_24/sala_calle_35_40`, `ruta_24/sala_calle_37_30`, `ruta_24/sala_calle_3_10`, `ruta_24/sala_calle_41_30`, `ruta_24/sala_calle_4_28`, `ruta_24/sala_calle_7_10`, `ruta_25/casa_1`, `ruta_25/casa_2`, `ruta_25/exterior`, `ruta_26/casa_1`, `ruta_26/exterior`, `ruta_26/sala_calle_9_9`, `ruta_3/casa_1`, `ruta_3/casa_2`, `ruta_3/exterior`, `ruta_3/sala_calle_6_66`, `ruta_4/casa_1`, `ruta_4/casa_2`, `ruta_4/exterior`, `ruta_4/sala_calle_29_27`, `ruta_4/sala_calle_30_38`, `ruta_4/sala_calle_34_14`, `ruta_4/sala_calle_38_28`, `ruta_4/sala_calle_38_39`, `ruta_4/sala_calle_44_39`, `ruta_4/sala_calle_45_28`, `ruta_4/sala_calle_9_24`, `ruta_5/casa_1`, `ruta_5/casa_2`, `ruta_5/exterior`, `ruta_5/sala_calle_31_12`, `ruta_5/sala_calle_47_11`, `ruta_5/sala_calle_56_12`, `ruta_5/sala_calle_58_27`, `ruta_5/sala_calle_65_11`, `ruta_6/casa_1`, `ruta_6/casa_2`, `ruta_6/exterior`, `ruta_6/sala_calle_32_16`, `ruta_6/sala_calle_42_16`, `ruta_6/sala_calle_47_16`, `ruta_6/sala_calle_61_16`, `ruta_6/sala_calle_65_15`, `ruta_7/exterior`, `ruta_8/casa_1`, `ruta_8/casa_2`, `ruta_8/exterior`, `ruta_8/sala_calle_36_10`, `ruta_8/sala_calle_51_36`, `ruta_8/sala_calle_56_36`, `ruta_9/exterior`, `ruta_9/sala_calle_11_74`, `ruta_9/sala_calle_15_65`, `ruta_9/sala_calle_16_24`, `ruta_9/sala_calle_17_33`, `ruta_9/sala_calle_17_74`, `ruta_9/sala_calle_18_15`, `ruta_9/sala_calle_19_56`, `ruta_9/sala_calle_21_24`, `ruta_9/sala_calle_22_33`, `ruta_9/sala_calle_22_40`, `ruta_9/sala_calle_22_66`, `ruta_9/sala_calle_23_74`, `ruta_9/sala_calle_31_65`, `ruta_9/sala_calle_32_74`, `ruta_9/sala_calle_34_55`, `ruta_9/sala_calle_41_67`, `ruta_9/sala_calle_5_74`, `ruta_9/sala_calle_7_66`, `sevilla/centro`, `sevilla/estanco`, `sevilla/gimnasio_1`, `sevilla/gimnasio_2`, `sevilla/gimnasio_3`, `sevilla/gimnasio_lider`, `sevilla/hospital`, `sevilla/maria_luisa`, `sevilla/mercadona`, `sevilla/rio`, `sevilla/sala_centro_10_41`, `sevilla/sala_centro_10_53`, `sevilla/sala_centro_10_7`, `sevilla/sala_centro_21_6`, `sevilla/sala_centro_22_40`, `sevilla/sala_centro_24_51`, `sevilla/sala_centro_27_6`, `sevilla/sala_centro_28_21`, `sevilla/sala_centro_33_47`, `sevilla/sala_centro_37_33`, `sevilla/sala_centro_37_39`, `sevilla/sala_centro_38_19`, `sevilla/sala_centro_3_40`, `sevilla/sala_centro_3_53`, `sevilla/sala_centro_3_8`, `sevilla/sala_centro_42_33`, `sevilla/sala_centro_43_39`, `sevilla/sala_centro_43_8`, `sevilla/sala_centro_44_19`, `sevilla/sala_centro_45_49`, `sevilla/sala_centro_47_33`, `sevilla/sala_centro_49_39`, `sevilla/sala_centro_50_20`, `sevilla/sala_centro_53_6`, `sevilla/sala_centro_54_36`, `sevilla/sala_centro_56_19`, `sevilla/sala_centro_59_11`, `sevilla/sala_centro_59_33`, `sevilla/sala_centro_59_42`, `sevilla/sala_rio_13_44`, `sevilla/sala_rio_13_52`, `sevilla/sala_rio_13_6`, `sevilla/sala_rio_15_15`, `sevilla/sala_rio_17_37`, `sevilla/sala_rio_18_22`, `sevilla/sala_rio_18_44`, `sevilla/sala_rio_18_52`, `sevilla/sala_rio_18_6`, `sevilla/sala_rio_37_45`, `sevilla/sala_rio_39_5`, `sevilla/sala_rio_3_37`, `sevilla/sala_rio_3_44`, `sevilla/sala_rio_3_52`, `sevilla/sala_rio_3_6`, `sevilla/sala_rio_40_23`, `sevilla/sala_rio_44_14`, `sevilla/sala_rio_45_23`, `sevilla/sala_rio_45_54`, `sevilla/sala_rio_45_6`, `sevilla/sala_rio_46_34`, `sevilla/sala_rio_50_23`, `sevilla/sala_rio_51_12`, `sevilla/sala_rio_52_46`, `sevilla/sala_rio_5_16`, `sevilla/sala_rio_8_44`, `sevilla/sala_rio_8_52`, `sevilla/sala_rio_8_6`, `valencia/ciutat_vella`, `valencia/estanco`, `valencia/gimnasio_1`, `valencia/gimnasio_2`, `valencia/gimnasio_3`, `valencia/gimnasio_lider`, `valencia/hospital`, `valencia/malvarrosa`, `valencia/malvarrosa/estanco`, `valencia/malvarrosa/hospital`, `valencia/malvarrosa/mercadona`, `valencia/mercadona`, `valencia/sala_ciutat_vella_10_9`, `valencia/sala_ciutat_vella_12_53`, `valencia/sala_ciutat_vella_15_9`, `valencia/sala_ciutat_vella_21_16`, `valencia/sala_ciutat_vella_22_37`, `valencia/sala_ciutat_vella_27_52`, `valencia/sala_ciutat_vella_31_27`, `valencia/sala_ciutat_vella_35_36`, `valencia/sala_ciutat_vella_41_25`, `valencia/sala_ciutat_vella_47_51`, `valencia/sala_ciutat_vella_49_8`, `valencia/sala_ciutat_vella_4_10`, `valencia/sala_ciutat_vella_4_53`, `valencia/sala_ciutat_vella_57_53`, `valencia/sala_ciutat_vella_58_10`, `valencia/sala_ciutat_vella_58_38`, `valencia/sala_ciutat_vella_9_24`, `valencia/sala_ciutat_vella_9_38`, `valencia/sala_malvarrosa_13_8`, `valencia/sala_malvarrosa_14_35`, `valencia/sala_malvarrosa_21_22`, `valencia/sala_malvarrosa_22_35`, `valencia/sala_malvarrosa_23_45`, `valencia/sala_malvarrosa_27_22`, `valencia/sala_malvarrosa_27_44`, `valencia/sala_malvarrosa_30_35`, `valencia/sala_malvarrosa_3_21`, `valencia/sala_malvarrosa_3_44`, `valencia/sala_malvarrosa_3_8`, `valencia/sala_malvarrosa_49_11`, `valencia/sala_malvarrosa_5_35`, `valencia/sala_malvarrosa_8_21`, `valencia/sala_malvarrosa_8_8`, `valencia/turia`, `valladolid/casa_1`, `valladolid/casa_2`, `valladolid/estanco`, `valladolid/exterior`, `valladolid/gimnasio_1`, `valladolid/gimnasio_2`, `valladolid/gimnasio_3`, `valladolid/gimnasio_lider`, `valladolid/hospital`, `valladolid/mercadona`, `valladolid/sala_calle_20_51`, `valladolid/sala_calle_23_15`, `valladolid/sala_calle_3_18`, `valladolid/sala_calle_3_6`, `valladolid/sala_calle_47_9`, `valladolid/sala_calle_49_47`, `valladolid/sala_calle_50_26`, `valladolid/sala_calle_52_59`, `valladolid/sala_calle_56_48`, `valladolid/sala_calle_59_16`, `valladolid/sala_calle_64_38`, `valladolid/sala_calle_65_50`, `valladolid/sala_calle_66_14`, `vigo/casa_1`, `vigo/casa_2`, `vigo/casa_3`, `vigo/casa_4`, `vigo/centro`, `vigo/estanco`, `vigo/exterior`, `vigo/mercadona`, `vigo/sala_calle_11_7`, `vigo/sala_calle_16_8`, `vigo/sala_calle_17_29`, `vigo/sala_calle_33_18`, `vigo/sala_calle_3_6`, `vigo/sala_calle_42_18`, `vigo/sala_calle_42_32`, `vigo/sala_calle_49_31`, `zaragoza/casa_1`, `zaragoza/casa_2`, `zaragoza/centro`, `zaragoza/estanco`, `zaragoza/exterior`, `zaragoza/mercadona`, `zaragoza/sala_calle_13_39`, `zaragoza/sala_calle_17_53`, `zaragoza/sala_calle_23_53`, `zaragoza/sala_calle_24_29`, `zaragoza/sala_calle_28_53`, `zaragoza/sala_calle_33_43`, `zaragoza/sala_calle_33_53`, `zaragoza/sala_calle_38_29`, `zaragoza/sala_calle_38_43`, `zaragoza/sala_calle_38_53`, `zaragoza/sala_calle_39_21`, `zaragoza/sala_calle_3_36`, `zaragoza/sala_calle_49_31`, `zaragoza/sala_calle_4_46`, `zaragoza/sala_calle_4_56`, `zaragoza/sala_calle_58_22`, `zaragoza/sala_calle_62_46`, `zaragoza/sala_calle_65_30`, `zaragoza/sala_calle_65_56`, `zaragoza/sala_calle_7_20`
- **Aislado del pueblo inicial** (4 mapas): `bilbao/gimnasio_1`, `bilbao/gimnasio_2`, `bilbao/gimnasio_3`, `bilbao/gimnasio_lider`

## Uniones pendientes

- `ruta_16/exterior` → `ruta_17/exterior` (borde north): el mapa de destino aún no existe.
- `madrid/atico_ayuso` → `madrid/chamberi`: solo de ida (falta la vuelta).
- `madrid/sala_moncloa_40_16` → `madrid/moncloa`: solo de ida (falta la vuelta).
- `madrid/sala_moncloa_58_29` → `madrid/moncloa`: solo de ida (falta la vuelta).

## Mapa por mapa

| Mapa | Nombre | Bordes | Pasarelas |
|---|---|---|---|
| `alicante/centro` | Centro Pokémon · Alicante | — | Salida → `alicante/exterior` |
| `alicante/estanco` | Estanco · Alicante | — | Salida → `alicante/exterior` |
| `alicante/exterior` | Alicante | north → `ruta_10/exterior`, west → `ruta_11/exterior` | Centro → `alicante/centro`, Mercadona → `alicante/mercadona`, Estanco → `alicante/estanco`, Sala58_12 → `alicante/sala_calle_58_12`, Sala28_33 → `alicante/sala_calle_28_33`, Sala20_43 → `alicante/sala_calle_20_43`, Sala4_9 → `alicante/sala_calle_4_9`, Sala12_9 → `alicante/sala_calle_12_9`, Sala22_9 → `alicante/sala_calle_22_9`, Sala31_8 → `alicante/sala_calle_31_8`, Sala42_8 → `alicante/sala_calle_42_8`, Sala6_19 → `alicante/sala_calle_6_19`, Sala24_20 → `alicante/sala_calle_24_20`, Sala29_20 → `alicante/sala_calle_29_20`, Sala19_32 → `alicante/sala_calle_19_32`, Sala44_32 → `alicante/sala_calle_44_32`, Sala7_43 → `alicante/sala_calle_7_43`, Sala42_42 → `alicante/sala_calle_42_42`, Sala51_43 → `alicante/sala_calle_51_43`, Sala50_26 → `alicante/sala_calle_50_26`, Sala55_26 → `alicante/sala_calle_55_26`, Sala50_31 → `alicante/sala_calle_50_31`, Sala55_31 → `alicante/sala_calle_55_31`, Sala42_19 → `alicante/sala_calle_42_19`, Sala56_42 → `alicante/sala_calle_56_42`, Sala32_12 → `alicante/sala_calle_32_12`, Sala68_36 → `alicante/sala_calle_68_36` |
| `alicante/mercadona` | Mercadona · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_12_9` | Oficinas · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_19_32` | Casa rosa · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_20_43` | Casa Carbonell · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_22_9` | Grandes almacenes · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_24_20` | Tienda azul · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_28_33` | Concatedral de San Nicolás · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_29_20` | Teatro · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_31_8` | Portal verde · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_32_12` | Puesto · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_42_19` | Casa naranja · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_42_42` | Edificio Cupula · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_42_8` | Casa de dos aguas · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_44_32` | Oficinas · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_4_9` | Portal · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_50_26` | Casa ibicenca · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_50_31` | Casa ibicenca · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_51_43` | Tienda naranja · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_55_26` | Casa ibicenca · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_55_31` | Casa ibicenca · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_56_42` | Puesto · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_58_12` | Castillo de Santa Bárbara · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_68_36` | Torre de socorro · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_6_19` | Gimnasio · Alicante | — | Salida → `alicante/exterior` |
| `alicante/sala_calle_7_43` | Portal verde · Alicante | — | Salida → `alicante/exterior` |
| `barcelona/barceloneta/hospital` | Hospital · Barceloneta | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/ciutat_vella` | Barcelona · Ciutat Vella | north → `barcelona/eixample` | FerryPalma → `palma/exterior`, Hospital → `barcelona/barceloneta/hospital`, Sala5_13 → `barcelona/sala_ciutat_vella_5_13`, Sala12_13 → `barcelona/sala_ciutat_vella_12_13`, Sala22_13 → `barcelona/sala_ciutat_vella_22_13`, Sala5_27 → `barcelona/sala_ciutat_vella_5_27`, Sala13_26 → `barcelona/sala_ciutat_vella_13_26`, Sala22_27 → `barcelona/sala_ciutat_vella_22_27`, Sala5_40 → `barcelona/sala_ciutat_vella_5_40`, Sala25_40 → `barcelona/sala_ciutat_vella_25_40`, Sala6_49 → `barcelona/sala_ciutat_vella_6_49`, Sala44_22 → `barcelona/sala_ciutat_vella_44_22`, Sala47_6 → `barcelona/sala_ciutat_vella_47_6`, Sala57_27 → `barcelona/sala_ciutat_vella_57_27`, Sala13_36 → `barcelona/sala_ciutat_vella_13_36`, Sala49_41 → `barcelona/sala_ciutat_vella_49_41` |
| `barcelona/eixample` | Barcelona · Eixample | west → `barcelona/les_corts`, south → `barcelona/ciutat_vella` | Hospital → `barcelona/hospital`, Mercadona → `barcelona/mercadona`, Estanco → `barcelona/estanco`, Sala5_19 → `barcelona/sala_eixample_5_19`, Sala17_19 → `barcelona/sala_eixample_17_19`, Sala37_19 → `barcelona/sala_eixample_37_19`, Sala52_18 → `barcelona/sala_eixample_52_18`, Sala59_19 → `barcelona/sala_eixample_59_19`, Sala68_19 → `barcelona/sala_eixample_68_19`, Sala17_31 → `barcelona/sala_eixample_17_31`, Sala25_31 → `barcelona/sala_eixample_25_31`, Sala37_31 → `barcelona/sala_eixample_37_31`, Sala5_41 → `barcelona/sala_eixample_5_41`, Sala17_41 → `barcelona/sala_eixample_17_41`, Sala25_41 → `barcelona/sala_eixample_25_41`, Sala37_41 → `barcelona/sala_eixample_37_41`, Sala55_41 → `barcelona/sala_eixample_55_41`, Sala61_51 → `barcelona/sala_eixample_61_51`, Sala12_19 → `barcelona/sala_eixample_12_19`, Sala45_18 → `barcelona/sala_eixample_45_18`, Sala10_31 → `barcelona/sala_eixample_10_31`, Sala44_31 → `barcelona/sala_eixample_44_31`, Sala12_41 → `barcelona/sala_eixample_12_41`, Sala44_41 → `barcelona/sala_eixample_44_41`, Sala5_5 → `barcelona/sala_eixample_5_5`, Sala17_5 → `barcelona/sala_eixample_17_5`, Sala39_5 → `barcelona/sala_eixample_39_5`, Sala51_5 → `barcelona/sala_eixample_51_5`, Sala63_5 → `barcelona/sala_eixample_63_5`, Sala25_6 → `barcelona/sala_eixample_25_6`, Sala33_7 → `barcelona/sala_eixample_33_7`, Sala15_50 → `barcelona/sala_eixample_15_50`, Sala33_53 → `barcelona/sala_eixample_33_53` |
| `barcelona/estanco` | Estanco · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/gimnasio_1` | Spotify Camp Nou · Túnel De Vestuarios | — | Salida → `barcelona/les_corts`, Siguiente → `barcelona/gimnasio_2` |
| `barcelona/gimnasio_2` | Spotify Camp Nou · Sala De Palancas | — | Salida → `barcelona/gimnasio_1`, Siguiente → `barcelona/gimnasio_3` |
| `barcelona/gimnasio_3` | Spotify Camp Nou · Palco | — | Salida → `barcelona/gimnasio_2`, Siguiente → `barcelona/gimnasio_lider` |
| `barcelona/gimnasio_lider` | Spotify Camp Nou · Despacho Del President | — | Salida → `barcelona/gimnasio_3` |
| `barcelona/hospital` | Hospital · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/les_corts` | Barcelona · Les Corts | west → `ruta_8/exterior`, east → `barcelona/eixample` | Mercadona → `barcelona/les_corts/mercadona`, Sala4_13 → `barcelona/sala_les_corts_4_13`, Sala13_12 → `barcelona/sala_les_corts_13_12`, Sala21_12 → `barcelona/sala_les_corts_21_12`, Sala30_12 → `barcelona/sala_les_corts_30_12`, Sala38_13 → `barcelona/sala_les_corts_38_13`, Sala46_13 → `barcelona/sala_les_corts_46_13`, Sala60_13 → `barcelona/sala_les_corts_60_13`, Sala26_40 → `barcelona/gimnasio_1`, Sala47_29 → `barcelona/sala_les_corts_47_29`, Sala55_30 → `barcelona/sala_les_corts_55_30`, Sala49_41 → `barcelona/sala_les_corts_49_41`, Sala57_41 → `barcelona/sala_les_corts_57_41`, Sala4_46 → `barcelona/sala_les_corts_4_46`, Sala53_6 → `barcelona/sala_les_corts_53_6`, Sala21_23 → `barcelona/sala_les_corts_21_23`, Sala53_22 → `barcelona/sala_les_corts_53_22` |
| `barcelona/les_corts/mercadona` | Mercadona · Les Corts | — | Salida → `barcelona/les_corts` |
| `barcelona/mercadona` | Mercadona · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_ciutat_vella_12_13` | Oficinas · Barcelona | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/sala_ciutat_vella_13_26` | Portal verde · Barcelona | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/sala_ciutat_vella_13_36` | Casa gris · Barcelona | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/sala_ciutat_vella_22_13` | Boqueria · Barcelona | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/sala_ciutat_vella_22_27` | Teatro · Barcelona | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/sala_ciutat_vella_25_40` | Tienda morada · Barcelona | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/sala_ciutat_vella_44_22` | Catedral Barcelona · Barcelona | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/sala_ciutat_vella_47_6` | Portal verde · Barcelona | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/sala_ciutat_vella_49_41` | Casa roja pequeña · Barcelona | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/sala_ciutat_vella_57_27` | Torre de socorro · Barcelona | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/sala_ciutat_vella_5_13` | Portal · Barcelona | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/sala_ciutat_vella_5_27` | Portal · Barcelona | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/sala_ciutat_vella_5_40` | Portal · Barcelona | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/sala_ciutat_vella_6_49` | Oficinas · Barcelona | — | Salida → `barcelona/ciutat_vella` |
| `barcelona/sala_eixample_10_31` | Portal · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_12_19` | Tienda azul · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_12_41` | Tienda morada · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_15_50` | Casa gris · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_17_19` | Oficinas · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_17_31` | Portal · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_17_41` | Oficinas · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_17_5` | Portal verde · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_25_31` | Casa Batlló · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_25_41` | Floristería · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_25_6` | Casa gris · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_33_53` | Casa roja pequeña · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_33_7` | Casa roja pequeña · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_37_19` | La Pedrera · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_37_31` | Portal verde · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_37_41` | Portal · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_39_5` | Portal verde · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_44_31` | Oficinas · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_44_41` | Portal verde · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_45_18` | Tienda verde · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_51_5` | Portal verde · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_52_18` | Portal verde · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_55_41` | Sagrada Familia · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_59_19` | Portal · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_5_19` | Portal · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_5_41` | Portal · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_5_5` | Portal verde · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_61_51` | Grandes almacenes · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_63_5` | Portal verde · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_eixample_68_19` | Oficinas · Barcelona | — | Salida → `barcelona/eixample` |
| `barcelona/sala_les_corts_13_12` | Oficinas · Barcelona | — | Salida → `barcelona/les_corts` |
| `barcelona/sala_les_corts_21_12` | Oficinas · Barcelona | — | Salida → `barcelona/les_corts` |
| `barcelona/sala_les_corts_21_23` | Casa roja pequeña · Barcelona | — | Salida → `barcelona/les_corts` |
| `barcelona/sala_les_corts_30_12` | Portal verde · Barcelona | — | Salida → `barcelona/les_corts` |
| `barcelona/sala_les_corts_38_13` | Oficinas · Barcelona | — | Salida → `barcelona/les_corts` |
| `barcelona/sala_les_corts_46_13` | Portal · Barcelona | — | Salida → `barcelona/les_corts` |
| `barcelona/sala_les_corts_47_29` | Granero · Barcelona | — | Salida → `barcelona/les_corts` |
| `barcelona/sala_les_corts_49_41` | Tienda morada · Barcelona | — | Salida → `barcelona/les_corts` |
| `barcelona/sala_les_corts_4_13` | Portal · Barcelona | — | Salida → `barcelona/les_corts` |
| `barcelona/sala_les_corts_4_46` | Portal · Barcelona | — | Salida → `barcelona/les_corts` |
| `barcelona/sala_les_corts_53_22` | Casa gris · Barcelona | — | Salida → `barcelona/les_corts` |
| `barcelona/sala_les_corts_53_6` | Casa gris · Barcelona | — | Salida → `barcelona/les_corts` |
| `barcelona/sala_les_corts_55_30` | Tienda azul · Barcelona | — | Salida → `barcelona/les_corts` |
| `barcelona/sala_les_corts_57_41` | Portal verde · Barcelona | — | Salida → `barcelona/les_corts` |
| `barcelona/sala_les_corts_60_13` | Portal · Barcelona | — | Salida → `barcelona/les_corts` |
| `bilbao/gimnasio_1` | San Mamés · Grada De Animación | — | Siguiente → `bilbao/gimnasio_2` |
| `bilbao/gimnasio_2` | San Mamés · Vestuario | — | Salida → `bilbao/gimnasio_1`, Siguiente → `bilbao/gimnasio_3` |
| `bilbao/gimnasio_3` | San Mamés · Túnel | — | Salida → `bilbao/gimnasio_2`, Siguiente → `bilbao/gimnasio_lider` |
| `bilbao/gimnasio_lider` | San Mamés · Césped | — | Salida → `bilbao/gimnasio_3` |
| `casa_de_campo/exterior` | Casa de Campo | west → `pozuelo/exterior`, north → `madrid/moncloa` | — |
| `getafe/casa_1` | Casa roja · Getafe | — | Salida → `getafe/exterior` |
| `getafe/casa_2` | Casa de dos aguas · Getafe | — | Salida → `getafe/exterior` |
| `getafe/casa_vecina` | Casa de la vecina / Getafe | — | Salida → `getafe/exterior` |
| `getafe/centro` | Centro Pokémon · Getafe | — | Salida → `getafe/exterior` |
| `getafe/estanco` | Estanco · Getafe | — | Salida → `getafe/exterior` |
| `getafe/exterior` | Getafe | south → `ruta_24/exterior`, west → `leganes/exterior` | CasaVecina → `getafe/casa_vecina`, Centro → `getafe/centro`, Mercadona → `getafe/mercadona`, Estanco → `getafe/estanco`, Casa1 → `getafe/casa_1`, Casa2 → `getafe/casa_2`, Sala5_9 → `getafe/sala_calle_5_9`, Sala27_21 → `getafe/sala_calle_27_21`, Sala16_20 → `getafe/sala_calle_16_20`, Sala37_36 → `getafe/sala_calle_37_36`, Sala4_46 → `getafe/sala_calle_4_46`, Sala21_46 → `getafe/sala_calle_21_46`, Sala31_47 → `getafe/sala_calle_31_47`, Sala19_58 → `getafe/sala_calle_19_58`, Sala4_58 → `getafe/sala_calle_4_58`, Sala55_23 → `getafe/sala_calle_55_23`, Sala30_58 → `getafe/sala_calle_30_58`, Sala25_27 → `getafe/sala_calle_25_27`, Sala54_44 → `getafe/sala_calle_54_44`, Sala51_6 → `getafe/sala_calle_51_6`, Sala59_7 → `getafe/sala_calle_59_7` |
| `getafe/mercadona` | Mercadona · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_16_20` | Casa naranja · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_19_58` | Casa de dos aguas · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_21_46` | Casa de madera · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_25_27` | Puesto · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_27_21` | Magdalena Getafe · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_30_58` | Granero · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_31_47` | Oficinas · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_37_36` | Tienda azul · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_4_46` | Granero · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_4_58` | Casa de la chimenea · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_51_6` | Casa gris · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_54_44` | Ermita Virgen Del Rio · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_55_23` | Casa de dos aguas · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_59_7` | Casa roja pequeña · Getafe | — | Salida → `getafe/exterior` |
| `getafe/sala_calle_5_9` | Oficinas · Getafe | — | Salida → `getafe/exterior` |
| `huelva/casa_1` | Casa de la chimenea · Huelva | — | Salida → `huelva/exterior` |
| `huelva/casa_2` | Casa de la chimenea · Huelva | — | Salida → `huelva/exterior` |
| `huelva/centro` | Centro Pokémon · Huelva | — | Salida → `huelva/exterior` |
| `huelva/estanco` | Estanco · Huelva | — | Salida → `huelva/exterior` |
| `huelva/exterior` | Huelva | east → `ruta_14/exterior` | FerryCanarias → `las_palmas/canteras`, Centro → `huelva/centro`, Mercadona → `huelva/mercadona`, Estanco → `huelva/estanco`, Casa1 → `huelva/casa_1`, Casa2 → `huelva/casa_2`, Sala20_12 → `huelva/sala_calle_20_12`, Sala31_12 → `huelva/sala_calle_31_12`, Sala49_8 → `huelva/sala_calle_49_8`, Sala55_8 → `huelva/sala_calle_55_8`, Sala39_27 → `huelva/sala_calle_39_27`, Sala46_31 → `huelva/sala_calle_46_31`, Sala53_17 → `huelva/sala_calle_53_17` |
| `huelva/mercadona` | Mercadona · Huelva | — | Salida → `huelva/exterior` |
| `huelva/sala_calle_20_12` | Palacio Infantado · Huelva | — | Salida → `huelva/exterior` |
| `huelva/sala_calle_31_12` | Catedral Ibiza · Huelva | — | Salida → `huelva/exterior` |
| `huelva/sala_calle_39_27` | Tienda naranja · Huelva | — | Salida → `huelva/exterior` |
| `huelva/sala_calle_46_31` | Portal · Huelva | — | Salida → `huelva/exterior` |
| `huelva/sala_calle_49_8` | Casa de la chimenea · Huelva | — | Salida → `huelva/exterior` |
| `huelva/sala_calle_53_17` | Casa roja pequeña · Huelva | — | Salida → `huelva/exterior` |
| `huelva/sala_calle_55_8` | Casa de la chimenea · Huelva | — | Salida → `huelva/exterior` |
| `ibiza/casa_1` | Casa ibicenca · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/casa_2` | Casa ibicenca · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/centro` | Centro Pokémon · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/estanco` | Estanco · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/exterior` | Ibiza | north → `maritima_1/exterior` | FerryValencia → `valencia/malvarrosa`, Centro → `ibiza/centro`, Mercadona → `ibiza/mercadona`, Estanco → `ibiza/estanco`, Casa1 → `ibiza/casa_1`, Casa2 → `ibiza/casa_2`, Sala21_15 → `ibiza/sala_calle_21_15`, Sala32_15 → `ibiza/sala_calle_32_15`, Sala37_15 → `ibiza/sala_calle_37_15`, Sala3_25 → `ibiza/sala_calle_3_25`, Sala8_25 → `ibiza/sala_calle_8_25`, Sala19_25 → `ibiza/sala_calle_19_25`, Sala37_25 → `ibiza/sala_calle_37_25`, Sala6_38 → `ibiza/sala_calle_6_38`, Sala11_38 → `ibiza/sala_calle_11_38`, Sala27_38 → `ibiza/sala_calle_27_38`, Sala6_46 → `ibiza/sala_calle_6_46`, Sala19_47 → `ibiza/sala_calle_19_47`, Sala27_46 → `ibiza/sala_calle_27_46`, Sala48_33 → `ibiza/sala_calle_48_33`, Sala61_39 → `ibiza/sala_calle_61_39`, Sala45_22 → `ibiza/sala_calle_45_22`, Sala37_41 → `ibiza/sala_calle_37_41` |
| `ibiza/mercadona` | Mercadona · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_11_38` | Casa ibicenca · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_19_25` | Casa ibicenca · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_19_47` | Catedral Ibiza · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_21_15` | Casa ibicenca · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_27_38` | Casa ibicenca · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_27_46` | Casa ibicenca · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_32_15` | Casa ibicenca · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_37_15` | Casa ibicenca · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_37_25` | Casa ibicenca · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_37_41` | Casa roja pequeña · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_3_25` | Casa ibicenca · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_45_22` | Casa gris · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_48_33` | Club Ibiza · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_61_39` | Torre de socorro · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_6_38` | Casa ibicenca · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_6_46` | Casa ibicenca · Ibiza | — | Salida → `ibiza/exterior` |
| `ibiza/sala_calle_8_25` | Casa ibicenca · Ibiza | — | Salida → `ibiza/exterior` |
| `las_palmas/canteras` | Las Palmas · Las Canteras | south → `las_palmas/vegueta_triana` | FerryHuelva → `huelva/exterior`, Mercadona → `las_palmas/mercadona`, Sala43_15 → `las_palmas/sala_canteras_43_15`, Sala26_19 → `las_palmas/sala_canteras_26_19`, Sala39_21 → `las_palmas/sala_canteras_39_21`, Sala25_32 → `las_palmas/sala_canteras_25_32`, Sala33_32 → `las_palmas/sala_canteras_33_32`, Sala41_31 → `las_palmas/sala_canteras_41_31`, Sala24_46 → `las_palmas/sala_canteras_24_46`, Sala41_46 → `las_palmas/sala_canteras_41_46` |
| `las_palmas/estanco` | Estanco · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/hospital` | Hospital · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/mercadona` | Mercadona · Las Palmas | — | Salida → `las_palmas/canteras` |
| `las_palmas/sala_canteras_24_46` | Oficinas · Las Palmas | — | Salida → `las_palmas/canteras` |
| `las_palmas/sala_canteras_25_32` | Edificio Cristal · Las Palmas | — | Salida → `las_palmas/canteras` |
| `las_palmas/sala_canteras_26_19` | Puesto · Las Palmas | — | Salida → `las_palmas/canteras` |
| `las_palmas/sala_canteras_33_32` | Portal · Las Palmas | — | Salida → `las_palmas/canteras` |
| `las_palmas/sala_canteras_39_21` | Tienda naranja · Las Palmas | — | Salida → `las_palmas/canteras` |
| `las_palmas/sala_canteras_41_31` | Portal verde · Las Palmas | — | Salida → `las_palmas/canteras` |
| `las_palmas/sala_canteras_41_46` | Portal · Las Palmas | — | Salida → `las_palmas/canteras` |
| `las_palmas/sala_canteras_43_15` | Castillo Luz · Las Palmas | — | Salida → `las_palmas/canteras` |
| `las_palmas/sala_vegueta_triana_11_8` | Casa de tejado azul · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_18_30` | Casa de teja · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_18_8` | Edificio Cupula · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_19_19` | Casa de tejado azul · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_21_38` | Catedral Santa Ana · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_24_19` | Casa de madera · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_25_8` | Casa de teja · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_31_27` | Casa roja pequeña · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_31_37` | Casa de madera · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_36_37` | Granero · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_37_46` | Casa de dos aguas · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_39_22` | Casa gris · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_3_35` | Casa de madera · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_3_46` | Casa de madera · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_42_37` | Puesto · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_42_46` | Casa de madera · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_4_8` | Casa de teja · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/sala_vegueta_triana_8_35` | Granero · Las Palmas | — | Salida → `las_palmas/vegueta_triana` |
| `las_palmas/vegueta_triana` | Las Palmas · Vegueta y Triana | north → `las_palmas/canteras`, south → `ruta_15/exterior` | Hospital → `las_palmas/hospital`, Estanco → `las_palmas/estanco`, Sala4_8 → `las_palmas/sala_vegueta_triana_4_8`, Sala11_8 → `las_palmas/sala_vegueta_triana_11_8`, Sala18_8 → `las_palmas/sala_vegueta_triana_18_8`, Sala25_8 → `las_palmas/sala_vegueta_triana_25_8`, Sala19_19 → `las_palmas/sala_vegueta_triana_19_19`, Sala24_19 → `las_palmas/sala_vegueta_triana_24_19`, Sala21_38 → `las_palmas/sala_vegueta_triana_21_38`, Sala31_37 → `las_palmas/sala_vegueta_triana_31_37`, Sala36_37 → `las_palmas/sala_vegueta_triana_36_37`, Sala42_37 → `las_palmas/sala_vegueta_triana_42_37`, Sala3_35 → `las_palmas/sala_vegueta_triana_3_35`, Sala8_35 → `las_palmas/sala_vegueta_triana_8_35`, Sala3_46 → `las_palmas/sala_vegueta_triana_3_46`, Sala37_46 → `las_palmas/sala_vegueta_triana_37_46`, Sala42_46 → `las_palmas/sala_vegueta_triana_42_46`, Sala39_22 → `las_palmas/sala_vegueta_triana_39_22`, Sala31_27 → `las_palmas/sala_vegueta_triana_31_27`, Sala18_30 → `las_palmas/sala_vegueta_triana_18_30` |
| `leganes/casa_1` | Casa de dos aguas · Leganés | — | Salida → `leganes/exterior` |
| `leganes/casa_2` | Casa roja · Leganés | — | Salida → `leganes/exterior` |
| `leganes/centro` | Centro Pokémon · Leganés | — | Salida → `leganes/exterior` |
| `leganes/estanco` | Estanco · Leganés | — | Salida → `leganes/exterior` |
| `leganes/exterior` | Leganés | west → `mostoles/exterior`, east → `getafe/exterior` | CercaniasAtocha → `madrid/retiro`, Centro → `leganes/centro`, Mercadona → `leganes/mercadona`, Estanco → `leganes/estanco`, Casa1 → `leganes/casa_1`, Casa2 → `leganes/casa_2`, Sala5_13 → `leganes/sala_calle_5_13`, Sala20_21 → `leganes/sala_calle_20_21`, Sala29_20 → `leganes/sala_calle_29_20`, Sala56_23 → `leganes/sala_calle_56_23`, Sala5_36 → `leganes/sala_calle_5_36`, Sala19_35 → `leganes/sala_calle_19_35`, Sala37_35 → `leganes/sala_calle_37_35`, Sala53_6 → `leganes/sala_calle_53_6`, Sala15_29 → `leganes/sala_calle_15_29`, Sala26_36 → `leganes/sala_calle_26_36`, Sala44_37 → `leganes/sala_calle_44_37`, Sala51_36 → `leganes/sala_calle_51_36`, Sala59_37 → `leganes/sala_calle_59_37` |
| `leganes/mercadona` | Mercadona · Leganés | — | Salida → `leganes/exterior` |
| `leganes/sala_calle_15_29` | Casa roja pequeña · Leganés | — | Salida → `leganes/exterior` |
| `leganes/sala_calle_19_35` | Granero · Leganés | — | Salida → `leganes/exterior` |
| `leganes/sala_calle_20_21` | San Salvador Leganes · Leganés | — | Salida → `leganes/exterior` |
| `leganes/sala_calle_26_36` | Casa de teja · Leganés | — | Salida → `leganes/exterior` |
| `leganes/sala_calle_29_20` | Casa naranja · Leganés | — | Salida → `leganes/exterior` |
| `leganes/sala_calle_37_35` | Casa de madera · Leganés | — | Salida → `leganes/exterior` |
| `leganes/sala_calle_44_37` | Portal · Leganés | — | Salida → `leganes/exterior` |
| `leganes/sala_calle_51_36` | Casa gris · Leganés | — | Salida → `leganes/exterior` |
| `leganes/sala_calle_53_6` | Casa gris · Leganés | — | Salida → `leganes/exterior` |
| `leganes/sala_calle_56_23` | Tienda azul · Leganés | — | Salida → `leganes/exterior` |
| `leganes/sala_calle_59_37` | Casa roja pequeña · Leganés | — | Salida → `leganes/exterior` |
| `leganes/sala_calle_5_13` | Oficinas · Leganés | — | Salida → `leganes/exterior` |
| `leganes/sala_calle_5_36` | Oficinas · Leganés | — | Salida → `leganes/exterior` |
| `madrid/atico_ayuso` | Ático de Ayuso · Chamberí | — | Bajar → `madrid/chamberi` |
| `madrid/atocha/mercadona` | Mercadona · Atocha | — | Salida → `madrid/retiro` |
| `madrid/bernabeu` | Madrid · Bernabéu | south → `madrid/chamberi` | Sala4_9 → `madrid/sala_bernabeu_4_9`, Sala34_9 → `madrid/sala_bernabeu_34_9`, Sala4_26 → `madrid/sala_bernabeu_4_26`, Sala34_26 → `madrid/sala_bernabeu_34_26`, Sala12_8 → `madrid/sala_bernabeu_12_8` |
| `madrid/centro` | Madrid · Sol y Gran Vía | west → `madrid/moncloa`, west → `madrid/palacio_real`, east → `madrid/retiro`, east → `madrid/retiro` | Hospital → `madrid/sol/hospital`, Sala5_5 → `madrid/sala_centro_5_5`, Sala14_5 → `madrid/sala_centro_14_5`, Sala25_13 → `madrid/sala_centro_25_13`, Sala31_13 → `madrid/sala_centro_31_13`, Sala41_7 → `madrid/sala_centro_41_7`, Sala40_16 → `madrid/sala_centro_40_16`, Sala46_17 → `madrid/sala_centro_46_17`, Sala53_17 → `madrid/sala_centro_53_17`, Sala62_21 → `madrid/sala_centro_62_21`, Sala68_21 → `madrid/sala_centro_68_21`, Sala4_19 → `madrid/sala_centro_4_19`, Sala11_19 → `madrid/sala_centro_11_19`, Sala5_27 → `madrid/sala_centro_5_27`, Sala14_27 → `madrid/sala_centro_14_27`, Sala22_27 → `madrid/sala_centro_22_27`, Sala39_31 → `madrid/gimnasio_1`, Sala20_42 → `madrid/sala_centro_20_42`, Sala4_48 → `madrid/sala_centro_4_48`, Sala54_31 → `madrid/sala_centro_54_31`, Sala63_31 → `madrid/sala_centro_63_31`, Sala67_31 → `madrid/sala_centro_67_31`, Sala53_42 → `madrid/sala_centro_53_42`, Sala60_41 → `madrid/sala_centro_60_41`, Sala68_41 → `madrid/sala_centro_68_41`, Sala53_52 → `madrid/sala_centro_53_52`, Sala62_52 → `madrid/sala_centro_62_52`, Sala18_4 → `madrid/sala_centro_18_4`, Sala33_6 → `madrid/sala_centro_33_6`, Sala49_10 → `madrid/sala_centro_49_10`, Sala53_8 → `madrid/sala_centro_53_8`, Sala68_13 → `madrid/sala_centro_68_13`, Sala49_26 → `madrid/sala_centro_49_26`, Sala35_50 → `madrid/sala_centro_35_50`, Sala3_39 → `madrid/sala_centro_3_39` |
| `madrid/chamberi` | Madrid · Chamberí | west → `madrid/moncloa`, north → `madrid/bernabeu` | Mercadona → `madrid/chamberi/mercadona`, Estanco → `madrid/chamberi/estanco`, Sala3_7 → `madrid/sala_chamberi_3_7`, Sala10_7 → `madrid/sala_chamberi_10_7`, Sala18_6 → `madrid/sala_chamberi_18_6`, Sala39_7 → `madrid/sala_chamberi_39_7`, Sala29_6 → `madrid/sala_chamberi_29_6`, Sala3_18 → `madrid/sala_chamberi_3_18`, Sala39_20 → `madrid/sala_chamberi_39_20`, Sala16_28 → `madrid/sala_chamberi_16_28`, Sala31_32 → `madrid/sala_chamberi_31_32`, Sala39_33 → `madrid/sala_chamberi_39_33`, Sala46_33 → `madrid/sala_chamberi_46_33`, Sala4_41 → `madrid/sala_chamberi_4_41`, Sala38_42 → `madrid/sala_chamberi_38_42`, Sala24_40 → `madrid/sala_chamberi_24_40`, Sala17_19 → `madrid/sala_chamberi_17_19`, Sala29_22 → `madrid/sala_chamberi_29_22`, Sala3_35 → `madrid/sala_chamberi_3_35`, Sala44_12 → `madrid/sala_chamberi_44_12` |
| `madrid/chamberi/estanco` | Estanco · Chamberí | — | Salida → `madrid/chamberi` |
| `madrid/chamberi/mercadona` | Mercadona · Chamberí | — | Salida → `madrid/chamberi` |
| `madrid/estanco` | Estanco · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/gimnasio_1` | Real Casa De Correos · Registro | — | Salida → `madrid/centro`, Siguiente → `madrid/gimnasio_2` |
| `madrid/gimnasio_2` | Real Casa De Correos · Grupo Popular | — | Salida → `madrid/gimnasio_1`, Siguiente → `madrid/gimnasio_3` |
| `madrid/gimnasio_3` | Real Casa De Correos · Archivo De Títulos | — | Salida → `madrid/gimnasio_2`, Siguiente → `madrid/gimnasio_lider` |
| `madrid/gimnasio_lider` | Real Casa De Correos · Despacho De La Presidenta | — | Salida → `madrid/gimnasio_3` |
| `madrid/hospital` | Hospital · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/laboratorio` | Laboratorio del profesor Unicoos | — | Salida → `madrid/moncloa` |
| `madrid/mercadona` | Mercadona · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/moncloa` | Madrid · Moncloa | west → `ruta_4/exterior`, east → `madrid/centro`, east → `madrid/chamberi`, south → `casa_de_campo/exterior` | Hospital → `madrid/hospital`, Mercadona → `madrid/mercadona`, Estanco → `madrid/estanco`, Sala7_41 → `madrid/sala_moncloa_7_41`, Sala23_37 → `madrid/sala_moncloa_23_37`, Sala23_49 → `madrid/sala_moncloa_23_49`, Sala40_16 → `madrid/laboratorio`, Sala47_17 → `madrid/sala_moncloa_47_17`, Sala56_17 → `madrid/sala_moncloa_56_17`, Sala58_29 → `madrid/quiron`, Sala39_39 → `madrid/sala_moncloa_39_39`, Sala59_39 → `madrid/sala_moncloa_59_39`, Sala34_38 → `madrid/sala_moncloa_34_38`, Sala32_49 → `madrid/sala_moncloa_32_49`, Sala38_49 → `madrid/sala_moncloa_38_49`, Sala29_32 → `madrid/sala_moncloa_29_32` |
| `madrid/palacio_real` | Madrid · Palacio Real | east → `madrid/centro` | Sala23_30 → `madrid/sala_palacio_real_23_30`, Sala23_54 → `madrid/sala_palacio_real_23_54`, Sala59_25 → `madrid/sala_palacio_real_59_25`, Sala46_11 → `madrid/sala_palacio_real_46_11`, Sala54_11 → `madrid/sala_palacio_real_54_11` |
| `madrid/quiron` | Hospital Quirón · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/retiro` | Madrid · Retiro y Prado | west → `madrid/centro`, west → `madrid/centro`, east → `ruta_5/exterior`, south → `madrid_rio/exterior` | CercaniasLeganes → `leganes/exterior`, CercaniasMostoles → `mostoles/exterior`, Mercadona → `madrid/atocha/mercadona`, Sala28_13 → `madrid/sala_retiro_28_13`, Sala55_47 → `madrid/sala_retiro_55_47`, Sala4_29 → `madrid/sala_retiro_4_29`, Sala23_44 → `madrid/sala_retiro_23_44`, Sala20_58 → `madrid/sala_retiro_20_58`, Sala3_13 → `madrid/sala_retiro_3_13`, Sala39_13 → `madrid/sala_retiro_39_13`, Sala23_31 → `madrid/sala_retiro_23_31`, Sala36_37 → `madrid/sala_retiro_36_37`, Sala3_47 → `madrid/sala_retiro_3_47` |
| `madrid/sala_bernabeu_12_8` | Oficinas · Madrid | — | Salida → `madrid/bernabeu` |
| `madrid/sala_bernabeu_34_26` | Tienda azul · Madrid | — | Salida → `madrid/bernabeu` |
| `madrid/sala_bernabeu_34_9` | Edificio Cristal · Madrid | — | Salida → `madrid/bernabeu` |
| `madrid/sala_bernabeu_4_26` | Portal · Madrid | — | Salida → `madrid/bernabeu` |
| `madrid/sala_bernabeu_4_9` | Oficinas · Madrid | — | Salida → `madrid/bernabeu` |
| `madrid/sala_centro_11_19` | Oficinas · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_14_27` | Tienda morada · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_14_5` | Tienda azul · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_18_4` | Puesto · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_20_42` | Panadería · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_22_27` | Grandes almacenes · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_25_13` | Edificio Carrion · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_31_13` | Teatro · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_33_6` | Tienda azul · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_35_50` | Portal · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_3_39` | Oficinas · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_40_16` | Oficinas · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_41_7` | Portal verde · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_46_17` | Teatro · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_49_10` | Tienda morada · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_49_26` | Portal verde · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_4_19` | Portal · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_4_48` | Mercado San Miguel · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_53_17` | Portal · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_53_42` | Portal · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_53_52` | Teatro · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_53_8` | Oficinas · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_54_31` | Portal verde · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_5_27` | Portal verde · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_5_5` | Portal verde · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_60_41` | Oficinas · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_62_21` | Edificio Metropolis · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_62_52` | Floristería · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_63_31` | Tienda morada · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_67_31` | Teatro · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_68_13` | Portal · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_68_21` | Oficinas · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_centro_68_41` | Portal verde · Madrid | — | Salida → `madrid/centro` |
| `madrid/sala_chamberi_10_7` | Oficinas · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_16_28` | Puesto · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_17_19` | Portal verde · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_18_6` | Portal verde · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_24_40` | Metro · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_29_22` | Portal · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_29_6` | Edificio Cupula · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_31_32` | Ático · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_38_42` | Portal · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_39_20` | Oficinas · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_39_33` | Portal · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_39_7` | Portal · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_3_18` | Portal · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_3_35` | Oficinas · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_3_7` | Portal · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_44_12` | Oficinas · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_46_33` | Tienda azul · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_chamberi_4_41` | Portal verde · Madrid | — | Salida → `madrid/chamberi` |
| `madrid/sala_moncloa_23_37` | Oficinas · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/sala_moncloa_23_49` | Portal · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/sala_moncloa_29_32` | Casa gris · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/sala_moncloa_32_49` | Portal verde · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/sala_moncloa_34_38` | Puesto · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/sala_moncloa_38_49` | Teatro · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/sala_moncloa_39_39` | Oficinas · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/sala_moncloa_40_16` | Oficinas · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/sala_moncloa_47_17` | Portal · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/sala_moncloa_56_17` | Grandes almacenes · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/sala_moncloa_58_29` | Portal · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/sala_moncloa_59_39` | Portal verde · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/sala_moncloa_7_41` | Templo Debod · Madrid | — | Salida → `madrid/moncloa` |
| `madrid/sala_palacio_real_23_30` | Palacio Real · Madrid | — | Salida → `madrid/palacio_real` |
| `madrid/sala_palacio_real_23_54` | Catedral Almudena · Madrid | — | Salida → `madrid/palacio_real` |
| `madrid/sala_palacio_real_46_11` | Portal · Madrid | — | Salida → `madrid/palacio_real` |
| `madrid/sala_palacio_real_54_11` | Oficinas · Madrid | — | Salida → `madrid/palacio_real` |
| `madrid/sala_palacio_real_59_25` | Teatro Real · Madrid | — | Salida → `madrid/palacio_real` |
| `madrid/sala_retiro_20_58` | Estacion Atocha · Madrid | — | Salida → `madrid/retiro` |
| `madrid/sala_retiro_23_31` | Oficinas · Madrid | — | Salida → `madrid/retiro` |
| `madrid/sala_retiro_23_44` | Museo Prado · Madrid | — | Salida → `madrid/retiro` |
| `madrid/sala_retiro_28_13` | Palacio Cibeles · Madrid | — | Salida → `madrid/retiro` |
| `madrid/sala_retiro_36_37` | Portal verde · Madrid | — | Salida → `madrid/retiro` |
| `madrid/sala_retiro_39_13` | Portal verde · Madrid | — | Salida → `madrid/retiro` |
| `madrid/sala_retiro_3_13` | Oficinas · Madrid | — | Salida → `madrid/retiro` |
| `madrid/sala_retiro_3_47` | Portal · Madrid | — | Salida → `madrid/retiro` |
| `madrid/sala_retiro_4_29` | Congreso · Madrid | — | Salida → `madrid/retiro` |
| `madrid/sala_retiro_55_47` | Palacio Cristal · Madrid | — | Salida → `madrid/retiro` |
| `madrid/sol/hospital` | Hospital · Sol | — | Salida → `madrid/centro` |
| `madrid_rio/exterior` | Madrid Río | south → `orcasitas/exterior`, north → `madrid/retiro` | — |
| `malaga/casa_1` | Casa de dos aguas · Málaga | — | Salida → `malaga/exterior` |
| `malaga/casa_2` | Casa de la chimenea · Málaga | — | Salida → `malaga/exterior` |
| `malaga/estanco` | Estanco · Málaga | — | Salida → `malaga/exterior` |
| `malaga/exterior` | Málaga | north → `ruta_26/exterior` | Hospital → `malaga/hospital`, Mercadona → `malaga/mercadona`, Estanco → `malaga/estanco`, Casa1 → `malaga/casa_1`, Casa2 → `malaga/casa_2`, Sala50_42 → `malaga/sala_calle_50_42`, Sala48_35 → `malaga/sala_calle_48_35`, Sala58_10 → `malaga/sala_calle_58_10`, Sala23_39 → `malaga/sala_calle_23_39`, Sala29_39 → `malaga/sala_calle_29_39`, Sala35_39 → `malaga/sala_calle_35_39`, Sala25_54 → `malaga/sala_calle_25_54`, Sala5_57 → `malaga/sala_calle_5_57`, Sala76_16 → `malaga/sala_calle_76_16`, Sala60_35 → `malaga/sala_calle_60_35`, Sala67_70 → `malaga/sala_calle_67_70`, Sala83_64 → `malaga/sala_calle_83_64`, Sala77_65 → `malaga/sala_calle_77_65`, Gimnasio → `malaga/gimnasio_1`, Sala3_6 → `malaga/sala_calle_3_6`, Sala31_7 → `malaga/sala_calle_31_7`, Sala72_8 → `malaga/sala_calle_72_8`, Sala80_9 → `malaga/sala_calle_80_9`, Sala87_8 → `malaga/sala_calle_87_8`, Sala5_13 → `malaga/sala_calle_5_13` |
| `malaga/gimnasio_1` | Rodaje En El Puerto · Catering | — | Salida → `malaga/exterior`, Siguiente → `malaga/gimnasio_2` |
| `malaga/gimnasio_2` | Rodaje En El Puerto · Camerinos | — | Salida → `malaga/gimnasio_1`, Siguiente → `malaga/gimnasio_3` |
| `malaga/gimnasio_3` | Rodaje En El Puerto · Maquillaje | — | Salida → `malaga/gimnasio_2`, Siguiente → `malaga/gimnasio_lider` |
| `malaga/gimnasio_lider` | Rodaje En El Puerto · Plató | — | Salida → `malaga/gimnasio_3` |
| `malaga/hospital` | Hospital · Málaga | — | Salida → `malaga/exterior` |
| `malaga/mercadona` | Mercadona · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_23_39` | Puesto · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_25_54` | Oficinas · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_29_39` | Puesto · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_31_7` | Casa roja pequeña · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_35_39` | Puesto · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_3_6` | Casa gris · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_48_35` | Catedral Malaga · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_50_42` | Tienda azul · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_58_10` | Casa naranja · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_5_13` | Casa roja pequeña · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_5_57` | Oficinas · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_60_35` | Castillo Luz · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_67_70` | Velero · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_72_8` | Casa de teja · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_76_16` | Castillo Luz · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_77_65` | Torre de socorro · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_80_9` | Portal · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_83_64` | Casa de madera · Málaga | — | Salida → `malaga/exterior` |
| `malaga/sala_calle_87_8` | Casa gris · Málaga | — | Salida → `malaga/exterior` |
| `maritima_1/exterior` | Ruta marítima 1 · Canal de Ibiza | north → `palma/exterior`, south → `ibiza/exterior` | — |
| `mostoles/casa_1` | Casa de dos aguas · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/casa_2` | Granero · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/centro` | Centro Pokémon · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/estanco` | Estanco · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/exterior` | Móstoles | east → `leganes/exterior` | CercaniasAtocha → `madrid/retiro`, Centro → `mostoles/centro`, Mercadona → `mostoles/mercadona`, Estanco → `mostoles/estanco`, Casa1 → `mostoles/casa_1`, Casa2 → `mostoles/casa_2`, Sala23_11 → `mostoles/sala_calle_23_11`, Sala20_20 → `mostoles/sala_calle_20_20`, Sala30_20 → `mostoles/sala_calle_30_20`, Sala39_19 → `mostoles/sala_calle_39_19`, Sala5_23 → `mostoles/sala_calle_5_23`, Sala24_29 → `mostoles/sala_calle_24_29`, Sala39_28 → `mostoles/sala_calle_39_28`, Sala55_28 → `mostoles/sala_calle_55_28`, Sala56_37 → `mostoles/sala_calle_56_37`, Sala41_49 → `mostoles/sala_calle_41_49`, Sala25_48 → `mostoles/sala_calle_25_48`, Sala53_48 → `mostoles/sala_calle_53_48`, Sala5_10 → `mostoles/sala_calle_5_10`, Sala11_6 → `mostoles/sala_calle_11_6`, Sala47_15 → `mostoles/sala_calle_47_15`, Sala32_48 → `mostoles/sala_calle_32_48`, Sala7_34 → `mostoles/sala_calle_7_34` |
| `mostoles/mercadona` | Mercadona · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_11_6` | Casa gris · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_20_20` | Asuncion Mostoles · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_23_11` | Oficinas · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_24_29` | Casa roja pequeña · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_25_48` | Casa de la chimenea · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_30_20` | Ermita Virgen Del Rio · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_32_48` | Casa de teja · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_39_19` | Casa naranja · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_39_28` | Casa azul pequeña · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_41_49` | Oficinas · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_47_15` | Casa roja pequeña · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_53_48` | Casa de dos aguas · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_55_28` | Casa pequeña · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_56_37` | Tienda azul · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_5_10` | Oficinas · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_5_23` | Casa de madera · Móstoles | — | Salida → `mostoles/exterior` |
| `mostoles/sala_calle_7_34` | Casa gris · Móstoles | — | Salida → `mostoles/exterior` |
| `murcia/centro` | Centro Pokémon · Murcia | — | Salida → `murcia/exterior` |
| `murcia/estanco` | Estanco · Murcia | — | Salida → `murcia/exterior` |
| `murcia/exterior` | Murcia | east → `ruta_11/exterior`, west → `ruta_12/exterior` | Centro → `murcia/centro`, Mercadona → `murcia/mercadona`, Estanco → `murcia/estanco`, Sala40_30 → `murcia/sala_calle_40_30`, Sala4_12 → `murcia/sala_calle_4_12`, Sala11_12 → `murcia/sala_calle_11_12`, Sala23_11 → `murcia/sala_calle_23_11`, Sala41_11 → `murcia/sala_calle_41_11`, Sala58_12 → `murcia/sala_calle_58_12`, Sala65_11 → `murcia/sala_calle_65_11`, Sala5_26 → `murcia/sala_calle_5_26`, Sala12_25 → `murcia/sala_calle_12_25`, Sala25_25 → `murcia/sala_calle_25_25`, Sala58_26 → `murcia/sala_calle_58_26`, Sala63_25 → `murcia/sala_calle_63_25`, Sala25_35 → `murcia/sala_calle_25_35`, Sala48_35 → `murcia/sala_calle_48_35`, Sala59_34 → `murcia/sala_calle_59_34`, Sala65_34 → `murcia/sala_calle_65_34`, Sala13_53 → `murcia/sala_calle_13_53`, Sala20_54 → `murcia/sala_calle_20_54`, Sala28_54 → `murcia/sala_calle_28_54`, Sala59_53 → `murcia/sala_calle_59_53`, Sala65_53 → `murcia/sala_calle_65_53`, Sala32_25 → `murcia/sala_calle_32_25` |
| `murcia/mercadona` | Mercadona · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_11_12` | Teatro · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_12_25` | Puesto · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_13_53` | Casa de madera · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_20_54` | Portal · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_23_11` | Oficinas · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_25_25` | Edificio Cupula · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_25_35` | Portal verde · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_28_54` | Tienda naranja · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_32_25` | Puesto · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_40_30` | Catedral de Murcia · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_41_11` | Portal verde · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_48_35` | Oficinas · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_4_12` | Portal · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_58_12` | Portal · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_58_26` | Tienda azul · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_59_34` | Casa naranja · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_59_53` | Casa naranja · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_5_26` | Floristería · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_63_25` | Casa de la chimenea · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_65_11` | Casa de dos aguas · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_65_34` | Casa de madera · Murcia | — | Salida → `murcia/exterior` |
| `murcia/sala_calle_65_53` | Casa de dos aguas · Murcia | — | Salida → `murcia/exterior` |
| `orcasitas/casa_jugador` | Tu casa · Orcasitas | — | Salida → `orcasitas/exterior` |
| `orcasitas/casa_rival` | Casa del rival · Orcasitas | — | Salida → `orcasitas/exterior` |
| `orcasitas/exterior` | Orcasitas | north → `madrid_rio/exterior` | CasaJugador → `orcasitas/casa_jugador`, CasaRival → `orcasitas/casa_rival`, Sala28_12 → `orcasitas/sala_calle_28_12`, Sala36_9 → `orcasitas/sala_calle_36_9`, Sala5_32 → `orcasitas/sala_calle_5_32`, Sala29_20 → `orcasitas/sala_calle_29_20` |
| `orcasitas/sala_calle_28_12` | Portal · Orcasitas | — | Salida → `orcasitas/exterior` |
| `orcasitas/sala_calle_29_20` | Tienda morada · Orcasitas | — | Salida → `orcasitas/exterior` |
| `orcasitas/sala_calle_36_9` | Portal verde · Orcasitas | — | Salida → `orcasitas/exterior` |
| `orcasitas/sala_calle_5_32` | Portal · Orcasitas | — | Salida → `orcasitas/exterior` |
| `palma/casa_1` | Casa de la chimenea · Palma | — | Salida → `palma/exterior` |
| `palma/casa_2` | Casa de dos aguas · Palma | — | Salida → `palma/exterior` |
| `palma/centro` | Centro Pokémon · Palma | — | Salida → `palma/exterior` |
| `palma/estanco` | Estanco · Palma | — | Salida → `palma/exterior` |
| `palma/exterior` | Palma de Mallorca | south → `maritima_1/exterior` | FerryBarcelona → `barcelona/ciutat_vella`, Centro → `palma/centro`, Mercadona → `palma/mercadona`, Estanco → `palma/estanco`, Casa1 → `palma/casa_1`, Casa2 → `palma/casa_2`, Sala7_14 → `palma/sala_calle_7_14`, Sala42_41 → `palma/sala_calle_42_41`, Sala32_40 → `palma/sala_calle_32_40`, Sala67_13 → `palma/sala_calle_67_13`, Sala44_12 → `palma/sala_calle_44_12`, Sala21_27 → `palma/sala_calle_21_27`, Sala45_26 → `palma/sala_calle_45_26`, Sala54_30 → `palma/sala_calle_54_30`, Sala61_30 → `palma/sala_calle_61_30`, Sala67_29 → `palma/sala_calle_67_29`, Sala59_43 → `palma/sala_calle_59_43`, Sala66_43 → `palma/sala_calle_66_43`, Sala19_6 → `palma/sala_calle_19_6`, Sala57_21 → `palma/sala_calle_57_21`, Sala3_38 → `palma/sala_calle_3_38` |
| `palma/mercadona` | Mercadona · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_19_6` | Casa gris · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_21_27` | Portal verde · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_32_40` | Torre · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_3_38` | Casa gris · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_42_41` | Catedral Palma · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_44_12` | Casa de madera · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_45_26` | Tienda azul · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_54_30` | Portal · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_57_21` | Casa roja pequeña · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_59_43` | Portal · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_61_30` | Oficinas · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_66_43` | Portal verde · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_67_13` | Portal · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_67_29` | Granero · Palma | — | Salida → `palma/exterior` |
| `palma/sala_calle_7_14` | Castillo Bellver · Palma | — | Salida → `palma/exterior` |
| `playa_del_ingles/estanco` | Estanco · Playa del Inglés | — | Salida → `playa_del_ingles/exterior` |
| `playa_del_ingles/exterior` | Playa del Inglés | north → `ruta_15/exterior` | AvionVigo → `vigo/exterior`, Hospital → `playa_del_ingles/hospital`, Mercadona → `playa_del_ingles/mercadona`, Estanco → `playa_del_ingles/estanco`, Sala41_7 → `playa_del_ingles/sala_calle_41_7`, Sala5_20 → `playa_del_ingles/sala_calle_5_20`, Sala16_18 → `playa_del_ingles/sala_calle_16_18`, Sala24_21 → `playa_del_ingles/sala_calle_24_21`, Sala33_20 → `playa_del_ingles/sala_calle_33_20`, Sala39_21 → `playa_del_ingles/sala_calle_39_21`, Sala53_11 → `playa_del_ingles/sala_calle_53_11`, Sala7_54 → `playa_del_ingles/sala_calle_7_54`, Gimnasio → `playa_del_ingles/gimnasio_1` |
| `playa_del_ingles/gimnasio_1` | Concierto En La Playa · Pista | — | Salida → `playa_del_ingles/exterior`, Siguiente → `playa_del_ingles/gimnasio_2` |
| `playa_del_ingles/gimnasio_2` | Concierto En La Playa · Zona Vip | — | Salida → `playa_del_ingles/gimnasio_1`, Siguiente → `playa_del_ingles/gimnasio_3` |
| `playa_del_ingles/gimnasio_3` | Concierto En La Playa · Backstage | — | Salida → `playa_del_ingles/gimnasio_2`, Siguiente → `playa_del_ingles/gimnasio_lider` |
| `playa_del_ingles/gimnasio_lider` | Concierto En La Playa · Escenario | — | Salida → `playa_del_ingles/gimnasio_3` |
| `playa_del_ingles/hospital` | Hospital · Playa del Inglés | — | Salida → `playa_del_ingles/exterior` |
| `playa_del_ingles/mercadona` | Mercadona · Playa del Inglés | — | Salida → `playa_del_ingles/exterior` |
| `playa_del_ingles/sala_calle_16_18` | Edificio Cristal · Playa del Inglés | — | Salida → `playa_del_ingles/exterior` |
| `playa_del_ingles/sala_calle_24_21` | Portal · Playa del Inglés | — | Salida → `playa_del_ingles/exterior` |
| `playa_del_ingles/sala_calle_33_20` | Portal verde · Playa del Inglés | — | Salida → `playa_del_ingles/exterior` |
| `playa_del_ingles/sala_calle_39_21` | Oficinas · Playa del Inglés | — | Salida → `playa_del_ingles/exterior` |
| `playa_del_ingles/sala_calle_41_7` | Tienda naranja · Playa del Inglés | — | Salida → `playa_del_ingles/exterior` |
| `playa_del_ingles/sala_calle_53_11` | Torre de socorro · Playa del Inglés | — | Salida → `playa_del_ingles/exterior` |
| `playa_del_ingles/sala_calle_5_20` | Grandes almacenes · Playa del Inglés | — | Salida → `playa_del_ingles/exterior` |
| `playa_del_ingles/sala_calle_7_54` | Faro · Playa del Inglés | — | Salida → `playa_del_ingles/exterior` |
| `pozuelo/casa_jugador` | Tu casa · Pozuelo | — | Salida → `pozuelo/exterior` |
| `pozuelo/casa_rival` | Casa del rival · Pozuelo | — | Salida → `pozuelo/exterior` |
| `pozuelo/exterior` | Pozuelo de Alarcón | east → `casa_de_campo/exterior` | CasaJugador → `pozuelo/casa_jugador`, CasaRival → `pozuelo/casa_rival`, Sala21_11 → `pozuelo/sala_calle_21_11`, Sala37_12 → `pozuelo/sala_calle_37_12`, Sala7_30 → `pozuelo/sala_calle_7_30`, Sala13_29 → `pozuelo/sala_calle_13_29`, Sala22_29 → `pozuelo/sala_calle_22_29`, Sala31_29 → `pozuelo/sala_calle_31_29`, Sala17_23 → `pozuelo/sala_calle_17_23` |
| `pozuelo/sala_calle_13_29` | Casa de madera · Pozuelo | — | Salida → `pozuelo/exterior` |
| `pozuelo/sala_calle_17_23` | Casa rosa · Pozuelo | — | Salida → `pozuelo/exterior` |
| `pozuelo/sala_calle_21_11` | Casa azul · Pozuelo | — | Salida → `pozuelo/exterior` |
| `pozuelo/sala_calle_22_29` | Casa de tejado rojo · Pozuelo | — | Salida → `pozuelo/exterior` |
| `pozuelo/sala_calle_31_29` | Casa de la chimenea · Pozuelo | — | Salida → `pozuelo/exterior` |
| `pozuelo/sala_calle_37_12` | Casa naranja · Pozuelo | — | Salida → `pozuelo/exterior` |
| `pozuelo/sala_calle_7_30` | Casa rosa · Pozuelo | — | Salida → `pozuelo/exterior` |
| `pueblo_inicial/casa_1` | Casa naranja · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `pueblo_inicial/casa_2` | Granero · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `pueblo_inicial/exterior` | San Miguel de Bernuy | west → `ruta_23/exterior`, south → `ruta_1/exterior` | Casa1 → `pueblo_inicial/casa_1`, Casa2 → `pueblo_inicial/casa_2`, Sala19_14 → `pueblo_inicial/sala_calle_19_14`, Sala36_14 → `pueblo_inicial/sala_calle_36_14`, Sala30_21 → `pueblo_inicial/sala_calle_30_21`, Sala38_21 → `pueblo_inicial/sala_calle_38_21`, Sala12_28 → `pueblo_inicial/sala_calle_12_28`, Sala25_29 → `pueblo_inicial/sala_calle_25_29`, Sala31_29 → `pueblo_inicial/sala_calle_31_29`, Sala36_29 → `pueblo_inicial/sala_calle_36_29`, Sala25_39 → `pueblo_inicial/sala_calle_25_39`, Sala30_39 → `pueblo_inicial/sala_calle_30_39`, Sala36_39 → `pueblo_inicial/sala_calle_36_39`, Sala13_46 → `pueblo_inicial/sala_calle_13_46`, Sala26_48 → `pueblo_inicial/sala_calle_26_48` |
| `pueblo_inicial/sala_calle_12_28` | Casa roja · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `pueblo_inicial/sala_calle_13_46` | Casa de tejado rojo · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `pueblo_inicial/sala_calle_19_14` | Iglesia San Miguel · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `pueblo_inicial/sala_calle_25_29` | Casa azul pequeña · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `pueblo_inicial/sala_calle_25_39` | Casa de madera · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `pueblo_inicial/sala_calle_26_48` | Ermita Virgen Del Rio · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `pueblo_inicial/sala_calle_30_21` | Edificio Cupula · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `pueblo_inicial/sala_calle_30_39` | Casa de dos aguas · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `pueblo_inicial/sala_calle_31_29` | Casa de dos aguas · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `pueblo_inicial/sala_calle_36_14` | Casa de la chimenea · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `pueblo_inicial/sala_calle_36_29` | Granero · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `pueblo_inicial/sala_calle_36_39` | Casa de la chimenea · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `pueblo_inicial/sala_calle_38_21` | Casa de madera · Pueblo | — | Salida → `pueblo_inicial/exterior` |
| `puertollano/casa_1` | Casa roja · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/casa_2` | Casa de dos aguas · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/centro` | Centro Pokémon · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/estanco` | Estanco · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/exterior` | Puertollano | south → `ruta_25/exterior`, north → `ruta_24/exterior` | Centro → `puertollano/centro`, Mercadona → `puertollano/mercadona`, Estanco → `puertollano/estanco`, Casa1 → `puertollano/casa_1`, Casa2 → `puertollano/casa_2`, Sala30_12 → `puertollano/sala_calle_30_12`, Sala44_35 → `puertollano/sala_calle_44_35`, Sala6_23 → `puertollano/sala_calle_6_23`, Sala19_24 → `puertollano/sala_calle_19_24`, Sala7_61 → `puertollano/sala_calle_7_61`, Sala21_60 → `puertollano/sala_calle_21_60`, Sala6_36 → `puertollano/sala_calle_6_36`, Sala16_43 → `puertollano/sala_calle_16_43`, Sala22_42 → `puertollano/sala_calle_22_42`, Sala65_51 → `puertollano/sala_calle_65_51`, Sala62_33 → `puertollano/sala_calle_62_33`, Sala51_60 → `puertollano/sala_calle_51_60`, Sala51_6 → `puertollano/sala_calle_51_6`, Sala59_7 → `puertollano/sala_calle_59_7`, Sala64_8 → `puertollano/sala_calle_64_8`, Sala38_13 → `puertollano/sala_calle_38_13`, Sala61_16 → `puertollano/sala_calle_61_16`, Sala37_21 → `puertollano/sala_calle_37_21` |
| `puertollano/mercadona` | Mercadona · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_16_43` | Asuncion Mostoles · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_19_24` | Casa naranja · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_21_60` | Casa de dos aguas · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_22_42` | Casa de la chimenea · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_30_12` | Ermita Virgen Del Rio · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_37_21` | Casa roja pequeña · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_38_13` | Portal · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_44_35` | Oficinas · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_51_6` | Casa gris · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_51_60` | Oficinas · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_59_7` | Casa roja pequeña · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_61_16` | Casa gris · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_62_33` | Oficinas · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_64_8` | Casa de teja · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_65_51` | Tienda azul · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_6_23` | Casa de madera · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_6_36` | Oficinas · Puertollano | — | Salida → `puertollano/exterior` |
| `puertollano/sala_calle_7_61` | Portal · Puertollano | — | Salida → `puertollano/exterior` |
| `ruta_1/exterior` | Ruta 1 · Hoces del Duratón | north → `pueblo_inicial/exterior`, south → `ruta_2/exterior` | — |
| `ruta_10/exterior` | Ruta 10 · Costa Blanca | north → `ruta_9/exterior`, south → `alicante/exterior` | Sala31_8 → `ruta_10/sala_calle_31_8`, Sala35_8 → `ruta_10/sala_calle_35_8`, Sala31_13 → `ruta_10/sala_calle_31_13`, Sala10_23 → `ruta_10/sala_calle_10_23`, Sala16_20 → `ruta_10/sala_calle_16_20`, Sala18_24 → `ruta_10/sala_calle_18_24`, Sala6_40 → `ruta_10/sala_calle_6_40`, Sala10_40 → `ruta_10/sala_calle_10_40`, Sala20_40 → `ruta_10/sala_calle_20_40`, Sala15_40 → `ruta_10/sala_calle_15_40`, Sala9_50 → `ruta_10/sala_calle_9_50`, Sala16_50 → `ruta_10/sala_calle_16_50`, Sala22_50 → `ruta_10/sala_calle_22_50`, Sala32_51 → `ruta_10/sala_calle_32_51`, Sala41_27 → `ruta_10/sala_calle_41_27`, Sala7_60 → `ruta_10/sala_calle_7_60`, Sala11_59 → `ruta_10/sala_calle_11_59`, Sala17_59 → `ruta_10/sala_calle_17_59`, Sala23_60 → `ruta_10/sala_calle_23_60` |
| `ruta_10/sala_calle_10_23` | Iglesia de Altea · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_10_40` | Apartamentos · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_11_59` | Casa azul pequeña · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_15_40` | Intempo · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_16_20` | Casa ibicenca · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_16_50` | Tienda azul · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_17_59` | Casa naranja · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_18_24` | Casa ibicenca · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_20_40` | Apartamentos · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_22_50` | Floristería · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_23_60` | Casa roja pequeña · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_31_13` | Casa ibicenca · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_31_8` | Casa ibicenca · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_32_51` | Portal · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_35_8` | Casa ibicenca · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_41_27` | Torre de socorro · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_6_40` | Apartamentos · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_7_60` | Casa rosa · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_10/sala_calle_9_50` | Tienda naranja · Ruta 10 | — | Salida → `ruta_10/exterior` |
| `ruta_11/exterior` | Ruta 11 · Palmeral de Elche | east → `alicante/exterior`, west → `murcia/exterior` | Sala35_28 → `ruta_11/sala_calle_35_28`, Sala44_27 → `ruta_11/sala_calle_44_27`, Sala11_27 → `ruta_11/sala_calle_11_27`, Sala17_27 → `ruta_11/sala_calle_17_27`, Sala23_27 → `ruta_11/sala_calle_23_27` |
| `ruta_11/sala_calle_11_27` | Casa de teja · Ruta 11 | — | Salida → `ruta_11/exterior` |
| `ruta_11/sala_calle_17_27` | Casa de la chimenea · Ruta 11 | — | Salida → `ruta_11/exterior` |
| `ruta_11/sala_calle_23_27` | Casa de madera · Ruta 11 | — | Salida → `ruta_11/exterior` |
| `ruta_11/sala_calle_35_28` | Basílica de Santa María · Ruta 11 | — | Salida → `ruta_11/exterior` |
| `ruta_11/sala_calle_44_27` | Casa de dos aguas · Ruta 11 | — | Salida → `ruta_11/exterior` |
| `ruta_12/casa_1` | Casa · Ruta 12 | — | Salida → `ruta_12/exterior` |
| `ruta_12/exterior` | Ruta 12 · Sierra Nevada y Granada | west → `ruta_13/exterior`, east → `murcia/exterior` | Casa1 → `ruta_12/casa_1` |
| `ruta_13/casa_1` | Casa · Ruta 13 | — | Salida → `ruta_13/exterior` |
| `ruta_13/casa_2` | Casa · Ruta 13 | — | Salida → `ruta_13/exterior` |
| `ruta_13/exterior` | Ruta 13 · Mar de olivos | east → `ruta_12/exterior`, west → `sevilla/centro` | Casa1 → `ruta_13/casa_1`, Casa2 → `ruta_13/casa_2` |
| `ruta_14/casa_1` | Casa · Ruta 14 | — | Salida → `ruta_14/exterior` |
| `ruta_14/casa_2` | Casa · Ruta 14 | — | Salida → `ruta_14/exterior` |
| `ruta_14/exterior` | Ruta 14 · Doñana | east → `sevilla/rio`, west → `huelva/exterior` | Casa1 → `ruta_14/casa_1`, Casa2 → `ruta_14/casa_2`, Sala53_9 → `ruta_14/sala_calle_53_9`, Sala53_17 → `ruta_14/sala_calle_53_17`, Sala57_9 → `ruta_14/sala_calle_57_9`, Sala34_13 → `ruta_14/sala_calle_34_13` |
| `ruta_14/sala_calle_34_13` | Cabaña · Ruta 14 | — | Salida → `ruta_14/exterior` |
| `ruta_14/sala_calle_53_17` | Casa ibicenca · Ruta 14 | — | Salida → `ruta_14/exterior` |
| `ruta_14/sala_calle_53_9` | Casa ibicenca · Ruta 14 | — | Salida → `ruta_14/exterior` |
| `ruta_14/sala_calle_57_9` | Casa ibicenca · Ruta 14 | — | Salida → `ruta_14/exterior` |
| `ruta_15/casa_1` | Casa · Ruta 15 | — | Salida → `ruta_15/exterior` |
| `ruta_15/casa_2` | Casa · Ruta 15 | — | Salida → `ruta_15/exterior` |
| `ruta_15/exterior` | Ruta 15 · Costa de Gran Canaria | north → `las_palmas/vegueta_triana`, south → `playa_del_ingles/exterior` | Casa1 → `ruta_15/casa_1`, Casa2 → `ruta_15/casa_2` |
| `ruta_16/casa_1` | Casa · Ruta 16 | — | Salida → `ruta_16/exterior` |
| `ruta_16/casa_2` | Casa · Ruta 16 | — | Salida → `ruta_16/exterior` |
| `ruta_16/exterior` | Ruta 16 · Rías Baixas | south → `vigo/exterior`, north → `ruta_17/exterior` | Casa1 → `ruta_16/casa_1`, Casa2 → `ruta_16/casa_2` |
| `ruta_2/casa_1` | Casa · Ruta 2 | — | Salida → `ruta_2/exterior` |
| `ruta_2/casa_2` | Casa · Ruta 2 | — | Salida → `ruta_2/exterior` |
| `ruta_2/exterior` | Ruta 2 · Tierra de Pinares y Acueducto | north → `ruta_1/exterior`, south → `ruta_3/exterior` | Casa1 → `ruta_2/casa_1`, Casa2 → `ruta_2/casa_2`, Sala27_51 → `ruta_2/sala_calle_27_51`, Sala9_61 → `ruta_2/sala_calle_9_61`, Sala14_61 → `ruta_2/sala_calle_14_61`, Sala27_61 → `ruta_2/sala_calle_27_61`, Sala2_51 → `ruta_2/sala_calle_2_51`, Sala2_61 → `ruta_2/sala_calle_2_61`, Sala33_61 → `ruta_2/sala_calle_33_61` |
| `ruta_2/sala_calle_14_61` | Granero · Ruta 2 | — | Salida → `ruta_2/exterior` |
| `ruta_2/sala_calle_27_51` | Casa de tejado rojo · Ruta 2 | — | Salida → `ruta_2/exterior` |
| `ruta_2/sala_calle_27_61` | Casa de la chimenea · Ruta 2 | — | Salida → `ruta_2/exterior` |
| `ruta_2/sala_calle_2_51` | Casa azul pequeña · Ruta 2 | — | Salida → `ruta_2/exterior` |
| `ruta_2/sala_calle_2_61` | Casa naranja · Ruta 2 | — | Salida → `ruta_2/exterior` |
| `ruta_2/sala_calle_33_61` | Casa de madera · Ruta 2 | — | Salida → `ruta_2/exterior` |
| `ruta_2/sala_calle_9_61` | Casa de dos aguas · Ruta 2 | — | Salida → `ruta_2/exterior` |
| `ruta_21/casa_1` | Casa · Ruta 21 | — | Salida → `ruta_21/exterior` |
| `ruta_21/casa_2` | Casa · Ruta 21 | — | Salida → `ruta_21/exterior` |
| `ruta_21/exterior` | Ruta 21 · Viñedos de La Rioja | south → `ruta_22/exterior` | Casa1 → `ruta_21/casa_1`, Casa2 → `ruta_21/casa_2`, Sala10_38 → `ruta_21/sala_calle_10_38`, Sala33_38 → `ruta_21/sala_calle_33_38` |
| `ruta_21/sala_calle_10_38` | Casa de madera · Ruta 21 | — | Salida → `ruta_21/exterior` |
| `ruta_21/sala_calle_33_38` | Casa de dos aguas · Ruta 21 | — | Salida → `ruta_21/exterior` |
| `ruta_22/casa_1` | Casa · Ruta 22 | — | Salida → `ruta_22/exterior` |
| `ruta_22/casa_2` | Casa · Ruta 22 | — | Salida → `ruta_22/exterior` |
| `ruta_22/exterior` | Ruta 22 · Burgos y Atapuerca | north → `ruta_21/exterior`, south → `valladolid/exterior` | Casa1 → `ruta_22/casa_1`, Casa2 → `ruta_22/casa_2`, Sala8_26 → `ruta_22/sala_calle_8_26`, Sala16_15 → `ruta_22/sala_calle_16_15` |
| `ruta_22/sala_calle_16_15` | Granero · Ruta 22 | — | Salida → `ruta_22/exterior` |
| `ruta_22/sala_calle_8_26` | Catedral Burgos · Ruta 22 | — | Salida → `ruta_22/exterior` |
| `ruta_23/casa_1` | Casa · Ruta 23 | — | Salida → `ruta_23/exterior` |
| `ruta_23/casa_2` | Casa · Ruta 23 | — | Salida → `ruta_23/exterior` |
| `ruta_23/cuellar/mercadona` | Mercadona · Cuéllar | — | Salida → `ruta_23/exterior` |
| `ruta_23/exterior` | Ruta 23 · Cuéllar y Tierra de Pinares | west → `valladolid/exterior`, east → `pueblo_inicial/exterior` | Mercadona → `ruta_23/cuellar/mercadona`, Casa1 → `ruta_23/casa_1`, Casa2 → `ruta_23/casa_2`, Sala12_11 → `ruta_23/sala_calle_12_11`, Sala22_11 → `ruta_23/sala_calle_22_11` |
| `ruta_23/sala_calle_12_11` | Castillo Cuellar · Ruta 23 | — | Salida → `ruta_23/exterior` |
| `ruta_23/sala_calle_22_11` | Iglesia San Miguel · Ruta 23 | — | Salida → `ruta_23/exterior` |
| `ruta_24/casa_1` | Casa · Ruta 24 | — | Salida → `ruta_24/exterior` |
| `ruta_24/casa_2` | Casa · Ruta 24 | — | Salida → `ruta_24/exterior` |
| `ruta_24/exterior` | Ruta 24 · La Mancha | south → `puertollano/exterior`, north → `getafe/exterior` | Casa1 → `ruta_24/casa_1`, Casa2 → `ruta_24/casa_2`, Sala3_10 → `ruta_24/sala_calle_3_10`, Sala7_10 → `ruta_24/sala_calle_7_10`, Sala11_10 → `ruta_24/sala_calle_11_10`, Sala15_10 → `ruta_24/sala_calle_15_10`, Sala19_10 → `ruta_24/sala_calle_19_10`, Sala33_30 → `ruta_24/sala_calle_33_30`, Sala37_30 → `ruta_24/sala_calle_37_30`, Sala41_30 → `ruta_24/sala_calle_41_30`, Sala4_28 → `ruta_24/sala_calle_4_28`, Sala35_40 → `ruta_24/sala_calle_35_40` |
| `ruta_24/sala_calle_11_10` | Molino Mancha · Ruta 24 | — | Salida → `ruta_24/exterior` |
| `ruta_24/sala_calle_15_10` | Molino Mancha · Ruta 24 | — | Salida → `ruta_24/exterior` |
| `ruta_24/sala_calle_19_10` | Molino Mancha · Ruta 24 | — | Salida → `ruta_24/exterior` |
| `ruta_24/sala_calle_33_30` | Molino Mancha · Ruta 24 | — | Salida → `ruta_24/exterior` |
| `ruta_24/sala_calle_35_40` | Casa de dos aguas · Ruta 24 | — | Salida → `ruta_24/exterior` |
| `ruta_24/sala_calle_37_30` | Molino Mancha · Ruta 24 | — | Salida → `ruta_24/exterior` |
| `ruta_24/sala_calle_3_10` | Molino Mancha · Ruta 24 | — | Salida → `ruta_24/exterior` |
| `ruta_24/sala_calle_41_30` | Molino Mancha · Ruta 24 | — | Salida → `ruta_24/exterior` |
| `ruta_24/sala_calle_4_28` | Granero · Ruta 24 | — | Salida → `ruta_24/exterior` |
| `ruta_24/sala_calle_7_10` | Molino Mancha · Ruta 24 | — | Salida → `ruta_24/exterior` |
| `ruta_25/casa_1` | Casa · Ruta 25 | — | Salida → `ruta_25/exterior` |
| `ruta_25/casa_2` | Casa · Ruta 25 | — | Salida → `ruta_25/exterior` |
| `ruta_25/exterior` | Ruta 25 · Despeñaperros | south → `ruta_26/exterior`, north → `puertollano/exterior` | Casa1 → `ruta_25/casa_1`, Casa2 → `ruta_25/casa_2` |
| `ruta_26/casa_1` | Casa · Ruta 26 | — | Salida → `ruta_26/exterior` |
| `ruta_26/exterior` | Ruta 26 · El Torcal de Antequera | south → `malaga/exterior`, north → `ruta_25/exterior` | Casa1 → `ruta_26/casa_1`, Sala9_9 → `ruta_26/sala_calle_9_9` |
| `ruta_26/sala_calle_9_9` | Dolmen Antequera · Ruta 26 | — | Salida → `ruta_26/exterior` |
| `ruta_3/casa_1` | Casa · Ruta 3 | — | Salida → `ruta_3/exterior` |
| `ruta_3/casa_2` | Casa · Ruta 3 | — | Salida → `ruta_3/exterior` |
| `ruta_3/exterior` | Ruta 3 · Puerto de Navacerrada | north → `ruta_2/exterior`, south → `ruta_4/exterior` | Casa1 → `ruta_3/casa_1`, Casa2 → `ruta_3/casa_2`, Sala6_66 → `ruta_3/sala_calle_6_66` |
| `ruta_3/sala_calle_6_66` | Basilica Cuelgamuros · Ruta 3 | — | Salida → `ruta_3/exterior` |
| `ruta_4/casa_1` | Casa · Ruta 4 | — | Salida → `ruta_4/exterior` |
| `ruta_4/casa_2` | Casa · Ruta 4 | — | Salida → `ruta_4/exterior` |
| `ruta_4/exterior` | Ruta 4 · El Escorial y Galapagar | north → `ruta_3/exterior`, east → `madrid/moncloa` | Casa1 → `ruta_4/casa_1`, Casa2 → `ruta_4/casa_2`, Sala9_24 → `ruta_4/sala_calle_9_24`, Sala34_14 → `ruta_4/sala_calle_34_14`, Sala29_27 → `ruta_4/sala_calle_29_27`, Sala38_28 → `ruta_4/sala_calle_38_28`, Sala45_28 → `ruta_4/sala_calle_45_28`, Sala30_38 → `ruta_4/sala_calle_30_38`, Sala38_39 → `ruta_4/sala_calle_38_39`, Sala44_39 → `ruta_4/sala_calle_44_39` |
| `ruta_4/sala_calle_29_27` | Casa azul · Ruta 4 | — | Salida → `ruta_4/exterior` |
| `ruta_4/sala_calle_30_38` | Casa roja · Ruta 4 | — | Salida → `ruta_4/exterior` |
| `ruta_4/sala_calle_34_14` | Casa de dos aguas · Ruta 4 | — | Salida → `ruta_4/exterior` |
| `ruta_4/sala_calle_38_28` | Casa de tejado rojo · Ruta 4 | — | Salida → `ruta_4/exterior` |
| `ruta_4/sala_calle_38_39` | Casa azul pequeña · Ruta 4 | — | Salida → `ruta_4/exterior` |
| `ruta_4/sala_calle_44_39` | Casa naranja · Ruta 4 | — | Salida → `ruta_4/exterior` |
| `ruta_4/sala_calle_45_28` | Casa de la chimenea · Ruta 4 | — | Salida → `ruta_4/exterior` |
| `ruta_4/sala_calle_9_24` | Monasterio Escorial · Ruta 4 | — | Salida → `ruta_4/exterior` |
| `ruta_5/casa_1` | Casa · Ruta 5 | — | Salida → `ruta_5/exterior` |
| `ruta_5/casa_2` | Casa · Ruta 5 | — | Salida → `ruta_5/exterior` |
| `ruta_5/exterior` | Ruta 5 · Corredor del Henares | west → `madrid/retiro`, east → `ruta_6/exterior` | Casa1 → `ruta_5/casa_1`, Casa2 → `ruta_5/casa_2`, Sala31_12 → `ruta_5/sala_calle_31_12`, Sala56_12 → `ruta_5/sala_calle_56_12`, Sala65_11 → `ruta_5/sala_calle_65_11`, Sala47_11 → `ruta_5/sala_calle_47_11`, Sala58_27 → `ruta_5/sala_calle_58_27` |
| `ruta_5/sala_calle_31_12` | Universidad Alcala · Ruta 5 | — | Salida → `ruta_5/exterior` |
| `ruta_5/sala_calle_47_11` | Casa de dos aguas · Ruta 5 | — | Salida → `ruta_5/exterior` |
| `ruta_5/sala_calle_56_12` | Palacio Infantado · Ruta 5 | — | Salida → `ruta_5/exterior` |
| `ruta_5/sala_calle_58_27` | Portal · Ruta 5 | — | Salida → `ruta_5/exterior` |
| `ruta_5/sala_calle_65_11` | Casa de la chimenea · Ruta 5 | — | Salida → `ruta_5/exterior` |
| `ruta_6/casa_1` | Casa · Ruta 6 | — | Salida → `ruta_6/exterior` |
| `ruta_6/casa_2` | Casa · Ruta 6 | — | Salida → `ruta_6/exterior` |
| `ruta_6/exterior` | Ruta 6 · Medinaceli y Calatayud | west → `ruta_5/exterior`, east → `zaragoza/exterior` | Casa1 → `ruta_6/casa_1`, Casa2 → `ruta_6/casa_2`, Sala32_16 → `ruta_6/sala_calle_32_16`, Sala42_16 → `ruta_6/sala_calle_42_16`, Sala47_16 → `ruta_6/sala_calle_47_16`, Sala61_16 → `ruta_6/sala_calle_61_16`, Sala65_15 → `ruta_6/sala_calle_65_15` |
| `ruta_6/sala_calle_32_16` | Casa de la chimenea · Ruta 6 | — | Salida → `ruta_6/exterior` |
| `ruta_6/sala_calle_42_16` | Casa de madera · Ruta 6 | — | Salida → `ruta_6/exterior` |
| `ruta_6/sala_calle_47_16` | Casa de dos aguas · Ruta 6 | — | Salida → `ruta_6/exterior` |
| `ruta_6/sala_calle_61_16` | Granero · Ruta 6 | — | Salida → `ruta_6/exterior` |
| `ruta_6/sala_calle_65_15` | Casa roja · Ruta 6 | — | Salida → `ruta_6/exterior` |
| `ruta_7/exterior` | Ruta 7 · Los Monegros | west → `zaragoza/exterior`, east → `ruta_8/exterior` | — |
| `ruta_8/casa_1` | Casa · Ruta 8 | — | Salida → `ruta_8/exterior` |
| `ruta_8/casa_2` | Casa · Ruta 8 | — | Salida → `ruta_8/exterior` |
| `ruta_8/exterior` | Ruta 8 · Montserrat | west → `ruta_7/exterior`, east → `barcelona/les_corts` | Casa1 → `ruta_8/casa_1`, Casa2 → `ruta_8/casa_2`, Sala36_10 → `ruta_8/sala_calle_36_10`, Sala51_36 → `ruta_8/sala_calle_51_36`, Sala56_36 → `ruta_8/sala_calle_56_36` |
| `ruta_8/sala_calle_36_10` | Monasterio Montserrat · Ruta 8 | — | Salida → `ruta_8/exterior` |
| `ruta_8/sala_calle_51_36` | Casa de madera · Ruta 8 | — | Salida → `ruta_8/exterior` |
| `ruta_8/sala_calle_56_36` | Granero · Ruta 8 | — | Salida → `ruta_8/exterior` |
| `ruta_9/exterior` | Ruta 9 · La Albufera y Gandía | north → `valencia/turia`, south → `ruta_10/exterior` | Sala16_24 → `ruta_9/sala_calle_16_24`, Sala21_24 → `ruta_9/sala_calle_21_24`, Sala17_33 → `ruta_9/sala_calle_17_33`, Sala22_33 → `ruta_9/sala_calle_22_33`, Sala18_15 → `ruta_9/sala_calle_18_15`, Sala22_40 → `ruta_9/sala_calle_22_40`, Sala19_56 → `ruta_9/sala_calle_19_56`, Sala34_55 → `ruta_9/sala_calle_34_55`, Sala7_66 → `ruta_9/sala_calle_7_66`, Sala15_65 → `ruta_9/sala_calle_15_65`, Sala22_66 → `ruta_9/sala_calle_22_66`, Sala5_74 → `ruta_9/sala_calle_5_74`, Sala11_74 → `ruta_9/sala_calle_11_74`, Sala17_74 → `ruta_9/sala_calle_17_74`, Sala23_74 → `ruta_9/sala_calle_23_74`, Sala32_74 → `ruta_9/sala_calle_32_74`, Sala31_65 → `ruta_9/sala_calle_31_65`, Sala41_67 → `ruta_9/sala_calle_41_67` |
| `ruta_9/sala_calle_11_74` | Tienda naranja · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_15_65` | Casa de teja · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_16_24` | Barraca · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_17_33` | Barraca · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_17_74` | Casa rosa · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_18_15` | Cabaña · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_19_56` | Portal · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_21_24` | Barraca · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_22_33` | Barraca · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_22_40` | Puesto · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_22_66` | Tienda naranja · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_23_74` | Casa roja pequeña · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_31_65` | Casa grande · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_32_74` | Tienda azul · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_34_55` | Faro · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_41_67` | Torre de socorro · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_5_74` | Casa rosa · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `ruta_9/sala_calle_7_66` | Palau Ducal dels Borja · Ruta 9 | — | Salida → `ruta_9/exterior` |
| `sevilla/centro` | Sevilla · Centro | east → `ruta_13/exterior`, west → `sevilla/rio`, south → `sevilla/maria_luisa` | Hospital → `sevilla/hospital`, Mercadona → `sevilla/mercadona`, Estanco → `sevilla/estanco`, Sala3_8 → `sevilla/sala_centro_3_8`, Sala10_7 → `sevilla/sala_centro_10_7`, Sala43_8 → `sevilla/sala_centro_43_8`, Sala53_6 → `sevilla/sala_centro_53_6`, Sala21_6 → `sevilla/sala_centro_21_6`, Sala59_11 → `sevilla/sala_centro_59_11`, Sala38_19 → `sevilla/sala_centro_38_19`, Sala44_19 → `sevilla/sala_centro_44_19`, Sala50_20 → `sevilla/sala_centro_50_20`, Sala56_19 → `sevilla/sala_centro_56_19`, Sala3_40 → `sevilla/sala_centro_3_40`, Sala10_41 → `sevilla/sala_centro_10_41`, Sala3_53 → `sevilla/sala_centro_3_53`, Sala10_53 → `sevilla/sala_centro_10_53`, Sala33_47 → `sevilla/sala_centro_33_47`, Sala28_21 → `sevilla/sala_centro_28_21`, Sala22_40 → `sevilla/sala_centro_22_40`, Sala24_51 → `sevilla/sala_centro_24_51`, Sala37_33 → `sevilla/sala_centro_37_33`, Sala42_33 → `sevilla/sala_centro_42_33`, Sala47_33 → `sevilla/sala_centro_47_33`, Sala37_39 → `sevilla/sala_centro_37_39`, Sala43_39 → `sevilla/sala_centro_43_39`, Sala49_39 → `sevilla/sala_centro_49_39`, Sala54_36 → `sevilla/sala_centro_54_36`, Sala59_33 → `sevilla/sala_centro_59_33`, Sala59_42 → `sevilla/sala_centro_59_42`, Sala27_6 → `sevilla/sala_centro_27_6`, Sala45_49 → `sevilla/sala_centro_45_49` |
| `sevilla/estanco` | Estanco · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/gimnasio_1` | El Club De La Comedia · Platea | — | Salida → `sevilla/rio`, Siguiente → `sevilla/gimnasio_2` |
| `sevilla/gimnasio_2` | El Club De La Comedia · Camerinos | — | Salida → `sevilla/gimnasio_1`, Siguiente → `sevilla/gimnasio_3` |
| `sevilla/gimnasio_3` | El Club De La Comedia · Entre Bambalinas | — | Salida → `sevilla/gimnasio_2`, Siguiente → `sevilla/gimnasio_lider` |
| `sevilla/gimnasio_lider` | El Club De La Comedia · Escenario | — | Salida → `sevilla/gimnasio_3` |
| `sevilla/hospital` | Hospital · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/maria_luisa` | Sevilla · Plaza de España | north → `sevilla/centro` | — |
| `sevilla/mercadona` | Mercadona · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/rio` | Sevilla · Río y Triana | east → `sevilla/centro`, west → `ruta_14/exterior` | Sala44_14 → `sevilla/sala_rio_44_14`, Sala37_45 → `sevilla/sala_rio_37_45`, Sala51_12 → `sevilla/sala_rio_51_12`, Sala46_34 → `sevilla/sala_rio_46_34`, Sala52_46 → `sevilla/sala_rio_52_46`, Sala45_54 → `sevilla/sala_rio_45_54`, Sala50_23 → `sevilla/sala_rio_50_23`, Sala40_23 → `sevilla/sala_rio_40_23`, Sala45_23 → `sevilla/sala_rio_45_23`, Sala39_5 → `sevilla/sala_rio_39_5`, Sala45_6 → `sevilla/sala_rio_45_6`, Sala9_31 → `sevilla/gimnasio_1`, Sala15_15 → `sevilla/sala_rio_15_15`, Sala5_16 → `sevilla/sala_rio_5_16`, Sala3_6 → `sevilla/sala_rio_3_6`, Sala8_6 → `sevilla/sala_rio_8_6`, Sala13_6 → `sevilla/sala_rio_13_6`, Sala18_6 → `sevilla/sala_rio_18_6`, Sala3_44 → `sevilla/sala_rio_3_44`, Sala8_44 → `sevilla/sala_rio_8_44`, Sala13_44 → `sevilla/sala_rio_13_44`, Sala18_44 → `sevilla/sala_rio_18_44`, Sala3_52 → `sevilla/sala_rio_3_52`, Sala13_52 → `sevilla/sala_rio_13_52`, Sala17_37 → `sevilla/sala_rio_17_37`, Sala8_52 → `sevilla/sala_rio_8_52`, Sala18_52 → `sevilla/sala_rio_18_52`, Sala3_37 → `sevilla/sala_rio_3_37`, Sala18_22 → `sevilla/sala_rio_18_22` |
| `sevilla/sala_centro_10_41` | Casa rosa · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_10_53` | Casa de tejado azul · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_10_7` | Casa de teja · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_21_6` | Casa rosa · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_22_40` | Catedral Sevilla · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_24_51` | Puerta Leon · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_27_6` | Casa gris · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_28_21` | Tienda naranja · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_33_47` | Oficinas · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_37_33` | Casa ibicenca · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_37_39` | Casa ibicenca · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_38_19` | Casa de la chimenea · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_3_40` | Casa de teja · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_3_53` | Portal · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_3_8` | Portal · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_42_33` | Casa ibicenca · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_43_39` | Casa ibicenca · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_43_8` | Oficinas · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_44_19` | Granero · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_45_49` | Casa roja pequeña · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_47_33` | Casa ibicenca · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_49_39` | Casa ibicenca · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_50_20` | Portal · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_53_6` | Portal verde · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_54_36` | Casa ibicenca · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_56_19` | Casa de madera · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_59_11` | Edificio Cupula · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_59_33` | Casa ibicenca · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_centro_59_42` | Casa ibicenca · Sevilla | — | Salida → `sevilla/centro` |
| `sevilla/sala_rio_13_44` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_13_52` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_13_6` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_15_15` | Puesto · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_17_37` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_18_22` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_18_44` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_18_52` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_18_6` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_37_45` | Torre · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_39_5` | Casa de la chimenea · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_3_37` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_3_44` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_3_52` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_3_6` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_40_23` | Granero · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_44_14` | Maestranza · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_45_23` | Casa de madera · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_45_54` | Teatro Real · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_45_6` | Casa de teja · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_46_34` | Oficinas · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_50_23` | Casa de dos aguas · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_51_12` | Casa de teja · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_52_46` | Portal · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_5_16` | Floristería · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_8_44` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_8_52` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `sevilla/sala_rio_8_6` | Casa ibicenca · Sevilla | — | Salida → `sevilla/rio` |
| `valencia/ciutat_vella` | Valencia · Ciutat Vella | north → `valencia/turia` | Hospital → `valencia/hospital`, Mercadona → `valencia/mercadona`, Estanco → `valencia/estanco`, Sala31_27 → `valencia/sala_ciutat_vella_31_27`, Sala9_24 → `valencia/sala_ciutat_vella_9_24`, Sala9_38 → `valencia/sala_ciutat_vella_9_38`, Sala4_10 → `valencia/sala_ciutat_vella_4_10`, Sala10_9 → `valencia/sala_ciutat_vella_10_9`, Sala15_9 → `valencia/sala_ciutat_vella_15_9`, Sala49_8 → `valencia/sala_ciutat_vella_49_8`, Sala58_10 → `valencia/sala_ciutat_vella_58_10`, Sala22_37 → `valencia/sala_ciutat_vella_22_37`, Sala58_38 → `valencia/sala_ciutat_vella_58_38`, Sala27_52 → `valencia/sala_ciutat_vella_27_52`, Sala4_53 → `valencia/sala_ciutat_vella_4_53`, Sala12_53 → `valencia/sala_ciutat_vella_12_53`, Sala47_51 → `valencia/sala_ciutat_vella_47_51`, Sala57_53 → `valencia/sala_ciutat_vella_57_53`, Sala21_16 → `valencia/sala_ciutat_vella_21_16`, Sala41_25 → `valencia/sala_ciutat_vella_41_25`, Sala35_36 → `valencia/sala_ciutat_vella_35_36` |
| `valencia/estanco` | Estanco · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/gimnasio_1` | Akuarela Playa · Pista | — | Salida → `valencia/malvarrosa`, Siguiente → `valencia/gimnasio_2` |
| `valencia/gimnasio_2` | Akuarela Playa · Reservado | — | Salida → `valencia/gimnasio_1`, Siguiente → `valencia/gimnasio_3` |
| `valencia/gimnasio_3` | Akuarela Playa · Zona Vip | — | Salida → `valencia/gimnasio_2`, Siguiente → `valencia/gimnasio_lider` |
| `valencia/gimnasio_lider` | Akuarela Playa · Cabina | — | Salida → `valencia/gimnasio_3` |
| `valencia/hospital` | Hospital · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/malvarrosa` | Valencia · Malvarrosa | west → `valencia/turia` | FerryIbiza → `ibiza/exterior`, Hospital → `valencia/malvarrosa/hospital`, Mercadona → `valencia/malvarrosa/mercadona`, Estanco → `valencia/malvarrosa/estanco`, Sala43_20 → `valencia/gimnasio_1`, Sala3_8 → `valencia/sala_malvarrosa_3_8`, Sala8_8 → `valencia/sala_malvarrosa_8_8`, Sala13_8 → `valencia/sala_malvarrosa_13_8`, Sala3_21 → `valencia/sala_malvarrosa_3_21`, Sala8_21 → `valencia/sala_malvarrosa_8_21`, Sala21_22 → `valencia/sala_malvarrosa_21_22`, Sala27_22 → `valencia/sala_malvarrosa_27_22`, Sala5_35 → `valencia/sala_malvarrosa_5_35`, Sala14_35 → `valencia/sala_malvarrosa_14_35`, Sala22_35 → `valencia/sala_malvarrosa_22_35`, Sala30_35 → `valencia/sala_malvarrosa_30_35`, Sala49_11 → `valencia/sala_malvarrosa_49_11`, Sala3_44 → `valencia/sala_malvarrosa_3_44`, Sala23_45 → `valencia/sala_malvarrosa_23_45`, Sala27_44 → `valencia/sala_malvarrosa_27_44` |
| `valencia/malvarrosa/estanco` | Estanco · Malvarrosa | — | Salida → `valencia/malvarrosa` |
| `valencia/malvarrosa/hospital` | Hospital · Malvarrosa | — | Salida → `valencia/malvarrosa` |
| `valencia/malvarrosa/mercadona` | Mercadona · Malvarrosa | — | Salida → `valencia/malvarrosa` |
| `valencia/mercadona` | Mercadona · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_10_9` | Casa de dos aguas · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_12_53` | Oficinas · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_15_9` | Casa de madera · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_21_16` | Casa gris · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_22_37` | Puesto · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_27_52` | Oficinas · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_31_27` | Micalet Catedral · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_35_36` | Casa gris · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_41_25` | Casa roja pequeña · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_47_51` | Portal verde · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_49_8` | Portal verde · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_4_10` | Portal · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_4_53` | Portal · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_57_53` | Portal · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_58_10` | Portal · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_58_38` | Portal · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_9_24` | Lonja Seda · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_ciutat_vella_9_38` | Mercado Central · Valencia | — | Salida → `valencia/ciutat_vella` |
| `valencia/sala_malvarrosa_13_8` | Casa de la chimenea · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/sala_malvarrosa_14_35` | Oficinas · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/sala_malvarrosa_21_22` | Tienda azul · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/sala_malvarrosa_22_35` | Portal · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/sala_malvarrosa_23_45` | Casa roja pequeña · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/sala_malvarrosa_27_22` | Portal · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/sala_malvarrosa_27_44` | Casa gris · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/sala_malvarrosa_30_35` | Oficinas · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/sala_malvarrosa_3_21` | Granero · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/sala_malvarrosa_3_44` | Casa gris · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/sala_malvarrosa_3_8` | Casa de dos aguas · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/sala_malvarrosa_49_11` | Torre de socorro · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/sala_malvarrosa_5_35` | Portal verde · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/sala_malvarrosa_8_21` | Casa de dos aguas · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/sala_malvarrosa_8_8` | Casa de madera · Valencia | — | Salida → `valencia/malvarrosa` |
| `valencia/turia` | Valencia · Jardín del Turia | south → `valencia/ciutat_vella`, east → `valencia/malvarrosa`, south → `ruta_9/exterior` | — |
| `valladolid/casa_1` | Casa roja · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/casa_2` | Casa de madera · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/estanco` | Estanco · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/exterior` | Valladolid | east → `ruta_23/exterior`, north → `ruta_22/exterior` | Hospital → `valladolid/hospital`, Mercadona → `valladolid/mercadona`, Estanco → `valladolid/estanco`, Casa1 → `valladolid/casa_1`, Casa2 → `valladolid/casa_2`, Sala35_18 → `valladolid/gimnasio_1`, Sala64_38 → `valladolid/sala_calle_64_38`, Sala23_15 → `valladolid/sala_calle_23_15`, Sala59_16 → `valladolid/sala_calle_59_16`, Sala66_14 → `valladolid/sala_calle_66_14`, Sala65_50 → `valladolid/sala_calle_65_50`, Sala52_59 → `valladolid/sala_calle_52_59`, Sala3_18 → `valladolid/sala_calle_3_18`, Sala47_9 → `valladolid/sala_calle_47_9`, Sala50_26 → `valladolid/sala_calle_50_26`, Sala20_51 → `valladolid/sala_calle_20_51`, Sala56_48 → `valladolid/sala_calle_56_48`, Sala3_6 → `valladolid/sala_calle_3_6`, Sala49_47 → `valladolid/sala_calle_49_47` |
| `valladolid/gimnasio_1` | Plaza Mayor · Soportales | — | Salida → `valladolid/exterior`, Siguiente → `valladolid/gimnasio_2` |
| `valladolid/gimnasio_2` | Plaza Mayor · Salón De Plenos | — | Salida → `valladolid/gimnasio_1`, Siguiente → `valladolid/gimnasio_3` |
| `valladolid/gimnasio_3` | Plaza Mayor · Palco Del Zorrilla | — | Salida → `valladolid/gimnasio_2`, Siguiente → `valladolid/gimnasio_lider` |
| `valladolid/gimnasio_lider` | Plaza Mayor · Balcón Del Ayuntamiento | — | Salida → `valladolid/gimnasio_3` |
| `valladolid/hospital` | Hospital · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/mercadona` | Mercadona · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/sala_calle_20_51` | Oficinas · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/sala_calle_23_15` | San Pablo Valladolid · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/sala_calle_3_18` | Casa de la chimenea · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/sala_calle_3_6` | Casa gris · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/sala_calle_47_9` | Casa de dos aguas · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/sala_calle_49_47` | Casa roja pequeña · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/sala_calle_50_26` | Casa de madera · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/sala_calle_52_59` | Oficinas · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/sala_calle_56_48` | Casa de dos aguas · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/sala_calle_59_16` | Catedral Valladolid · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/sala_calle_64_38` | Tienda azul · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/sala_calle_65_50` | Casa de dos aguas · Valladolid | — | Salida → `valladolid/exterior` |
| `valladolid/sala_calle_66_14` | Portal · Valladolid | — | Salida → `valladolid/exterior` |
| `vigo/casa_1` | Casa de dos aguas · Vigo | — | Salida → `vigo/exterior` |
| `vigo/casa_2` | Casa de madera · Vigo | — | Salida → `vigo/exterior` |
| `vigo/casa_3` | Casa de la chimenea · Vigo | — | Salida → `vigo/exterior` |
| `vigo/casa_4` | Casa naranja · Vigo | — | Salida → `vigo/exterior` |
| `vigo/centro` | Centro Pokémon · Vigo | — | Salida → `vigo/exterior` |
| `vigo/estanco` | Estanco · Vigo | — | Salida → `vigo/exterior` |
| `vigo/exterior` | Vigo | north → `ruta_16/exterior` | AvionGranCanaria → `playa_del_ingles/exterior`, Centro → `vigo/centro`, Mercadona → `vigo/mercadona`, Estanco → `vigo/estanco`, Casa1 → `vigo/casa_1`, Casa2 → `vigo/casa_2`, Casa3 → `vigo/casa_3`, Casa4 → `vigo/casa_4`, Sala33_18 → `vigo/sala_calle_33_18`, Sala42_18 → `vigo/sala_calle_42_18`, Sala17_29 → `vigo/sala_calle_17_29`, Sala42_32 → `vigo/sala_calle_42_32`, Sala49_31 → `vigo/sala_calle_49_31`, Sala3_6 → `vigo/sala_calle_3_6`, Sala11_7 → `vigo/sala_calle_11_7`, Sala16_8 → `vigo/sala_calle_16_8` |
| `vigo/mercadona` | Mercadona · Vigo | — | Salida → `vigo/exterior` |
| `vigo/sala_calle_11_7` | Casa roja pequeña · Vigo | — | Salida → `vigo/exterior` |
| `vigo/sala_calle_16_8` | Casa de teja · Vigo | — | Salida → `vigo/exterior` |
| `vigo/sala_calle_17_29` | Granero · Vigo | — | Salida → `vigo/exterior` |
| `vigo/sala_calle_33_18` | Tienda azul · Vigo | — | Salida → `vigo/exterior` |
| `vigo/sala_calle_3_6` | Casa gris · Vigo | — | Salida → `vigo/exterior` |
| `vigo/sala_calle_42_18` | Portal · Vigo | — | Salida → `vigo/exterior` |
| `vigo/sala_calle_42_32` | Oficinas · Vigo | — | Salida → `vigo/exterior` |
| `vigo/sala_calle_49_31` | Portal verde · Vigo | — | Salida → `vigo/exterior` |
| `zaragoza/casa_1` | Casa de dos aguas · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/casa_2` | Granero · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/centro` | Centro Pokémon · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/estanco` | Estanco · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/exterior` | Zaragoza | west → `ruta_6/exterior`, east → `ruta_7/exterior` | Centro → `zaragoza/centro`, Mercadona → `zaragoza/mercadona`, Estanco → `zaragoza/estanco`, Casa1 → `zaragoza/casa_1`, Casa2 → `zaragoza/casa_2`, Sala24_29 → `zaragoza/sala_calle_24_29`, Sala38_29 → `zaragoza/sala_calle_38_29`, Sala49_31 → `zaragoza/sala_calle_49_31`, Sala65_30 → `zaragoza/sala_calle_65_30`, Sala33_43 → `zaragoza/sala_calle_33_43`, Sala38_43 → `zaragoza/sala_calle_38_43`, Sala17_53 → `zaragoza/sala_calle_17_53`, Sala23_53 → `zaragoza/sala_calle_23_53`, Sala28_53 → `zaragoza/sala_calle_28_53`, Sala33_53 → `zaragoza/sala_calle_33_53`, Sala38_53 → `zaragoza/sala_calle_38_53`, Sala4_46 → `zaragoza/sala_calle_4_46`, Sala4_56 → `zaragoza/sala_calle_4_56`, Sala62_46 → `zaragoza/sala_calle_62_46`, Sala65_56 → `zaragoza/sala_calle_65_56`, Sala7_20 → `zaragoza/sala_calle_7_20`, Sala39_21 → `zaragoza/sala_calle_39_21`, Sala58_22 → `zaragoza/sala_calle_58_22`, Sala3_36 → `zaragoza/sala_calle_3_36`, Sala13_39 → `zaragoza/sala_calle_13_39` |
| `zaragoza/mercadona` | Mercadona · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_13_39` | Casa roja pequeña · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_17_53` | Casa de la chimenea · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_23_53` | Casa de madera · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_24_29` | Basilica Pilar · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_28_53` | Granero · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_33_43` | Casa de madera · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_33_53` | Casa de dos aguas · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_38_29` | Oficinas · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_38_43` | Casa de dos aguas · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_38_53` | Casa de la chimenea · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_39_21` | Casa roja pequeña · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_3_36` | Casa gris · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_49_31` | La Seo · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_4_46` | Portal · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_4_56` | Oficinas · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_58_22` | Casa de teja · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_62_46` | Portal · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_65_30` | Tienda azul · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_65_56` | Portal verde · Zaragoza | — | Salida → `zaragoza/exterior` |
| `zaragoza/sala_calle_7_20` | Casa gris · Zaragoza | — | Salida → `zaragoza/exterior` |
