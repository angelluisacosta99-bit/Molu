"""Objetivo 3: acierto en trayectos y condiciones no vistos en el entrenamiento.

1) Validación cruzada agrupada por trayecto (StratifiedGroupKFold, 10 pliegues): el grupo es la
   longitud del canal, que identifica el par de estaciones (pares con la misma longitud quedan en el
   mismo grupo, lo que hace la prueba más exigente). Escenarios A y B.
2) Extrapolación en el escenario B: entrenar con canales de hasta 15 años y evaluar con los de más
   de 15; entrenar con T >= -5 °C (sin hielo) y evaluar con T < -5 °C.
Usa los mismos datos y modelos que experimento.py. Escribe resultados/no_vistos.txt.
"""
import sys
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.metrics import f1_score, recall_score, roc_auc_score
from sklearn.model_selection import StratifiedGroupKFold, cross_validate

AQUI = Path(__file__).parent
EXP = AQUI.parent / "paso-3-experimento"
sys.path.insert(0, str(EXP))
import simulador as sim  # noqa: E402

df = pd.read_csv(EXP / "datos" / "dataset.csv")
y = 1 - df["cumple"].values
SEMILLA = 42


def modelos():
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.linear_model import LogisticRegression
    from sklearn.pipeline import make_pipeline
    from sklearn.preprocessing import StandardScaler
    from xgboost import XGBClassifier
    peso = (1 - y.mean()) / y.mean()
    return {
        "Regresión logística": make_pipeline(StandardScaler(), LogisticRegression(max_iter=2000, class_weight="balanced")),
        "Random Forest": RandomForestClassifier(n_estimators=300, min_samples_leaf=2, class_weight="balanced",
                                                random_state=SEMILLA, n_jobs=-1),
        "XGBoost": XGBClassifier(n_estimators=300, max_depth=4, learning_rate=0.1, subsample=0.9,
                                 scale_pos_weight=peso, random_state=SEMILLA, n_jobs=-1, eval_metric="logloss"),
    }


lineas = []
cv = StratifiedGroupKFold(n_splits=10, shuffle=True, random_state=SEMILLA)
grupos = df["longitud_km"].values
for esc, vars_ in [("A", sim.VARIABLES_PLANIFICACION), ("B", sim.VARIABLES_MONITORIZACION)]:
    X = df[vars_].values
    for nombre, m in modelos().items():
        r = cross_validate(m, X, y, groups=grupos, cv=cv, scoring={"auc": "roc_auc", "f1": "f1", "sens": "recall"})
        lineas.append(f"Agrupada por trayecto | {esc} | {nombre}: AUC {r['test_auc'].mean():.3f} ± {r['test_auc'].std():.3f}; "
                      f"F1 {r['test_f1'].mean():.3f} ± {r['test_f1'].std():.3f}; sensibilidad {r['test_sens'].mean():.3f}")

Xb = df[sim.VARIABLES_MONITORIZACION].values
for etiqueta, entreno in [("Antigüedad: entrena <=15 años, evalúa >15", df["antiguedad_anios"] <= 15),
                          ("Temperatura: entrena >=-5 °C, evalúa <-5 °C", df["temperatura_c"] >= -5)]:
    tr, te = entreno.values, ~entreno.values
    for nombre, m in modelos().items():
        m.fit(Xb[tr], y[tr])
        p = m.predict_proba(Xb[te])[:, 1]
        lineas.append(f"Extrapolación B | {etiqueta} | {nombre}: AUC {roc_auc_score(y[te], p):.3f}; "
                      f"F1 {f1_score(y[te], p >= 0.5):.3f}; sensibilidad {recall_score(y[te], p >= 0.5):.3f} "
                      f"(n evaluación = {te.sum()})")

(AQUI / "resultados").mkdir(exist_ok=True)
(AQUI / "resultados" / "no_vistos.txt").write_text("\n".join(lineas) + "\n", encoding="utf-8")
print("\n".join(lineas))
