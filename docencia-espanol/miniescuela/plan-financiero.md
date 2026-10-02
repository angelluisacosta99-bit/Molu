# Miniescuela: plan financiero y estructura legal

Plan para derivar a otros profesores los alumnos que Angel no puede
atender (falta de horario, o niños pequeños), cobrando una comisión por
la derivación y la gestión.

**Calculadora interactiva** (comisión, impuesto, transferencias y
proyección al crecer el equipo):
<https://claude.ai/artifact/WcirE8m7BDg1eS1V3rfLMn>

Este documento hace aritmética y recoge investigación verificada. **No es
asesoría fiscal.** Cada punto marcado como PROBABLE o NO VERIFICADO hay
que contrastarlo con un contable antes de actuar.

---

## 1. Situación de partida

| Dato | Valor |
|---|---|
| Precio de la clase | 2.000 ₽/hora |
| Impuesto que paga Angel | 6 % |
| Primera profesora | Una amiga, **sin dar de alta** |
| Cobro | Los alumnos pagan a Angel (ella no puede abrir cuenta) |
| Pago a la profesora | Vía USDT (planteamiento inicial) |
| Comisión decidida | **20 %** |

El horario del máster (lunes a viernes, 16:00–20:00 hora de Madrid,
28 sep – 18 dic 2026) bloquea justamente la franja en la que dan clase
los alumnos rusos. La miniescuela nace de ahí: los alumnos que llegan no
se pierden, se derivan.

---

## 2. Hallazgos verificados que cambian el plan

### 2.1 Angel casi con seguridad es ИП на УСН «доходы», no самозанятый

El régimen НПД (самозанятый) solo lo pueden usar ciudadanos de Rusia, de
la UEEA (Bielorrusia, Kazajistán, Armenia, Kirguistán) y de Ucrania —
art. 5 ч.3 de la ley 422-ФЗ. **Un ciudadano cubano no puede serlo**, ni
con ВНЖ. Además, un самозанятый cobrando a personas físicas pagaría 4 %,
no 6 %. Las dos señales apuntan a ИП на УСН «доходы».

CONFIRMADO: [consultant.ru](https://www.consultant.ru/law/podborki/mozhet_li_inostrannyj_grazhdanin_stat_samozanyatym/) ·
[regberry.ru](https://www.regberry.ru/nalogooblozhenie/mozhet-li-inostrannyy-grazhdanin-byt-samozanyatym)

**Acción:** confirmar el régimen exacto antes de montar nada encima.

### 2.2 Sin contrato de agencia, el impuesto se come el 30 % del margen

En УСН «доходы» la base imponible es el **ingreso bruto**: lo que se le
paga a un colaborador no se deduce (para eso existe УСН «доходы минус
расходы», al 15 %). Con 2.000 ₽ cobrados y 1.600 ₽ que son de ella,
Angel paga el 6 % de 2.000 ₽ = **120 ₽**, no el 6 % de su comisión de
400 ₽. Es decir, **el 30 % de su comisión bruta se va en impuesto**.

CONFIRMADO: [e-kontur.ru](https://e-kontur.ru/enquiry/2103) ·
[base.garant.ru](https://base.garant.ru/72113648/31de5683116b8d79b08fa2d768e33df6/)

### 2.3 La salida legal: договор агентский (contrato de agencia)

Con un contrato de agencia entre Angel y la profesora, el dinero del
alumno que pertenece a ella **no computa como ingreso de Angel** — solo
su comisión lo hace (art. 251 п.1 пп.9 НК РФ, aplicable también a УСН
«доходы»). El impuesto pasa a calcularse sobre 400 ₽, no sobre 2.000 ₽.

CONFIRMADO: [kontur.ru](https://kontur.ru/qa/18093) ·
[consultant.ru](https://www.consultant.ru/document/cons_doc_LAW_28165/850d11e08b0cb09a2318af00f2f0aff805d39c85/)

**Importante:** esta vía es válida para un ИП y está **prohibida en
НПД** — la 422-ФЗ (art. 4 ч.2 п.5) excluye del régimen a quien actúa en
interés de otro por contrato de agencia o comisión. Una razón más para
confirmar primero el punto 2.1.

CONFIRMADO: [e-kontur.ru](https://e-kontur.ru/enquiry/1688/npd-tolko-v-svoih-interesah)

### 2.4 La profesora debe darse de alta — y es trivial hacerlo

El contrato de agencia necesita que ella esté registrada para ser real y
defendible: sus чеки son la prueba documental del reparto ante Hacienda
y ante el banco.

El alta como самозанятая es **gratuita**, se hace por la app «Мой налог»
con pasaporte y selfie, **en menos de 10 minutos**, sin visita a
Hacienda, y con un bono inicial de 10.000 ₽ que rebaja el tipo al 3–4 %
hasta agotarse. Requisito: nacionalidad rusa, de la UEEA o ucraniana
(mismo límite del punto 2.1 — si ella no cumple, habría que buscar otra
figura).

CONFIRMADO: [kontur.ru](https://kontur.ru/elba/spravka/79495-kak_oformit_samozanyatost_v_2025_godu) ·
[t-j.ru](https://t-j.ru/moi-nalog/)

Trabajar sin registro expone a una multa administrativa de 500–2.000 ₽
(art. 14.1 КоАП) — ridícula — pero el riesgo real es fiscal: НДФЛ del
13 % sobre todo lo cobrado, más recargos.

### 2.5 Pagarle en USDT no es viable legalmente

El art. 14 ч.5 de la ley **259-ФЗ** prohíbe **aceptar criptomoneda como
contraprestación por servicios** a personas físicas que pasen 183 días o
más al año en Rusia. Ella, viviendo en Rusia, no puede aceptar
legalmente USDT como pago por sus clases. Poseer y transferir cripto no
está prohibido; usarla como medio de pago interno, sí.

CONFIRMADO: [base.garant.ru](https://base.garant.ru/74451466/888134b28b1397ffae87a0ab1e117954/) ·
[sberbusiness.live](https://sberbusiness.live/publications/zakon-o-tsifrovoi-valyute-chto-razresheno-biznesu-i-fizlitsam)

A eso se suma el riesgo bancario: desde enero de 2026 los bancos
bloquean más operaciones por indicios ampliados de transferencia
sospechosa, y las transferencias P2P regulares entre particulares son la
zona de máximo riesgo (115-ФЗ / 161-ФЗ), con bloqueo simultáneo en todos
los bancos vía la base del Banco Central.

**Vía limpia:** transferencia bancaria rusa contra чек de ella. Además,
la comisión baja a cero, lo que elimina toda la optimización de
frecuencia de liquidación que hacía falta con USDT.

### 2.6 Lo que queda sin verificar

- **Cómo tributará España** estos ingresos cuando Angel sea residente
  fiscal allí, y si hay convenio de doble imposición Rusia-España
  plenamente operativo. NO VERIFICADO — es el punto que más dinero puede
  costar y el que conviene consultar con un asesor español **antes** de
  mudarse.
- Mantener ИП desde el extranjero es posible mientras la actividad y los
  clientes sigan en Rusia (PROBABLE, según fuentes especializadas, no
  una carta oficial).

---

## 3. Los números, al 20 % de comisión

Base: 2.000 ₽/hora, 16 horas al mes por profesor, impuesto del 6 %,
transferencia bancaria (0 ₽ de comisión).

### Sin contrato de agencia (situación actual)

| Concepto | Importe |
|---|---|
| Cobrado a los alumnos | 32.000 ₽ |
| − Parte de la profesora (fija, 1.600 ₽/hora) | −25.600 ₽ |
| − Impuesto (6 % de **todo** lo cobrado) | −1.920 ₽ |
| **Te queda a ti** | **4.480 ₽** |

### Con contrato de agencia

| Concepto | Importe |
|---|---|
| Cobrado a los alumnos | 32.000 ₽ |
| − Parte de la profesora (no es ingreso tuyo) | −25.600 ₽ |
| = Tu comisión (20 %) | 6.400 ₽ |
| − Impuesto (6 % de tu comisión) | −384 ₽ |
| Recibe la profesora | 25.600 ₽ |
| **Te queda a ti** | **6.016 ₽** |

El impuesto total pagado cae de 1.920 ₽ a 384 ₽: **1.536 ₽ al mes por
profesor que dejan de irse en impuestos** (18.432 ₽ al año). Lo que
cobra la profesora no cambia en ninguna de las dos tablas (25.600 ₽) —
todo el ahorro es para ti: tu neto pasa de 4.480 ₽ a 6.016 ₽ al mes.
Es una decisión de reparto, no de aritmética: el contrato de agencia
crea valor (el ahorro fiscal), y también se puede compartir con ella en
vez de quedártelo entero.

### Efecto en las cuotas de ИП

Las cuotas fijas de ИП (57.390 ₽ en 2026) se pagan igual, haya o no
miniescuela. Pero el recargo del **1 % sobre lo que exceda 300.000 ₽ de
ingresos** sí depende de la base:

- Sin agencia, con 5 profesores: ingresos computados 1.920.000 ₽/año →
  recargo ≈ 16.200 ₽.
- Con agencia, mismos 5 profesores: ingresos computados 384.000 ₽/año →
  recargo ≈ 840 ₽.

(En УСН «доходы» el impuesto se puede reducir con las cuotas pagadas —
confirmar el cálculo exacto con un contable.)

---

## 4. Si la escuela crece

Neto mensual de Angel, con contrato de agencia, 20 % de comisión y 16
horas al mes por profesor:

| Profesores | Horas/mes | Facturado | Tu neto/mes | Tu neto/año |
|---|---|---|---|---|
| 1 | 16 | 32.000 ₽ | 6.016 ₽ | 72.192 ₽ |
| 3 | 48 | 96.000 ₽ | 18.048 ₽ | 216.576 ₽ |
| 5 | 80 | 160.000 ₽ | 30.080 ₽ | 360.960 ₽ |
| 10 | 160 | 320.000 ₽ | 60.160 ₽ | 721.920 ₽ |

Supone 12 meses de actividad igual, lo que no ocurre: verano y
vacaciones bajan el volumen. Sirve como techo, no como previsión.

Umbral a vigilar: desde 2026 el límite de exención de IVA para ИП baja a
20 millones ₽ (15 en 2027, 10 en 2028). Muy lejos todavía.

---

## 5. Checklist de arranque

1. **Confirmar el régimen fiscal propio** (ИП на УСН «доходы» vs. otra
   cosa). Todo lo demás depende de esto.
2. **Que la profesora se dé de alta** como самозанятая por «Мой налог» —
   gratis, 10 minutos. Es el paso más barato y de mayor impacto.
3. **Firmar un договор агентский** entre ambos, con la comisión del 20 %
   por escrito. Plantilla revisada por un contable ruso, no una genérica
   de internet.
4. **Sustituir USDT por transferencia bancaria** contra чек de ella.
5. **Acordar la frecuencia de liquidación.** Sin comisión de por medio,
   semanal es perfectamente viable y construye confianza mucho más
   rápido que mensual.
6. **Consultar con un asesor español** cómo tributará todo esto desde
   España, antes de la mudanza.
7. **Dejar por escrito lo no financiero**: quién responde ante el alumno
   si la clase se cae, qué pasa si un alumno derivado quiere volver con
   Angel, y qué nivel/edades acepta cada profesor.

---

## 6. Qué replicar con futuros profesores

El modelo está pensado para escalar sin rehacer la cuenta cada vez:

- La comisión del 20 % es la misma para todos — evita negociaciones
  caso a caso y discusiones comparativas entre profesores.
- Cada profesor nuevo repite los pasos 2 y 3 del checklist: alta propia
  y contrato de agencia propio.
- Cada profesor recibe su propia liquidación: con transferencia bancaria
  el coste marginal es cero, así que el número de profesores no
  encarece la operación.
- El límite real de crecimiento no es fiscal, es de atención: cada
  profesor añade coordinación, resolución de incidencias y control de
  calidad. Ahí es donde conviene parar y pensar, no en los impuestos.
