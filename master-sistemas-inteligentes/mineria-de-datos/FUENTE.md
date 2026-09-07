Material heredado del Drive de Arlet Acosta González (MSI), copiado el 2026-08-30.

## Copiado

**Nivel raíz** (temario y guías):
- 0-Presentación asignatura.pdf
- Arlet Acosta González, Trabajo Minería de datos.pdf
- MANUAL WEKA.pdf
- MineríaDatos Tema1.pdf, Tema2.pdf, Tema3.pdf, Tema4.pdf
- Trabajo obligatorio (2023-2024).pdf
- Weka-EjemploAplicación.pdf

**dataset/** (5 de 9 archivos):
- Rice_Cammeo_Osmancik.arff
- Thyroid_Diff.csv
- database_pos.csv
- drug_consumption.data
- secondary_data.csv

**data/** (21 de 25 archivos .arff de ejemplo para WEKA):
- airline.arff, contact-lenses.arff, cpu.arff, cpu.with.vendor.arff,
  credit-g.arff, hypothyroid.arff, ionosphere.arff, iris.arff, iris.2D.arff,
  ReutersCorn-test.arff, ReutersCorn-train.arff, ReutersGrain-test.arff,
  ReutersGrain-train.arff, segment-challenge.arff, segment-test.arff,
  soybean.arff, supermarket.arff, unbalanced.arff, vote.arff,
  weather.nominal.arff, weather.numeric.arff

## Excluido tras la revisión independiente (contenido problemático)

- `WEKA TFM_Asier_Arostegui.pdf` — es el TFM completo de otro alumno del
  máster (no de Arlet ni del profesorado), sin verificación de que fuera
  material público de la asignatura. Se excluye por el mismo criterio de
  privacidad que ya se aplica al resto de este PR (compañeros de clase,
  no profesorado), a diferencia de "Pastora" en la carpeta de Herramientas
  de Simulación, que sí se confirmó como profesora antes de mantenerse.

## Excluido por el límite de 8 MB

- `dataset/database_gas.csv` (~34,6 MB)

## Excluido por un problema técnico de transferencia en esta pasada

- `dataset/data_ref_until_2020-02-13.csv` (~6,5 MB) — la descarga falló
  repetidamente (conector de Drive inestable) a pesar de estar dentro del
  límite de 8 MB. Disponible en Drive.
- `data/labor.arff` — al transcribir manualmente el contenido se detectó una
  discrepancia de tamaño frente al original de Drive (posible error de
  transcripción); se descartó por seguridad en vez de arriesgar un archivo
  corrupto.
- `dataset/primary_data.csv` (~22 KB) y `dataset/SomervilleHappinessSurvey2015.csv`
  (~4,3 KB) — su tamaño cae en un rango intermedio en el que el conector solo
  devuelve el contenido embebido en línea (no se guarda aparte en disco de
  forma automática), y la transcripción manual de ese contenido demostró ser
  poco fiable en esta sesión (ver el caso de `labor.arff` arriba). Se
  descartan por el mismo motivo. Ambos siguen disponibles en Drive.
- `data/breast-cancer.arff` (~29 KB), `data/glass.arff` (~18 KB) y
  `data/diabetes.arff` (~37 KB) — mismo motivo: tamaño en el rango
  intermedio de riesgo de transcripción manual.

## Excluido por las reglas del profesor / fuera de alcance

- `Rice (Cammeo and Osmancik) - UCI Machine Learning Repository_files/`,
  `Single elder home monitoring_ Gas and position - UCI Machine Learning
  Repository_files/`, `Somerville Happiness Survey - UCI Machine Learning
  Repository_files/` y los `.html` sueltos correspondientes — páginas web
  guardadas de UCI ML Repository, no material propio de la asignatura.
