# Lección 1 — Python para ciencia de datos: NumPy y Pandas

Fase 0, semana 1 del plan de entrenamiento. Partimos de cero: no se
asume ningún conocimiento previo de NumPy ni Pandas.

Ejecuta este código en Google Colab (`colab.research.google.com`, no
necesita instalar nada) o en tu propio Python con
`pip install numpy pandas matplotlib`.

## 1. NumPy — arrays y operaciones vectorizadas

Un array de NumPy es como una lista de Python, pero mucho más rápido
para cálculos numéricos porque opera sobre todos los elementos a la vez
(vectorización), sin bucles `for` explícitos.

```python
import numpy as np

# Una lista normal de Python
temperaturas_lista = [18, 20, 22, 19, 17]

# El mismo dato como array de NumPy
temperaturas = np.array(temperaturas_lista)

print(temperaturas)          # [18 20 22 19 17]
print(temperaturas.mean())   # media: 19.2
print(temperaturas.std())    # desviación típica
print(temperaturas + 2)      # suma 2 a CADA elemento, sin bucle: [20 22 24 21 19]
```

Esto importa porque en el TFM vas a trabajar con miles de horas de
datos de generación solar/eólica — hacerlo con bucles `for` sería
lentísimo; NumPy (y Pandas, que está construido encima) lo hace en una
fracción del tiempo.

**Broadcasting** — NumPy aplica una operación entre arrays de tamaños
distintos de forma automática cuando es compatible:

```python
generacion_solar = np.array([0, 0, 5, 20, 35, 40, 35, 20, 5, 0, 0])
eficiencia_panel = 0.85  # un solo número (escalar)

generacion_real = generacion_solar * eficiencia_panel
print(generacion_real)
```

## 2. Pandas — DataFrames y series temporales

Un DataFrame es una tabla (como una hoja de Excel) con filas y columnas
con nombre. Es la estructura que vas a usar para cargar los datos de
REData.

```python
import pandas as pd

datos = pd.DataFrame({
    "hora": pd.date_range("2026-01-01", periods=5, freq="h"),
    "generacion_solar_mw": [0, 0, 5, 20, 35],
    "generacion_eolica_mw": [120, 115, 110, 105, 100],
})

print(datos)
print(datos.describe())          # estadísticas de cada columna
print(datos["generacion_solar_mw"].max())  # máximo de una columna
```

**Índice temporal** — cuando trabajas con series temporales, conviene
poner la fecha/hora como índice, no como una columna más:

```python
datos = datos.set_index("hora")
print(datos.loc["2026-01-01 02:00"])  # acceder por fecha/hora directamente
```

**Limpieza básica** — los datos reales casi nunca vienen perfectos:

```python
datos_sucios = pd.DataFrame({"valor": [10, None, 12, None, 15]})

print(datos_sucios.isna().sum())            # cuenta valores vacíos (NaN)
datos_limpios = datos_sucios.interpolate()  # rellena huecos interpolando
print(datos_limpios)
```

## 3. Visualización rápida

```python
import matplotlib.pyplot as plt

datos["generacion_eolica_mw"].plot(title="Generación eólica (MW)")
plt.show()
```

## Ejercicio (entregable de la semana 1)

1. Crea un DataFrame con 24 horas de datos simulados de generación
   solar (usa `np.random` o valores inventados razonables: 0 de noche,
   pico al mediodía).
2. Pon la hora como índice.
3. Calcula la media y el máximo del día.
4. Rellena con `interpolate()` si insertas manualmente algún valor
   `None`.
5. Grafica la serie del día completo.

No hay solución "oficial" — la idea es que el código corra sin errores
y el gráfico tenga sentido (una curva que sube y baja como el sol).
Cuando lo tengas, retómalo en una sesión de Claude Code para revisarlo
antes de pasar a la Fase 1.
