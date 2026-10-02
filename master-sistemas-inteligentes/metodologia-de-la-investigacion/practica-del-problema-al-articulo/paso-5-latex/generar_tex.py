"""Genera articulo/main.tex (plantilla LNCS) a partir de ../paso-4-redaccion/contenido.py.
El texto vive en un solo sitio (el borrador del Paso 4, ya entregado y que no se toca); las mejoras
propias del artículo final van en CAMBIOS y RESUMEN, más abajo.
Uso: python generar_tex.py   (después, subir la carpeta articulo/ a Overleaf o compilar con latexmk -pdf main.tex)"""
import re
import shutil
import sys
from pathlib import Path

AQUI = Path(__file__).parent
BASE = AQUI.parent
sys.path.insert(0, str(BASE / "paso-4-redaccion"))
from contenido import BLOQUES, TABLA_RESULTADOS, TABLA_VARIABLES  # noqa: E402

OUT = AQUI / "articulo"

# Firma normalizada (recomendación FECYT: apellidos unidos con guion, segundo nombre en inicial)
AUTOR = "Angel L. Acosta-González"
INSTITUCION = (r"Máster Universitario en Sistemas Inteligentes, Universidad de Salamanca\\"
               r"Plaza de los Caídos s/n, 37008 Salamanca, España")
EMAIL = ""  # correo institucional @usal.es; vacío = no se imprime \email

# Resumen del artículo: 100-150 palabras para cumplir a la vez el Paso 4 (100-200) y typeinst (70-150)
RESUMEN = (
    "La calidad de transmisión (QoT) de las redes DWDM ferroviarias suele verificarse una sola vez, en el "
    "diseño, con márgenes fijos. Este trabajo evalúa si un modelo de aprendizaje automático entrenado con "
    "parámetros observables de los enlaces predice si cada canal cumple el umbral BER ≤ 10<sup>−11</sup> cuando "
    "la red se degrada. Se generaron 10 000 canales sintéticos de la red Moscú-Kazánskaya – Riazán con un modelo "
    "físico que incluye envejecimiento, reparaciones y hielo, y se compararon una regresión logística, Random "
    "Forest y XGBoost en tres escenarios de información. Con la potencia recibida medida, la variable decisiva, "
    "los tres modelos alcanzan un AUC de 0,998; los ensambles obtienen mayor F1 (0,947 frente a 0,931) y cometen "
    "menos errores (McNemar, p ≤ 0,0013 tras Bonferroni), aunque la regresión logística detecta más canales que no cumplen. La "
    "hipótesis se confirma con matices y debe contrastarse con datos reales."
)

# Mejoras del artículo respecto al borrador del Paso 4 (texto original -> texto del artículo)
CAMBIOS = {
    "Cada canal une dos de las 21 estaciones de la línea, a una distancia <i>d</i> de entre 5,4 y 198,3 km "
    "(208 pares posibles; se omite una estación cuyo punto kilométrico no consta en [1]), y transmite":
    "Cada canal une dos de las 21 estaciones de la línea con punto kilométrico conocido (de las 22 de [1], una "
    "no lo tiene) separadas al menos 5 km, lo que da 208 pares posibles a una distancia <i>d</i> de entre 5,4 y "
    "198,3 km, y transmite",
    "El código y los datos, incluido este análisis, están disponibles como material complementario.":
    "El código en Python y el conjunto de datos, incluido este análisis, se adjuntan a este artículo como "
    "material complementario.",
    "<i>P</i><sub>rx</sub> = <i>P</i><sub>tx</sub> − <i>L</i>/<i>n</i> es la":
    "$P_{\\mathrm{rx}} = P_{\\mathrm{tx}} - L/n$ es la",
    "En los amplificados domina el ruido de emisión espontánea amplificada (ASE).":
    "En los canales amplificados domina el ruido de emisión espontánea amplificada (ASE).",
    "cualquiera de los tres modelos supera ampliamente a la estimación con datos de inventario.":
    "cualquiera de los tres modelos alcanza un F1 de 0,93–0,95, frente a 0,83–0,85 con solo datos de inventario.",
}

# Orden de la lista de referencias del borrador -> claves de referencias.bib
CLAVES = ["acosta2026tfg", "pointurier2021", "samadi2017", "rottondi2018", "morais2018", "kozdrowski2021",
          "aladin2020", "allogba2022", "yu2019", "igarashi2024", "dicicco2023"]

ECUACIONES = {
    1: r"L_{\mathrm{nom}} = \alpha d + 0{,}1\left\lceil d/4 \right\rceil + 1 + 5 \quad [\mathrm{dB}] .",
    2: r"Q_t = 7{,}03 \cdot 10^{(P_{\mathrm{rx}} + 25)/10} .",
    3: r"\mathrm{OSNR} = 58 + P_{\mathrm{rx}} - \mathrm{NF} - 10\log_{10} n \quad [\mathrm{dB}] ,",
    4: r"Q_{\mathrm{ASE}} = \sqrt{\frac{B_o}{B_e}}\,\frac{2\,\mathrm{OSNR}}{1 + \sqrt{1 + 4\,\mathrm{OSNR}}} ,",
    5: r"Q_{\mathrm{amp}} = \left(Q_{\mathrm{ASE}}^{-2} + (10 \cdot 7{,}03)^{-2}\right)^{-1/2} .",
    6: r"\mathrm{BER} = \tfrac{1}{2}\,\mathrm{erfc}\!\left(Q/\sqrt{2}\right) ,",
}
FIGURAS = {"fig1_q_vs_longitud": "fig:q", "fig2_f1_escenarios": "fig:f1", "fig3_importancia": "fig:importancia"}
TABLAS = {1: "tab:variables", 2: "tab:resultados"}

PREAMBULO = r"""\documentclass[runningheads]{llncs}

\usepackage[T1]{fontenc}
\usepackage[spanish,es-tabla]{babel}
\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{array}  %% columnas de texto alineadas a la izquierda en las tablas
\usepackage{flafter}  %% ninguna figura o tabla aparece antes del párrafo que la cita

%% Figuras y tablas como flotantes [htbp] (pauta de Springer): se escriben justo
%% después del párrafo que las cita y LaTeX las coloca en esa página o la siguiente.
\renewcommand{\topfraction}{0.9}
\renewcommand{\bottomfraction}{0.8}
\renewcommand{\textfraction}{0.07}
\renewcommand{\floatpagefraction}{0.8}
\makeatletter
\setlength{\@fptop}{0pt}
\setlength{\@fpsep}{12pt plus 1fil}
\makeatother

%% Nombres de la plantilla LNCS en español (babel los cambiaría a «Figura»)
\addto\captionsspanish{\def\abstractname{Resumen.}\def\figurename{Fig.}}
\def\keywordname{\textbf{Palabras clave:}}
\newcommand{\keywords}[1]{\par\addvspace\baselineskip\noindent\keywordname\enspace\ignorespaces#1}

%% Símbolos que se escriben tal cual en el texto
\DeclareUnicodeCharacter{2212}{\textminus}
\DeclareUnicodeCharacter{2264}{\ensuremath{\leq}}
\DeclareUnicodeCharacter{2265}{\ensuremath{\geq}}
\DeclareUnicodeCharacter{2248}{\ensuremath{\approx}}
\DeclareUnicodeCharacter{2713}{\ensuremath{\checkmark}}
\DeclareUnicodeCharacter{03C7}{\ensuremath{\chi}}
\DeclareUnicodeCharacter{03C3}{\ensuremath{\sigma}}
\DeclareUnicodeCharacter{03B1}{\ensuremath{\alpha}}

\begin{document}
\mainmatter

\title{%(titulo)s}
\titlerunning{QoT con aprendizaje automático en una red DWDM ferroviaria}
\author{%(autor)s}
\authorrunning{%(autor)s}
\institute{%(institucion)s}
\maketitle

\begin{abstract}
%(resumen)s
\keywords{%(claves)s}
\end{abstract}
"""


def texto(t):
    """HTML ligero del borrador -> LaTeX."""
    t = t.replace("%", r"\%").replace("&", r"\&")
    t = re.sub(r"(\d) \\%", r"\1~\\%", t)
    t = re.sub(r"<i>(.*?)</i>", r"\\emph{\1}", t)
    t = re.sub(r"<b>(.*?)</b>", r"\\textbf{\1}", t)
    t = re.sub(r"<sup>(.*?)</sup>", r"\\textsuperscript{\1}", t)
    t = re.sub(r"<sub>(.*?)</sub>", r"\\textsubscript{\1}", t)
    t = t.replace("<br>", r" \\ ").replace(" < ", r" $<$ ")
    # Citas [1], [2]... -> \cite{clave}
    t = re.sub(r"\[(\d+)\]", lambda m: r"~\cite{" + CLAVES[int(m.group(1)) - 1] + "}", t)
    t = t.replace(" ~\\cite", "~\\cite")
    # Referencias cruzadas: tablas, figuras, secciones y ecuaciones con \ref
    t = re.sub(r"Tabla (\d)", lambda m: r"Tabla~\ref{" + TABLAS[int(m.group(1))] + "}", t)
    t = re.sub(r"Fig\. (\d)", lambda m: r"Fig.~\ref{" + list(FIGURAS.values())[int(m.group(1)) - 1] + "}", t)
    t = re.sub(r"sección (\d)", r"sección~\\ref{sec:\1}", t)
    t = t.replace("ecs. 2–5", r"ecs.~(\ref{eq:2})--(\ref{eq:5})")
    t = re.sub(r"ec\. \((\d)\)", r"ec.~(\\ref{eq:\1})", t)
    t = t.replace("señal/ruido", r"señal/\allowbreak ruido")
    # espacios irrompibles: número-unidad, «p < x», «BER ≤ 10», «Voskresensk – Riazán»
    t = re.sub(r"(\d) (GHz|Gbit/s|dBm|dB|km|ps/nm|nm|°C|años)\b", r"\1~\2", t)
    t = t.replace("p $<$ ", "p~$<$~").replace("p ≤ ", "p~≤~").replace("BER ≤ ", "BER~≤~")
    t = t.replace("Q ≥ ", "Q~≥~").replace("Voskresensk – ", "Voskresensk~– ")
    t = t.replace("·", r"\textperiodcentered{}").replace("½", r"\textonehalf{}")
    return t


def tabla(pie, filas, etiqueta):
    pie = re.sub(r"<b>Tabla \d\.</b>\s*", "", pie)
    if etiqueta == "tab:variables":
        cols, tam = r">{\raggedright\arraybackslash}p{3.1cm}>{\raggedright\arraybackslash}p{5.4cm}ccc", r"\footnotesize"
    else:
        cols, tam = "llcccc", r"\footnotesize\setlength{\tabcolsep}{3.5pt}"
        filas = [["Esc.", "Modelo", "AUC", "Exact. equil.", "Sensib.", "F1"]] + \
                [[f[0], f[1].replace("Regresión logística", "Reg. logística")] + f[2:] for f in filas[1:]]
        pie += " Esc.: escenario; Exact. equil.: exactitud equilibrada; Sensib.: sensibilidad."
    lineas = [r"\begin{table}[htbp]", r"\centering", tam, r"\caption{" + texto(pie) + "}",
              r"\label{" + etiqueta + "}", r"\begin{tabular}{" + cols + "}", r"\toprule",
              " & ".join(texto(c) for c in filas[0]) + r" \\", r"\midrule"]
    lineas += [" & ".join(texto(c).replace(" ± ", r" $\pm$ ") for c in f) + r" \\" for f in filas[1:]]
    lineas += [r"\bottomrule", r"\end{tabular}", r"\end{table}", ""]
    return "\n".join(lineas)


def main():
    (OUT / "figuras").mkdir(parents=True, exist_ok=True)
    shutil.copy(BASE / "plantilla-lncs" / "llncs.cls", OUT)
    shutil.copy(BASE / "plantilla-lncs" / "splncs.bst", OUT)
    shutil.copy(AQUI / "referencias.bib", OUT)

    datos = {k: v for k, v, *_ in BLOQUES if k in ("titulo", "resumen", "claves")}
    institucion = INSTITUCION + (r"\\ \email{" + EMAIL + "}" if EMAIL else "")
    cuerpo = [PREAMBULO % {"titulo": texto(datos["titulo"]), "autor": AUTOR, "institucion": institucion,
                           "resumen": texto(RESUMEN), "claves": texto(datos["claves"])}]
    usados = set()
    n_tabla = 0
    for b in BLOQUES:
        k = b[0]
        if k == "h2":
            num, titulo = b[1].split(" ", 1)
            cuerpo.append("\n\\section{" + texto(titulo) + "}\\label{sec:" + num + "}\n")
        elif k == "h3":
            cuerpo.append("\n\\subsection{" + texto(b[1].split(" ", 1)[1]) + "}\n")
        elif k == "p":
            t = b[1]
            for viejo, nuevo in CAMBIOS.items():
                if viejo in t:
                    t = t.replace(viejo, nuevo); usados.add(viejo)
            if t[0].islower() and cuerpo[-1].endswith("\\end{equation}\n"):
                cuerpo[-1] = cuerpo[-1][:-1]  # la frase continúa tras la ecuación: sin línea en blanco ni sangría
            cuerpo.append(texto(t) + "\n")
        elif k == "eq":
            cuerpo.append("\\begin{equation}\n" + ECUACIONES[b[2]] + "\n\\label{eq:" + str(b[2]) + "}\n\\end{equation}\n")
        elif k == "tabla":
            n_tabla += 1
            cuerpo.append(tabla(b[1], b[2], TABLAS[n_tabla]))
        elif k == "fig":
            nombre = Path(b[1]).stem
            shutil.copy(BASE / "paso-3-experimento" / "figuras" / (nombre + ".pdf"), OUT / "figuras")
            pie = re.sub(r"<b>Fig\. \d\.</b>\s*", "", b[2])
            cuerpo.append("\\begin{figure}[htbp]\n\\centering\n\\includegraphics[width=0.7\\textwidth]{figuras/"
                          + nombre + "}\n\\caption{" + texto(pie) + "}\n\\label{" + FIGURAS[nombre] + "}\n\\end{figure}\n")
    assert usados == set(CAMBIOS), f"CAMBIOS sin aplicar: {set(CAMBIOS) - usados}"
    cuerpo.append("\n\\bibliographystyle{splncs}\n\\bibliography{referencias}\n\n\\end{document}\n")
    (OUT / "main.tex").write_text("\n".join(cuerpo), encoding="utf-8")
    print("articulo/main.tex creado")


if __name__ == "__main__":
    main()
