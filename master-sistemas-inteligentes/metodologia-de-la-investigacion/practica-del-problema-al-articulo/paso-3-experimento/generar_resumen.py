"""Genera resumen-paso-3.pdf (tabla + figuras + interpretación) a partir de
resultados/ y figuras/. Ejecutar después de experimento.py.
Uso: python generar_resumen.py   (necesita Chrome/Chromium; en Windows, poner su ruta
en la variable de entorno CHROME, p. ej. C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe)"""
import csv, os, subprocess
from pathlib import Path

AQUI = Path(__file__).parent
CHROME = os.environ.get("CHROME", "/opt/pw-browsers/chromium-1194/chrome-linux/chrome")

filas = list(csv.DictReader(open(AQUI / "resultados" / "tabla_resultados.csv", encoding="utf-8")))
coma = lambda s: s.replace(".", ",")
tabla = "".join(
    f"<tr><td>{f['Escenario'].split(' (')[0]}</td><td>{f['Modelo']}</td>"
    + "".join(f"<td>{coma(f[m])}</td>" for m in ("AUC", "Exactitud equilibrada", "Sensibilidad (no cumple)", "F1 (no cumple)"))
    + "</tr>" for f in filas)

def figura(n, archivo, pie, ancho="62%"):
    return (f'<figure><img src="figuras/{archivo}.png" style="width:{ancho}">'
            f"<figcaption><b>Fig. {n}.</b> {pie}</figcaption></figure>")

html = f"""<!doctype html><html lang="es"><meta charset="utf-8"><style>
@page{{size:A4;margin:1.6cm 1.8cm}}
body{{font-family:"Times New Roman",Times,serif;font-size:11pt;line-height:1.2;margin:0}}
h1{{font-size:13pt;text-align:center;margin:0 0 2pt}} .m{{text-align:center;font-size:10pt;margin-bottom:8pt}}
h2{{font-size:11pt;margin:9pt 0 3pt}} p,li{{text-align:justify;margin:0 0 3pt}} ul{{margin:0;padding-left:1.2em}}
table{{border-collapse:collapse;width:100%;font-size:9pt;margin-top:3pt}}
th,td{{padding:2pt 4pt;text-align:center}} td:nth-child(-n+2){{text-align:left}}
thead tr{{border-top:1.2pt solid #000;border-bottom:.6pt solid #000}} tbody tr:last-child{{border-bottom:1.2pt solid #000}}
tr:nth-child(3n) td{{border-bottom:.3pt solid #999}}
.cap{{font-size:9.5pt;margin-bottom:2pt}} figure{{margin:6pt 0;text-align:center;break-inside:avoid}}
figcaption{{font-size:9.5pt;text-align:center}}
</style><body>
<h1>Paso 3 — Diseño experimental y resultados</h1>
<div class="m">Angel Luis Acosta González · Máster Universitario en Sistemas Inteligentes (USAL) · Metodología de la Investigación<br>
Estimación de la calidad de transmisión (QoT) con aprendizaje automático en la red DWDM ferroviaria Moscú-Kazánskaya – Riazán</div>

<p><b>Hipótesis.</b> Un modelo de ensamble (Random Forest, XGBoost) entrenado con parámetros que el operador puede medir
predice si un canal cumple BER&nbsp;≤&nbsp;10<sup>−11</sup> con mayor acierto que un modelo lineal sencillo (regresión logística).</p>

<h2>1. Diseño experimental</h2>
<ul>
<li><b>Datos:</b> 10&nbsp;000 canales ópticos sintéticos (10&nbsp;Gbit/s NRZ, detección directa) entre pares de estaciones reales
de la línea (5–198&nbsp;km), generados con un modelo físico: balance de potencia, ruido térmico, ruido ASE de los EDFA y
dispersión cromática. Parámetros de partida del TFG (α&nbsp;=&nbsp;0,22&nbsp;dB/km, sensibilidad −25&nbsp;dBm).</li>
<li><b>Degradación:</b> 0–25 años de servicio, envejecimiento de fibra, láser y EDFA, reparaciones (solo el 60&nbsp;% registradas),
hielo y conectores sucios. <b>Etiqueta:</b> Q&nbsp;≥&nbsp;6,71 ⇔ BER&nbsp;≤&nbsp;10<sup>−11</sup>; no cumple el 20,4&nbsp;%.</li>
<li><b>Escenarios:</b> A = planificación (solo inventario); B = A + potencia recibida medida (±0,5&nbsp;dB);
C = oráculo con las causas ocultas (solo referencia).</li>
<li><b>Modelos:</b> regresión logística, Random Forest (300 árboles) y XGBoost (300 árboles), con pesos de clase.</li>
<li><b>Validación:</b> validación cruzada estratificada 10 pliegues × 3 repeticiones; prueba de McNemar sobre un 30&nbsp;% de prueba.
Clase positiva = «no cumple». Semilla fija (42): resultados reproducibles.</li>
</ul>

<h2>2. Resultados</h2>
<p>En la Tabla 1 se recogen las métricas de validación cruzada de los tres modelos en los tres escenarios:
AUC, exactitud equilibrada, sensibilidad y F1 de la clase «no cumple».</p>
<div class="cap"><b>Tabla 1.</b> Validación cruzada (media ± desviación típica). Clase positiva: canal que no cumple BER&nbsp;≤&nbsp;10<sup>−11</sup>.</div>
<table><thead><tr><th>Escenario</th><th>Modelo</th><th>AUC</th><th>Exactitud equilibrada</th><th>Sensibilidad</th><th>F1</th></tr></thead>
<tbody>{tabla}</tbody></table>
<p style="margin-top:5pt"><b>McNemar (escenario B):</b> Random Forest acierta 44 casos que la logística falla, frente a 13 al revés
(p&nbsp;=&nbsp;7·10<sup>−5</sup>); XGBoost, 54 frente a 23 (p&nbsp;=&nbsp;6·10<sup>−4</sup>).</p>

<p>La Fig. 1 representa el factor Q de cada canal frente a su longitud: los canales que no cumplen quedan por debajo del
umbral y se concentran entre 40 y 110&nbsp;km; por debajo de 40&nbsp;km cumple el 99&nbsp;%.</p>
{figura(1, "fig1_q_vs_longitud", "Factor Q de cada canal según su longitud; la línea discontinua es el umbral BER = 10<sup>−11</sup>.", "44%")}
<p>En la Fig. 2 se compara el F1 de los tres modelos en cada escenario: la mayor mejora se debe a pasar
del escenario A al B, no al cambio de modelo.</p>
{figura(2, "fig2_f1_escenarios", "F1 de la clase «no cumple» por escenario y modelo (media ± desviación típica).", "44%")}
<p>La Fig. 3 muestra cuánto empeora el AUC del Random Forest al desordenar cada variable: la potencia recibida
medida es, con diferencia, la más importante.</p>
{figura(3, "fig3_importancia", "Importancia de las variables por permutación (Random Forest, escenario B).", "44%")}

<h2>3. Interpretación</h2>
<ul>
<li><b>La hipótesis se cumple solo en parte:</b> los ensambles tienen mejor F1 y la diferencia es significativa (McNemar),
pero el AUC es igual en los tres modelos y la logística detecta más canales que fallan, a costa de más falsas alarmas.</li>
<li><b>La potencia recibida medida es la variable decisiva</b> (Fig. 3): el AUC sube de 0,98 (A) a 0,998 (B).
Monitorizar el receptor aporta más que cambiar de modelo.</li>
<li><b>Limitación:</b> los datos son sintéticos y la etiqueta sale de un modelo físico determinista, por eso la tarea resulta
fácil (AUC ≥ 0,98). Habrá que contrastarlo con datos medidos reales.</li>
</ul>
<p style="font-size:9.5pt;margin-top:6pt">Código, datos y figuras en alta resolución (PNG y PDF): archivo .zip adjunto
(<i>experimento.ipynb</i>, <i>simulador.py</i>, <i>experimento.py</i>, <i>datos/dataset.csv</i>).</p>
</body></html>"""

tmp = AQUI / "resumen-paso-3.html"
tmp.write_text(html, encoding="utf-8")
subprocess.run([CHROME, "--headless", "--no-sandbox", "--disable-gpu", "--no-pdf-header-footer",
                f"--print-to-pdf={AQUI / 'resumen-paso-3.pdf'}", tmp.as_uri()],
               check=True, capture_output=True)
tmp.unlink()
print("resumen-paso-3.pdf creado")
