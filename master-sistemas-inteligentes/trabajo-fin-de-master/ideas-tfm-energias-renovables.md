# Ideas de TFM: sistemas inteligentes aplicados a energías renovables

Registro de la lluvia de ideas hecha en sesión de Claude Code sobre una
posible orientación del TFM hacia energías renovables/sostenibilidad,
para retomarlo en una sesión independiente sin repetir la investigación.

## Por qué esta orientación tiene sentido

Angel ya trae formación complementaria en energía (cursos "Gen. Energy
Storage - Battery and Hydrogen Technology", "Análisis de Sistemas
Eléctricos y Transición Energética", "Energy and Environment" de
Dartmouth) y llegó a escribir una carta de motivación para el máster de
Energías Renovables de la UCLM como alternativa al MUSI. El MUSI no
exige un TFM de "IA pura" — lo habitual es aplicar sistemas inteligentes
a un dominio, y energía es un dominio de investigación muy activo ahora
mismo. Además, BISITE (el grupo de investigación de IA de la USAL)
tiene una línea de investigación propia en energía.

## Dos opciones evaluadas

### Opción A — Predicción de generación renovable con deep learning

- **Estado del arte (2025-2026):** el foco ya no está en redes más
  profundas, sino en arquitecturas específicas para series temporales
  (LSTM, GRU, TCN, Transformer, PatchTST, modelos de espacio de estados
  tipo Mamba) y en incorporar conocimiento físico (variables
  meteorológicas, restricciones de causalidad). No hay un "ganador"
  único — depende del horizonte de predicción. Las mejoras recientes
  vienen más de la ingeniería de variables que de arquitecturas más
  grandes, lo que favorece un TFM con recursos limitados.
- **Datasets:**
  - **REData (Red Eléctrica de España)** — API REST abierta y gratuita,
    sin clave, con datos de generación por tecnología, demanda y
    mercado. La opción más práctica por accesibilidad. (El dato de
    "series desde 1990" que circulaba antes no se pudo verificar de
    forma independiente — confirmar el rango real de fechas al
    consultar la API directamente, en vez de darlo por bueno aquí.)
    `https://www.ree.es/en/datos/apidata`
  - **NREL WIND Toolkit** — referencia en la literatura para eólica.
  - **SKIPP'D** — imágenes de cielo + generación fotovoltaica, para
    predicción a muy corto plazo (más ambicioso, visión por computador).
- **Viabilidad en un año:** alta. Autocontenido, datos abiertos
  garantizados, alcance fácil de acotar. Riesgo: quedarse en un simple
  benchmarking de modelos si no se le añade una aportación propia.

### Opción B — Sistema multiagente para gestión de microrredes (smart grid)

- **Estado del arte:** línea de "agentic AI" — agentes que perciben el
  estado de la red, razonan sobre objetivos, planifican acciones
  multi-paso e interactúan con operadores humanos en tiempo real. Hay
  trabajo reciente integrando LLMs como "cerebro" de los agentes de
  control de red (`Grid-Agent`, arXiv 2508.05702) y arquitecturas
  jerárquicas de agentes especializados. También hay una línea
  consolidada de Multi-Agent Reinforcement Learning para redes
  energéticas.
- **Datos/entorno:** no es un dataset estático — hace falta un
  simulador de red eléctrica (`pandapower`, `GridLAB-D`, o entornos de
  RL para microrredes) alimentado con datos de generación de REData
  como entrada realista.
- **Viabilidad en un año:** más ambiciosa. Construir el simulador,
  definir agentes y su lógica de negociación es más trabajo de
  ingeniería. Factible si se acota bien el alcance (2-3 agentes, un
  escenario simple), con más riesgo de quedarse corto de tiempo si se
  expande demasiado.

### Recomendación

Empezar por la **Opción A como núcleo**, con un giro que la conecte con
B sin asumir toda su complejidad: **predicción de generación renovable +
un módulo de decisión simple (lógica difusa, no un multiagente
completo) que use esa predicción para gestionar una batería o el
consumo**. Esto da alcance controlable, datos garantizados desde el día
uno, una aportación propia (el módulo de decisión, no solo comparar
modelos), y conexión con "Computación Neuroborrosa" si se usa lógica
difusa. Si BISITE empuja hacia el multiagente completo (Opción B), ya
habría margen para subir la ambición más adelante.

## Revisión 2026-09-14: la aportación propia declarada NO se sostiene

Primera revisión de esta idea hecha con los conectores de investigación
ya activos (Consensus, alphaXiv, Scite), en vez de con conocimiento del
modelo. Resultado: **el planteamiento general aguanta, pero la
"aportación propia" tal y como está escrita arriba no.**

### Hallazgo bloqueante: "predicción + módulo difuso para batería" está saturado

La recomendación de arriba dice que el módulo de decisión difuso es la
aportación propia, "no solo comparar modelos". Contrastado contra la
literatura real: **esa combinación exacta es un tema resuelto y
publicado desde 2017**, con validación experimental en microrredes
reales. Dos referencias canónicas, metadatos verificados con Scite
(DOI, autores, revista y volumen reales, sin retracciones):

- Arcos-Avilés et al. (2017), *Applied Energy* 205:69-84,
  DOI `10.1016/j.apenergy.2017.07.123` — control difuso de baja
  complejidad + **previsión de generación y demanda** + batería, con
  validación experimental en una microrred real de la Universidad
  Pública de Navarra. 142 publicaciones citantes. Acceso abierto
  (green OA): <https://hdl.handle.net/2454/38382>
- Arcos-Avilés et al. (2018), *IEEE Transactions on Smart Grid*
  9(2):530-543, DOI `10.1109/TSG.2016.2555245` — el FLC de 25 reglas.
  332 publicaciones citantes. Acceso abierto:
  <http://hdl.handle.net/2117/106638>

Y no es solo cosa de 2017-2018: la búsqueda devolvió la misma idea
publicándose de forma continuada hasta hoy (microrred aislada con
previsión, Ecuador 2021; EMS predictivo PV-batería con difusa y estado
de salud, IEEE Access 2021; difusa multiobjetivo con batería+hidrógeno,
2020; FLC-EMS para PV-eólica-batería, *Scientific Reports* 2025).

**Consecuencia práctica:** si el TFM se presenta como "mi aportación es
el módulo difuso que usa la predicción para gestionar la batería",
cualquier miembro del tribunal que conozca a Arcos-Avilés preguntará
qué aporta esto sobre un *Applied Energy* de 2017. Hay que reencuadrar
la contribución antes de escribir la propuesta, no después.

### Lo que sí aguanta del planteamiento original

- **Que no hay una arquitectura ganadora única** y que las mejoras
  vienen más de ingeniería de variables que de modelos más grandes:
  confirmado por trabajo reciente (benchmark de modelos de espacio de
  estados vs. Transformers vs. recurrentes para red eléctrica de EEUU,
  arXiv 2602.21415, que concluye que el rendimiento depende sobre todo
  de los datos disponibles; y modelos lineales ligeros que siguen
  siendo "notablemente fuertes", arXiv 2606.01339).
- **REData, alcance de un año, conexión con Computación Neuroborrosa**:
  sin cambios, siguen siendo buenas decisiones.

### Dónde se ha movido el estado del arte (y dónde queda hueco real)

El frente activo en 2026 son los **modelos fundacionales de series
temporales (TSFM)** aplicados a energía — predicción *zero-shot* sin
entrenar un modelo por dataset. Oleada de trabajo muy reciente en
arXiv, toda de 2026: benchmark FETS sobre si los modelos fundacionales
generalizan en series de energía (arXiv 2604.22328; **es el preprint de
lo que en este mismo archivo se cita después como artículo de *Energy
and AI*, 2026** — verificar cuál de las dos versiones se cita al
final); si pueden sustituir a
los modelos específicos de mercado eléctrico, **incluyendo arbitraje de
batería** (2609.00089); predicción de carga informada por covariables
con TSFM (2609.06656, y la variante explicable de KIT 2604.28149);
riesgos de contaminación de datos y dependencia de covariables al
evaluarlos (2607.02623); y viabilidad operativa real (2605.24381).
TimesFM-3 (330M parámetros, multivariante) es de agosto de 2026.

Importante: **la pregunta sigue abierta** — varios de esos papers
encuentran que los TSFM *no* ganan claramente, y señalan por qué
(cambio de distribución, dependencia de covariables, contaminación del
conjunto de entrenamiento). Un tema abierto y discutido es mejor
terreno de TFM que uno cerrado.

### Dos reencuadres posibles (decisión de Angel, no tomada aquí)

1. **Métrica orientada a la decisión, no al RMSE.** Mantener todo el
   pipeline planeado (predicción + módulo difuso + REData) pero cambiar
   la pregunta de investigación a: *¿mejorar el RMSE del pronóstico se
   traduce de verdad en mejores decisiones de la batería?* El módulo
   difuso deja de venderse como "la aportación" y pasa a ser el banco de
   pruebas que mide valor de decisión. Ya hay precedente de este enfoque
   para predicción de carga (métricas orientadas a la aplicación,
   arXiv 2607.01966) pero está poco explorado para decisiones de
   batería. Ventaja: no tira nada de lo planeado y convierte el riesgo
   de "esto es solo un benchmark" en la contribución misma.
2. **TSFM sobre datos españoles.** Evaluar modelos fundacionales
   (zero-shot) frente a un LSTM/TCN entrenado a medida, sobre
   generación renovable real de REData. El hueco: los trabajos citados
   evalúan precios belgas, red de EEUU o benchmarks genéricos — no
   generación renovable peninsular española. Más actual y más
   arriesgado (depende de que los TSFM sean accesibles y de que el
   resultado sea publicable aunque salga negativo, que sí lo es).

Ambos son compatibles: 2 puede ser el modelo de predicción dentro de 1.

**Aviso metodológico:** los identificadores de arXiv de esta sección
vienen de una búsqueda con alphaXiv y **solo se verificó el título y la
fecha**, no autores ni metadatos completos. Antes de citar cualquiera
de ellos en `main.tex`, verificarlos uno a uno (Scite o la propia
página de arXiv) igual que se hizo con los dos de Arcos-Avilés. Solo
esos dos están ya en `Bibliografia.bib`.

## Revisión 2026-09-14 (segunda pasada): verificación de factibilidad

Angel pidió no empezar a trabajar hasta tener verificado que la idea es
factible. Esto es lo comprobado, con lo bueno y lo malo.

### REData: la API existe y sirve, pero está bloqueada desde aquí

Documentación oficial confirmada (vía Firecrawl, porque el dominio está
bloqueado en este entorno): `apidatos.ree.es`, endpoint
`generacion/estructura-generacion`, parámetro `time_trunc` con valor
`hour` admitido, rango por fechas ISO 8601, y filtros geográficos
(`geo_trunc=electric_system`, `geo_limit=peninsular|ccaa`). Los ejemplos
oficiales usan fechas de 2014 a 2019, así que hay histórico de sobra.
**No pide clave de API.** La granularidad horaria que necesita el TFM
existe.

**Bloqueo real:** `apidatos.ree.es` y `www.ree.es` devuelven 403 del
gateway de red de este entorno (`connect_rejected`, política de la
organización). No es un fallo de REData. Para tocar los datos desde una
sesión de Claude Code hay que **autorizar `apidatos.ree.es`** junto con
`numpy.org` y `pandas.pydata.org` (la lista canónica y al día está en
la entrada del **2026-09-14** de `lluvia-de-ideas.md`). Alternativa
sin depender de eso: descargar los datos desde VS Code en la máquina de
Angel, que es donde el plan ya dice que corre el código pesado.

### Sin GPU para inferencia zero-shot: confirmado (el barrido completo, no medido)

Dato duro que resuelve la mayor duda de recursos: un benchmark de 2026
evaluó Chronos-Bolt, Chronos-2, Moirai-2 y TinyTimeMixer sobre carga
horaria real de ERCOT (2020-2024) **en hardware de consumo — AMD Ryzen
7, 16 GB de RAM, sin GPU**. El benchmark FETS (*Energy and AI*, 2026)
añade que los modelos fundacionales tienen "bajas demandas de inferencia
y hardware" y que Chronos-2 logró el menor NRMSE mediano (0,472),
por debajo de XGBoost (0,611) y random forest (0,696) *entrenados con
todo el histórico de la serie objetivo*.

Traducción: el camino de modelos fundacionales es **más factible** que
entrenar una LSTM propia, no menos. Y `amazon/chronos-2` está en Hugging
Face con licencia Apache-2.0.

### Malo: el reencuadre que propuse ayer también se está llenando

Honestidad por encima de coherencia con lo que dije ayer. La opción
"evaluar TSFM zero-shot frente a modelos entrenados a medida sobre
generación renovable" **ya está hecha varias veces en 2026**:

- Benchmark empírico de TSFM + transformers + baselines para **solar,
  eólica y carga** sobre datos ERCOT, evaluando TimesFM, Chronos-Bolt,
  Moirai, MOMENT, TinyTimeMixer, TFT, PatchTST, TimeXer, LSTM y CNN, en
  ocho dimensiones (zero-shot, fine-tuning, generalización a
  emplazamientos no vistos, probabilístico...). Es prácticamente el
  reencuadre 2 entero, ya publicado.
- Benchmark FETS: 54 datasets de energía, modelos fundacionales frente a
  ML específico de tarea.
- WindFM: modelo fundacional **específico de eólica**, 8,1M parámetros,
  código abierto, SOTA zero-shot.
- Varios más de predicción de carga a corto plazo con TSFM zero-shot.

Lo único no reclamado es "sobre datos españoles de REData", que es
novedad **geográfica** — la más débil de todas. Un tribunal puede decir
con razón: "has replicado un paper de 2026 con datos de España".

### Lo que sigue abierto de verdad (y es donde queda el TFM)

Lo que ninguno de esos trabajos cubre: **traducir el pronóstico a una
decisión de batería y medir el valor de esa decisión**, no el error de
predicción. El benchmark de hardware de consumo toca "analítica
prescriptiva para soporte a la decisión" pero sobre carga, no sobre
despacho de batería con un controlador difuso. La pregunta
*"¿un MASE más bajo produce mejores decisiones de batería, o a partir de
cierto punto da igual?"* sigue sin responder, y es la intersección de
todo lo que Angel ya tenía planeado.

**Valoración honesta del nivel:** esto es una contribución
*incremental*, no rompedora — replicación con extensión propia. Para un
TFM es suficiente y defendible; para presentarlo como investigación
original de calado, no. Conviene decirlo así al tutor desde el principio
en vez de sobrevenderlo.

**Riesgo de calendario:** el campo se mueve rápido (los papers citados
son todos de 2026). Un TFM planteado como "benchmark de quién gana"
llegará tarde. Planteado como pregunta de valor-de-decisión envejece
mucho mejor, porque la respuesta no caduca cuando sale un modelo nuevo.

## Revisión 2026-09-14 (tercera pasada): la propuesta se cae, y por qué

Angel pidió verificar al detalle antes de enviar nada a una catedrática.
Se lanzaron **dos agentes independientes**: uno con el papel de revisor
adversarial experto en el dominio, otro a verificar la afirmación de
novedad contra la literatura. **Los dos encontraron fallos bloqueantes.**
Esta es la lección más cara de toda la planificación del TFM, así que se
registra completa.

### Fallo 1 (bloqueante): la novedad declarada no existe

La afirmación era: "nadie ha variado deliberadamente el error de
predicción para medir cuánto se traslada a la decisión de batería, ni ha
buscado el umbral de saturación". **Falsa en las dos mitades**, con
literatura verificada:

- **Yin, W., Lei, S. y Feng, S. (2024). "Assessing the Value of
  Renewable Forecasting Accuracy in Power System Operation". *IEEE
  Transactions on Power Systems*, 39(2), 4561-4573.**
  DOI `10.1109/TPWRS.2023.3317534` (metadatos verificados con Scite).
  Su título enuncia esa misma pregunta de investigación — no con las
  palabras exactas del borrador, pero sí el mismo problema, y publicado
  en una revista de primer nivel del área. Además deriva **fórmulas analíticas de sensibilidad** del
  coste operativo al error, y cataloga explícitamente la *perturbación
  numérica* — el método del borrador — como el enfoque previo que ellos
  superan.
- Barridos sistemáticos de precisión ya hechos: Mc Garrigle y Leahy
  (2015, *Renewable Energy*) generan pronósticos ARMA de precisión
  especificada; Wang et al. (2016, *IEEE TSTE*) cruzan 270 escenarios de
  mix, penetración y nivel de mejora del pronóstico.
- Aplicado a **baterías** en concreto: Campos et al. (2022, *J. Energy
  Storage*) evalúan 11 niveles de precisión sobre reparto de PV+batería;
  Kiedanski et al. (2019) publican "Sensitivity to Forecast Errors in
  Energy Storage Arbitrage"; Maciejowska et al. construyen un pool de
  192 pronósticos y muestran que RMSE/MAE se correlacionan solo
  débilmente con el beneficio del BESS — casi palabra por palabra el
  "hallazgo" que el borrador presentaba como propio.

**Pendiente:** estas siete referencias (Mc Garrigle y Leahy 2015; Wang
et al. 2016; Campos et al. 2022; Kiedanski et al. 2019; Maciejowska et
al., **sin año todavía**; y también Wahdany et al. 2023, *EPSR*, y
Beichter et al. 2025, citados más abajo) **no están en
`Bibliografia.bib`**, porque sus
metadatos no se han verificado con Scite. Según el flujo fijado en
`lluvia-de-ideas.md`, verificarlas y añadirlas antes de usarlas en
`main.tex`.

### Fallo 2 (bloqueante): faltaba el marco teórico del campo

**Decision-focused learning / Smart "Predict, then Optimize"**
(Elmachtoub, A. N. y Grigas, P., 2022, *Management Science*, 68(1),
9-26, DOI `10.1287/mnsc.2020.3922`, **905 publicaciones citantes**,
acceso abierto en `arxiv.org/pdf/1710.08005`) es exactamente el marco
que formaliza que minimizar el error de predicción no es lo mismo que
optimizar la decisión. Ya está aplicado a energía (Wahdany et al., 2023,
*EPSR*; y trabajo específico de *scheduling* PV-batería). Proponer la
disociación precisión/decisión como idea propia sin citar SPO se lee
como no conocer el campo.

### Fallo 3 (bloqueante): el barrido sintético es circular

Degradar un pronóstico con ruido i.i.d. no simula un modelo peor: el
error real es autocorrelacionado, heterocedástico, con sesgo condicional
en rampas y sobre todo con **error de fase** (la rampa ocurre, pero
tarde). Para almacenamiento, el error de fase concentra casi todo el
daño económico; el ruido blanco de media cero **se promedia solo** dentro
del horizonte de decisión, produciendo una curva plana. Es decir: se
obtendría "satura pronto" **por construcción**, que era justamente la
conclusión buscada. Alternativas válidas: barrer por **horizonte de
predicción** (error real degradándose con estructura real), o una
escalera de modelos reales; la degradación sintética solo vale como
ablación estructurada, y entonces la pregunta buena pasa a ser *qué
componente del error destruye valor*.

### Fallo 4 (bloqueante): no había problema de decisión

Generación **peninsular agregada** + una batería no define un escenario.
O se baja a autoconsumo local (hace falta perfil de consumo local, no el
agregado nacional) o se sube a arbitraje de mercado (y entonces lo que
se predice son **precios**, no generación). Faltaban además: modelo de
batería (rendimiento de ida y vuelta ~0,85-0,92, límites de carga,
degradación por ciclos), esquema rodante con re-optimización, y las dos
**políticas ancla** sin las cuales los euros no significan nada —
oráculo con previsión perfecta y política ingenua. El valor se mide
normalizado entre esos extremos (VSS/EVPI).

### Fallos menores pero visibles

- **Métricas contradictorias**: coste, ciclos y autoconsumo se oponen
  entre sí. Hace falta *una* función objetivo (coste neto incluyendo
  coste de degradación) y el resto como descriptivas.
- **La lógica difusa no optimiza**: es heurística. Una "saturación"
  medida solo con control difuso puede ser saturación *del controlador*,
  no del valor del pronóstico. Hace falta un módulo óptimo (MPC/LP) como
  contraste.
- **Contaminación de datos**: Chronos pudo entrenarse con datos de red
  europeos que incluyan España. Un revisor lo preguntará.
- La afirmación "sin GPU" vale para inferencia zero-shot, no para el
  barrido completo (N modelos × M horizontes × K configuraciones).

### Lo único que sobrevive como hueco defendible

No *si* el error se traslada a la decisión (resuelto), sino el **mapa de
contingencia**: bajo qué configuración de activo (potencia, ciclos,
degradación), estructura de mercado y régimen de precios **se desplaza
el umbral**. Se reportan pérdidas de arbitraje que van del 6% al 50%
según contexto, sin explicación sistemática de por qué. Esa dispersión
sin explicar es la grieta. Encuadre correcto: *caracterización del
umbral condicionada al activo y al mercado, usando DFL como marco* —
nunca como "descubrimiento de que el umbral existe".

### Consecuencia práctica que hay que decidir antes de seguir

El tema reformulado **exige más maquinaria de la que había**: optimización
bajo incertidumbre (MPC/LP), modelo de degradación de batería, datos de
mercado y el marco DFL. El plan de entrenamiento actual
(`preparacion/plan-de-entrenamiento.md`) va de Python a deep learning y
lógica difusa, pero **no incluye optimización en ninguna fase**. Hay un
desajuste real entre el nivel que pide el tema reformulado y el punto de
partida (Fase 0 recién hecha). Decisión pendiente de Angel, anotada sin
resolver aquí.

## Decisión pendiente: los tres caminos (abierta desde 2026-09-14)

Cerrada la tercera revisión, Angel pidió guardar el veredicto y pensar
la opción con calma. **Ninguna está elegida todavía.** Quien retome
esto: no dar por hecho ningún camino, preguntarle.

### Estado de recursos, verificado

| Recurso | Estado real |
|---|---|
| Generación renovable (API REData, `apidatos.ree.es`) | ✅ Libre, sin clave. Histórico **al menos** desde 2014 (los ejemplos oficiales llegan ahí; el inicio real de la serie sin confirmar) |
| Precios de mercado (API ESIOS, `api.esios.ree.es`) | ⚠️ **Exige solicitar un token personal.** El borrador descartado ni siquiera contemplaba señal de precios — ver Fallo 4 |
| Perfil de consumo / demanda | ❌ Ni siquiera estaba identificado en el borrador. Sin demanda que servir, una batería no tiene nada que decidir |
| Cómputo | ⚠️ Chronos-2 son 119,5 M parámetros, licencia Apache-2.0, corre en CPU. Sin GPU **para inferencia zero-shot**; el barrido completo (N modelos × M horizontes × K configuraciones) **no está medido** — ver `### Fallos menores pero visibles` |
| Optimización bajo incertidumbre (MPC/LP) + degradación de batería | ❌ Ver el desajuste con el plan de entrenamiento, abajo |

**Dato que conviene no olvidar:** la propia Sara Rodríguez, en su
artículo de 2026 (*Electronics* 15(11):2269), **no usó REData**. Usó
GEFCom2014 + carga sintética + precios españoles representativos. Si
ella no vio práctico montarlo con datos reales del sistema español,
proponérselo como si fuera trivial delata inexperiencia.

### El desajuste con el plan de entrenamiento

Lo único que sobrevive de la idea original es el **mapa de
contingencias**: bajo qué configuración de activo (potencia, ciclos,
degradación), qué estructura de mercado y qué régimen de precios se
desplaza el umbral de saturación. Las pérdidas por arbitraje que
reporta la literatura van del 6 % al 50 % sin que nadie explique esa
horquilla — eso sí es una pregunta abierta de verdad.

**Pero ese tema reformulado exige optimización bajo incertidumbre**
(MPC o programación lineal), modelado de degradación de batería y el
marco de *decision-focused learning*. Y `preparacion/plan-de-entrenamiento.md`
va Python → matemáticas → ML → deep learning → lógica difusa → REData →
proyecto: **no contempla ninguna fase de optimización**, y Angel está
en la Fase 0. El desajuste es real, no un detalle de calendario.

### Los tres caminos

**A. Estrechar y ampliar el plan.** Mantener el mapa de contingencias
con DFL/SPO como marco teórico, y añadir una fase de optimización al
plan de entrenamiento. Es el camino más ambicioso y el que más tiempo
consume antes de poder escribir una sola línea de la memoria.

**B. Pivotar.** Buscar otro ángulo de energía + IA que encaje mejor con
un TFM de un año empezando desde la Fase 0, sin necesitar optimización
bajo incertidumbre.

**C. Escribir a Sara como pregunta abierta informada**, no como
propuesta cerrada: "he leído su artículo de 2026 y el de Yin et al.
2024; veo este hueco concreto; ¿lo ve trabajable?". Esto sí se sostiene
— la fuerza está en haber leído el estado del arte, no en fingir
novedad.

**Recomendación dada a Angel el 2026-09-14, antes de que se abriera el
camino D:** C, y decidir entre A y B con lo que ella conteste. **Léase
junto a `## Camino D: pivotar a redes móviles (candidato, NO verificado
del todo)`**, que cambió el peso relativo de las opciones.
 Un tutor con experiencia prefiere a alguien que llega con el
estado del arte leído y una pregunta afilada, antes que con una
propuesta cerrada que va a tener que desmontar.

**Antes de decidir:** Angel debería leer el artículo de Sara de 2026
(*Electronics* 15(11):2269, acceso abierto, corto) para tener criterio
propio y no depender solo del análisis de esta sesión.

## Tutores de TFM — candidatos concretos

| Candidato | Especialidad | Encaje |
|---|---|---|
| **Sara Rodríguez González** | BISITE, Departamento de Informática y Automática, Área de Ciencia de la Computación e IA. **Coautora en 2026 de "Enhancing Energy Efficiency and Economic Benefits with Battery Energy Storage Systems: An Agent-Based Optimization Approach"** (*Electronics* 15(11):2269, DOI `10.3390/electronics15112269`, metadatos verificados con Scite): gestión de batería + fotovoltaica + **precios del mercado eléctrico español**, evaluada por **beneficio económico**, no por error de predicción. | **El más alto tras el reencuadre** — es literalmente el vecindario de la pregunta que queda abierta (ver revisión del 2026-09-14). Ver nota de encaje abajo. |
| **Pablo Chamoso Santos** | Profesor Titular, BISITE desde 2011. Tesis doctoral: "Arquitectura multiagente auto-adaptativa para la gestión de smart cities". Coordina el grupo de transferencia "DeepTech" (IA, IoT, Blockchain). | **Alto, pero el argumento cambió.** Su tesis encajaba con la Opción B (multiagente), que se descartó. Sigue siendo buena opción por la línea de energía de BISITE, pero al escribirle hay que apoyarse en esa línea, no en su tesis doctoral. |
| **Alfonso González-Briones** | USAL/BISITE, coautor del paper de batería de arriba junto a Sara Rodríguez. | Medio-alto — misma línea de trabajo, alternativa natural si ella no tiene hueco. |
| **Juan Manuel Corchado** | Director de BISITE, contacto principal del grupo (+34 923 294 400 ext. 1525). Línea de energía confirmada: Ambient Intelligence, Energy Efficiency, Green Computing. | Alto como puerta de entrada/director del grupo, aunque como director puede tener menos disponibilidad para tutorías directas. |
| Francisco José García Peñalvo, Alicia García-Holgado, Diego Manuel Jiménez Bravo | Área de Ciencia de la Computación e IA (30 investigadores en total en esta área) | Sin confirmar línea exacta — preguntar si Chamoso no está disponible. |
| **Dr. Carlos García Figuerola** (`figue@usal.es`) — tutor del TFM de Arlet Acosta González ("Caracterización de las darknets", 2024) | Cibermetría, análisis de redes/grafos, minería web | **Bajo** para este tema — no hay overlap natural con energía/smart grid salvo forzando el TFM hacia análisis de topología de red como grafo. Plan de respaldo, no primera opción. |

Fuente BISITE energía: `https://bisite.usal.es/es/investigacion/lineas-investigacion/energia`
Departamento (90 investigadores, 4 áreas): `https://produccioncientifica.usal.es/unidades/1871/investigadores`

### Nota de encaje: por qué Sara Rodríguez pasa a ser la primera opción

Su paper de 2026 hace battery storage + fotovoltaica + precios del
mercado español y lo evalúa por **valor económico de la decisión**, que
es justo el eje que el TFM necesita tras el reencuadre. Pero **no varía
la calidad del pronóstico**: toma los datos como dados (GEFCom2014 +
perfiles sintéticos + precios day-ahead) y optimiza la política de
carga/descarga con Deep Q-Learning. Es decir, **la pregunta "¿cómo se
propaga el error de predicción hasta la calidad de la decisión?" sigue
sin responder incluso en su propio trabajo** — y es exactamente el hueco
identificado en la revisión del 2026-09-14. Eso convierte el TFM en el
complemento natural de su línea, que es la mejor posición posible para
pedir tutoría.

**Confirmado por Angel el 2026-09-14: sí es la profesora que dio clase a
Arlet.** Eso da además una vía de presentación personal en el primer
correo (mencionarla una vez, de pasada, sin apoyarse en ella como
argumento).

**Lo que sigue sin verificar:**
- **Su categoría aparece distinta según la fuente**: la ficha de BISITE
  dice "Profesora Titular de Universidad" y el portal de producción
  científica de la USAL dice "Catedrática de Universidad". Usar el
  tratamiento neutro ("Dra.") al escribirle, o comprobar cuál es la
  vigente, en vez de arriesgarse a degradarla en el saludo.

## Correspondencia relacionada

- **Enviado** a `bisite@usal.es` (**12/09/2026**, 20:21 UTC; fecha
  verificada en Gmail el 2026-09-14 — antes figuraba 13/09): propuesta de TFM +
  colaboración, nombrando explícitamente a Pablo Chamoso y su tesis
  sobre arquitecturas multiagente, mencionando la línea de energía de
  BISITE y la posible Beca de Colaboración en Departamentos. Sin
  respuesta aún a la fecha de este registro.
- Ver también `../admision-y-becas/becas-y-tramites-2026-2027.md`
  para el resto de correspondencia con la USAL (mastersi@usal.es,
  bintmaster@usal.es, rrii@usal.es) y el contexto de la matrícula
  condicionada/apostilla, que también condiciona la Beca de
  Colaboración ligada a este posible TFM.

## Qué tanto puede ayudar Claude Code en este TFM (evaluación honesta)

Registrado tal cual se le respondió a Angel cuando preguntó
directamente, para que quede claro el rol esperado en sesiones futuras:

**Ayuda real:**
- Revisión bibliográfica y estado del arte (búsqueda, comparación de
  arquitecturas, datasets).
- Código: escribir/depurar/iterar el pipeline (preprocesado, modelos,
  evaluación).
- Redacción de la memoria: estructura, español académico, claridad.
- Explicar conceptos (lógica difusa, RL multiagente, Transformers).
- Organización del proyecto y continuidad entre sesiones vía el repo.

**Límites reales:**
- No puede entrenar modelos a escala real — este entorno no tiene GPU
  ni permite corridas largas; el entrenamiento real lo tiene que correr
  Angel en su propia máquina, Colab, o el clúster de la USAL.
- Puede equivocarse en afirmaciones técnicas concretas (ya pasó una vez
  en esta sesión, con el requisito del 75% de créditos de la beca) —
  cualquier cifra o resultado de un paper debe verificarse contra la
  fuente antes de citarlo en la memoria.
- No sustituye al tutor real para la validación científica de la
  contribución.
- No valida la corrección física/ingenieril de una simulación de red
  eléctrica sin revisión de alguien con formación en sistemas
  eléctricos.
- Sin continuidad garantizada entre sesiones si esto no se guarda en el
  repo — de ahí este mismo archivo.
- La autoría del TFM tiene que ser de Angel: revisar la política de la
  USAL sobre uso de IA en el TFM (existe una "Declaración de Autoría"
  que hay que firmar, ver la carpeta del TFM de Arlet en Drive) y
  respetarla.

## IMDEA como criterio de empleabilidad (abierto, 2026-09-14)

Angel planteó una idea nueva: su hermana Arlet trabaja en **IMDEA** y
está a gusto allí, así que quizá convenga elegir un tema de TFM que
además resulte atractivo a ese instituto de cara a un trabajo tras la
graduación. Es un criterio legítimo y, de hecho, útil para desempatar
entre los tres caminos de la sección `## Decisión pendiente: los tres
caminos (abierta desde 2026-09-14)` — y, de hecho, es el criterio del
que sale el cuarto, el camino D.

**Confirmado por Angel el 2026-09-14: Arlet trabaja en IMDEA
Networks**, no en Energía — coherente con que su TFM fuera sobre Tor.
Conviene tenerlo claro porque IMDEA no es una empresa: son siete
fundaciones independientes de la Comunidad de Madrid (creadas
2006-2007) — Agua, Alimentación/Nutrición, Energía, Materiales,
Nanociencia, Networks y Software — y trabajar en una no es trabajar en
las otras. **Qué tema resulta atractivo depende por completo de cuál
sea.**

### Si hubiera sido IMDEA Energía (escenario DESCARTADO; se conserva solo por si el criterio cambia)

Lo que sigue se investigó antes de que Angel confirmara el instituto.
**No es la vía real** — se deja como registro, no como recomendación.

Sede en Móstoles (Madrid). Acreditación **Unidad de Excelencia "María
de Maeztu"** (Agencia Estatal de Investigación, 2020). Está
activamente metido en IA aplicada a energía, con hechos concretos:

- **Mesa redonda "Energía e Inteligencia Artificial"** (28 de enero),
  con Iberdrola, Endesa/Enel, Indra/Minsait, Sener y NCompany. Más de
  70 asistentes.
- **Seminario "Toward AI-Native Energy Systems"** (9 de febrero de
  2026). Su contenido es directamente relevante: predicción guiada por
  física (modelos espacio-temporales, PINNs), gemelos digitales
  calibrados en continuo, y **toma de decisiones segura mediante MPC
  con restricciones y RL seguro**. Es decir: el instituto ya piensa en
  el mismo territorio (optimización bajo incertidumbre) que la
  reformulación del tema exige.
- Simposio **I-Labs4S** (27-28 mayo 2026) sobre laboratorios autónomos
  con IA y robótica.
- Su **Unidad de Análisis de Sistemas** hace evaluación de
  sostenibilidad, diseño/simulación/optimización de procesos y
  **modelos de planificación energética** — la unidad más cercana a un
  perfil de sistemas inteligentes.

**Vía de entrada concreta y verificada:** IMDEA Energía convoca
**becas de prácticas para estudiantes de Grado y Máster** (una
convocatoria reciente fue de 26 becas). Condiciones publicadas: hasta
**2.500 €** para nivel máster, duración máxima **350 horas**, una sola
solicitud por candidato, enviada al correo que indique cada línea de
investigación. También ofrecen contratos de prácticas de un año
(~13.500 € brutos anuales) con posible continuidad.

**Consecuencia estratégica, que NO aplica:** si Arlet estuviera en
Energía, el camino A (mapa de contingencias con DFL, que exige
MPC/optimización) habría pasado de "el más ambicioso" a el más alineado
con lo que ese instituto hace. Como está en **Networks**, este criterio
empuja hacia otro tipo de tema — ver `## Camino D: pivotar a redes
móviles (candidato, NO verificado del todo)` más abajo, que es la vía
que sí sale de aquí.

### Limitación técnica de esta sesión

`energia.imdea.org` está **bloqueado por la política de red del
entorno** (`EGRESS_BLOCKED`), igual que pasó con `numpy.org` y
`pandas.pydata.org`. Todo lo anterior se obtuvo por búsqueda web
indirecta, no leyendo sus páginas. Para verificar la convocatoria
vigente, las líneas de investigación exactas y los correos de contacto
hace falta autorizar los dominios de IMDEA en la configuración de red
del entorno. **La lista canónica está en la entrada del 2026-09-14 de
`lluvia-de-ideas.md`** — no mantener copias parciales aquí.

## Camino D: pivotar a redes móviles (candidato, NO verificado del todo)

Surge el 2026-09-14 al confirmar Angel que **Arlet trabaja en IMDEA
Networks**, no en IMDEA Energía. Eso invalida el razonamiento de la
sección anterior (elegir tema de energía para gustar a IMDEA) y abre
una alternativa que, sobre el papel, encaja mejor con cuatro cosas a la
vez.

### Por qué encaja

1. **Es el dominio propio de Angel.** Su formación es ingeniería de
   telecomunicaciones (ver la carpeta `telecomunicaciones/` de este
   repo, con especialidad ferroviaria). En un máster de Sistemas
   Inteligentes, llegar con dominio de telecomunicaciones es un
   diferencial real frente a un tema de energía donde parte de cero.
2. **IMDEA Networks.** Lidera los proyectos **MAP-6G** (analítica con
   preservación de privacidad para 6G), **RISC-6G** y **TUCAN6-CM**,
   con entregables declarados en "inteligencia de red, **eficiencia
   energética**, localización y analítica con privacidad", en
   colaboración con Telefónica, NEC Europe, BluSpecs y PI Lighting. La
   eficiencia energética de red es literalmente una de sus áreas.
3. **Reaprovecha todo el trabajo teórico ya hecho.** El marco DFL/SPO,
   Chronos-2 y los modelos fundacionales, y la pregunta
   precisión-frente-a-decisión siguen valiendo tal cual. No se tira
   nada de las tres revisiones anteriores.
4. **El problema de decisión es mucho más simple que el de la
   batería.** Encender/apagar una celda es binario: no hay degradación
   del activo, ni rendimiento de ida y vuelta, ni precios de mercado,
   ni token de ESIOS. Eso reduce mucho el desajuste con
   `preparacion/plan-de-entrenamiento.md`, que no tiene fase de
   optimización: un ILP o una política de umbral es abordable; un MPC
   con dinámica de batería, no tanto.

### Lo que se comprobó (2026-09-14) y lo que NO

**Comprobado — el problema clásico está saturado.** "Predicción de
tráfico + apagado de estaciones base" tiene al menos diez trabajos
entre 2017 y 2026 en revistas fuertes (IEEE/ACM Transactions on
Networking, IEEE Transactions on Communications, IEEE TNSE, IEEE
TGCN). Proponer eso sin más sería repetir exactamente el error de las
tres revisiones anteriores. **Todos ellos**, por lo que se ve en sus
resúmenes, siguen el patrón de dos etapas (predecir, luego decidir) y
evalúan ahorro de energía dando el pronóstico por dado.

**Comprobado — DFL/SPO está llegando a redes, pero muy recientemente.**
Song, Wang y Chin publicaron en 2026 en *IEEE Networking Letters* un
tutorial de SPO para redes IoT cuyo propio resumen afirma que "a día de
hoy no hay tutoriales ni trabajos específicos de IoT centrados en el
marco SPO". Metadatos verificados con Scite. Hay además trabajo de DFL
robusto para sistemas computacionales y de red (3D-Learning,
arXiv:2602.02943, 2026), pero aplicado a servicio de LLM en nube,
respuesta a demanda de centros de datos y planificación de carga en el
borde — **no** a ahorro energético en la red de acceso radio.

**Comprobado — el lado de energía está aún más saturado de lo que
creíamos.** Búsquedas nuevas devuelven DFL aplicado a baterías
(*IEEE TSG* 2025), sistemas multienergía (*IEEE TSG* 2026), bombeo
hidráulico (*IEEE TSTE* 2026), PV-batería (*Journal of Energy Storage*
2026), y hasta ajuste fino con decisión de modelos fundacionales de
series temporales (Beichter et al., 2025). Esto **refuerza** el
veredicto de la tercera revisión, no lo matiza.

**NO comprobado, y es lo que decide si el camino D vale:** si alguien
ya ha aplicado DFL/SPO —o simplemente la pregunta del valor de decisión
del pronóstico— al apagado de estaciones base o al ahorro energético en
la red de acceso. Las búsquedas hechas no lo encontraron, **pero no
encontrarlo no es lo mismo que demostrar que no existe**: ese
razonamiento es justo el que tumbó el primer borrador. Antes de que
Angel escriba nada a nadie con este tema hace falta una verificación
sistemática dedicada (varios conectores, varias formulaciones de la
consulta, revisión de los trabajos que citan a Elmachtoub y Grigas
dentro del ámbito de redes).

### Pendiente además

- ~~Confirmar el grupo concreto de IMDEA Networks...~~ **Hecho
  2026-09-16**, ver la revisión de más abajo: es Orlando E.
  Martínez-Durive, Networks Data Science Group.
- ~~Buscar datos abiertos de tráfico móvil (Telecom Italia)...~~
  **Hecho 2026-09-16**: confirmado, es abierto y ya usado para este
  problema exacto — ver la revisión de más abajo.
- Replantear quién sería el tutor: la lista actual de
  `## Tutores de TFM — candidatos concretos` se hizo para un tema de
  energía. Si el tema pasa
  a redes, hay que rehacerla. **Sigue pendiente** — Martínez-Durive es
  de IMDEA (Madrid), no de la USAL, así que no puede ser tutor formal
  del TFM (tiene que ser profesorado de la USAL); como mucho es un
  contacto de colaboración o referencia a citar, no un tutor.

## Revisión 2026-09-16: verificación sistemática del hueco del Camino D (con acceso de red ampliado)

Angel abrió esta sesión con la política de red ampliada que pedían las
dos entradas de 2026-09-13/14 de `lluvia-de-ideas.md`. Esto es la
verificación sistemática dedicada que quedaba pendiente antes de
escribir a nadie sobre el Camino D — la única forma de saber si de
verdad no existe el hueco es buscarlo en serio, no otra vez de pasada.

### Dominios: confirmado en vivo, con un matiz importante

- `networks.imdea.org` — **accesible**, probado con una consulta real
  (ver más abajo, esta misma sesión).
- `numpy.org`, `pandas.pydata.org` — **accesibles**, probados con un
  fetch simple. Pendiente todavía completar la Lección 1 con esto (no
  se ha hecho en esta sesión, era una tarea distinta).
- `apidatos.ree.es` — **matiz, no es un bloqueo de política de red**:
  con `curl` directo (no `WebFetch`) se confirma que el problema ya no
  es `connect_rejected` de nuestro entorno, sino un **403 de Incapsula**
  (el WAF/antibot propio de REData) que rechaza el patrón de la
  petición automatizada, no el dominio en sí. Es un problema distinto
  al que describían las entradas anteriores — no se soluciona
  autorizando más dominios. Sigue en pie la alternativa ya conocida:
  descargar los datos desde la máquina de Angel.

### El hueco sigue sin encontrarse — ahora con búsqueda mucho más amplia

Se buscó con **Consensus** (3 formulaciones), **alphaXiv** (2
formulaciones) y el **grafo de citas de Scite** sobre el propio paper
de Elmachtoub y Grigas (SPO), en vez de con una sola búsqueda como la
vez anterior.

**Lo que sí existe, en abundancia (2017-2026):** "predicción de
tráfico + apagado de estaciones base/celdas" es un campo maduro y muy
publicado — DeepBSC (Wu et al., 2021, *IEEE/ACM ToN*, 127 citas),
DeepNap (Liu et al., 2018, *IEEE IoT Journal*), y al menos otros ocho
trabajos de 2020-2026 en revistas IEEE fuertes (TGCN, TNSE, redes
neuronales+RL en distintas variantes). **Todos** siguen uno de dos
patrones: (a) dos etapas clásicas — predecir tráfico con LSTM/GCN,
luego decidir con una heurística, ILP o umbral; o (b) un MDP/RL de
extremo a extremo que aprende la política directamente de la
recompensa, sin pasar por una predicción explícita. **Ninguno** de los
encontrados enmarca el problema como *decision-focused learning*/SPO,
ni mide explícitamente si mejorar la precisión del pronóstico se
traduce en más ahorro energético real — la pregunta que sí se ha hecho
para baterías (Yin, Lei y Feng, 2024) y que aquí sigue sin respuesta.

**Grafo de citas de Elmachtoub y Grigas (2022):** 917 papers citantes
resueltos por Scite. Filtrando por palabras clave de redes/telecom en
el título, solo aparece **uno**: *"Black-box optimization for
anticipated baseband-function placement in 5G networks"* (Zorello,
Bliek y Troia, 2024, *Computer Networks*) — y es un problema distinto
(ubicación de funciones de banda base, no apagado de celdas/RAN).
**Cero** de los 917 tocan apagado de estaciones base o eficiencia
energética de RAN, **según el filtro de palabras clave usado** (redes/
telecom en el título) — un paper on-topic con un título que no incluya
esas palabras (p. ej. "traffic-aware sleep scheduling for energy
savings") se habría colado sin detectarse; el filtrado fue por título,
no por resumen ni texto completo de los 917. Es evidencia mucho más
fuerte que la búsqueda de la sesión anterior, pero sigue siendo
evidencia de ausencia, no prueba de ausencia — no cambia esa cautela
metodológica, y esta limitación del método la refuerza todavía más.

### Lo más cercano encontrado: un seminario invitado en IMDEA Networks, no una línea propia

`networks.imdea.org` sí tiene contenido directamente relevante, pero
hay que leerlo con precisión: el **11 de septiembre de 2026**, el
`#NetworksWeeklySeminar` (organizado con el grupo NETCOM del
Departamento de Ingeniería Telemática de la UC3M) tuvo una **charla
invitada** — no un proyecto propio de IMDEA — de **Tianxin Wang**
(investigadora postdoctoral en la Universidad de Edimburgo) sobre
**TWINERGY**: "Digital Twin Empowered Practical Energy Saving in
Heterogeneous Mobile Networks". Su enfoque: un gemelo digital de red
de alta fidelidad busca decisiones seguras de apagado de estación
base y las traduce a umbrales para políticas ya desplegadas basadas en
umbrales, combinando el gemelo digital con aprendizaje por refuerzo
multiagente. Resultados: 26,0%/12,4% de ahorro energético en
evaluación 4G/5G con gemelo digital, y 13,07%/12,20% en redes reales
rurales/densas 5G sin degradar la calidad de servicio. **Sigue siendo
un enfoque de dos etapas** (el gemelo digital genera la decisión,
luego se traduce a umbral) — no menciona *decision-focused learning*.
Al ser una charla invitada de fuera, no cambia el argumento de
empleabilidad con IMDEA Networks como institución (Arlet sigue siendo
el precedente real), pero sí confirma que el tema interesa lo bastante
para que IMDEA Networks organice un seminario sobre él en fechas muy
recientes.

### El hallazgo que sí cambia algo: quién en IMDEA Networks trabaja en esto de verdad

**Dr. Orlando E. Martínez-Durive**, investigador postdoctoral del
**Networks Data Science Group** de IMDEA Networks (dirigido por el
Dr. Marco Fiore), tiene como línea de investigación declarada
literalmente **"ML solutions for energy-saving policies for mobile
networks"**. No es una inferencia — está en su propia página del
instituto. Su publicación más relevante en esto es *"An Evaluation of
RAN Sustainability Strategies in Production Networks"* (IEEE INFOCOM
2025), fruto de una estancia en **Telefónica Innovación Digital**
(febrero 2023 - agosto 2024): evalúa **cinco políticas de apagado de
celda basadas en umbrales fijos** desplegadas en una red de producción
real a gran escala, y concluye que las redes de producción de hoy
dependen de políticas simples y pide explícitamente **"enfoques más
flexibles"**. Es importante leer esto con precisión: **no** resuelve
el hueco del Camino D — no usa predicción de tráfico ni DFL/SPO, mide
políticas de umbral tal cual están desplegadas — pero sí es la
confirmación más fuerte hasta ahora de dos cosas: (1) que el problema
real de producción sigue resuelto con reglas simples, dejando hueco de
verdad para algo más sofisticado, y (2) que hay un investigador
concreto, activo, publicando en 2025, con acceso a datos de operador
real (vía Telefónica), cuya línea es exactamente el dominio del Camino
D. Email: `orlando.martinez@networks.imdea.org` (formato deducido de
la página, confirmarlo antes de escribir).

### Telecom Italia (Milán/Trentino): confirmado

El conjunto abierto de CDR de Milán, candidato mencionado sin verificar
en `lluvia-de-ideas.md`, está confirmado: Öztürk, Abubakar y Nadas
(2021, *IEEE Transactions on Green Communications and Networking*,
acceso abierto CC-BY, metadatos verificados con Scite) lo usan
directamente para exactamente este problema — apagado de celdas con
RL informado por predicción de tráfico — y lo describen como "the open
call detail record (CDR) data set from the city of Milan, Italy".
Añadido a `Bibliografia.bib` junto con el paper de Martínez-Durive.

### Conclusión de esta revisión

El hueco identificado el 2026-09-14 (aplicar DFL/SPO, o simplemente la
pregunta de "¿cuánta precisión de pronóstico se traduce en cuánto
ahorro energético real?", al apagado de estaciones base) **sigue sin
encontrarse reclamado por nadie**, y esta vez con una búsqueda mucho
más amplia (tres conectores, varias formulaciones, y el grafo completo
de citas del paper fundacional de SPO). Eso no lo convierte en
garantía — la cautela de la revisión anterior sigue aplicando — pero
sí sube la confianza. Además, ahora hay un contacto concreto y activo
en IMDEA Networks (Martínez-Durive) cuya propia publicación de 2025
deja dicho, en sus propias palabras, que faltan "enfoques más
flexibles" que los umbrales fijos de hoy — lo cual es, de hecho, un
apoyo directo a la premisa del Camino D, no solo la ausencia de una
objeción.

**No decidido aquí:** si esto es suficiente para que Angel se decante
por el Camino D en firme, o para escribir a alguien (a Martínez-Durive,
a un tutor de la USAL, o ambos). Sigue siendo su decisión.

## Revisión 2026-09-16 (segunda pasada): profesorado real del MUSI, fuente primaria

Angel pidió investigar más profesores candidatos y sus líneas. La
tabla de `## Tutores de TFM` de arriba se construyó navegando la web
de BISITE — útil, pero es una fuente secundaria. Esta vez se usó la
fuente primaria correcta: el **"Perfil del Currículum Vitae del
Personal Docente e Investigador que imparte docencia en la
titulación"** del MUSI, curso 2024-2025, documento oficial de la USAL
para la renovación de la acreditación
(`https://usal.es/files/cv/sistinteligentes-4314233_cvprof24-25.pdf`,
28 páginas, texto extraído con `pymupdf` porque `poppler-utils` volvió
a fallar con el mismo 404 de índice caducado ya documentado en
`ejercicio-interactivo/SKILL.md`). Lista a los 18 profesores que
impartían docencia en el MUSI en el curso 2024-2025, con su grupo de
investigación, líneas y proyectos activos — no una lista de "quién
está en BISITE", sino de quién enseñaba en el máster.

**Aviso de fecha, corregido tras que Angel lo señalara:** 24-25 **no
es el curso actual** (hoy es septiembre de 2026, así que ya se cursó
también el 25-26) — es simplemente **la versión más reciente que la
USAL ha publicado**. Comprobado en vivo: ni
`sistinteligentes-4314233_cvprof25-26.pdf` ni `...cvprof26-27.pdf`
existen (404 ambos), y hasta la propia página
`https://usal.es/master-sistemas-inteligentes`, titulada "Curso
2026/2027", enlaza ese mismo PDF de 24-25 — la USAL no lo actualiza
cada curso. Consecuencia real: cada dato de proyecto financiado
(código de referencia, importe, fechas) sigue siendo verificado y
fiable, pero el vínculo concreto "esta persona imparte en el MUSI" es
una foto con hasta dos cursos de antigüedad, no una confirmación de
que siga siendo así hoy. Quien retome esto y quiera confirmarlo del
todo: preguntar directamente, no asumir que la lista de abajo sigue
100% vigente.

### Hallazgo que corrige la tabla anterior: tres candidatos no aparecen aquí

**Sara Rodríguez González, Pablo Chamoso Santos y Alfonso
González-Briones no figuran en este documento oficial de docencia del
MUSI 2024-2025.** Esto no demuestra que no puedan ser tutores del TFM
(la normativa de tutoría puede no exigir impartir una asignatura
concreta del máster — pendiente de confirmar en el Reglamento de TFM
ya en esta carpeta), pero sí es una discrepancia real con la tabla
anterior, que los presentaba como los candidatos más fuertes sin haber
verificado esto. Matiz a favor de Chamoso: **sí aparece** como
miembro del equipo (no IP) del proyecto SUNHIVE (ver abajo) — sigue
activo en investigación con BISITE, solo que no consta que enseñe en
el MUSI este curso.

### Candidatos nuevos o reforzados, con proyecto financiado verificado

| Candidato | Categoría / área | Asignatura MUSI 24-25 | Proyecto financiado verificado (fuente: `produccioncientifica.usal.es`) | Encaje |
|---|---|---|---|---|
| **Juan Manuel Corchado Rodríguez** | Catedrático, Ciencia Computación e IA. Director BISITE (ya conocido, reforzado aquí) | Inteligencia Ambiental y Sistemas Multiagente | **IP de 6GEMELLUS** ("Entorno avanzado... IA eXplicable, Gemelos Digitales y Ciberseguridad en el ámbito del 5G avanzado y el 6G", ref. TSI-064100-2023-0019, €332.449, Ministerio de Asuntos Económicos y Transformación Digital, ejecutado ene-2024 a jun-2025, **ya finalizado**). También IP de SCRIN (IoT seguro) y de "Virtualización para la Protección de redes IoT en infraestructura de Comunicaciones 5G" | **El más fuerte para el Camino D con docencia real en el máster** — a diferencia de Martínez-Durive (IMDEA), él sí puede ser tutor formal. El proyecto ya cerró, pero el track record en 5G/6G de BISITE es real y verificado, no solo declarado |
| **Pastora Isabel Vega Cruz** | Catedrática, Ingeniería de Sistemas y Automática. Nueva | Nuevas Tendencias en Sistemas Inteligentes / Control Inteligente / Herramientas Interactivas de Simulación y Control | **IP** de "Aprendizaje automático y metodologías híbridas para sistemas de aguas urbanas óptimos y energéticamente neutros" (PID2024-156522OB-C31, financiación nacional competitiva 2024) y de control distribuido con teoría de juegos (PID2019-105434RB-C31). Además, miembro del equipo (no IP) de **SUNHIVE** — ver abajo | Fuerte para el Camino A: control/optimización + ML aplicado a sistemas energéticamente neutros, con financiación activa real, no solo líneas declaradas en una web |
| **María Belén Pérez Lancho** | Profesora Titular, Ingeniería de Sistemas y Automática. Nueva | Mismas asignaturas que Vega Cruz | Miembro del equipo de **SUNHIVE** y de los proyectos IoT/5G de BISITE (SCRIN, virtualización redes IoT 5G) | Puente entre Camino A y Camino D — es de los pocos con proyectos activos en ambos frentes a la vez |
| **Emilio Santiago Corchado Rodríguez** | Catedrático, Ciencia Computación e IA (no confundir con Juan Manuel — es su hermano, confirmado por prensa independiente: Salamancahoy, 31/05/2024, artículo centrado en Juan Manuel Corchado como rector electo de la USAL, que dice de él: "...con eventos como Startup Olé, que dirige su hermano Emilio Corchado" — el sujeto elidido de la frase es Juan Manuel, no otra persona mencionada antes en el artículo; ambos catedráticos en el mismo departamento). Nueva | **Computación Neuroborrosa** — la asignatura que la Opción A original ya conectaba con lógica difusa | Coordina el programa de doctorado "Energía y Propulsión Marina"; participa en las plataformas de energía renovable/Edge-IoT de BISITE | Encaje directo con la asignatura de Angel y con energía, aunque sin un proyecto de IP tan concreto como los de arriba |
| **María Angélica González Arrieta** | Profesora Titular, Ciencia Computación e IA. Nueva | También Computación Neuroborrosa | Mismos proyectos BISITE de energía/IoT/5G que los Corchado (Edge-IoT DLT, SCRIN, virtualización redes 5G) | Alternativa si los de arriba no tienen hueco |

**Importante — quién NO es candidato pese a lo prometedor de su
proyecto:** el **IP real de SUNHIVE** ("Federated Learning and
Bio-inspired models for optimising demand-response in photovoltaic
generation", CPP2022-009747, €460.875, Ministerio de Ciencia e
Innovación, en ejecución hasta oct-2026 — el proyecto de energía +
aprendizaje federado más fuerte y mejor financiado de todos los
encontrados en esta sesión) es **Fernando de la Prieta Pintado**, que
**no aparece en el documento de docencia del MUSI 24-25**. No consta
que pueda ser tutor formal del TFM por esta vía; como mucho, un
colaborador si el reglamento admite cotutoría con alguien fuera de la
lista de profesorado del máster — sin confirmar.

### Contacto no-investigador a tener presente

**Roberto Therón Sánchez**, Catedrático, es el **Director actual del
MUSI** ("Dtor. Máster Tipo 1 MU Sistemas inteligentes") y Presidente de
la Comisión de Máster — su línea de investigación (analítica visual,
interacción persona-ordenador) no encaja con ningún camino del TFM,
pero es el contacto procedimental si hace falta resolver algo a nivel
de máster, no de tutoría de investigación.

### No decidido aquí

Sigue sin elegirse ningún camino ni ningún tutor. Esta tabla amplía las
opciones con fuente primaria verificada — no sustituye la decisión de
Angel entre A/B/C/D, ni descarta a Sara Rodríguez/Chamoso/
González-Briones, solo señala que su presencia en la docencia oficial
del MUSI este curso no está confirmada.

## Empleabilidad siendo extracomunitario: Networks frente a Energía (2026-09-14)

Angel preguntó, sabiendo que le gusta más la energía, en cuál de los dos
institutos hay más posibilidades reales de contrato, beca o prácticas
**siendo cubano**. Lo que sigue es lo verificado en esa sesión. El punto
de partida está en `../admision-y-becas/becas-y-tramites-2026-2027.md`:
nacionalidad cubana, formación de ingeniería en RUT-MIIT (Moscú),
matrícula en MUSI condicionada a la apostilla del título.

### Tamaño y perfil de cada instituto

| | IMDEA Networks | IMDEA Energía |
|---|---|---|
| Plantilla | ~56 personas | ~158 (117 investigadores, 19 técnicos, 22 gestión) |
| Nacionalidades | 19 (cifra que el propio instituto publicita) | No publicada; documentación institucional en español |
| Idioma de trabajo | **Inglés** — se define a sí mismo como "English-speaking institute" | Español, con entorno descrito como internacional |
| Perfil dominante | 100 % computación y redes | Mayoría química, materiales, térmica; la parte computacional es la Unidad de Análisis de Sistemas |

**Lectura honesta del tamaño:** en bruto, Energía casi triplica a
Networks, y eso sí es un argumento a su favor. Pero de sus 117
investigadores, la mayoría están en laboratorios experimentales. Para un
perfil de IA y telecomunicaciones, el número de plazas *relevantes*
probablemente favorece a Networks, no a Energía. No está medido: es una
inferencia del reparto por unidades, no un dato publicado.

### Vía de entrada concreta encontrada en Networks

Networks publica **plazas de doctorando asalariadas** (contrato, no
beca), con el candidato pre-aceptado condicionalmente en el programa de
doctorado de la UC3M u otra universidad de Madrid. Piden CV, carta de
motivación y dos cartas de referencia. Declaran explícitamente que
promueven la diversidad y no discriminan por origen étnico.

En el momento de esta consulta tenían abierta una plaza titulada
**"PhD Student Position in Trustworthy Agentic AI for 6G Networks"** —
IA aplicada a redes 6G, exactamente el cruce del camino D.

### Lo jurídico, que es lo que de verdad decide

Cuatro hechos verificados que cambian el cálculo:

1. **Un contrato vale mucho más que una beca.** Las becas públicas
   españolas remiten al régimen del RD 1721/2007, con requisito de
   nacionalidad/residencia — es justo el obstáculo ya documentado para
   la Beca de Colaboración. Un contrato laboral, en cambio, sí
   construye camino hacia la residencia. Que Networks pague sus plazas
   de doctorado como contrato, y no como beca, no es un detalle
   administrativo: es la diferencia entre una vía que lleva a alguna
   parte y otra que no.
2. **Con el permiso de estudiante ya se puede trabajar hasta 30 h
   semanales**, sin permiso aparte, desde el RD 629/2022 (en vigor el
   16/08/2022), siempre que sea compatible con los estudios. Esto
   habilita prácticas remuneradas o media jornada *durante* el máster.
3. **El permiso de investigador de la Ley 14/2013** (sección de
   movilidad internacional) **no aplica la situación nacional de
   empleo** — es decir, no hay que demostrar que ningún español o
   comunitario podía ocupar el puesto. Por eso un organismo de
   investigación es, para un extracomunitario, de los empleadores
   jurídicamente más fáciles que existen en España. Aplica a los dos
   institutos por igual, pero solo sirve si hay puesto.
4. **Tras titularse hay una autorización de residencia para búsqueda de
   empleo de 24 meses improrrogables** (DA 17.ª de la Ley 14/2013,
   ampliada de 12 a 24 por la Ley 28/2022; **la cifra de 12 meses es la
   redacción derogada de 2018, que muchas gestorías siguen
   publicando**). Se pide en los 60 días naturales previos a la
   expiración de la autorización de estudios, o en los 90 posteriores
   con riesgo de procedimiento sancionador. **No habilita por sí sola a
   trabajar**. El RD 316/2026 habilitaría provisionalmente en cuanto se
   admite a trámite la solicitud de cambio a residencia y trabajo, pero
   **ese punto concreto procede de resúmenes de terceros y sigue sin
   confirmar en el BOE**.
   Detalle completo y fuentes en
   `../admision-y-becas/becas-y-tramites-2026-2027.md`.

### Conclusión

Para **contrato**, Networks gana con claridad: idioma inglés, 19
nacionalidades sobre unas 56 personas, plazas asalariadas en vez de
becas, contratación
internacional habitual, y una plaza abierta justo en IA para 6G. Para
**volumen bruto de plantilla**, gana Energía, pero en áreas que no son
las de Angel.

**No obliga a renunciar a la energía.** La eficiencia energética de red
es literalmente una de las áreas declaradas de Networks (proyectos
MAP-6G, RISC-6G, TUCAN6-CM). El camino D permite trabajar sobre consumo
energético dentro del dominio de redes.

### Pendiente de verificar

**Solo si el criterio volviera a IMDEA Energía** (hoy descartado, ver
arriba):

- Si sus becas de prácticas (350 h, hasta 2.500 €) admiten
  extracomunitarios y si exigen convenio con la universidad de
  matrícula. **Salamanca está a ~2,5 h de Madrid**: unas prácticas
  curriculares exigirían convenio USAL-IMDEA y resolver el
  desplazamiento. No comprobado ninguno de los dos puntos.
- Plazas abiertas actuales en IMDEA Energía con perfil computacional.

**Vigentes:**
- El requisito de medios económicos del permiso de búsqueda de empleo:
  **tanto la cuantía del IPREM vigente como la base de cálculo**. Que
  el permiso dure 24 meses no implica que haya que acreditar medios
  para los 24 — ni el texto del BOE ni la Hoja informativa 20 lo dicen.
  Ambas cosas están pendientes.
- Los tres dominios de IMDEA seguían bloqueados por la política de red
  del entorno cuando se escribió esto, así que todo lo anterior se
  obtuvo por búsqueda indirecta. **La lista de dominios a autorizar se
  mantiene solo en la entrada del 2026-09-14 de `lluvia-de-ideas.md`**,
  no aquí.

### Precedente real: el camino de Arlet (confirmado por Angel, 2026-09-14)

Angel precisó que **Arlet entró a trabajar con la oportunidad de empezar
el doctorado, y compagina trabajo y doctorado**. Eso es exactamente el
modelo de plaza asalariada de doctorando descrito más arriba: contrato
laboral y doctorado a la vez, no beca.

Vale más que cualquier búsqueda web hecha en esta sesión, por tres
motivos:

1. **Demuestra que la vía funciona para una persona cubana**, en ese
   instituto concreto, y hace poco. No es una inferencia a partir de
   estadísticas de plantilla: es un caso real y cercano.
2. **Es el desenlace bueno del problema de extranjería.** Quien sale del
   máster con contrato firmado no necesita la autorización de búsqueda
   de empleo — ese permiso es la red de seguridad para quien termina sin
   oferta, no el objetivo. Su duración quedó verificada en **24 meses
   improrrogables** (ver `../admision-y-becas/becas-y-tramites-2026-2027.md`),
   lo que da bastante margen; aun así, siguiendo el camino de Arlet ese
   permiso no llega a hacer falta.
3. **Arlet conoce el procedimiento por dentro**: cómo se enteró de la
   plaza, en qué mes se convoca, qué pesó en la selección, y cómo se
   resolvió el cambio de situación de estudios a trabajo. Preguntárselo
   es más barato y más fiable que seguir investigando por fuera.

**Consecuencia para la planificación del TFM:** si la meta es reproducir
ese camino, el TFM no es solo un requisito académico — es la carta de
presentación técnica ante el tribunal de selección de una plaza de
doctorando en ese ámbito. Eso refuerza el camino D (redes) frente al
tema de energía: un TFM sobre redes leído por un comité de IMDEA
Networks pesa de otra forma que uno sobre baterías.
