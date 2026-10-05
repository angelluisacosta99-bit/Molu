# Candidatos de artículo (lógica difusa aplicada, 2021+) — verificados 2026-10-05

Origen: informe de LeapSpace (ScienceDirect) del 5 oct 2026, contrastado con
Crossref (el DOI existe, revista, año, citas), OpenAlex (impacto de la
revista) y la página del editor. Requisitos del profesor: ver `../FUENTE.md`.

**Aviso:** el informe de LeapSpace asocia mal varias afirmaciones con sus
referencias (por ejemplo, cita una revisión y un artículo de series
financieras como si fueran estudios de eólica y de tráfico móvil). Ningún
número del informe vale hasta comprobarlo en el artículo.

El "impacto" de la tabla es la media de citas a 2 años de la revista según
OpenAlex, **no** el factor de impacto JCR (de pago). Falta confirmar el
cuartil en Scimago antes de poner "factor de impacto" en el email.

| # | Artículo (DOI) | Revista, editorial, año | Técnica y datos | Resultado verificado | Acceso | Impacto revista |
|---|---|---|---|---|---|---|
| B | Salameh et al., ANFIS para predecir potencia de un sistema FV conectado a red, Sharjah (10.1016/j.ecmx.2025.100958) | Energy Conversion and Management: X, Elsevier, 2025 | ANFIS; FV de 2,88 kW, datos reales de temporada pico | R² = 0,9967 (potencia), 0,9076 (tensión), 0,9913 (corriente); comparado con regresión lineal, árbol, SVM y random forest | Abierto, ScienceDirect | 4,09 |
| C | Bilal et al., predicción de potencia de turbina eólica con ANFIS de ventana móvil (10.1016/j.energy.2022.126159) | Energy, Elsevier, 2023 | ANFIS-MoW; parque eólico real de 30 MW (Mauritania) | Sin comprobar: LeapSpace no da cifras | De pago (acceso USAL) | 11,18 |
| A | Lara-Cerecedo et al., FV de 60 kW con ANFIS y ANFIS-PSO (10.3390/en16166050) | Energies, MDPI, 2023 | ANFIS y ANFIS-PSO; 225.441 registros por variable (~26 meses) medidos | ANFIS-PSO: RMSE 0,754 kW, MAPE 0,556 %. ANFIS: 1,79 kW y 1,47 % (leído en el texto) | Abierto, pero **no** es ScienceDirect | 5,18 |
| D | Wu et al., demanda eléctrica a corto plazo con ANFIS-ELM (10.1016/j.apenergy.2023.121316) | Applied Energy, Elsevier, 2023 | ANFIS-ELM + optimizador | Sin comprobar | De pago | 15,60 |
| E | Fazlollahtabar, optimización difusa en dos fases bajo incertidumbre (10.1016/j.ecmx.2026.101600) | Energy Conversion and Management: X, Elsevier, 2026 | Mamdani + programación lineal difusa; datos de California ISO | Sin comprobar (LeapSpace: −18,7 % de coste, 99,2 % de fiabilidad) | Abierto | 4,09 |

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
