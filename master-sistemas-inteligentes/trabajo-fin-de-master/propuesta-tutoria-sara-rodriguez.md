# Propuesta de TFM — borrador para la Dra. Sara Rodríguez González

## ⛔ NO ENVIAR — ESTE BORRADOR TIENE FALLOS BLOQUEANTES

**Estado: DESCARTADO el 2026-09-14**, tras dos revisiones independientes
con agentes. Se conserva solo como registro de lo que no funciona. Los
motivos, en detalle, en `ideas-tfm-energias-renovables.md`, sección
"Revisión 2026-09-14 (tercera pasada): la propuesta se cae, y por qué".
Resumen:

1. **La afirmación de novedad es falsa.** Yin, Lei y Feng publicaron en
   2024 en *IEEE Transactions on Power Systems* "Assessing the Value of
   Renewable Forecasting Accuracy in Power System Operation", un
   artículo cuyo título enuncia la misma pregunta de investigación que
   este borrador presentaba como hueco.
2. **El "barrido controlado de error" es metodológicamente circular** si
   se hace con ruido sintético, y además ya está catalogado en la
   literatura como el método *anterior* al que trabajos de 2024 superan.
3. **No hay problema de decisión bien planteado**: generación peninsular
   agregada + una batería no define un escenario; faltan perfil de
   consumo, señal de precios, modelo de batería y políticas ancla.
4. **Falta el marco teórico correcto**: *decision-focused learning* /
   Smart Predict-then-Optimize (Elmachtoub y Grigas, *Management
   Science*, 2022, 905 citas). Presentar la disociación
   precisión/decisión como hallazgo propio sin citarlo se leería como
   desconocimiento del campo.

Lo que sigue es el texto original, **inservible tal cual**.

---

Destinataria: Dra. Sara Rodríguez González (BISITE, Departamento de
Informática y Automática, USAL). Ver `ideas-tfm-energias-renovables.md`
para por qué es la primera opción y para las advertencias de
tratamiento (su categoría aparece distinta según la fuente: usar "Dra.").

---

## Parte 1 — Cuerpo del correo (corto, es lo que de verdad se lee)

> **Asunto:** Propuesta de TFM (MUSI 2026-2027): valor de decisión de la
> predicción en gestión de almacenamiento
>
> Estimada Dra. Rodríguez González:
>
> Me llamo Angel Luis Acosta González y este curso comienzo el Máster
> Universitario en Sistemas Inteligentes. Mi hermana, Arlet Acosta
> González, cursó el máster y fue alumna suya.
>
> Le escribo con una propuesta concreta de TFM, no con una consulta
> abierta. Al revisar el estado del arte para orientar el trabajo hacia
> predicción de generación renovable, encontré su artículo de este año
> en *Electronics* sobre gestión de almacenamiento con agentes y
> precios del mercado español. Me interesó especialmente que la
> evaluación sea económica y no de error de predicción.
>
> Precisamente ahí veo la pregunta que me gustaría trabajar: en la
> literatura que he revisado, la calidad del pronóstico y la calidad de
> la decisión se evalúan por separado. No he encontrado trabajo que
> **varíe sistemáticamente el error de predicción para medir cuánto se
> traslada a la decisión de carga/descarga** — es decir, a partir de qué
> punto mejorar el modelo deja de cambiar lo que la batería hace.
>
> Adjunto una propuesta de dos páginas con el planteamiento, la
> metodología y una valoración honesta de su alcance. Si le parece que
> encaja con su línea, le agradecería mucho la oportunidad de
> comentarla; y si no, cualquier orientación sobre a quién dirigirme
> sería igualmente valiosa.
>
> Un cordial saludo,
> Angel Luis Acosta González

---

## Parte 2 — Propuesta adjunta (2 páginas)

### Título provisional

**Del error de predicción al valor de la decisión: evaluación de
modelos fundacionales de series temporales para la gestión de
almacenamiento en sistemas de generación renovable.**

### 1. Punto de partida

La predicción de generación renovable y la gestión de almacenamiento se
han estudiado ampliamente, pero en compartimentos separados:

**Predicción.** La literatura reciente se ha desplazado hacia modelos
fundacionales de series temporales (TSFM), capaces de predecir sin
entrenamiento específico por conjunto de datos. El *benchmark* FETS
(*Energy and AI*, 2026) sitúa a Chronos-2 con el menor NRMSE mediano
(0,472) sobre 54 conjuntos de datos energéticos, por debajo de XGBoost
(0,611) y *random forest* (0,696) pese a que estos se entrenaron con el
histórico completo de la serie objetivo. Existen ya evaluaciones
empíricas para solar, eólica y demanda sobre datos de ERCOT.

**Decisión.** La gestión de almacenamiento mediante control difuso a
partir de previsiones está consolidada desde los trabajos de
Arcos-Avilés et al. (*Applied Energy*, 2017; *IEEE TSG*, 2018), con
validación experimental en microrred real. Su propio trabajo
(Rodríguez González et al., *Electronics*, 2026) avanza esta línea
optimizando la política de carga/descarga con aprendizaje por refuerzo
y evaluándola por **beneficio económico**.

**El hueco.** Ambas líneas miden cosas distintas y no se cruzan: la
primera compite en MASE/NRMSE, la segunda evalúa euros o vida útil de
batería, tomando el pronóstico como dado. No he encontrado trabajo que
**degrade o mejore deliberadamente el pronóstico para medir la
elasticidad de la decisión frente a ese error**.

### 2. Pregunta de investigación

> ¿Cuánta mejora en la precisión del pronóstico de generación renovable
> se traduce realmente en mejores decisiones de carga/descarga de un
> sistema de almacenamiento, y a partir de qué punto deja de importar?

Subpreguntas:

1. ¿Ordenan igual a los modelos las métricas de error (MASE, NRMSE) y
   las métricas de decisión (coste, ciclos de batería, autoconsumo)?
2. ¿Es esa relación lineal, o existe un umbral de saturación a partir
   del cual un pronóstico mejor no cambia la política?
3. ¿Depende ese umbral del módulo de decisión empleado (reglas difusas
   frente a optimización)?

### 3. Metodología

1. **Datos.** Generación renovable peninsular horaria de la API REData
   de Red Eléctrica (`apidatos.ree.es`, acceso libre sin clave,
   histórico disponible desde al menos 2014).
2. **Predicción.** Modelos fundacionales en modo *zero-shot*
   (Chronos-2, licencia Apache-2.0, disponible en Hugging Face) frente
   a una línea base entrenada a medida (LSTM/TCN) y a referencias
   estadísticas (SARIMA, *seasonal naive*).
3. **Barrido controlado de error.** El paso central y diferencial:
   generar una familia de pronósticos con error creciente y controlado
   (degradando sistemáticamente las predicciones, o usando horizontes
   crecientes) para poder tratar la calidad del pronóstico como
   *variable independiente* en lugar de como dato fijo.
4. **Decisión.** Módulo de gestión de batería basado en lógica difusa
   —lo que conecta directamente con la asignatura de Computación
   Neuroborrosa del máster— alimentado por cada pronóstico del barrido.
5. **Evaluación dual.** Cada configuración se mide simultáneamente con
   métricas de error y con métricas de decisión, para construir la
   curva error-de-predicción frente a valor-de-decisión que responde a
   la pregunta.

### 4. Viabilidad

- **Datos:** abiertos, sin clave, sin trámite.
- **Cómputo:** no requiere GPU. Un *benchmark* de 2026 evaluó
  Chronos-2, Chronos-Bolt, Moirai-2 y TinyTimeMixer sobre cinco años de
  datos horarios en hardware de consumo (Ryzen 7, 16 GB, sin GPU). El
  enfoque *zero-shot* elimina además el coste de entrenar.
- **Alcance temporal:** el trabajo es acotable. El barrido de error y la
  evaluación dual son el núcleo; ampliaciones (más modelos, módulo de
  decisión alternativo) son incrementos opcionales, no requisitos.

### 5. Aportación esperada, y su límite

La aportación es **metodológica e incremental**: no propone una
arquitectura nueva ni un controlador nuevo, sino un procedimiento para
medir algo que la literatura actual no mide, y una respuesta empírica
sobre datos del sistema eléctrico español. Prefiero plantearlo así
desde el principio antes que presentarlo como más novedoso de lo que es.

Su interés práctico, si el umbral de saturación existe, es directo:
indicaría cuándo deja de compensar invertir esfuerzo en mejorar el
modelo de predicción para una aplicación de almacenamiento dada.

### 6. Encaje con la línea de trabajo del grupo

La propuesta es complementaria a su artículo de 2026: aquel optimiza la
política de decisión tomando el pronóstico como dado; este trabajo
mantendría fija la política y haría variar el pronóstico. Encaja
igualmente con la línea de energía y eficiencia energética de BISITE.

### Referencias

- Arcos-Avilés, D., Pascual, J., Marroyo, L., Sanchis, P. y Guinjoan, F.
  (2017). Low complexity energy management strategy for grid profile
  smoothing of a residential grid-connected microgrid using generation
  and demand forecasting. *Applied Energy*, 205, 69-84.
  DOI: 10.1016/j.apenergy.2017.07.123
- Arcos-Avilés, D., Pascual, J., Marroyo, L., Sanchis, P. y Guinjoan, F.
  (2018). Fuzzy Logic-Based Energy Management System Design for
  Residential Grid-Connected Microgrids. *IEEE Transactions on Smart
  Grid*, 9(2), 530-543. DOI: 10.1109/TSG.2016.2555245
- Rodríguez González, S., González-Briones, A. y López Flórez, S.
  (2026). Enhancing Energy Efficiency and Economic Benefits with Battery
  Energy Storage Systems: An Agent-Based Optimization Approach.
  *Electronics*, 15(11), 2269. DOI: 10.3390/electronics15112269
- Obermeier, M. et al. (2026). FETS benchmark: Foundation Models enable
  scalable and generalizable Energy Time Series Forecasting.
  *Energy and AI*.

---

## Notas internas (NO enviar, quitar antes de exportar)

- **Verificar antes de enviar:** la lista completa de autores del paper
  de *Electronics* (Scite solo devuelve los tres primeros) y del
  *benchmark* FETS, y el tratamiento correcto de la destinataria
  (Profesora Titular vs. Catedrática según la fuente).
- **No mencionar** el correo genérico ya enviado a `bisite@usal.es` sin
  respuesta: no aporta y puede leerse como insistencia.
- **La mención a Arlet va una sola vez y de pasada.** Es una vía de
  presentación honesta, no un argumento; el peso lo lleva la propuesta.
- Las referencias de arXiv del estado del arte (benchmarks de ERCOT,
  WindFM, etc.) están sin verificar en metadatos completos — por eso
  aquí solo se citan las tres verificadas con Scite (Arcos-Avilés 2017 y
  2018, y Rodríguez González 2026) más FETS, **cuyos metadatos están
  incompletos**: sin DOI, sin volumen y sin lista de autores. Verificar
  FETS y el resto antes de llevarlas a `main.tex`, y no darlo por
  comprobado mientras tanto.
