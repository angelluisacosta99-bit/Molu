# Neural Designer: cómo funciona (estudiado 2026-10-07)

Fuente: guía oficial de Artelnics (neuraldesigner.com/learning/user-guide), versión
de ago-sep 2026. **Es la documentación, no la app de la USAL**: la versión
instalada puede tener menús o valores por defecto distintos.

## Las tres ventanas

- **Editor**: aquí se configura. Tiene el libro de datos (pestañas Data set,
  Neural network, Training strategy, Model selection), el gestor de tareas
  (lista de tareas por componente) y una consola con avisos y errores.
- **Motor**: sin ventana, ejecuta en segundo plano lo que se lanza desde el
  gestor de tareas.
- **Visor**: se abre solo al ejecutar una tarea y muestra tablas, gráficas y
  texto. Exporta a PDF, y cada tabla o gráfica a PNG o CSV (clic derecho).
  Guarda los resultados en un archivo `.ndo`.

## Flujo de un proyecto (siempre el mismo orden)

1. **Crear proyecto**: New approximation model (predecir un número) o New
   classification model (predecir una categoría). Guardar el proyecto en la
   misma carpeta que el CSV.
2. **Data set**: Browse data file e importar (revisar separador, cabecera,
   codificación). Marcar cada variable como entrada (input), objetivo (target)
   o sin usar. Neural Designer escala los datos por defecto
   (MeanStandardDeviation) y reparte las muestras. En la guía 2026 el reparto
   es desarrollo/prueba (41/10 en el ejemplo, ~80/20); en versiones anteriores
   era entrenamiento/validación/prueba.
3. **Neural network**: capas por defecto: scaling, dense oculta (tanh), dense
   de salida (lineal en regresión), unscaling y clamping. Con 1 entrada y 3
   neuronas ocultas son 10 parámetros.
4. **Training strategy**: función de pérdida (error cuadrático medio en
   regresión; entropía cruzada en clasificación), regularización L1/L2 y
   algoritmo (Adam por defecto; también SGD, quasi-Newton y
   Levenberg-Marquardt). Tarea: Perform training.
5. **Model selection**: busca la mejor arquitectura. Neurons selection
   (cuántas neuronas ocultas) e Inputs selection (qué variables de entrada
   sirven: growing, pruning o algoritmo genético). Es el paso que evita el
   sobreajuste.
6. **Testing analysis**: evalúa con muestras que no se usaron para ajustar.
   Regresión: goodness-of-fit (R² y gráfica predicho/real). Clasificación:
   matriz de confusión, ROC, métricas.
7. **Model deployment**: predicciones, importancia de variables, y exportar el
   modelo como expresión matemática o código en Python, C, JavaScript o PHP.

## Tipos de aplicación

Aproximación, clasificación, pronóstico de series temporales (red recurrente,
capas LSTM), detección de anomalías, y clasificación de imágenes y de texto.

## Ojo con (puntos débiles)

- **Es una caja de botones**: se puede obtener un R² alto sin entender nada.
  La nota depende de explicar qué hace cada paso.
- **Sobreajuste**: R² alto en entrenamiento no vale. Mirar siempre el error en
  las muestras de prueba o selección.
- **Reparto aleatorio vs. secuencial**: en series temporales el reparto debe
  ser secuencial; el aleatorio filtra información del futuro.
- **Neural Designer no hace lógica borrosa**: es la parte neuronal de la
  asignatura (Angélica González Arrieta), no la de Corchado. Para ANFIS habría
  que usar otra herramienta (por ejemplo MATLAB).
- **Licencia**: dura hasta el fin del máster. Guardar los proyectos y los
  resultados exportados.
- **Ejemplo oficial de práctica**: guía de 7 pasos con `y = x²` (CSV de 51
  muestras en la propia guía) y, después, el ejemplo de clasificación de flores
  iris.

Pendiente: ver la versión instalada de la USAL y saber qué ejercicio manda la
profesora.
