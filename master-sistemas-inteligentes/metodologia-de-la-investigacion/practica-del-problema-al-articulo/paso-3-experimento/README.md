# Paso 3 — Diseño experimental y resultados

Entregable de Studium: archivo de datos/código y las imágenes/tablas listas
para insertar en el manuscrito.

## Cómo ejecutarlo (en VS Code)
1. Abrir `experimento.ipynb` → *Select Kernel* → Python 3 → *Run All*.
2. Tarda unos 2–3 minutos. Regenera `datos/`, `resultados/` y `figuras/`.
   Sin el cuaderno: `python experimento.py`.

Probado con Python 3.11. Librerías: numpy, pandas, scipy, scikit-learn, xgboost y matplotlib.

## Archivos
| Archivo | Qué es |
|---|---|
| `simulador.py` | Modelo físico y generador de datos (10 000 canales). Todos los supuestos están comentados |
| `experimento.py` | Entrenamiento, validación cruzada, McNemar y figuras |
| `experimento.ipynb` | Cuaderno guiado y ya ejecutado (se ven los resultados sin volver a ejecutarlo) |
| `crear_cuaderno.py` | Regenera el cuaderno si se cambia su texto |
| `resumen-paso-3.pdf` | Resumen de 2 páginas para Studium: diseño, tabla, figuras e interpretación |
| `generar_resumen.py` | Regenera ese PDF desde `resultados/` y `figuras/` (usa Chromium) |
| `datos/dataset.csv` | Conjunto de datos generado (semilla 42) |
| `resultados/tabla_resultados.{csv,tex}` | Tabla de métricas; la `.tex` va directa al artículo LNCS |
| `resultados/mcnemar.txt` | Prueba estadística Random Forest / XGBoost frente a regresión logística |
| `figuras/fig1_q_vs_longitud` | Factor Q de cada canal según su longitud, con el umbral de BER |
| `figuras/fig2_f1_escenarios` | F1 por escenario y modelo (media ± desviación típica) |
| `figuras/fig3_importancia` | Importancia de las variables por permutación (Random Forest, escenario B) |

## Diseño (resumen para la sección de Métodos)
- **Canales:** pares de estaciones reales de la línea (tabla del TFG), de 5
  a 198 km. Son de 10 Gbit/s NRZ con detección directa.
- **Regla de diseño con margen fijo:** si el margen nominal es menor de
  3 dB, el canal lleva preamplificador EDFA, con un EDFA cada ≤ 110 km.
- **Degradación:** de 0 a 25 años de servicio; envejecimiento de fibra,
  láser y EDFA; reparaciones (Poisson por km y año, solo el 60 %
  registradas); hielo a menos de −5 °C; conectores sucios.
- **Calidad:** Q térmico (tramos sin amplificar), Q por ruido ASE
  (tramos amplificados) y penalización por dispersión.
  **Etiqueta:** Q ≥ 6,71 ⇔ BER ≤ 10⁻¹¹. El 20,4 % de los canales no cumple.
- **Escenarios:** A = planificación (inventario); B = + potencia recibida
  medida (±0,5 dB); C = oráculo con las causas ocultas.
- **Modelos:** regresión logística (referencia), Random Forest (300
  árboles) y XGBoost (300 árboles, profundidad 4), todos con pesos de clase.
- **Validación:** validación cruzada estratificada de 10 pliegues × 3
  repeticiones, más McNemar sobre un 30 % de prueba. Clase positiva =
  «no cumple».

## Resultados

| Escenario | Modelo | AUC | Exactitud equilibrada | Sensibilidad | F1 |
|---|---|---|---|---|---|
| A: planificación | Regresión logística | 0,983 ± 0,003 | 0,929 ± 0,009 | 0,939 ± 0,017 | 0,832 ± 0,014 |
| A: planificación | Random Forest | 0,981 ± 0,003 | 0,921 ± 0,011 | 0,901 ± 0,023 | 0,847 ± 0,015 |
| A: planificación | XGBoost | 0,982 ± 0,003 | 0,925 ± 0,010 | 0,914 ± 0,019 | 0,845 ± 0,014 |
| B: monitorización | Regresión logística | 0,998 ± 0,001 | 0,977 ± 0,004 | 0,987 ± 0,007 | 0,931 ± 0,009 |
| B: monitorización | Random Forest | 0,998 ± 0,001 | 0,976 ± 0,007 | 0,974 ± 0,012 | 0,947 ± 0,012 |
| B: monitorización | XGBoost | 0,998 ± 0,001 | 0,973 ± 0,008 | 0,964 ± 0,014 | 0,947 ± 0,012 |
| C: oráculo | Regresión logística | 0,998 ± 0,001 | 0,980 ± 0,004 | 0,991 ± 0,006 | 0,940 ± 0,010 |
| C: oráculo | Random Forest | 0,998 ± 0,001 | 0,978 ± 0,006 | 0,976 ± 0,011 | 0,951 ± 0,011 |
| C: oráculo | XGBoost | 0,999 ± 0,001 | 0,978 ± 0,007 | 0,969 ± 0,012 | 0,958 ± 0,011 |

**McNemar (escenario B, 30 % de prueba):** Random Forest frente a la logística,
44 frente a 13 casos que solo acierta uno de los dos, p = 7·10⁻⁵. XGBoost
frente a la logística, 54 frente a 23, p = 6·10⁻⁴.

## Interpretación honesta (para Resultados y Discusión)
1. **La hipótesis se cumple solo en parte.** Los modelos de ensamble aciertan
   más en conjunto (F1 más alto y McNemar significativo), pero el **AUC es
   igual** en los tres modelos. La regresión logística detecta **más**
   canales que no cumplen (mayor sensibilidad), a costa de más falsas
   alarmas. Es un resultado matizado, como el del artículo de Espejo et
   al. que usa la profesora de modelo.
2. **Qué importa para el operador:** no detectar un canal que falla
   (falso negativo) cuesta más que una falsa alarma. Con ese criterio, la
   logística sigue siendo competitiva. Conviene discutirlo y proponer
   ajustar el umbral de decisión del ensamble.
3. **La potencia recibida medida es la variable decisiva** (fig. 3): el AUC
   pasa de 0,98 (A) a 0,998 (B). Monitorizar el receptor aporta más que
   cualquier modelo.
4. **Circularidad:** entre B y C apenas hay diferencia, porque la potencia
   medida ya recoge casi todas las causas ocultas. La tarea resulta
   relativamente fácil (AUC ≥ 0,98) porque la etiqueta sale de un modelo
   físico determinista. Es la limitación principal: hay que declararla y
   proponer validarlo con datos reales (dataset de Microsoft).
5. **El modelo físico no es el cálculo del TFG.** En el tramo de 108,9 km
   este modelo da Q ≈ 10,5 (con preamplificador EDFA y ruido ASE); el TFG
   daba 7,37 con otro planteamiento y con incoherencias internas
   detectadas en la revisión independiente. En el artículo, el TFG se cita
   como el diseño de partida, no como fuente de estos números.
