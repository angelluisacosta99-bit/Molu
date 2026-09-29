# Notas de lectura — los 10 artículos del `referencias.bib`

Estudio hecho el 2026-09-29 para preparar los Pasos 3–5. Fuente de cada nota
indicada: **[texto completo]** = leído el PDF/HTML de acceso abierto;
**[resumen]** = solo resumen o metadatos (sin acceso libre al texto).
Las cifras vienen de los artículos; no inventar otras al citarlos.

## Resumen en una tabla

| Clave | Tipo de datos | Tarea | Modelos | Resultado clave | Uso en nuestro trabajo |
|---|---|---|---|---|---|
| rottondi2018 | Sintéticos (herramienta de BER con efectos no lineales), topologías Japón y NSF | Clasificar si BER < umbral (T = 4·10⁻³) | **Random Forest** (25 árboles), también KNN, SVM, logística | Exactitud ≈ 0,96, AUC ≈ 0,99; basta con ~1000 muestras | **Precedente directo** de nuestro método: RF + datos sintéticos + clasificación por umbral |
| morais2018 | Sintéticos, 3 escenarios de red | Clasificar QoT de canales nuevos + estimar margen residual | KNN, logística, SVM, ANN | Todos > 90 %; ANN ≈ 99,9 %; margen residual con error medio 0,4 dB | Justifica el objetivo 4 (margen) y la comparación de varios modelos |
| kozdrowski2021 | **Reales**, plano de control de 2 redes DWDM (187 y 83 nodos) | Clasificar canal "bueno/malo" | Logística, SVM, árbol, **RF, XGBoost** | AUC 0,86–0,89 (red 1) y 0,97–0,98 (red 2); RF y XGBoost los mejores | Aviso de **desbalance de clases**: usar curvas precisión-recall, validación cruzada estratificada, pesos o SMOTE |
| aladin2020 | Sintéticos (modelo GN, 38 400 instancias) + 13 meses de SNR real | Clasificar QoT + pronosticar SNR | SVM, ANN; LSTM, GRU | 99,4–99,6 % con todas las variables, pero **85–89 % solo con 3** (longitud, nº de vanos, modulación); RMSE < 0,285 dB | **Clave para la circularidad**: al ocultar variables la exactitud baja; eso es lo realista |
| allogba2022 | Tutorial: sintéticos + campo (CANARIE, NASP, Microsoft) | Estimación y pronóstico | KNN, SVM, RF, NN; LSTM, GRU, MLP | SVM 99,2 %, NN 99,6 % | Recomendaciones: no usar solo exactitud (recall, F1, matriz de confusión), tratar valores atípicos, escasez de datos reales |
| yu2019 | Simulación de varios sistemas (formatos, distancias, tipos de fibra) | Regresión del factor Q | ANN + transferencia de aprendizaje | Reentrenar con 20 muestras en vez de 1000; hasta 4× menos tiempo de entrenamiento | Vía futura: adaptar el modelo sintético a la red real con pocas medidas |
| igarashi2024 | Simulación SSFM (dispersión + SPM), **IM/DD**, 3 vanos de 36 km | Estimar BER | ANN en cascada (propagación + BER) | BER en 0,7 s, complejidad 91× menor que SSFM | **Mismo tipo de sistema que la red ferroviaria (IM/DD)**; la ventaja de tiempo es frente a un simulador caro, no frente a una fórmula |
| dicicco2023 | **Reales**: Microsoft WAN (4000 canales, 14 meses, cada 15 min) | Pronóstico de QoT con incertidumbre | RNN bayesiana (Seq2Seq) | Supera al MLP de referencia; intervalos con buena cobertura | Intervalos de incertidumbre para mantenimiento y anomalías; conecta con los márgenes (objetivo 4) |
| pointurier2021 | Revisión | Taxonomía de la estimación de QoT con ML | — | Fuentes de inexactitud; compara todos los trabajos publicados | Marco teórico de la Introducción [resumen] |
| samadi2017 | Pionero (ECOC 2017) | Predicción de QoT para operación dinámica WDM | ML | — | Antecedente histórico; solo metadatos disponibles [resumen] |

## Lecciones para el Paso 3 (diseño experimental)

1. **Tarea:** clasificación binaria "cumple / no cumple BER ≤ 10⁻¹¹", como
   Rottondi y Morais. Usar AUC y precisión-recall además de la exactitud
   (Kozdrowski, Allogba).
2. **Modelos:** una regresión logística como referencia sencilla, más
   Random Forest y XGBoost. Son los mejores en Rottondi y Kozdrowski y
   encajan con la hipótesis.
3. **Evitar la circularidad (lección de Aladin 2020):** entrenar solo con
   variables observables (longitud, nº de vanos, potencia recibida,
   antigüedad, reparaciones) y dejar ocultas las causas físicas
   (empalmes, envejecimiento real, ruido ASE). Es esperable que la
   exactitud baje de ~99 % a ~85–90 %: es un resultado realista, no un
   fallo.
4. **Tamaño:** ~1000 muestras bastan para RF (Rottondi). Usaremos más
   (unas 10 000) y mostraremos una curva de aprendizaje.
5. **Desbalance:** en la red real casi todos los canales cumplen
   (Kozdrowski). Hay que generar suficientes casos "no cumple" o usar pesos
   de clase, y usar validación cruzada estratificada.
6. **Validación externa:** el dataset de Microsoft (usado en Di Cicco y
   Allogba) sirve para contrastar con datos medidos, aunque es una red
   troncal coherente de 100G o más, no IM/DD de 10G.
7. **Tiempo de cálculo:** no prometer que el modelo sea "más rápido" que
   una fórmula cerrada. Igarashi muestra la ventaja solo frente a
   simuladores caros (SSFM).
8. **Objetivo 4 (margen):** Morais estima el margen residual (0,4 dB de
   error) y Di Cicco usa intervalos de incertidumbre. Son los dos
   referentes para esa parte.

## Pendiente
- Morais & Pedro 2018 y Samadi 2017: no hay acceso libre al texto
  completo (el depósito de Zenodo de Morais fue retirado). Leer desde la
  red de la USAL si hace falta citar detalles concretos.
- Pointurier 2021: solo el resumen; leerlo desde la USAL para la
  Introducción.
