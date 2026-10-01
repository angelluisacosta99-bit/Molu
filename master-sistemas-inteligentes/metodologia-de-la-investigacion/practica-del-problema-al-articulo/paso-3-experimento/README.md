# Paso 3 — Diseño experimental y resultados

Material complementario: conjunto de datos, código, tabla de resultados y
figuras del estudio.

## Reproducción
1. Instalar las dependencias (`requirements.txt`, con las versiones de las
   bibliotecas principales):
   `python -m pip install -r requirements.txt`.
2. Ejecutar `python experimento.py`, o todas las celdas de `experimento.ipynb`
   (unos 2–3 minutos). Se regeneran `datos/`, `resultados/` y `figuras/`.

Entorno de referencia: Python 3.11. Semilla aleatoria fija (42).

## Archivos
| Archivo | Qué es |
|---|---|
| `simulador.py` | Modelo físico y generador de datos (10 000 canales). Todos los supuestos están comentados |
| `experimento.py` | Entrenamiento, validación cruzada, McNemar y figuras |
| `experimento.ipynb` | Cuaderno con el experimento completo, ya ejecutado |
| `datos/dataset.csv` | Conjunto de datos generado (semilla 42) |
| `resultados/tabla_resultados.{csv,tex}` | Tabla de métricas (CSV y LaTeX) |
| `resultados/mcnemar.txt` | Prueba estadística Random Forest / XGBoost frente a regresión logística |
| `figuras/fig1_q_vs_longitud` | Factor Q de cada canal según su longitud, con el umbral de BER |
| `figuras/fig2_f1_escenarios` | F1 por escenario y modelo (media ± desviación típica) |
| `figuras/fig3_importancia` | Importancia de las variables por permutación (Random Forest, escenario B) |

## Diseño experimental
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

## Interpretación
1. **La hipótesis se cumple solo en parte.** Los modelos de ensamble aciertan
   más en conjunto (F1 más alto y McNemar significativo), pero el **AUC es
   igual** en los tres modelos. La regresión logística detecta **más**
   canales que no cumplen (mayor sensibilidad), a costa de más falsas
   alarmas: en el 30 % de prueba del escenario B, Random Forest deja sin
   detectar 12 canales que no cumplen (2 la logística) con 49 falsas
   alarmas (90 la logística).
2. **Coste de los errores:** para el operador, no detectar un canal que falla
   (falso negativo) cuesta más que una falsa alarma. Con ese criterio, la
   logística sigue siendo competitiva, y el umbral de decisión del ensamble
   podría ajustarse a ese coste.
3. **La potencia recibida medida es la variable decisiva** (fig. 3): el AUC
   pasa de 0,98 (A) a 0,998 (B). Monitorizar el receptor aporta más que
   cambiar de modelo.
4. **Circularidad:** entre B y C apenas hay diferencia, porque la potencia
   medida ya recoge casi todas las causas ocultas. La tarea resulta
   relativamente fácil (AUC ≥ 0,98) porque la etiqueta sale de un modelo
   físico determinista. Es la limitación principal del estudio; la
   validación con datos medidos (p. ej., el conjunto público de Microsoft)
   queda como trabajo futuro.
5. **El modelo físico no reproduce el cálculo del TFG** (Q ≈ 10,4 frente a
   7,37 en el tramo de 108,9 km, con distinto planteamiento): el TFG aporta el
   diseño de partida, y las cifras de este estudio proceden del modelo físico
   de `simulador.py`.
6. **Generalización:** los 10 000 canales proceden de 208 pares de
   estaciones, así que la validación cruzada no mide el acierto en
   trayectos no vistos; esa validación agrupada por trayecto se presenta en
   el artículo (`paso-4-redaccion/analisis_no_vistos.py`).
