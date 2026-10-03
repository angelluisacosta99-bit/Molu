"""Dos análisis de robustez del escenario B para el trabajo final (mejora del artículo del Paso 5).

1) Sensibilidad al ruido de medida de la potencia recibida. El dataset ya trae la potencia medida con
   error gaussiano σ = 0,5 dB; para simular un medidor peor se le suma un error independiente adicional
   N(0, √(σ² − 0,5²)), de modo que el error total tenga desviación σ = 1,0; 1,5 y 2,0 dB. La etiqueta
   (cumple / no cumple) no cambia: depende del Q real. Mismo protocolo que experimento.py
   (10 pliegues × 3 repeticiones) y errores en el 30 % de prueba.
2) Umbral de decisión. Con σ = 0,5 dB y la misma partición 70/30 que experimento.py: falsos negativos
   y falsas alarmas para umbrales 0,1-0,9 y, para un punto de operación elegido sin mirar la prueba,
   el umbral que en validación cruzada sobre el entrenamiento iguala la sensibilidad de la logística.
Escribe resultados/sensibilidad.txt.
"""
import sys
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.model_selection import (RepeatedStratifiedKFold, StratifiedKFold, cross_val_predict,
                                     cross_validate, train_test_split)

AQUI = Path(__file__).parent
EXP = AQUI.parent / "paso-3-experimento"
sys.path.insert(0, str(EXP))
import simulador as sim  # noqa: E402

SEMILLA = 42
df = pd.read_csv(EXP / "datos" / "dataset.csv")
y = 1 - df["cumple"].values                      # positiva = no cumple


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


def errores(p, verdad, umbral=0.5):
    pred = p >= umbral
    return int(np.sum(~pred & (verdad == 1))), int(np.sum(pred & (verdad == 0)))   # (FN, FP)


lineas = ["# 1) Sensibilidad al ruido de medida de la potencia recibida (escenario B)",
          "sigma_dB | modelo | AUC (CV) | F1 (CV) | sensibilidad (CV) | prueba: FN, FP, errores"]
cv = RepeatedStratifiedKFold(n_splits=10, n_repeats=3, random_state=SEMILLA)
rng = np.random.default_rng(SEMILLA)
extra = rng.normal(0, 1, len(df))                # mismo ruido base para todos los σ (comparación pareada)
for sigma in (0.5, 1.0, 1.5, 2.0):
    d = df.copy()
    d["p_rx_medida_dbm"] = df["p_rx_medida_dbm"] + extra * np.sqrt(sigma**2 - 0.5**2)
    X = d[sim.VARIABLES_MONITORIZACION].values
    Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=0.3, stratify=y, random_state=SEMILLA)
    for nombre, m in modelos().items():
        r = cross_validate(m, X, y, cv=cv, scoring={"auc": "roc_auc", "f1": "f1", "sens": "recall"})
        fn, fp = errores(m.fit(Xtr, ytr).predict_proba(Xte)[:, 1], yte)
        lineas.append(f"{sigma:.1f} | {nombre} | {r['test_auc'].mean():.3f} ± {r['test_auc'].std():.3f} | "
                      f"{r['test_f1'].mean():.3f} ± {r['test_f1'].std():.3f} | {r['test_sens'].mean():.3f} | "
                      f"{fn}, {fp}, {fn + fp}")
        print(lineas[-1])

lineas += ["", "# 2) Umbral de decisión (escenario B, σ = 0,5 dB, 30 % de prueba: "
           f"{int((train_test_split(y, test_size=0.3, stratify=y, random_state=SEMILLA)[1] == 1).sum())} canales que no cumplen)",
           "umbral | " + " | ".join(f"{k}: FN, FP" for k in modelos())]
X = df[sim.VARIABLES_MONITORIZACION].values
Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=0.3, stratify=y, random_state=SEMILLA)
prob, oof = {}, {}
for nombre, m in modelos().items():
    oof[nombre] = cross_val_predict(m, Xtr, ytr, cv=StratifiedKFold(5, shuffle=True, random_state=SEMILLA),
                                    method="predict_proba")[:, 1]
    prob[nombre] = m.fit(Xtr, ytr).predict_proba(Xte)[:, 1]
for u in np.round(np.arange(0.1, 0.91, 0.1), 1):
    lineas.append(f"{u:.1f} | " + " | ".join("{}, {}".format(*errores(prob[k], yte, u)) for k in prob))

objetivo = np.mean(oof["Regresión logística"][ytr == 1] >= 0.5)   # sensibilidad de la logística con umbral 0,5
lineas += ["", "Punto de operación elegido en el entrenamiento (CV de 5 pliegues): mayor umbral con la misma "
           f"sensibilidad que la logística con umbral 0,5 ({objetivo:.3f})",
           "modelo | umbral | prueba: FN, FP, errores"]
for k in prob:
    u = max(u for u in np.round(np.arange(0.0, 0.991, 0.01), 2) if np.mean(oof[k][ytr == 1] >= u) >= objetivo)
    fn, fp = errores(prob[k], yte, u)
    lineas.append(f"{k} | {u:.2f} | {fn}, {fp}, {fn + fp}")

(AQUI / "resultados").mkdir(exist_ok=True)
(AQUI / "resultados" / "sensibilidad.txt").write_text("\n".join(lineas) + "\n", encoding="utf-8")
print("\n".join(lineas))
