"""Crea experimento.ipynb (cuaderno guiado del Paso 3). Uso: python crear_cuaderno.py"""
import nbformat as nbf

nb = nbf.v4.new_notebook()
c = []
M = lambda t: c.append(nbf.v4.new_markdown_cell(t))
C = lambda t: c.append(nbf.v4.new_code_cell(t))

M("""# Paso 3 — Diseño experimental y resultados
**Pregunta:** ¿puede un modelo de ensamble predecir si un canal de la red DWDM ferroviaria Moscú-Kazánskaya – Riazán cumple BER ≤ 10⁻¹¹ mejor que un modelo lineal sencillo?

Este cuaderno se ejecuta de arriba abajo con ▶ (o *Run All*). Usa dos archivos de esta carpeta:
- `simulador.py`: el modelo físico que genera los datos sintéticos.
- `experimento.py`: entrena los modelos, calcula la tabla y dibuja las figuras.""")
M("""## 1. Comprobar el modelo físico con el caso del TFG
El tramo más desfavorable del proyecto (Voskresensk – Riazán-1, 108,9 km) debe cumplir cuando la red es nueva.""")
C("""import numpy as np
import simulador as sim

d = np.array([108.9])
perdida = sim.perdida_nominal(d)[0]
print(f"Pérdida nominal: {perdida:.1f} dB -> potencia en el preamplificador: {-perdida:.1f} dBm")
q = sim.q_ase(58 - perdida - 6.5)          # figura de ruido del EDFA: 6,5 dB
print(f"Q = {q:.2f}  ->  BER = {sim.ber_desde_q(q):.1e}  (el TFG obtuvo Q = 7,37)")""")
M("""## 2. Generar el conjunto de datos
10 000 canales entre pares de estaciones reales de la línea, con entre 0 y 25 años de servicio, reparaciones, hielo y envejecimiento.
Las columnas `oculta_*` son causas físicas que **el operador no puede medir**: no se dan a los modelos en los escenarios A y B.""")
C("""df = sim.generar(n=10000, semilla=42)
print("Proporción de canales que NO cumplen:", round(1 - df.cumple.mean(), 3))
df.head()""")
C("""df.describe().T[["mean", "min", "max"]]""")
M("""## 3. Entrenar, validar y dibujar
`experimento.py` compara regresión logística, Random Forest y XGBoost en tres escenarios:
- **A: planificación**: solo datos del inventario (longitud, amplificación, antigüedad, reparaciones registradas, temperatura).
- **B: monitorización**: lo anterior más la potencia recibida que mide el propio transceptor.
- **C: oráculo**: además, las causas ocultas (solo como referencia: en la realidad no se conocen).

Validación cruzada estratificada de 10 pliegues repetida 3 veces, y prueba de McNemar en un conjunto de prueba del 30 %. Tarda unos 2–3 minutos.""")
C("""%run experimento.py""")
M("## 4. Resultados")
C("""import pandas as pd
tabla = pd.read_csv("resultados/tabla_resultados.csv")
tabla[["Escenario", "Modelo", "AUC", "Exactitud equilibrada", "Sensibilidad (no cumple)", "F1 (no cumple)"]]""")
C("""print(open("resultados/mcnemar.txt", encoding="utf-8").read())""")
C("""from IPython.display import Image, display
for f in ["fig1_q_vs_longitud", "fig2_f1_escenarios", "fig3_importancia"]:
    display(Image(f"figuras/{f}.png", width=450))""")

nb.cells = c
nb.metadata["kernelspec"] = {"name": "python3", "display_name": "Python 3", "language": "python"}
nbf.write(nb, "experimento.ipynb")
print("experimento.ipynb creado")
