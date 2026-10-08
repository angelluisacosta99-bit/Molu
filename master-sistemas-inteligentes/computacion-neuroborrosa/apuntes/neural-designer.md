# Neural Designer: guía de estudio (tutoriales oficiales, 2026-10-07)

Fuentes: tutoriales, guía de usuario, blogs y ejemplos oficiales de
neuraldesigner.com (lista al final). **Es la documentación, no la aplicación
instalada en la USAL**: menús y valores por defecto pueden variar. Lo que las
páginas no dicen está marcado **[no aparece]**; lo que añado yo de ML estándar
está marcado **[estándar]**. Las páginas tienen erratas (sección 10): no copiar
fórmulas sin contrastarlas.

## 1. Idea general y flujo de trabajo

Neural Designer es una herramienta visual (sin código) para construir redes
neuronales. Los tutoriales siguen siempre el mismo orden: Model types, Data set,
Neural network, Training strategy, Model selection, Testing analysis, Model
deployment. El blog lo cuenta en seis pasos (sin Model types).

La aplicación tiene tres piezas: el **Editor** (libro de datos con las pestañas
Data set, Neural network, Training strategy y Model selection, más el gestor de
tareas y una consola de avisos), el **Motor** (calcula en segundo plano) y el
**Visor** (muestra tablas y gráficas; exporta a PDF, y cada tabla o gráfica a PNG
o CSV).

## 2. Elegir el tipo de modelo

La Tabla 1 resume los seis tipos de proyecto, qué predicen y la pérdida y el
optimizador que el tutorial de Training strategy asigna por defecto. La pantalla
de inicio de la app ofrece cinco botones (approximation, classification,
forecasting, text classification e image classification); la detección de
anomalías aparece en la documentación como modelo propio.

**Tabla 1.** Tipos de modelo y valores por defecto según el tutorial de Training strategy.

| Tipo | Qué predice | Pérdida por defecto | Optimizador por defecto |
|---|---|---|---|
| Approximation | un número continuo | Mean squared error | Adam |
| Forecasting | valores futuros de una serie | Mean squared error | Adam |
| Binary classification | clase sí/no (probabilidad) | Weighted squared error | Quasi-Newton |
| Multiclass classification | una de varias clases | Cross-entropy | Quasi-Newton |
| Anomaly detection | si una muestra es anómala (red auto-asociativa, entrena solo con muestras normales) | Mean absolute error | Adam |
| Image / text classification | clase de una imagen / texto | Cross-entropy | Adam |

Regla práctica: si el objetivo es un número y el orden temporal importa (por
ejemplo, producción eólica hora a hora), es **forecasting**, no approximation.

## 3. Data set

- **Variables:** cada columna es input, target o unused. Las constantes, los
  identificadores y las direcciones van como `Unused`. Tipos citados:
  continuas, binarias y categóricas.
- **Muestras:** training (construye los modelos), selection (elige el mejor) y
  testing (medida final); `Unused` para outliers y repetidas. Reparto estándar
  del tutorial: 60 / 20 / 20, secuencial o aleatorio. **[no aparece]** cuál es el
  valor por defecto de la app. En series temporales el reparto debe ser
  secuencial [estándar].
- **Valores perdidos:** marcar con `NA`, `NaN`, `Unknown` o `?`, nunca con
  `-999`. Si hay muchas muestras y pocos perdidos: `Samples unusing`. Si hay
  muchos perdidos o pocos datos: `Data imputation` (media; mediana si hay
  outliers o asimetría). En series: interpolación.
- **Tareas de análisis:** Statistics, Distributions, Box plots, Scatter charts,
  Inputs correlations, Inputs-targets correlations y, en series, Time series
  plots, Autocorrelations y Cross-correlations.
- **Outliers:** tres métodos complementarios. *Univariate* (Tukey, con
  `cleaning parameter`: grande detecta pocos, pequeño detecta muchos),
  *Multivariate* (entrena un modelo y quita las muestras con más error) y
  *Minkowski error* (no detecta ni limpia: reduce su peso al entrenar,
  exponente típico 1,5). **[no aparece]** el valor por defecto del cleaning
  parameter (0,6 es solo el del ejemplo).
- **Escalado:** conviene siempre. Se hace en la red (sección 4) y la app
  sincroniza data set y red sola. **[no aparece]** el escalador por defecto.

## 4. Neural network

La Tabla 2 recoge las nueve capas que documenta Neural Designer.

**Tabla 2.** Capas disponibles.

| Capa | Para qué sirve | Parámetros entrenables |
|---|---|---|
| Scaling / unscaling | llevan las entradas a un rango adecuado y las salidas a sus unidades | no (guardan estadísticas) |
| Dense | conecta todo con todo (`z = b + Σ w·x`, `y = f(z)`); neuronas, activación y dropout | sí |
| Clamping | limita cada salida a [mínimo, máximo] (`min(max(y, inf), sup)`) | no |
| Convolutional / pooling | imágenes (filtros, kernel, stride; max o average) | solo la convolucional |
| Embedding / multi-head attention | texto (las cabezas deben dividir la dimensión del embedding) | sí |
| LSTM | series temporales (puertas forget, input, state y output) | sí |

**Activaciones de la capa dense:** linear (salida de approximation y
forecasting), tanh (capas ocultas, salida entre −1 y 1), ReLU (muy usada en
ocultas y convolucionales), sigmoid (salida binaria) y softmax (salida
multiclase, probabilidades que suman 1).

**Arquitectura típica:** approximation = scaling + dense(s) + unscaling (+
clamping); classification = scaling + dense(s), última con sigmoid o softmax;
forecasting = scaling + LSTM (o capa recurrente) + dense(s) + unscaling.
"Dos capas dense bastan para muchos data sets".

**Escalado:** min-max lleva a [−1, 1] (variables uniformes); media-desviación
da media 0 y desviación 1 (normales); desviación estándar (half-normal).
Fórmulas correctas [estándar]: `(x − media)/sd` y su inversa
`media + y·sd`; min-max inverso `mín + 0,5·(y + 1)·(máx − mín)`.

## 5. Training strategy

`loss = error + regularización`. En la Tabla 3, los siete errores que lista el
tutorial.

**Tabla 3.** Funciones de error.

| Error | Cuándo |
|---|---|
| Mean squared error | approximation y forecasting (por defecto) |
| Mean absolute error | anomaly detection; menos sensible a errores grandes |
| Normalized squared error | regresión; cerca de 1 = no mejora a predecir la media, 0 = perfecto |
| Weighted squared error | binaria con clases desbalanceadas |
| Cross-entropy | clasificación (multiclase exige softmax) |
| 3D cross-entropy | modelos de lenguaje |
| Minkowski error | regresión con outliers; potencia entre 1 y 2 (defecto 1,5); solo CPU |

- **Regularización:** L1 (`λ·Σ|θ|`) y L2 (`λ·Σθ²`) penalizan parámetros
  grandes y reducen el sobreajuste. Según el tutorial no hay ninguna por
  defecto. **[no aparece]** el valor de λ ni cuándo preferir L1 o L2.
- **Optimizadores:** Adam y SGD (mini-batch, CPU y GPU; para redes grandes y
  datos grandes); Quasi-Newton (full-batch, CPU; tabulares moderados);
  Levenberg-Marquardt (full-batch, CPU; regresión dense pequeña; no admite
  softmax, capas no dense ni errores weighted, cross-entropy o Minkowski).
- **Parada:** loss goal, maximum epochs, maximum time, validation failures y,
  solo en Quasi-Newton y Levenberg-Marquardt, minimum loss decrease. Con
  validación, la app restaura por defecto los mejores parámetros (*Restore
  best*). Batch size 0 = el mayor batch que cabe en memoria.
- **[no aparece]** learning rate, betas, epochs ni tiempos por defecto.

## 6. Model selection y sobreajuste

- **Training error** = ajuste a lo que la red ve; **selection error** =
  capacidad de generalizar. *Underfitting*: los dos altos (red demasiado
  simple). *Overfitting*: el de training baja mientras el de selection sube
  (red demasiado compleja). Con la complejidad adecuada, training, selection y
  testing son parecidos.
- **Neuron selection:** *Growing neurons* (parte de una red pequeña y añade
  neuronas hasta que el selection error deja de bajar).
- **Input selection:** *Growing inputs* (parte del input más correlacionado),
  *Pruning inputs* (parte de todos y quita los menos correlacionados) y
  *Genetic algorithm* (población de subconjuntos de variables; población
  por defecto 10·N múltiplo de 4; mutación 1/m; más potente y más caro).
  Neural Designer implementa una versión más avanzada que la del blog.

## 7. Testing analysis

La Tabla 4 resume las métricas de regresión y la Tabla 5 las de clasificación.
Las páginas **no dan fórmulas ni umbrales de "bueno"**; las fórmulas son
[estándar].

**Tabla 4.** Testing de approximation y forecasting.

| Análisis | Qué mide | Lectura |
|---|---|---|
| Testing errors | MSE, NSE, Minkowski (y SSE y RMSE en forecasting) en training, validation y testing | comparar los tres: test mucho peor = sobreajuste |
| Errors statistics | mínimo, máximo, media y desviación del error (absoluto, relativo, porcentual) | la media esconde el peor caso |
| Errors histogram | distribución del error | esperable: normal centrada en 0 |
| Maximal errors | las muestras con más error | revisar si son errores de medida o zonas con pocos datos |
| Goodness-of-fit | R² y recta predicho/real | R² = 1 perfecto; "bueno" depende del problema |
| Outputs plot (forecasting) | serie real y predicha en el tiempo | la predicción debe seguir a la serie sin desfase |

**Tabla 5.** Testing de clasificación.

| Análisis | Qué mide |
|---|---|
| Confusion matrix | aciertos (diagonal) y fallos; umbral de decisión 0,5 por defecto |
| Binary classification tests | accuracy, error rate, sensitivity, specificity, precision, F1, Matthews, etc., para el umbral elegido |
| Multiple classification tests | precision, recall y F1 por clase, con macro y weighted average |
| ROC curve | sensitivity frente a 1 − specificity en todos los umbrales; AUC 0,5 = azar, 1 = perfecto |
| Cumulative gain, lift chart, positives and negatives rates, profit chart | ventaja frente al azar al ordenar por probabilidad (por ejemplo 50 % de la población, 80 % de los positivos: lift 80/50 = 1,6 veces) |
| Misclassified instances | qué filas fallan (falsos positivos y falsos negativos) |

## 8. Model deployment

Neural network outputs (una predicción), Output data (muchos casos nuevos desde
un archivo), Directional outputs (varía una entrada con las demás fijas),
Sample input importances (local, una muestra, con signo), Model input
importances (global, normalizada; perturba hasta 50 muestras), Response
optimization (solo approximation; con varios objetivos devuelve un frente de
Pareto), Mathematical expression, Programming language expressions (C, Python,
JavaScript y PHP; incluyen escalado y desescalado) y Deployment package
(imagen y texto; Windows, Python 3 o C).

## 9. Lo que enseñan los ejemplos oficiales

La Tabla 6 compara los cuatro ejemplos leídos a fondo. El índice tiene unos 70;
**ninguno es de viento ni de aerogeneradores**.

**Tabla 6.** Ejemplos oficiales leídos.

| Ejemplo | Tipo | Datos | Red | Resultado en test | Lección |
|---|---|---|---|---|---|
| Ciclo combinado | Approximation | 9.568 filas, 4 entradas | 4–3–1, 19 parámetros, L2 0,01, Quasi-Newton | R² 0,9377; RMSE 4,421 MW | flujo completo; hay 16 filas de test duplicadas en training |
| Iris | Clasificación (3 clases) | 150 filas, 4 entradas | solo softmax 4→3, 15 parámetros | accuracy 100 % (30 filas) | el modelo más simple basta; hay una fila duplicada entre particiones |
| Inflación en Polonia | Forecasting | 348 meses, 12 retardos, 3 pasos | recurrente (5) + dense (3) | R² 0,969 / 0,909 / 0,837 en t+1, t+2 y t+3 | el rendimiento cae al alejar el horizonte; falta comparar con persistencia |
| Fotovoltaica | Approximation | 7.080 filas, 20 entradas | 20–3–1 | R² 0,999 | **fuga de información**: el objetivo es exactamente la suma de cinco entradas |

**Orden de práctica recomendado:** tutorial de 7 pasos de la propia app
(`y = x²`), después ciclo combinado, Iris e inflación. Datasets descargables:
CSV de ciclo combinado e Iris en las páginas de cada ejemplo.

## 10. Discrepancias y erratas de la documentación

1. **Valores por defecto contradictorios:** el tutorial de Training strategy
   dice MSE + Adam sin regularización; el blog del proceso de modelado dice
   NSE + L2 + Quasi-Newton; la guía de 7 pasos usa MSE + L2 (0,01) + Adam (lote
   32, tasa 0,001). **Comprobar en la app lo que viene preseleccionado.**
2. **Reparto de muestras:** el tutorial habla de training / selection / testing
   (60/20/20); la guía de 7 pasos de desarrollo / testing (41/10).
3. **Fórmulas erróneas en el tutorial de Neural network:** el escalado
   "mean and standard deviation" aparece idéntico al de "standard deviation"; el
   desescalado "mean and standard deviation" aparece mal escrito; el desescalado
   min-max omite el `0,5·(y + 1)` (la página de deployment sí lo escribe bien).
4. **Data set:** el blog de valores perdidos dice "sin outliers, usar la
   mediana" (debería ser la media); el tutorial describe mal la correlación
   negativa; el blog de la matriz de datos intercambia las dimensiones de
   muestra y variable.
5. **Testing:** los porcentajes de la matriz de confusión de ejemplo no cuadran
   con sus recuentos; escribe "lift 1,6 % más" cuando es 1,6 veces.
6. **Nombres:** el algoritmo de neuronas se llama *Growing neurons* en los
   tutoriales (la página técnica lo llama *incremental order*).
7. Las fórmulas de la Tabla 3 salen algo rotas de la web: revisar factores
   (por ejemplo 1/2N) antes de citarlas.

## 11. Errores típicos (resumen)

1. Mirar solo el training error: baja siempre al añadir neuronas.
2. Usar el conjunto de test para elegir arquitectura o parar: solo mide al final.
3. Reparto aleatorio en series temporales (se filtra el futuro).
4. Variables que casi equivalen al objetivo (ejemplo fotovoltaico) o filas
   duplicadas entre particiones.
5. Fiarse de la accuracy con clases desbalanceadas; mirar sensitivity,
   precision, F1 y ROC. Las métricas binarias dependen del umbral (0,5).
6. Un R² alto aislado: mirar también el histograma y los errores máximos.
7. Pensar que la importancia de variables es causalidad.
8. Optimizar respuesta o extrapolar fuera del rango de los datos.
9. Copiar código exportado sin las capas de escalado y desescalado.
10. Usar Levenberg-Marquardt o Quasi-Newton con datos grandes o redes no dense.
11. Dejar muchas variables sin revisar: constantes, identificadores y outliers.

## 12. Comprobar en la app (pendiente)

- Qué pérdida y qué reparto de muestras vienen preseleccionados (punto 1 de la
  sección 10; la pestaña Data set sigue sin comprobar).
- **Visto en la app (captura del 7 oct, pestaña Training strategy):**
  regularización *None*, algoritmo Adam, batch size 100, learning rate 0,001,
  training loss goal 0, maximum epochs 75, maximum time 6.000 min, minimum loss
  decrease 0, hardware multi-core (CPU) con opción NVIDIA CUDA (GPU). Coincide
  con el tutorial en "sin regularización" y Adam, pero no con la guía de 7
  pasos (lote 32, 1.000 épocas, L2). Los 75 epochs son pocos: mirar si la curva
  de error sigue bajando al parar. **[no aparece]** si estos valores son los de
  fábrica o los de un proyecto concreto.
- Nombres exactos de menús y botones: las páginas **no los describen**.
- Si el escalador por defecto y el cleaning parameter coinciden con la guía.
- Cómo se evalúa la parte neuronal de la asignatura.

## Fuentes (todas en neuraldesigner.com/learning)

- Guía de usuario: `user-guide/user-guide`, `neural-designer-components`,
  `design-a-neural-network` (7 pasos), `technical-features`.
- Tutoriales: `tutorials/data-set`, `neural-networks-applications`,
  `neural-network`, `training-strategy`, `model-selection`,
  `testing-analysis`, `model-deployment`.
- Blog: `modelling-process`, `genetic_algorithms_for_feature_selection`,
  `dataset-datamatrix`, `missing-values`,
  `effective-outlier-treatment-methods-machine-learning`.
- Ejemplos: `examples/examples` (índice), `iris-flowers-classification`,
  `inflation-prediction`, `solar-power-generation`, `combined-cycle-power-plant`.
- No leídos: el blog de los cinco algoritmos de entrenamiento, el de los seis
  tests de clasificación binaria y el de tipos de variables.
