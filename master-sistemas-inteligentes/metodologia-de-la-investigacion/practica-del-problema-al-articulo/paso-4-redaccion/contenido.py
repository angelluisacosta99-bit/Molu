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
    "AUC de 0,998 (≥ 0,996 en trayectos no vistos); los ensambles obtienen mayor F1 (0,947 frente a 0,931) y "
    "cometen menos errores (prueba de McNemar, p < 0,001), aunque la regresión logística detecta más canales "
    "que no cumplen. La potencia recibida medida es la variable decisiva en la red simulada. La hipótesis se "
    "confirma con matices y debe contrastarse con datos medidos en la red real."
)

REFS = [
    "Acosta González, A.L.: Organización de la red primaria de comunicaciones en el tramo ferroviario "
    "Moscú-Kazánskaya – Riazán. Trabajo de fin de grado (no publicado, en ruso), Universidad Rusa de Transporte "
    "(RUT MIIT), Moscú (2026)",
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
    ["Potencia recibida medida", "Medida del transceptor, error gaussiano σ = 0,5 dB", "", "✓", "✓"],
    ["Causas ocultas", "Pérdidas por reparaciones, hielo y conectores; NF del EDFA; atenuación real", "", "", "✓"],
]

TABLA_RESULTADOS = [
    ["Escenario", "Modelo", "AUC", "Exactitud equilibrada", "Sensibilidad", "F1"],
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
    ("resumen", RESUMEN),
    ("claves", "redes ópticas DWDM · calidad de transmisión · aprendizaje automático · Random Forest · "
               "comunicaciones ferroviarias"),

    # ---------------------------------------------------------------- 1. Introducción
    ("h2", "1 Introducción y marco teórico"),
    ("p", "Las redes de comunicaciones ferroviarias transportan servicios críticos para la seguridad de la "
          "circulación: señalización, telemando, voz operativa y datos de explotación. En los tramos troncales "
          "estas redes se construyen cada vez más sobre fibra óptica con multiplexación densa por división de "
          "longitud de onda (DWDM), que permite transportar decenas de canales por la misma fibra. Cada canal "
          "óptico debe cumplir un umbral de calidad de transmisión (<i>quality of transmission</i>, QoT), "
          "expresado habitualmente como una tasa de error de bit (<i>bit error rate</i>, BER) máxima o su factor Q "
          "equivalente."),
    ("p", "El caso de estudio es la red primaria de comunicaciones del tramo Moscú-Kazánskaya – Riazán-1 "
          "(198,3 km), diseñada en un trabajo previo del autor [1] como un anillo DWDM con canales de 10 Gbit/s sobre fibra "
          "G.652. En ese diseño la QoT se verificó con un modelo analítico aplicado una sola vez al tramo más "
          "desfavorable (108,9 km), con márgenes fijos y sin considerar la degradación de la red durante su "
          "explotación: envejecimiento de la fibra y de los amplificadores, empalmes añadidos en reparaciones o "
          "pérdidas por hielo, riesgos que el propio proyecto identifica en el trazado."),
    ("p", "La estimación de la QoT con aprendizaje automático es un campo consolidado en redes troncales; "
          "Pointurier [2] revisa sus técnicas y sus fuentes de inexactitud. Samadi et al. [3] propusieron su "
          "uso para la operación dinámica de redes WDM, y Rottondi et al. [4] clasificaron canales como "
          "aceptables o no con Random Forest entrenado con datos sintéticos, con una exactitud cercana a 0,96 y "
          "unas 1000 muestras suficientes. Morais y Pedro [5] compararon varios modelos y estimaron además el "
          "margen residual, y Kozdrowski et al. [6] confirmaron con datos reales de dos redes DWDM que Random "
          "Forest y XGBoost son los clasificadores más precisos, aunque con clases muy desbalanceadas. Aladin "
          "et al. [7] observaron que la exactitud cae de más del 99 % a un 85–89 % cuando solo se usan unas pocas "
          "variables, y Allogba et al. [8] recomiendan evaluar con métricas más allá de la exactitud. Otros "
          "trabajos abordan la transferencia de modelos entre redes [9], la estimación en sistemas IM/DD como "
          "el de la red ferroviaria [10] y el pronóstico con incertidumbre [11]."),
    ("p", "En la búsqueda bibliográfica realizada en Web of Science (septiembre de 2026) no se han encontrado "
          "trabajos que apliquen estas técnicas a redes ferroviarias regionales, con muchas estaciones de acceso, "
          "condiciones climáticas severas y equipos de detección directa. La pregunta de investigación es si un "
          "modelo de aprendizaje automático entrenado con parámetros observables de los enlaces puede predecir si "
          "cada canal cumple el umbral BER ≤ 10<sup>−11</sup> en condiciones de degradación con más acierto que un "
          "modelo sencillo. La hipótesis es que un modelo de ensamble lo predice con mayor acierto que un modelo "
          "lineal. Para contrastarla se plantean cuatro objetivos: (1) construir un conjunto de datos de canales de "
          "la red con un modelo físico que incluya degradación; (2) entrenar y comparar modelos de ensamble con una "
          "regresión logística de referencia; (3) evaluar su acierto en canales y condiciones no vistos durante el "
          "entrenamiento; y (4) cuantificar el margen de diseño que podría ahorrarse sin incumplir el umbral. Este "
          "trabajo aborda los objetivos 1 a 3; el objetivo 4, que exige estimar el margen residual de cada canal "
          "[5] con su incertidumbre [11], queda fuera de su alcance y se plantea como trabajo futuro."),
    ("p", "Las aportaciones son: (i) un modelo físico de la red con degradación en explotación y un conjunto de datos "
          "reproducible; (ii) la comparación de tres modelos en tres escenarios de información con validación "
          "cruzada y una prueba estadística, incluida la evaluación en trayectos y condiciones no vistos; y (iii) la identificación de la variable que más aporta a la "
          "predicción. La sección 2 describe los métodos, la sección 3 presenta y discute los resultados y la "
          "sección 4 recoge las conclusiones."),

    # ---------------------------------------------------------------- 2. Métodos
    ("h2", "2 Métodos"),
    ("h3", "2.1 Modelo físico de transmisión"),
    ("p", "Cada canal une dos de las 21 estaciones de la línea, a una distancia <i>d</i> de entre 5,4 y 198,3 km "
          "(208 pares posibles; se omite una estación cuyo punto kilométrico no consta en [1]), y transmite "
          "10 Gbit/s en formato sin retorno a cero (NRZ) con detección directa. La pérdida nominal del canal es la "
          "suma de la atenuación de la fibra (α = 0,22 dB/km), un empalme de 0,1 dB cada 4 km, 1 dB de conectores "
          "y 5 dB de los multiplexores de inserción-extracción (OADM), aplicados por igual a todos los canales:"),
    ("eq", "L<sub>nom</sub> = α·d + 0,1·⌈d/4⌉ + 1 + 5  [dB]", 1),
    ("p", "Con un láser de 0 dBm y una sensibilidad del receptor de −25 dBm, el canal se diseña con "
          "preamplificador de fibra dopada con erbio (EDFA) cuando el margen nominal es inferior a 3 dB, lo que "
          "ocurre en los canales de más de 65 km; los canales amplificados llevan un EDFA cada 110 km como máximo "
          "(<i>n</i> vanos iguales), y <i>P</i><sub>rx</sub> = <i>P</i><sub>tx</sub> − <i>L</i>/<i>n</i> es la "
          "potencia a la entrada de cada amplificador o del receptor. En los canales sin amplificar, limitados por el ruido térmico del receptor, el factor Q crece de forma lineal con la "
          "potencia recibida <i>P</i><sub>rx</sub>, con Q = 7,03 en la sensibilidad (BER = 10<sup>−12</sup>):"),
    ("eq", "Q<sub>t</sub> = 7,03 · 10<sup>(P<sub>rx</sub> + 25)/10</sup>", 2),
    ("p", "En los amplificados domina el ruido de emisión espontánea amplificada (ASE). La relación señal/ruido "
          "óptica en 0,1 nm y el factor Q con detección directa se obtienen como:"),
    ("eq", "OSNR = 58 + P<sub>rx</sub> − NF − 10·log<sub>10</sub> n  [dB]", 3),
    ("eq", "Q<sub>ASE</sub> = √(B<sub>o</sub>/B<sub>e</sub>) · 2·OSNR / (1 + √(1 + 4·OSNR))", 4),
    ("p", "donde NF es la figura de ruido del EDFA (6–7 dB más su envejecimiento), B<sub>o</sub> = 12,5 GHz y "
          "B<sub>e</sub> = 7,5 GHz. El ruido térmico del receptor preamplificado, con la señal unas diez veces por "
          "encima de la sensibilidad, se combina con el anterior:"),
    ("eq", "Q<sub>amp</sub> = (Q<sub>ASE</sub><sup>−2</sup> + (10·7,03)<sup>−2</sup>)<sup>−1/2</sup>", 5),
    ("p", "Se resta además una penalización por dispersión cromática de 2·(D/1600)<sup>2</sup> dB, con D la "
          "dispersión acumulada en ps/nm (17 ps/(nm·km) en los canales sin compensar y una residual de ±250 ps/nm "
          "en los amplificados). La tasa de error es:"),
    ("eq", "BER = ½ · erfc(Q / √2)", 6),
    ("p", "y un canal cumple si Q ≥ 6,71, que equivale a BER ≤ 10<sup>−11</sup>, el umbral del diseño de "
          "partida [1]. Como comprobación, el tramo Voskresensk – Riazán-1 (108,9 km), sin degradación y con "
          "NF = 6,5 dB, obtiene Q ≈ 10,4 con preamplificador. El valor difiere del Q = 7,37 de [1] porque el modelo "
          "físico es distinto (preamplificador EDFA limitado por ruido ASE); todas las cifras de este artículo "
          "proceden del modelo aquí descrito."),

    ("h3", "2.2 Degradación y conjunto de datos"),
    ("p", "Para cada canal se sortean (distribuciones uniformes U salvo indicación): la antigüedad, U(0, 25) "
          "años; la temperatura, U(−30, 35) °C; las averías, un proceso de Poisson con tasa U(0,002; 0,015) por km "
          "y año, con dos empalmes de U(0,05; 0,5) dB por reparación, de las que solo el 60 % queda registrado; "
          "el hielo, que por debajo de −5 °C aparece con probabilidad 0,3 y añade U(0,5; 5) dB; los conectores, "
          "1 dB más una pérdida exponencial de media 0,4 dB; y el envejecimiento: la atenuación aumenta "
          "U(0; 0,0015) dB/km por año (y 0,0002 dB/km por cada 10 °C bajo cero), la potencia del láser es "
          "N(0; 0,3) dBm menos U(0; 0,1) dB por año, y la figura de ruido del EDFA aumenta U(0; 0,08) dB por año. "
          "Se generaron 10 000 canales con semilla 42; el 50,3 % va amplificado y el 20,4 % no cumple el umbral. "
          "Estos rangos son supuestos del estudio, y la degradación se eligió deliberadamente severa para disponer "
          "de suficientes casos de la clase minoritaria; una red real tendría muchos menos fallos [6]."),
    ("p", "La Tabla 1 resume las variables de entrada de cada escenario. El escenario A (planificación) usa solo "
          "datos de inventario; el B (monitorización) añade la potencia recibida que mide el propio transceptor; "
          "y el C (oráculo) añade las causas físicas que el operador no puede medir, solo como cota superior."),
    ("tabla", "<b>Tabla 1.</b> Variables de entrada de los modelos en cada escenario.", TABLA_VARIABLES),

    ("h3", "2.3 Modelos y protocolo de evaluación"),
    ("p", "Se comparan una regresión logística con variables estandarizadas (modelo lineal de referencia), un "
          "Random Forest de 300 árboles (mínimo de 2 muestras por hoja) y un XGBoost de 300 árboles de profundidad 4 "
          "(tasa de aprendizaje 0,1, submuestreo 0,9). Todos usan pesos de clase "
          "para compensar el desbalance, hiperparámetros fijados a priori y un umbral de decisión de 0,5. La clase "
          "positiva es «no cumple», porque el interés del operador es detectar los canales en riesgo."),
    ("p", "La evaluación usa validación cruzada estratificada de 10 pliegues con 3 repeticiones y se informa de "
          "la media y la desviación típica de cuatro métricas: el área bajo la curva ROC (AUC), que mide la "
          "capacidad de ordenar los canales por riesgo; la exactitud equilibrada (media de sensibilidad y "
          "especificidad); la sensibilidad (fracción de canales que no cumplen que se detectan); y el F1 (media "
          "armónica de precisión y sensibilidad). El criterio principal de acierto para la hipótesis es el número "
          "de canales bien clasificados, contrastado con la prueba de McNemar (con corrección de continuidad) entre "
          "cada ensamble y la regresión logística sobre un conjunto de prueba estratificado del 30 % (3000 canales) "
          "del escenario B, con corrección de Bonferroni para dos comparaciones; el AUC y la sensibilidad se "
          "analizan como criterios secundarios. La importancia de las variables se mide por permutación como la "
          "caída del AUC."),
    ("p", "Para evaluar el acierto en trayectos no vistos (objetivo 3) se repite la validación agrupando por "
          "trayecto (10 pliegues estratificados; los canales de la misma longitud forman un grupo, de modo que "
          "ningún trayecto aparece a la vez en entrenamiento y prueba). Para condiciones no vistas se entrena con "
          "los canales de hasta 15 años y se evalúa con los de más de 15, y se entrena sin hielo (T ≥ −5 °C) y se "
          "evalúa con T < −5 °C. El código y los datos, incluido este análisis, están disponibles como material "
          "complementario."),

    # ---------------------------------------------------------------- 3. Resultados
    ("h2", "3 Resultados y discusión"),
    ("p", "La Fig. 1 muestra el factor Q de cada canal frente a su longitud. Los canales que no cumplen se "
          "concentran entre 40 y 110 km (el 84 % de los fallos): canales sin amplificar con poco margen (hasta 65 km) "
          "y canales con un solo vano amplificado de gran pérdida (de 65 a 110 km); casi todo el resto son canales "
          "de dos vanos de más de 110 km, y por debajo de 40 km cumple el 99 % de los canales. El margen fijo de "
          "diseño, por tanto, no protege por igual a todos los tramos frente a la degradación supuesta."),
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
          "(0,947 frente a 0,931 en B). La prueba de McNemar confirma que, en el escenario B, los ensambles cometen "
          "menos errores que la logística (61 frente a 92 de 3000 canales para ambos ensambles): Random Forest acierta 44 canales que la logística falla, frente a 13 en sentido "
          "contrario (χ<sup>2</sup> = 15,79; p = 7·10<sup>−5</sup>), y XGBoost 54 frente a 23 (χ<sup>2</sup> = "
          "11,69; p = 6·10<sup>−4</sup>), ambas significativas tras la corrección de Bonferroni."),
    ("fig", FIG + "fig2_f1_escenarios.png",
     "<b>Fig. 2.</b> F1 de la clase «no cumple» por escenario y modelo (media ± desviación típica)."),
    ("p", "Sin embargo, el AUC y la exactitud equilibrada son prácticamente iguales en los tres modelos, y el tipo "
          "de error difiere: en el conjunto de prueba, Random Forest deja sin detectar 12 de los 612 canales que no "
          "cumplen y da 49 falsas alarmas, XGBoost 18 y 43, y la regresión logística 2 y 90. Como para "
          "el operador un canal defectuoso no detectado cuesta más que una revisión innecesaria, la ventaja del "
          "ensamble depende del umbral de decisión y del coste de cada error. En el escenario A no hay una ventaja "
          "clara del ensamble (menor AUC y exactitud equilibrada). La hipótesis se confirma, por tanto, con matices."),
    ("p", "Los resultados se mantienen fuera de las condiciones de entrenamiento (objetivo 3). Con validación "
          "agrupada por trayecto, en el escenario B el AUC es de 0,998, 0,997 y 0,996 y el F1 de 0,931, 0,947 y "
          "0,941 (logística, Random Forest y XGBoost), prácticamente iguales que con la validación estándar; en el "
          "escenario A, el F1 es de 0,831, 0,846 y 0,838. Al entrenar con canales de hasta 15 años y evaluar con "
          "los más antiguos, el AUC es ≥ 0,991 y el F1 de 0,911, 0,955 y 0,947; al entrenar sin hielo y evaluar "
          "por debajo de −5 °C, el AUC es de 0,997 y el F1 de 0,934, 0,949 y 0,942. Las variaciones son pequeñas "
          "(hasta unas 0,02 en F1 y sensibilidad). Esta prueba es, no obstante, poco exigente: el simulador no "
          "incluye efectos propios de cada trayecto (p. ej., tendidos o climas locales distintos), por lo que la "
          "generalización a trayectos reales no vistos debe confirmarse con datos medidos."),
    ("p", "La Fig. 3 muestra la importancia de cada variable para Random Forest en el escenario B. Al permutar la "
          "potencia recibida el AUC cae 0,26, diez veces más que con la segunda variable (amplificado, 0,03); la "
          "temperatura no aporta información. En la red simulada, monitorizar la potencia en el receptor aporta, así, "
          "más que cambiar de modelo."),
    ("fig", FIG + "fig3_importancia.png",
     "<b>Fig. 3.</b> Importancia de las variables por permutación (Random Forest, escenario B). Barras de error: "
     "desviación típica en 10 permutaciones."),
    ("p", "Estos resultados concuerdan con la literatura: Random Forest y XGBoost son los clasificadores más "
          "precisos en [6], Random Forest también en [4], y la pérdida de exactitud al reducir variables observada en [7] se reproduce "
          "aquí al pasar del escenario B al A. Las cifras son más altas que con datos reales [6] porque la etiqueta "
          "se obtiene de forma determinista de un modelo físico en el que el factor Q depende directamente de la "
          "potencia recibida (ecs. 2–5), que el escenario B observa con solo 0,5 dB de error; la importancia de esa "
          "variable es, en parte, consecuencia del propio simulador. Esta circularidad y el uso de datos sintéticos "
          "son las principales limitaciones del estudio."),

    # ---------------------------------------------------------------- 4. Conclusiones
    ("h2", "4 Conclusiones"),
    ("p", "Este trabajo ha construido un modelo físico de la red DWDM ferroviaria Moscú-Kazánskaya – Riazán con "
          "degradación en explotación y ha evaluado tres modelos de aprendizaje automático para predecir si cada "
          "canal cumple BER ≤ 10<sup>−11</sup> (objetivos 1 y 2). En el escenario de monitorización (B), los modelos "
          "de ensamble cometen significativamente menos errores que la regresión logística (McNemar, p < 0,001 tras "
          "Bonferroni) y obtienen mayor F1, de modo que la hipótesis se confirma según el criterio principal, aunque "
          "con matices: la ventaja no se extiende a la capacidad de ordenar los canales (AUC de 0,998 en los tres modelos) ni a la "
          "detección de canales que no cumplen (sensibilidad 0,987 de la logística frente a 0,974 de Random Forest "
          "con el umbral de 0,5), y en el escenario A no hay una ventaja clara. Los resultados se mantienen, en la red "
          "simulada, en trayectos, antigüedades y temperaturas no vistos en el "
          "entrenamiento (objetivo 3)."),
    ("p", "En la red simulada, la potencia recibida que ya mide el transceptor es la variable decisiva: con ella "
          "cualquiera de los tres modelos supera ampliamente a la estimación con datos de inventario. Como el factor "
          "Q se calcula a partir de ella, este resultado debe confirmarse con datos medidos. Como trabajo futuro se "
          "proponen la validación con datos de la red real, el ajuste del umbral de decisión según el coste de cada "
          "error, la cuantificación del margen de diseño que podría ahorrarse (objetivo 4) y la transferencia de "
          "modelos entre redes [9]."),

    ("refs", REFS),
]
