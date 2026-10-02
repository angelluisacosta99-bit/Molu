"""Genera articulo/main.tex (plantilla LNCS) a partir de ../paso-4-redaccion/contenido.py.
El texto vive en un solo sitio: si cambia el borrador, se vuelve a ejecutar este script.
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

# Orden de la lista de referencias del borrador -> claves de referencias.bib
CLAVES = ["acosta2026tfg", "pointurier2021", "samadi2017", "rottondi2018", "morais2018", "kozdrowski2021",
          "aladin2020", "allogba2022", "yu2019", "igarashi2024", "dicicco2023"]

ECUACIONES = {
    1: r"L_{\mathrm{nom}} = \alpha d + 0{,}1\left\lceil d/4 \right\rceil + 1 + 5 \quad [\mathrm{dB}]",
    2: r"Q_t = 7{,}03 \cdot 10^{(P_{\mathrm{rx}} + 25)/10}",
    3: r"\mathrm{OSNR} = 58 + P_{\mathrm{rx}} - \mathrm{NF} - 10\log_{10} n \quad [\mathrm{dB}]",
    4: r"Q_{\mathrm{ASE}} = \sqrt{\frac{B_o}{B_e}}\,\frac{2\,\mathrm{OSNR}}{1 + \sqrt{1 + 4\,\mathrm{OSNR}}}",
    5: r"Q_{\mathrm{amp}} = \left(Q_{\mathrm{ASE}}^{-2} + (10 \cdot 7{,}03)^{-2}\right)^{-1/2}",
    6: r"\mathrm{BER} = \tfrac{1}{2}\,\mathrm{erfc}\!\left(Q/\sqrt{2}\right)",
}
FIGURAS = {"fig1_q_vs_longitud": "fig:q", "fig2_f1_escenarios": "fig:f1", "fig3_importancia": "fig:importancia"}
TABLAS = {1: "tab:variables", 2: "tab:resultados"}

PREAMBULO = r"""\documentclass[runningheads]{llncs}

\usepackage[T1]{fontenc}
\usepackage[spanish,es-tabla]{babel}
\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{textcomp}
\usepackage{url}

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

\title{%(titulo)s}
\titlerunning{QoT con aprendizaje automático en una red DWDM ferroviaria}
\author{%(autor)s}
\authorrunning{A.~L. Acosta González}
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
    t = t.replace("·", r"\textperiodcentered{}").replace("½", r"\textonehalf{}")
    return t


def tabla(pie, filas, etiqueta):
    pie = re.sub(r"<b>Tabla \d\.</b>\s*", "", pie)
    if etiqueta == "tab:variables":
        cols, tam = r"p{2.6cm}p{5.6cm}ccc", r"\footnotesize"
    else:
        cols, tam = "llcccc", r"\scriptsize"
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
    autor, institucion = dict((k, v) for k, v, *_ in BLOQUES)["autor"].split("<br>")
    cuerpo = [PREAMBULO % {"titulo": texto(datos["titulo"]), "autor": autor, "institucion": institucion,
                           "resumen": texto(datos["resumen"]), "claves": texto(datos["claves"])}]
    n_tabla = 0
    for b in BLOQUES:
        k = b[0]
        if k == "h2":
            num, titulo = b[1].split(" ", 1)
            cuerpo.append("\n\\section{" + texto(titulo) + "}\\label{sec:" + num + "}\n")
        elif k == "h3":
            cuerpo.append("\n\\subsection{" + texto(b[1].split(" ", 1)[1]) + "}\n")
        elif k == "p":
            cuerpo.append(texto(b[1]) + "\n")
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
    cuerpo.append("\n\\bibliographystyle{splncs}\n\\bibliography{referencias}\n\n\\end{document}\n")
    (OUT / "main.tex").write_text("\n".join(cuerpo), encoding="utf-8")
    print("articulo/main.tex creado")


if __name__ == "__main__":
    main()
