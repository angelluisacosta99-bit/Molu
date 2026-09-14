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
  9(2):530-543, DOI `10.1109/tsg.2016.2555245` — el FLC de 25 reglas.
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
generalizan en series de energía (2604.22328); si pueden sustituir a
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
`numpy.org` y `pandas.pydata.org` (ver entrada anterior). Alternativa
sin depender de eso: descargar los datos desde VS Code en la máquina de
Angel, que es donde el plan ya dice que corre el código pesado.

### Sin GPU: confirmado que no hace falta (si se va por modelos fundacionales)

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
  DOI `10.1109/tpwrs.2023.3317534` (metadatos verificados con Scite).
  El título es, literalmente, la pregunta de investigación que se iba a
  proponer. Además deriva **fórmulas analíticas de sensibilidad** del
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

- **Enviado** a `bisite@usal.es` (13/09/2026): propuesta de TFM +
  colaboración, nombrando explícitamente a Pablo Chamoso y su tesis
  sobre arquitecturas multiagente, mencionando la línea de energía de
  BISITE y la posible Beca de Colaboración en Departamentos. Sin
  respuesta aún a la fecha de este registro.
- Ver también `master-sistemas-inteligentes/admision-y-becas/becas-y-tramites-2026-2027.md`
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
