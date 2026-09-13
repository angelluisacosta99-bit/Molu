# Plan de entrenamiento para el TFM (energías renovables + sistemas inteligentes)

Plan pensado desde cero — aunque Angel ya cursó formación complementaria
en energía y análisis predictivo, este plan trata cada tema como si no
se supiera nada, para no dar nada por sentado. Objetivo final: llegar
preparado para ejecutar el TFM descrito en
`../ideas-tfm-energias-renovables.md` (predicción de generación
renovable con deep learning + módulo de decisión difuso).

**Bibliografía**: sacada directamente de las guías docentes oficiales
del MUSI ("Guía Académica 2024-2025", fichas de asignaturas de
Computación Neuroborrosa, Minería de Datos y Control Inteligente) — no
son recomendaciones genéricas de internet, son los libros que la propia
USAL exige/recomienda en esas asignaturas.

## Fase 0 — Python para ciencia de datos (2 semanas)

Aunque ya conoces Python, aquí lo tratamos desde NumPy/Pandas puros,
sin dar nada por supuesto.

- **Semana 1:** NumPy (arrays, operaciones vectorizadas, broadcasting).
- **Semana 2:** Pandas (DataFrames, limpieza de datos, series
  temporales con `pandas.DatetimeIndex`).
- **Bibliografía:** Géron, A., *Hands-On Machine Learning with
  Scikit-Learn, Keras and TensorFlow*, 3ª ed., O'Reilly, 2022 —
  capítulo 2 (proyecto end-to-end) es el mejor punto de entrada
  práctico. (Bibliografía oficial de Minería de Datos, MUSI.)
- **Entregable:** cargar un CSV de series temporales, limpiarlo,
  graficarlo.

## Fase 1 — Fundamentos matemáticos (2 semanas)

- Álgebra lineal básica (vectores, matrices, producto escalar).
- Probabilidad y estadística descriptiva (media, varianza, distribución
  normal).
- Cálculo diferencial básico (derivada, gradiente) — necesario para
  entender el descenso de gradiente sin tratarlo como caja negra.
- **Bibliografía:** Shalev-Shwartz, S. & Ben-David, S., *Understanding
  Machine Learning: From Theory to Algorithms*, Cambridge University
  Press, 2014 — capítulos introductorios. (Bibliografía oficial de
  Minería de Datos, MUSI.)

## Fase 2 — Machine Learning clásico (2 semanas)

- Regresión lineal/logística, árboles de decisión, k-NN, clustering.
- Evaluación de modelos: train/test split, validación cruzada, métricas
  (RMSE, MAE para regresión — relevante para predicción de energía).
- **Bibliografía:**
  - Hernández, J., Ramírez, M.J., Ferri, C., *Introducción a la
    Minería de Datos*, Pearson Education, 2004. (Libro de texto
    oficial de Minería de Datos, MUSI — en español.)
  - Zaki, M.J., Meira, W. Jr., *Data Mining and Analysis: Fundamental
    Concepts and Algorithms*, Cambridge University Press, 2014.
  - Géron (ya citado), capítulos 3-7.
- **Entregable:** un modelo de regresión simple prediciendo una serie
  temporal sencilla, con `scikit-learn`.

## Fase 3 — Redes neuronales y deep learning para series temporales (3 semanas)

- Perceptrón, retropropagación, redes neuronales feedforward.
- Redes recurrentes (RNN, LSTM, GRU) y redes convolucionales temporales
  (TCN) — la base de la Opción A del TFM.
- **Bibliografía:**
  - Haykin, S., *Neural Networks: A Comprehensive Foundation*,
    McMillan, 1998. (Bibliografía oficial de Computación Neuroborrosa,
    MUSI — el clásico de referencia en redes neuronales.)
  - Gulli, A., Kapoor, A., Pal, S., *Deep Learning with TensorFlow 2
    and Keras*, 2ª ed., Packt Publishing, 2021. (Bibliografía oficial
    de Computación Neuroborrosa, MUSI — el más práctico/moderno de la
    lista.)
  - Géron, capítulos 10-15 (redes neuronales y RNN con Keras).
- **Entregable:** una LSTM simple entrenada sobre una serie temporal de
  ejemplo (antes de tocar datos reales de energía).

## Fase 4 — Lógica difusa y sistemas neuroborrosos (2 semanas)

- Conjuntos difusos, funciones de pertenencia, reglas difusas,
  inferencia (Mamdani/Sugeno).
- Sistemas neuroborrosos (ANFIS) — la asignatura "Computación
  Neuroborrosa" del máster en sí.
- **Bibliografía:**
  - Jang, J.-S. R., Sun, C.-T., Mizutani, E., *Neuro-Fuzzy and Soft
    Computing*, Prentice Hall, 1996/1997. (**El** libro de texto
    oficial de Computación Neuroborrosa, MUSI — máxima prioridad de
    esta fase.)
  - Driankov, D., Hellendoorn, H., Reinfrank, M., *An Introduction to
    Fuzzy Control*, Springer Verlag, 1993. (Bibliografía oficial de
    Control Inteligente, MUSI.)
  - Repasar también el primer de fuzzy logic ya construido en esta
    sesión de Claude Code: artefacto "Neurodifuso" (fuzzy +
    ANFIS + demo interactiva de termostato difuso).
- **Entregable:** un controlador difuso simple (ej. el termostato del
  primer de Neurodifuso, o adaptado a decisión de carga de batería).

## Fase 5 — Dominio: datos abiertos de energía (1-2 semanas)

- Familiarizarse con la API REST de REData (Red Eléctrica de España):
  `https://www.ree.es/en/datos/apidata`.
- Descargar series reales de generación solar/eólica, limpiar,
  explorar (EDA).
- **Entregable:** dataset real descargado y explorado, listo para
  entrenar el modelo de la Fase 3 sobre datos reales en vez de
  ejemplos de juguete.

## Fase 6 — Proyecto aplicado (a partir de la semana 14, iterativo)

Integrar todo: LSTM/TCN entrenado sobre datos reales de REData +
módulo de decisión difuso que use la predicción para gestionar una
batería o el consumo — el núcleo del TFM. Esta fase ya no tiene fecha
de cierre fija, se itera con el tutor de TFM (ver
`../ideas-tfm-energias-renovables.md` para candidatos).

## Cómo usar este plan

- Cada fase termina en un entregable concreto y comprobable, no solo
  "leer el libro" — sigue el principio de la skill `ponytail` de este
  repo: lo mínimo que demuestre que el concepto se entendió, no una
  lectura pasiva.
- Ir guardando el código de cada entregable en
  `master-sistemas-inteligentes/trabajo-fin-de-master/preparacion/` (un
  archivo o notebook por fase) para tener continuidad entre sesiones de
  Claude Code, igual que se ha hecho con el resto de este máster.
- La Lección 1 (Fase 0, semana 1) se entrega junto con este plan en la
  misma sesión que lo creó — ver el historial de esa sesión para el
  contenido exacto si hace falta recuperarlo.
