"""Contenido del borrador del artículo (Paso 4). Una sola fuente para el PDF y el DOCX.

Bloques: ("titulo", txt) ("autor", txt) ("nota", txt) ("resumen", txt) ("claves", txt)
("h2", txt) ("h3", txt) ("p", txt) ("eq", txt, n) ("tabla", pie, filas) ("fig", archivo, pie)
("refs", [txt, ...]). Texto en línea: <i>, <b>, <sup>, <sub>.
"""

FIG = "../paso-3-experimento/figuras/"

RESUMEN = (
    "La calidad de transmisión (QoT) de los canales de una red DWDM ferroviaria suele verificarse una sola vez, "
    "en la fase de diseño, con un cálculo analítico del caso más desfavorable y márgenes fijos. Este trabajo "
    "evalúa si un modelo de aprendizaje automático entrenado con parámetros observables de los enlaces puede "
    "predecir si cada canal cumple el umbral BER ≤ 10<sup>−11</sup> cuando la red se degrada. Se generaron "
    "10 000 canales sintéticos de la red Moscú-Kazánskaya – Riazán con un modelo físico de transmisión que "
    "incluye envejecimiento, reparaciones y hielo, y se compararon una regresión logística, Random Forest y "
    "XGBoost en tres escenarios de información. Con la potencia recibida medida, los tres modelos alcanzan un "
    "AUC de 0,998; los ensambles obtienen mayor F1 (0,947 frente a 0,931) y menos errores (prueba de McNemar, "
    "p < 0,001), aunque la regresión logística detecta más canales que no cumplen. La potencia recibida medida "
    "es la variable decisiva. Los resultados apoyan parcialmente la hipótesis y deben contrastarse con datos "
    "medidos en la red real."
)

REFS = [
    "Acosta González, A.L.: Organización de la red primaria de comunicaciones en el tramo ferroviario "
    "Moscú-Kazánskaya – Riazán. Trabajo de fin de grado, Universidad Rusa de Transporte (RUT MIIT), Moscú (2026). "
    "En ruso",
    "Pointurier, Y.: Machine learning techniques for quality of transmission estimation in optical networks. "
    "J. Opt. Commun. Netw. <b>13</b>(4), B60–B71 (2021)",
    "Samadi, P., Amar, D., Lepers, C., Lourdiane, M., Bergman, K.: Quality of transmission prediction with "
    "machine learning for dynamic operation of optical WDM networks. En: 43rd European Conference on Optical "
    "Communication (ECOC 2017). IEEE (2017)",
    "Rottondi, C., Barletta, L., Giusti, A., Tornatore, M.: Machine-learning method for quality of "
    "transmission prediction of unestablished lightpaths. J. Opt. Commun. Netw. <b>10</b>(2), A286–A297 (2018)",
    "Morais, R.M., Pedro, J.: Machine learning models for estimating quality of transmission in DWDM networks. "
    "J. Opt. Commun. Netw. <b>10</b>(10), D84–D99 (2018)",
    "Kozdrowski, S., Cichosz, P., Paziewski, P., Sujecki, S.: Machine learning algorithms for prediction of "
    "the quality of transmission in optical networks. Entropy <b>23</b>(1), 7 (2021)",
    "Aladin, S., Tran, A.V.S., Allogba, S., Tremblay, C.: Quality of transmission estimation and short-term "
    "performance forecast of lightpaths. J. Lightwave Technol. <b>38</b>(10), 2806–2813 (2020)",
    "Allogba, S., Aladin, S., Tremblay, C.: Machine-learning-based lightpath QoT estimation and forecasting. "
    "J. Lightwave Technol. <b>40</b>(10), 3115–3127 (2022)",
    "Yu, J., Mo, W., Huang, Y., Ip, E., Kilper, D.C.: Model transfer of QoT prediction in optical networks "
    "based on artificial neural networks. J. Opt. Commun. Netw. <b>11</b>(10), C48–C57 (2019)",
    "Igarashi, R., Koma, R., Hara, K., Kani, J., Yoshida, T.: Fast QoT estimation method using cascaded "
    "artificial neural network for real-time path provisioning in IMDD based all-optical networks. "
    "Opt. Express <b>32</b>(2), 1176–1187 (2024)",
    "Di Cicco, N., Talpini, J., Ibrahimi, M., Savi, M., Tornatore, M.: Uncertainty-aware QoT forecasting in "
    "optical networks with Bayesian recurrent neural networks. En: ICC 2023 – IEEE International Conference "
    "on Communications, pp. 441–446. IEEE (2023)",
]

TABLA_VARIABLES = [
    ["Variable", "Descripción", "A", "B", "C"],
    ["Longitud", "Distancia del canal entre estaciones (km)", "✓", "✓", "✓"],
    ["Amplificado, n.º de vanos", "Si lleva preamplificador EDFA y número de vanos", "✓", "✓", "✓"],
    ["Antigüedad", "Años de servicio (0–25)", "✓", "✓", "✓"],
    ["Reparaciones registradas", "Averías anotadas en el inventario (60 % de las reales)", "✓", "✓", "✓"],
    ["Temperatura", "Temperatura ambiente (°C)", "✓", "✓", "✓"],
    ["Potencia recibida medida", "Medida del transceptor, error ±0,5 dB", "", "✓", "✓"],
    ["Causas ocultas", "Pérdidas por reparaciones, hielo y conectores; NF del EDFA; atenuación real", "", "", "✓"],
]

TABLA_RESULTADOS = [
    ["Escenario", "Modelo", "AUC", "Exactitud equil.", "Sensibilidad", "F1"],
    ["A", "Regresión logística", "0,983 ± 0,003", "0,929 ± 0,009", "0,939 ± 0,017", "0,832 ± 0,014"],
    ["A", "Random Forest", "0,981 ± 0,003", "0,921 ± 0,011", "0,901 ± 0,023", "0,847 ± 0,015"],
    ["A", "XGBoost", "0,982 ± 0,003", "0,925 ± 0,010", "0,914 ± 0,019", "0,845 ± 0,014"],
    ["B", "Regresión logística", "0,998 ± 0,001", "0,977 ± 0,004", "0,987 ± 0,007", "0,931 ± 0,009"],
    ["B", "Random Forest", "0,998 ± 0,001", "0,976 ± 0,007", "0,974 ± 0,012", "0,947 ± 0,012"],
    ["B", "XGBoost", "0,998 ± 0,001", "0,973 ± 0,008", "0,964 ± 0,014", "0,947 ± 0,012"],
    ["C", "Regresión logística", "0,998 ± 0,001", "0,980 ± 0,004", "0,991 ± 0,006", "0,940 ± 0,010"],
    ["C", "Random Forest", "0,998 ± 0,001", "0,978 ± 0,006", "0,976 ± 0,011", "0,951 ± 0,011"],
    ["C", "XGBoost", "0,999 ± 0,001", "0,978 ± 0,007", "0,969 ± 0,012", "0,958 ± 0,011"],
]

BLOQUES = [
    ("titulo", "Estimación de la calidad de transmisión con aprendizaje automático en la red DWDM ferroviaria "
               "Moscú-Kazánskaya – Riazán"),
    ("autor", "Angel Luis Acosta González<br>Máster Universitario en Sistemas Inteligentes, Universidad de Salamanca"),
    ("nota", "Borrador redactado en orden inverso (metodología de «La Casa»): conclusiones → resultados y discusión → "
             "métodos → introducción → resumen. Se presenta en el orden de lectura del artículo."),
    ("resumen", RESUMEN),
    ("claves", "redes ópticas DWDM · calidad de transmisión · aprendizaje automático · Random Forest · "
               "comunicaciones ferroviarias"),

    # ---------------------------------------------------------------- 1. Introducción
    ("h2", "1 Introducción"),
    ("p", "Las redes de comunicaciones ferroviarias transportan servicios críticos para la seguridad de la "
          "circulación: señalización, telemando, voz operativa y datos de explotación. En los tramos troncales "
          "estas redes se construyen cada vez más sobre fibra óptica con multiplexación densa por división de "
          "longitud de onda (DWDM), que permite transportar decenas de canales por la misma fibra. Cada canal "
          "óptico debe cumplir un umbral de calidad de transmisión (<i>quality of transmission</i>, QoT), "
          "expresado habitualmente como una tasa de error de bit (BER) máxima o su factor Q equivalente."),
    ("p", "El caso de estudio es la red primaria de comunicaciones del tramo Moscú-Kazánskaya – Riazán-1 "
          "(198,3 km), diseñada en un trabajo previo [1] como un anillo DWDM con canales de 10 Gbit/s sobre fibra "
          "G.652. En ese diseño la QoT se verificó con un modelo analítico aplicado una sola vez al tramo más "
          "desfavorable (108,9 km), con márgenes fijos y sin considerar la degradación de la red durante su "
          "explotación: envejecimiento de la fibra y de los amplificadores, empalmes añadidos en reparaciones o "
          "pérdidas por hielo, riesgos que el propio proyecto identifica en el trazado."),
    ("p", "La estimación de la QoT con aprendizaje automático es un campo consolidado en redes troncales; "
          "Pointurier [2] revisa sus técnicas y sus fuentes de inexactitud. Samadi et al. [3] mostraron su "
          "utilidad para la operación dinámica de redes WDM, y Rottondi et al. [4] clasificaron canales como "
          "aceptables o no con Random Forest entrenado con datos sintéticos, con una exactitud cercana a 0,96 y "
          "unas 1000 muestras suficientes. Morais y Pedro [5] compararon varios modelos y estimaron además el "
          "margen residual, y Kozdrowski et al. [6] confirmaron con datos reales de dos redes DWDM que Random "
          "Forest y XGBoost son los clasificadores más precisos, aunque con clases muy desbalanceadas. Aladin "
          "et al. [7] observaron que la exactitud cae de más del 99 % a un 85–89 % cuando solo se usan unas pocas "
          "variables, y Allogba et al. [8] recomiendan evaluar con métricas más allá de la exactitud. Otros "
          "trabajos abordan la transferencia de modelos entre redes [9], la estimación en sistemas IM/DD como "
          "el de la red ferroviaria [10] y el pronóstico con incertidumbre [11]."),
    ("p", "No se han encontrado trabajos que apliquen estas técnicas a redes ferroviarias regionales, con muchas "
          "estaciones de acceso, condiciones climáticas severas y equipos de detección directa. La hipótesis de "
          "este trabajo es que un modelo de ensamble entrenado con parámetros observables de los enlaces predice "
          "si un canal cumple BER ≤ 10<sup>−11</sup> con mayor acierto que un modelo lineal sencillo. Las "
          "aportaciones son: (i) un modelo físico de la red con degradación en explotación y un conjunto de datos "
          "reproducible; (ii) la comparación de tres modelos en tres escenarios de información con validación "
          "cruzada y una prueba estadística; y (iii) la identificación de la variable que más aporta a la "
          "predicción. La sección 2 describe los métodos, la sección 3 presenta y discute los resultados y la "
          "sección 4 recoge las conclusiones."),

    # ---------------------------------------------------------------- 2. Métodos
    ("h2", "2 Métodos"),
    ("h3", "2.1 Modelo físico de transmisión"),
    ("p", "Cada canal une dos de las 21 estaciones de la línea, a una distancia <i>d</i> de entre 5,4 y 198,3 km "
          "(208 pares posibles), y transmite 10 Gbit/s en formato NRZ con detección directa. La pérdida nominal "
          "del canal es la suma de la atenuación de la fibra (α = 0,22 dB/km), un empalme de 0,1 dB cada 4 km, "
          "1 dB de conectores y 5 dB del multiplexor y demultiplexor:"),
    ("eq", "L<sub>nom</sub> = α·d + 0,1·⌈d/4⌉ + 1 + 5  [dB]", 1),
    ("p", "Con un láser de 0 dBm y una sensibilidad del receptor de −25 dBm, el canal se diseña con "
          "preamplificador EDFA cuando el margen nominal es inferior a 3 dB, lo que ocurre a partir de 65 km; los "
          "canales amplificados llevan un EDFA cada 110 km como máximo (<i>n</i> vanos). En los canales sin "
          "amplificar, limitados por el ruido térmico del receptor, el factor Q crece de forma lineal con la "
          "potencia recibida <i>P</i><sub>rx</sub>, con Q = 7,03 en la sensibilidad (BER = 10<sup>−12</sup>):"),
    ("eq", "Q<sub>t</sub> = 7,03 · 10<sup>(P<sub>rx</sub> + 25)/10</sup>", 2),
    ("p", "En los amplificados domina el ruido de emisión espontánea amplificada (ASE). La relación señal/ruido "
          "óptica en 0,1 nm y el factor Q con detección directa se obtienen como:"),
    ("eq", "OSNR = 58 + P<sub>rx</sub> − NF − 10·log<sub>10</sub> n  [dB]", 3),
    ("eq", "Q<sub>ASE</sub> = √(B<sub>o</sub>/B<sub>e</sub>) · 2·OSNR / (1 + √(1 + 4·OSNR))", 4),
    ("p", "donde NF es la figura de ruido del EDFA, B<sub>o</sub> = 12,5 GHz y B<sub>e</sub> = 7,5 GHz. Se "
          "resta además una penalización por dispersión cromática de 2·(D/1600)<sup>2</sup> dB, con D la "
          "dispersión acumulada en ps/nm (17 ps/(nm·km) en los canales sin compensar). La tasa de error es:"),
    ("eq", "BER = ½ · erfc(Q / √2)", 5),
    ("p", "y un canal cumple si Q ≥ 6,71, que equivale a BER ≤ 10<sup>−11</sup>, el umbral del diseño de "
          "partida [1]. Como comprobación, el tramo de 108,9 km de la red nueva obtiene Q ≈ 10,4 con "
          "preamplificador, por encima del umbral."),

    ("h3", "2.2 Degradación y conjunto de datos"),
    ("p", "Para cada canal se sortean su antigüedad (0–25 años), la temperatura (−30 a 35 °C), las averías (proceso "
          "de Poisson proporcional a la longitud y la antigüedad, con dos empalmes de 0,05–0,5 dB por reparación), "
          "pérdidas por hielo de 0,5–5 dB por debajo de −5 °C, conectores sucios y el envejecimiento de la fibra, "
          "del láser y del EDFA. Solo el 60 % de las averías queda registrado en el inventario. Se generaron "
          "10 000 canales con semilla fija; el 50,3 % va amplificado y el 20,4 % no cumple el umbral. Estos "
          "rangos de degradación son supuestos del estudio."),
    ("p", "La Tabla 1 resume las variables de entrada de cada escenario. El escenario A (planificación) usa solo "
          "datos de inventario; el B (monitorización) añade la potencia recibida que mide el propio transceptor; "
          "y el C (oráculo) añade las causas físicas que el operador no puede medir, solo como cota superior."),
    ("tabla", "<b>Tabla 1.</b> Variables de entrada de los modelos en cada escenario.", TABLA_VARIABLES),

    ("h3", "2.3 Modelos y protocolo de evaluación"),
    ("p", "Se comparan una regresión logística con variables estandarizadas (modelo lineal de referencia), un "
          "Random Forest de 300 árboles y un XGBoost de 300 árboles de profundidad 4. Todos usan pesos de clase "
          "para compensar el desbalance, hiperparámetros fijados a priori y un umbral de decisión de 0,5. La clase "
          "positiva es «no cumple», porque el interés del operador es detectar los canales en riesgo."),
    ("p", "La evaluación usa validación cruzada estratificada de 10 pliegues con 3 repeticiones y se informa de "
          "la media y la desviación típica del AUC, la exactitud equilibrada, la sensibilidad y el F1. Para "
          "contrastar la hipótesis se aplica la prueba de McNemar a las predicciones de cada ensamble frente a la "
          "regresión logística sobre un conjunto de prueba estratificado del 30 % (3000 canales) del escenario B, "
          "con corrección de Bonferroni para dos comparaciones. La importancia de las variables se mide por "
          "permutación como la caída del AUC. El código y los datos están disponibles como material "
          "complementario."),

    # ---------------------------------------------------------------- 3. Resultados
    ("h2", "3 Resultados y discusión"),
    ("p", "La Fig. 1 muestra el factor Q de cada canal frente a su longitud. Los canales que no cumplen se "
          "concentran entre 40 y 110 km: canales sin amplificar con poco margen (hasta 65 km) y canales con un solo "
          "vano amplificado de gran pérdida (de 65 a 110 km); por debajo de 40 km cumple el 99 % de los canales. El margen fijo de diseño, por "
          "tanto, no protege por igual a todos los tramos frente a la degradación."),
    ("fig", FIG + "fig1_q_vs_longitud.png",
     "<b>Fig. 1.</b> Factor Q de cada canal según su longitud (muestra aleatoria de 1500 canales por clase); "
     "la línea discontinua es el umbral BER = 10<sup>−11</sup>."),
    ("p", "La Tabla 2 recoge las métricas de validación cruzada. En el escenario A, con solo datos de inventario, "
          "los tres modelos alcanzan un AUC de 0,98 y un F1 de 0,83–0,85. Al añadir la potencia recibida "
          "(escenario B) el AUC sube a 0,998 en los tres modelos y el F1 a 0,93–0,95. El escenario C apenas mejora "
          "al B, porque la potencia medida ya recoge casi todo el efecto de las causas ocultas."),
    ("tabla", "<b>Tabla 2.</b> Resultados de la validación cruzada estratificada (10 pliegues × 3 repeticiones), "
              "media ± desviación típica. Clase positiva: canal que no cumple BER ≤ 10<sup>−11</sup>.",
     TABLA_RESULTADOS),
    ("p", "La Fig. 2 compara el F1 de los tres modelos: la mejora más grande se debe a pasar del escenario A al B, "
          "no al cambio de modelo. Dentro de cada escenario, los ensambles superan a la regresión logística en F1 "
          "(0,947 frente a 0,931 en B). La prueba de McNemar sobre el conjunto de prueba confirma que la diferencia "
          "no se debe al azar: Random Forest acierta 44 canales que la logística falla, frente a 13 en sentido "
          "contrario (χ<sup>2</sup> = 15,79; p = 7·10<sup>−5</sup>), y XGBoost 54 frente a 23 (χ<sup>2</sup> = "
          "11,69; p = 6·10<sup>−4</sup>), ambas significativas tras la corrección de Bonferroni."),
    ("fig", FIG + "fig2_f1_escenarios.png",
     "<b>Fig. 2.</b> F1 de la clase «no cumple» por escenario y modelo (media ± desviación típica)."),
    ("p", "Sin embargo, el AUC y la exactitud equilibrada son prácticamente iguales en los tres modelos, y el tipo "
          "de error difiere: en el conjunto de prueba, Random Forest deja sin detectar 12 de los 612 canales que no "
          "cumplen y da 49 falsas alarmas, mientras que la regresión logística deja sin detectar 2 y da 90. Como para "
          "el operador un canal defectuoso no detectado cuesta más que una revisión innecesaria, la ventaja del "
          "ensamble depende del umbral de decisión y del coste de cada error. La hipótesis se cumple, por tanto, "
          "solo en parte."),
    ("p", "La Fig. 3 muestra la importancia de cada variable para Random Forest en el escenario B. Al permutar la "
          "potencia recibida el AUC cae 0,26, diez veces más que con la segunda variable (amplificado, 0,03); la "
          "temperatura no aporta información. Monitorizar la potencia en el receptor aporta, así, más que cambiar "
          "de modelo."),
    ("fig", FIG + "fig3_importancia.png",
     "<b>Fig. 3.</b> Importancia de las variables por permutación (Random Forest, escenario B). Barras de error: "
     "desviación típica en 10 permutaciones."),
    ("p", "Estos resultados concuerdan con la literatura: Random Forest y XGBoost son los clasificadores más "
          "precisos en [4] y [6], y la pérdida de exactitud al reducir variables observada en [7] se reproduce "
          "aquí al pasar del escenario B al A. Las cifras son más altas que con datos reales [6] porque la etiqueta "
          "procede de un modelo físico determinista con las mismas variables, de modo que la tarea es más fácil "
          "que en una red real. Además, los canales proceden de 208 pares de estaciones y la validación cruzada no "
          "mide el acierto en trayectos no vistos. Estas son las principales limitaciones del estudio."),

    # ---------------------------------------------------------------- 4. Conclusiones
    ("h2", "4 Conclusiones"),
    ("p", "Este trabajo ha construido un modelo físico de la red DWDM ferroviaria Moscú-Kazánskaya – Riazán con "
          "degradación en explotación y ha evaluado tres modelos de aprendizaje automático para predecir si cada "
          "canal cumple BER ≤ 10<sup>−11</sup>. Los modelos de ensamble obtienen mayor F1 y cometen menos errores "
          "que la regresión logística, con diferencia significativa, pero ordenan los canales igual de bien (AUC de "
          "0,998) y detectan menos canales defectuosos con el umbral por defecto. La hipótesis se cumple en parte."),
    ("p", "La conclusión más relevante para el operador es que la potencia recibida que ya mide el transceptor "
          "es la variable decisiva: con ella cualquiera de los tres modelos supera ampliamente a la estimación con "
          "datos de inventario. Como trabajo futuro se proponen la validación con datos medidos en la red, la "
          "validación agrupada por trayecto, el ajuste del umbral de decisión según el coste de cada error, la "
          "cuantificación del margen de diseño que podría ahorrarse y la transferencia de modelos entre redes [9]."),

    ("refs", REFS),
]
