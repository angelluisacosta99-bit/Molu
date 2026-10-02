"""Experimento del Paso 3: ¿predice un modelo de ensamble el cumplimiento de
BER <= 1e-11 mejor que un modelo lineal sencillo?

Genera: datos/dataset.csv, resultados/tabla_resultados.csv y .tex, resultados/mcnemar.txt,
figuras/fig1_q_vs_longitud, fig2_f1_escenarios, fig3_importancia (PNG y PDF).
Uso:  python experimento.py
"""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy.stats import chi2
from sklearn.ensemble import RandomForestClassifier
from sklearn.inspection import permutation_importance
from sklearn.linear_model import LogisticRegression

from sklearn.model_selection import RepeatedStratifiedKFold, cross_validate, train_test_split
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from xgboost import XGBClassifier

import simulador as sim

AQUI = Path(__file__).parent
for carpeta in ("datos", "resultados", "figuras"):
    (AQUI / carpeta).mkdir(exist_ok=True)

SEMILLA = 42
AZUL, NARANJA, VERDE = "#2a78d6", "#eb6834", "#1baf7a"   # paleta distinguible con daltonismo
TINTA, GRIS = "#1f1f1e", "#8a8a85"
plt.rcParams.update({"pdf.fonttype": 42, "font.family": "serif", "font.size": 9, "axes.edgecolor": GRIS,
                     "axes.labelcolor": TINTA, "xtick.color": TINTA, "ytick.color": TINTA,
                     "axes.spines.top": False, "axes.spines.right": False})

# 1. Datos ---------------------------------------------------------------
df = sim.generar(n=10000, semilla=SEMILLA)
df.to_csv(AQUI / "datos" / "dataset.csv", index=False)
# Etiqueta positiva = "no cumple": lo que interesa al operador es detectar los canales en riesgo.
y = 1 - df["cumple"].values
print(f"Canales: {len(df)} | no cumplen: {y.mean():.1%}")


def modelos():
    peso = (1 - y.mean()) / y.mean()
    return {
        "Regresión logística": make_pipeline(StandardScaler(), LogisticRegression(max_iter=2000, class_weight="balanced")),
        "Random Forest": RandomForestClassifier(n_estimators=300, min_samples_leaf=2, class_weight="balanced",
                                                random_state=SEMILLA, n_jobs=-1),
        "XGBoost": XGBClassifier(n_estimators=300, max_depth=4, learning_rate=0.1, subsample=0.9,
                                 scale_pos_weight=peso, random_state=SEMILLA, n_jobs=-1, eval_metric="logloss"),
    }


ESCENARIOS = {
    "A: planificación": sim.VARIABLES_PLANIFICACION,
    "B: monitorización": sim.VARIABLES_MONITORIZACION,
    "C: oráculo (con variables ocultas)": sim.VARIABLES_MONITORIZACION + [
        "oculta_perdida_reparaciones_db", "oculta_perdida_hielo_db", "oculta_perdida_conectores_db", "oculta_nf_db", "oculta_alfa_db_km"],
}

# 2. Validación cruzada estratificada repetida (10 pliegues x 3) ----------
cv = RepeatedStratifiedKFold(n_splits=10, n_repeats=3, random_state=SEMILLA)
metricas = {"AUC": "roc_auc", "Exactitud equilibrada": "balanced_accuracy",
            "Sensibilidad (no cumple)": "recall", "F1 (no cumple)": "f1"}
filas = []
for esc, vars_ in ESCENARIOS.items():
    X = df[vars_].values
    for nombre, modelo in modelos().items():
        r = cross_validate(modelo, X, y, cv=cv, scoring=metricas, n_jobs=1)
        fila = {"Escenario": esc, "Modelo": nombre}
        for m in metricas:
            v = r["test_" + m]
            fila[m] = f"{v.mean():.3f} ± {v.std():.3f}"
            fila[m + "_media"] = v.mean()
        filas.append(fila)
        print(esc, "|", nombre, "| AUC", fila["AUC"], "| F1", fila["F1 (no cumple)"])
tabla = pd.DataFrame(filas)
tabla.to_csv(AQUI / "resultados" / "tabla_resultados.csv", index=False)
cols = ["Escenario", "Modelo"] + list(metricas)
tabla[cols].to_latex(AQUI / "resultados" / "tabla_resultados.tex", index=False,
                     caption="Resultados de la validación cruzada estratificada (10 pliegues × 3 repeticiones), media ± desviación típica. Clase positiva: canal que no cumple BER $\\leq 10^{-11}$.",
                     label="tab:resultados")

# 3. Prueba de McNemar (Random Forest vs regresión logística, escenario B) --
Xb = df[sim.VARIABLES_MONITORIZACION].values
Xtr, Xte, ytr, yte = train_test_split(Xb, y, test_size=0.3, stratify=y, random_state=SEMILLA)
m = modelos()
pred = {k: m[k].fit(Xtr, ytr).predict(Xte) for k in m}


def mcnemar(a, b, verdad):
    ok_a, ok_b = a == verdad, b == verdad
    n01, n10 = np.sum(ok_a & ~ok_b), np.sum(~ok_a & ok_b)
    est = (abs(n01 - n10) - 1) ** 2 / (n01 + n10) if n01 + n10 else 0.0
    return n01, n10, est, 1 - chi2.cdf(est, 1)


with open(AQUI / "resultados" / "mcnemar.txt", "w", encoding="utf-8") as f:
    for otro in ("Random Forest", "XGBoost"):
        n01, n10, est, p = mcnemar(pred[otro], pred["Regresión logística"], yte)
        linea = (f"{otro} vs Regresión logística (escenario B, test 30 %): "
                 f"solo acierta {otro}: {n01}; solo acierta la logística: {n10}; "
                 f"chi2 = {est:.2f}; p = {p:.2e}")
        print(linea)
        f.write(linea + "\n")

# 4. Figuras ---------------------------------------------------------------
# Fig. 1: factor Q frente a la longitud, por clase
fig, ax = plt.subplots(figsize=(3.4, 2.5))
for clase, color, marca, etiqueta in [(1, AZUL, "o", "Cumple"), (0, NARANJA, "^", "No cumple")]:
    s = df[df.cumple == clase].sample(1500, random_state=SEMILLA, replace=False) if (df.cumple == clase).sum() > 1500 else df[df.cumple == clase]
    ax.scatter(s.longitud_km, s.q, s=6, marker=marca, color=color, alpha=0.55, linewidths=0, label=etiqueta)
ax.axhline(sim.Q_UMBRAL, color=TINTA, lw=1, ls="--", label="Umbral Q = 6,71\n(BER = 10$^{-11}$)")
ax.set_yscale("log"); ax.set_ylim(0.1, 4000)  # margen arriba para que la leyenda no tape puntos
ax.set_xlabel("Longitud del canal (km)"); ax.set_ylabel("Factor Q")
ax.legend(frameon=False, fontsize=7, loc="upper right", markerscale=2)
fig.tight_layout()
for ext in ("png", "pdf"):
    fig.savefig(AQUI / "figuras" / f"fig1_q_vs_longitud.{ext}", dpi=300,
                metadata={"CreationDate": None} if ext == "pdf" else None)
plt.close(fig)

# Fig. 2: F1 de la clase "no cumple" por escenario y modelo (media ± desviación típica en la CV)
fig, ax = plt.subplots(figsize=(3.4, 2.6))
etiquetas = ["A: planificación", "B: monitorización", "C: oráculo"]
for k, (nombre, color, marca) in enumerate([("Regresión logística", NARANJA, "s"), ("Random Forest", AZUL, "o"), ("XGBoost", VERDE, "^")]):
    sub = tabla[tabla.Modelo == nombre]
    medias = sub["F1 (no cumple)_media"].values
    desv = [float(v.split("± ")[1]) for v in sub["F1 (no cumple)"]]
    ax.errorbar(np.arange(3) + (k - 1) * 0.18, medias, yerr=desv, fmt=marca, color=color, ms=6,
                capsize=2, lw=1, label=nombre)
ax.set_xticks(range(3)); ax.set_xticklabels(etiquetas, fontsize=7)
ax.set_xlabel("Escenario"); ax.set_ylabel("F1 (clase «no cumple»)"); ax.set_ylim(0.78, 1.0)
ax.grid(axis="y", color="#e6e6e3", lw=0.6); ax.set_axisbelow(True)
ax.legend(frameon=False, fontsize=7, loc="lower right")
fig.tight_layout()
for ext in ("png", "pdf"):
    fig.savefig(AQUI / "figuras" / f"fig2_f1_escenarios.{ext}", dpi=300,
                metadata={"CreationDate": None} if ext == "pdf" else None)
plt.close(fig)

# Fig. 3: importancia por permutación (Random Forest, escenario B)
imp = permutation_importance(m["Random Forest"], Xte, yte, scoring="roc_auc", n_repeats=10, random_state=SEMILLA)
nombres = {"longitud_km": "Longitud", "amplificado": "Amplificado", "n_vanos": "N.º de vanos",
           "antiguedad_anios": "Antigüedad", "reparaciones_registradas": "Reparaciones",
           "temperatura_c": "Temperatura", "p_rx_medida_dbm": "Potencia recibida"}
orden = np.argsort(imp.importances_mean)
fig, ax = plt.subplots(figsize=(3.6, 2.4))
ax.barh([nombres[sim.VARIABLES_MONITORIZACION[i]] for i in orden], imp.importances_mean[orden],
        xerr=imp.importances_std[orden], color=AZUL, height=0.6, error_kw={"ecolor": GRIS, "lw": 1})
ax.set_xlabel("Caída de AUC al permutar")
fig.tight_layout()
for ext in ("png", "pdf"):
    fig.savefig(AQUI / "figuras" / f"fig3_importancia.{ext}", dpi=300,
                metadata={"CreationDate": None} if ext == "pdf" else None)
plt.close(fig)
print("Listo: datos/, resultados/ y figuras/ generados.")
