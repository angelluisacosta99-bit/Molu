"""Generador de datos sintéticos de calidad de transmisión (QoT) para la red
DWDM ferroviaria Moscú-Kazánskaya – Riazán-1.

Cada fila es un canal óptico (lightpath) de 10 Gbit/s NRZ-OOK con detección
directa (IM/DD) entre dos estaciones de la red. El modelo físico es un
balance de potencia más ruido del receptor y de los amplificadores EDFA:

  potencia recibida = potencia del láser - pérdidas (fibra, empalmes,
                      conectores, OADM, incidencias por hielo)
  Q térmico  : receptor limitado por ruido térmico (Q proporcional a la
               potencia recibida en lineal)
  Q ASE      : si el canal va amplificado (EDFA cada <= 110 km, vanos
               iguales), ruido de emisión espontánea amplificada con la
               OSNR acumulada de todos los vanos (0,1 nm)
  penalización de dispersión cromática (tramos sin compensar)
  cumple = Q_efectivo >= 6,71  (equivale a BER <= 1e-11)

Parámetros de partida tomados del trabajo de fin de grado (RUT MIIT, 2026):
distancias entre estaciones, alfa = 0,22 dB/km, empalmes cada 4 km de
0,1 dB, sensibilidad del receptor -25 dBm, figura de ruido del EDFA 6-9 dB.
Los rangos de degradación (envejecimiento, reparaciones, hielo) son
supuestos del estudio y se documentan en los comentarios de la función
generar(). Simplificación:
la pérdida de OADM (5 dB) se aplica igual a todos los canales, con
independencia de cuántos OADM atraviesen.
"""

import numpy as np
import pandas as pd
from scipy.special import erfc

# Distancias kilométricas de las estaciones (tabla de estaciones del TFG).
# Se omite Rýbnoye (MRC-1) porque su kilómetro no se lee en la tabla.
ESTACIONES_KM = [0.0, 10.6, 21.1, 33.4, 45.5, 56.9, 67.2, 71.8, 89.4, 93.8,
                 101.9, 116.9, 122.3, 136.4, 145.8, 152.9, 158.9, 169.2,
                 180.4, 192.4, 198.3]

# Constantes del diseño (TFG y fichas técnicas)
ALFA_NOMINAL = 0.22          # dB/km, fibra G.652 a 1550 nm
LONG_CONSTRUCCION = 4.0      # km entre empalmes de fábrica
PERDIDA_EMPALME = 0.1        # dB por empalme nominal
PERDIDA_CONECTORES = 1.0     # dB (dos conectores)
PERDIDA_OADM = 5.0           # dB (multiplexor + demultiplexor)
SENSIBILIDAD = -25.0         # dBm, receptor
Q_SENSIBILIDAD = 7.03        # Q en la sensibilidad (BER 1e-12)
Q_UMBRAL = 6.71              # Q para BER = 1e-11
MARGEN_DISENO = 3.0          # dB: si el margen nominal es menor, se pone preamplificador EDFA
DISPERSION = 17.0            # ps/(nm·km)
TOLERANCIA_DISP = 1600.0     # ps/nm tolerados por el transceptor ZR
BO_BE = 12.5 / 7.5           # ancho óptico (0,1 nm) / ancho eléctrico


def ber_desde_q(q):
    return 0.5 * erfc(q / np.sqrt(2))


def q_termico(p_rx_dbm):
    return Q_SENSIBILIDAD * 10 ** ((p_rx_dbm - SENSIBILIDAD) / 10)


def q_ase(osnr_db):
    osnr = 10 ** (osnr_db / 10)
    return np.sqrt(BO_BE) * 2 * osnr / (1 + np.sqrt(1 + 4 * osnr))


def perdida_nominal(d_km):
    empalmes = np.ceil(d_km / LONG_CONSTRUCCION)
    return ALFA_NOMINAL * d_km + empalmes * PERDIDA_EMPALME + PERDIDA_CONECTORES + PERDIDA_OADM


def generar(n=10000, semilla=42):
    """Genera n canales con su estado de degradación y la etiqueta cumple/no cumple."""
    rng = np.random.default_rng(semilla)
    km = np.array(ESTACIONES_KM)
    pares = [(i, j) for i in range(len(km)) for j in range(i + 1, len(km)) if km[j] - km[i] >= 5]
    idx = rng.integers(len(pares), size=n)
    d = np.array([km[pares[k][1]] - km[pares[k][0]] for k in idx])

    # --- Diseño (el día de la instalación) ---
    amplificado = (-perdida_nominal(d) - SENSIBILIDAD) < MARGEN_DISENO   # regla de diseño con margen fijo

    # --- Estado de explotación (variables observables por el operador) ---
    antiguedad = rng.uniform(0, 25, n)                        # años en servicio
    temperatura = rng.uniform(-30, 35, n)                     # °C, clima de Riazán
    tasa_rep = rng.uniform(0.002, 0.015, n)                   # averías por km y año (oculta)
    rep_reales = rng.poisson(tasa_rep * d * antiguedad)
    rep_registradas = rng.binomial(rep_reales, 0.6)           # muchas averías no quedan registradas

    # --- Causas físicas ocultas ---
    alfa = (ALFA_NOMINAL
            + rng.uniform(0.0, 0.0015, n) * antiguedad         # envejecimiento de la fibra
            + 0.0002 * np.maximum(0, -temperatura) / 10)       # ligero aumento con frío
    empalmes_fab = np.ceil(d / LONG_CONSTRUCCION)
    perd_empalmes = empalmes_fab * rng.normal(PERDIDA_EMPALME, 0.02, n).clip(0.03)
    perd_reparaciones = np.array([rng.uniform(0.05, 0.5, 2 * r).sum() for r in rep_reales])
    hielo = (temperatura < -5) & (rng.random(n) < 0.30)       # microcurvaturas por hielo
    perd_hielo = np.where(hielo, rng.uniform(0.5, 5.0, n), 0.0)
    p_laser = rng.normal(0.0, 0.3, n) - rng.uniform(0.0, 0.1, n) * antiguedad   # el láser envejece
    nf = rng.uniform(6.0, 7.0, n) + rng.uniform(0.0, 0.08, n) * antiguedad      # el EDFA envejece
    disp_residual = rng.uniform(-250, 250, n)                 # ps/nm tras compensar (tramos amplificados)

    perd_conectores = PERDIDA_CONECTORES + rng.exponential(0.4, n)   # conectores sucios o dañados
    perdida = (alfa * d + perd_empalmes + perd_reparaciones + perd_hielo
               + perd_conectores + PERDIDA_OADM)
    # Los canales amplificados llevan un EDFA cada <= 110 km (vanos iguales);
    # p_rx es la potencia a la entrada de cada amplificador o del receptor.
    n_vanos = np.where(amplificado, np.ceil(d / 110.0), 1)
    p_rx = p_laser - perdida / n_vanos

    # --- Calidad de transmisión ---
    q_t = q_termico(p_rx)
    osnr = 58.0 + p_rx - nf - 10 * np.log10(n_vanos)          # OSNR acumulada (0,1 nm)
    q_a = q_ase(osnr)
    q_amp = 1 / np.sqrt(1 / q_a**2 + 1 / (Q_SENSIBILIDAD * 10) ** 2)  # el preamplificador eleva la señal
    q = np.where(amplificado, q_amp, q_t)
    disp_acum = np.where(amplificado, np.abs(disp_residual), DISPERSION * d)
    penal_disp = 2.0 * (disp_acum / TOLERANCIA_DISP) ** 2      # dB
    q_ef = q * 10 ** (-penal_disp / 10)

    p_rx_medida = p_rx + rng.normal(0, 0.5, n)                 # monitorización DDM del SFP (±0,5 dB)

    return pd.DataFrame({
        # observables
        "longitud_km": d.round(1),
        "amplificado": amplificado.astype(int),
        "n_vanos": n_vanos.astype(int),
        "antiguedad_anios": antiguedad.round(2),
        "reparaciones_registradas": rep_registradas,
        "temperatura_c": temperatura.round(1),
        "p_rx_medida_dbm": p_rx_medida.round(2),
        # ocultas (no se dan a los modelos)
        "oculta_perdida_reparaciones_db": perd_reparaciones.round(3),
        "oculta_perdida_hielo_db": perd_hielo.round(3),
        "oculta_perdida_conectores_db": perd_conectores.round(3),
        "oculta_nf_db": nf.round(2),
        "oculta_alfa_db_km": alfa.round(4),
        # resultado físico
        "q": q_ef.round(3),
        "ber": ber_desde_q(q_ef),
        "cumple": (q_ef >= Q_UMBRAL).astype(int),
    })


# Variables observables de los escenarios A y B (el C añade las ocultas en experimento.py)
VARIABLES_PLANIFICACION = ["longitud_km", "amplificado", "n_vanos", "antiguedad_anios",
                           "reparaciones_registradas", "temperatura_c"]
VARIABLES_MONITORIZACION = VARIABLES_PLANIFICACION + ["p_rx_medida_dbm"]


if __name__ == "__main__":
    df = generar()
    print(df.describe().T[["mean", "min", "max"]])
    print("Proporción que cumple:", df.cumple.mean().round(3))
    print(df.groupby("amplificado").cumple.agg(["mean", "size"]))
