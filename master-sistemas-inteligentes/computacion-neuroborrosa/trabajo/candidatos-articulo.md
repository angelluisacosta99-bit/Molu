# Candidatos de artículo (lógica difusa aplicada, 2021+) — verificados 2026-10-05

Origen: informe de LeapSpace (ScienceDirect) del 5 oct 2026, contrastado con
Crossref (el DOI existe, revista, año, citas), OpenAlex (impacto de la
revista) y la página del editor. Requisitos del profesor: ver `../FUENTE.md`.

**Aviso:** el informe de LeapSpace asocia mal varias afirmaciones con sus
referencias (por ejemplo, cita una revisión y un artículo de series
financieras como si fueran estudios de eólica y de tráfico móvil). Ningún
número del informe vale hasta comprobarlo en el artículo.

El "impacto" de la tabla es la media de citas a 2 años de la revista según
OpenAlex, **no** el factor de impacto JCR (de pago). Dato JCR real: ver el apartado "JCR consultado" al final.

| # | Artículo (DOI) | Revista, editorial, año | Técnica y datos | Resultado verificado | Acceso | Impacto revista |
|---|---|---|---|---|---|---|
| B | Salameh et al., ANFIS para predecir potencia de un sistema FV conectado a red, Sharjah (10.1016/j.ecmx.2025.100958) | Energy Conversion and Management: X, Elsevier, 2025 | ANFIS; FV de 2,88 kW, datos reales de temporada pico | R² = 0,9967 (potencia), 0,9076 (tensión), 0,9913 (corriente); comparado con regresión lineal, árbol, SVM y random forest | Abierto, ScienceDirect | 4,09 |
| C | Bilal et al., predicción de potencia de turbina eólica con ANFIS de ventana móvil (10.1016/j.energy.2022.126159) | Energy, Elsevier, 2023 | ANFIS-MoW; parque eólico real de 30 MW (Mauritania) | Leído entero (ver sección final): RMSE 36,7 kW y R = 0,9987 en ventana de 10 min | De pago (acceso USAL) | 11,18 |
| A | Lara-Cerecedo et al., FV de 60 kW con ANFIS y ANFIS-PSO (10.3390/en16166050) | Energies, MDPI, 2023 | ANFIS y ANFIS-PSO; 225.441 registros por variable (~26 meses) medidos | ANFIS-PSO: RMSE 0,754 kW, MAPE 0,556 %. ANFIS: 1,79 kW y 1,47 % (leído en el texto) | Abierto, pero **no** es ScienceDirect | 5,18 |
| D | Wu et al., demanda eléctrica a corto plazo con ANFIS-ELM (10.1016/j.apenergy.2023.121316) | Applied Energy, Elsevier, 2023 | ANFIS-ELM + optimizador | Leído entero: reduce el RMSE un 48,4 % frente a ELM (media semanal) | De pago | 15,60 |
| E | Fazlollahtabar, optimización difusa en dos fases bajo incertidumbre (10.1016/j.ecmx.2026.101600) | Energy Conversion and Management: X, Elsevier, 2026 | Mamdani + programación lineal difusa; datos de California ISO | Leído entero: **no recomendable**, ver sección final | Abierto | 4,09 |

## Notas por candidato

- **B (mejor opción para empezar):** datos reales, varios modelos de
  comparación, acceso abierto y en ScienceDirect, que es el repositorio que
  indica el profesor. Límites: solo temporada pico y un sistema pequeño.
- **A:** cifras claras, pero un solo modelo de comparación (ANFIS), MDPI fuera
  de ScienceDirect y una errata en las conclusiones del propio artículo
  (invierte los valores de ANFIS y ANFIS-PSO).
- **C:** encaja con eólica y con el TFM, pero hay que leer el artículo para
  saber qué aporta la ventana móvil.
- **E:** de 2026, con una sola cita. Enlaza con el hueco del TFM
  (optimización bajo incertidumbre), pero es un riesgo como artículo
  principal.

## Descartados del informe de LeapSpace

- Hossain Lipu et al. 2021 (referencias 2 y 11): es una revisión.
- Referencias 14 y 35: capítulos de libro, no artículos de revista.
- Referencia 16: series financieras, nada que ver con tráfico móvil.
- Referencias 17, 18, 44 y 46: no usan lógica difusa o no tratan tráfico móvil.
- Franck-Stève et al. 2026, RS-ANFIS (10.1016/j.sasc.2026.200480): 0 citas,
  revista nueva y R² = 0,9999, sospechoso de sobreajuste.
- No hay artículos de lógica difusa sobre tráfico de redes móviles en lo
  recuperado, por lo que este trabajo no sirve para el Camino D del TFM.

## Lectura completa de C, D y E (2026-10-05)

Hecha sobre los PDF que subió Angel. **Resultado: C es la mejor opción técnica,
B la más sencilla, D es más complejo y E se descarta.**

### C — Bilal et al., Energy 2023 (ANFIS-MoW, eólica)

- **Datos:** SCADA real de un parque de 30 MW (15 aerogeneradores de 2 MW,
  Nouakchott), medias de 10 min, cuatro turbinas y cuatro ventanas temporales
  (10 min, 1 h, 1 día, 1 semana).
- **Método:** ANFIS con ventana móvil; reparto 70 % entrenamiento y 30 % prueba
  (el texto no aclara si es cronológico). Entrada: velocidad del viento y estado
  de la turbina.
- **Resultado:** en 10 min, RMSE 36,7 kW y R = 0,9987; empeora con la ventana
  (1 semana: 44,2 kW y R = 0,9977).
- **Comparación justa:** contra cinco variantes de ANFIS (partición en rejilla,
  agrupamiento sustractivo, fuzzy c-means, algoritmo genético y PSO) sobre los
  mismos datos. Las demás dan RMSE de 37,2 a 65,3 kW frente a 36,6 kW: la mejor
  alternativa queda a solo un 1,6 % de distancia.
- **Límite:** la Tabla 3 compara con modelos de la literatura (persistencia, AR,
  VAR, etc.) cuyos números salen de otros conjuntos de datos.
- **Para el curso:** explica varias formas de construir un sistema borroso
  (rejilla frente a agrupamiento), que encaja con el temario.

### D — Wu et al., Applied Energy 2023 (ANFIS-ELM)

- **Datos:** consumo eléctrico de Serbia de **un solo mes** (noviembre de 2021),
  separado por días de la semana.
- **Resultado:** el híbrido reduce el RMSE un 48,4 % frente a ELM, y mejora a
  ANFIS en media. Se compara además con SSA-CNN-BiGRU, ARIMAX-GARCH y VMD-LSTM.
- **Límites:** la lógica borrosa es solo un componente; el peso del trabajo está
  en un algoritmo de optimización nuevo. "ELM" aquí es una red de Elman, no la
  *Extreme Learning Machine* habitual: ojo con la confusión de siglas.

### E — Fazlollahtabar, ECM:X 2026 (descartado)

- **Bibliografía:** de 20 DOIs, **11 no existen en Crossref**. Nueve tienen cifras
  con patrón de relleno (…123456, …234567, …345678 dos veces, …567890,
  …654321, …678901, …789012, …901234). Es señal de referencias inventadas.
- **Datos incoherentes:** dice usar todo 2023 y luego "Q2 2023, nodo 1";
  normaliza a [0,1] y define los números borrosos en MW; el "10-node" lleva una
  demanda de 200-300 MW; la fuente de datos citada ([42]) es un plan de
  transmisión en PDF, no un conjunto de datos.
- **Conclusión:** no usarlo. LeapSpace lo había puesto entre los "mejor
  respaldados", lo que confirma que su lista no es fiable sin comprobar.

## JCR consultado (2026-10-05, con el acceso de la USAL)

Fuente: PDF "2025 Journal Performance Data" de Journal Citation Reports,
descargado por Angel el 5-6/10/2026. Consultadas Energy (C) y Energy Conversion and Management: X (B).

| Revista | Factor de impacto 2025 | Sin autocitas | Cuartil y categoría (2025) |
|---|---|---|---|
| Energy (C) | 10,1 (76.991 citas / 7.608 ítems citables, cuenta comprobada) | 8,6 | Q1 en Energy & Fuels (puesto 34 de 191) y Q1 en Thermodynamics (puesto 3 de 78) |
| Energy Conversion and Management: X (B) | 8,8 (4.467 citas / 506 ítems citables, cuenta comprobada) | 7,6 | Q1 en Energy & Fuels (43 de 191), Q1 en Mechanics (6 de 172) y Q1 en Thermodynamics (4 de 78) |

ECM: X figura en la edición ESCI (Emerging Sources Citation Index), no en la
SCIE: tiene factor de impacto, pero conviene decirlo si el profesor pregunta.

Pendiente de consultar: Applied Energy (D, 0306-2619) y Energies (A, 1996-1073).

## Candidatos V y S (aportados por el compañero, 2026-10-06)

Leídos en sus secciones clave. Detalle completo en el documento compartido.

- **V — Alhamad, *Visual comfort index (VCI)*, Building and Environment 287
  (2026), 113872** (10.1016/j.buildenv.2025.113872). Mamdani puro con 8
  entradas. Validado solo con 20 escenarios y 3.000 casos simulados, sin datos
  reales ni personas; los umbrales se ajustan contra el propio sistema difuso.
  Bibliografía: 38 de 45 DOIs resuelven, los 7 restantes son límites de consulta
  o DOIs cortados por la extracción. Scimago Q1 (2024). JCR sin consultar
  (ISSN 0360-1323). Cumple con reservas.
- **S — Usman et al., *Energy management for smart residential homes*,
  Electric Power Systems Research 238 (2025), 111057**
  (10.1016/j.epsr.2024.111057). Datos reales de 15 hogares (Ontario, julio de
  2016). La lógica difusa es un controlador de 2 entradas dentro de un
  algoritmo mayor; solo se compara con un caso base y con su versión sin lógica
  difusa. Scimago Q1 (SJR 1,14). JCR sin consultar (ISSN 0378-7796). Cumple.
