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

## Tutores de TFM — candidatos concretos

| Candidato | Especialidad | Encaje |
|---|---|---|
| **Pablo Chamoso Santos** | Profesor Titular, BISITE desde 2011. Tesis doctoral: "Arquitectura multiagente auto-adaptativa para la gestión de smart cities". Coordina el grupo de transferencia "DeepTech" (IA, IoT, Blockchain). | **Alto** — su propia tesis es del mismo dominio que la Opción B. Primera opción. |
| **Juan Manuel Corchado** | Director de BISITE, contacto principal del grupo (+34 923 294 400 ext. 1525). Línea de energía confirmada: Ambient Intelligence, Energy Efficiency, Green Computing. | Alto como puerta de entrada/director del grupo, aunque como director puede tener menos disponibilidad para tutorías directas. |
| Francisco José García Peñalvo, Alicia García-Holgado, Diego Manuel Jiménez Bravo | Área de Ciencia de la Computación e IA (30 investigadores en total en esta área) | Sin confirmar línea exacta — preguntar si Chamoso no está disponible. |
| **Dr. Carlos García Figuerola** (`figue@usal.es`) — tutor del TFM de Arlet Acosta González ("Caracterización de las darknets", 2024) | Cibermetría, análisis de redes/grafos, minería web | **Bajo** para este tema — no hay overlap natural con energía/smart grid salvo forzando el TFM hacia análisis de topología de red como grafo. Plan de respaldo, no primera opción. |

Fuente BISITE energía: `https://bisite.usal.es/es/investigacion/lineas-investigacion/energia`
Departamento (90 investigadores, 4 áreas): `https://produccioncientifica.usal.es/unidades/1871/investigadores`

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
