# Compra de tarjeta gráfica (GPU) para IA

Guía para decidir qué tarjeta gráfica comprar para el PC de sobremesa,
con un presupuesto de **300–600 €**. Usos previstos: el TFM y las
asignaturas del máster (MUSI), y ejecutar IA en local (modelos de
lenguaje con Ollama o LM Studio).

> Precios consultados el **2026-09-26** (idealo.es, MediaMarkt,
> Chollometro, Wallapop, bestvaluegpu.com). Cambian cada semana, así que
> compruébalos otra vez antes de comprar.

## 1. Antes de nada: ¿hace falta para el TFM?

**Para la parte principal del TFM, no.** Chronos-2 (119,5 M parámetros)
hace inferencia zero-shot en CPU: un benchmark de 2026 lo ejecutó en un
Ryzen 7 con 16 GB de RAM y sin GPU (ver
`master-sistemas-inteligentes/trabajo-fin-de-master/ideas-tfm-energias-renovables.md`,
sección "Sin GPU para inferencia zero-shot").

La GPU **sí ayuda** para:

- El barrido completo de experimentos (varios modelos × horizontes ×
  configuraciones), que no está medido y podría tardar mucho en CPU.
- El fine-tuning de Chronos-2 o entrenar una red propia (LSTM,
  Transformer).
- Las asignaturas del máster con deep learning.
- Tener un LLM en local, privado y sin pagar una API.

**Alternativa gratis, para probar antes de gastar:**
[Kaggle Notebooks](https://www.kaggle.com/code) (unas 30 h de GPU a la
semana) y [Google Colab](https://colab.research.google.com/) (GPU T4 con
límite de sesión). Si con eso te basta para el TFM, puedes retrasar la
compra.

## 2. La regla más importante: la VRAM

Para IA, lo que más importa es la **memoria de la tarjeta (VRAM)**, no
lo rápida que sea en juegos. Si un modelo no cabe en la VRAM, o no
funciona o va muy lento.

| VRAM | Qué puedes hacer |
|------|------------------|
| 8 GB | Poco. **Evitar para IA.** |
| 12 GB | Fine-tuning de Chronos-2 sin problema; LLMs de ~7–12 B parámetros cuantizados |
| 16 GB | Lo anterior con margen; LLMs de ~14 B cuantizados, contextos más largos |

**Marca: NVIDIA mejor que AMD para quien empieza.** PyTorch, Hugging
Face y casi todos los tutoriales dan por hecho CUDA (el sistema de
NVIDIA). AMD funciona (ROCm, Vulkan), pero da más problemas de
instalación, sobre todo en Windows.

## 3. Opciones y precios reales (idealo.es, 2026-09-26)

**Aviso:** los precios "desde 470–520 €" que muestra idealo para la RTX
5060 Ti son de la versión de **8 GB**. La de 16 GB está ahora muy por
encima del presupuesto (ver tabla). Primera versión de esta guía lo
confundía; corregido el 2026-09-26.

### NVIDIA RTX 5060 Ti 16 GB, nueva (precio más bajo por modelo)

| Modelo | Precio |
|--------|--------|
| MSI 16G Ventus 2X OC Plus | 746 € |
| MSI 16G Shadow 2X OC Plus | 750 € |
| ASUS 16GB Dual OC | 781 € |
| Zotac 16GB AMP | 796 € |
| ASUS 16GB Prime OC | 825 € |
| PNY Dual Fan OC 16GB | 825 € |
| ASUS 16GB TUF Gaming OC | 850 € |
| Gigabyte Eagle OC Ice 16G | 938 € |
| Gigabyte Windforce OC 16G | 970 € |

### AMD RX 9060 XT 16 GB, nueva (Sapphire)

| Modelo | Precio |
|--------|--------|
| Sapphire Pure 16G | 593 € |
| Sapphire Pulse 16G | 644 € |
| Sapphire Nitro+ 16G | 673 € |

### Otras referencias

| Opción | VRAM | Precio aprox. | Veredicto |
|--------|------|---------------|-----------|
| RTX 3060 12 GB (segunda mano, Wallapop) | 12 GB | 235–250 € | ✅ **Mejor calidad-precio dentro del presupuesto** |
| RTX 5060 Ti 16 GB (segunda mano, eBay UE) | 16 GB | ~540 € | 👍 Si aparece en buen estado y con factura |
| RX 9060 XT 16 GB nueva | 16 GB | 593–673 € | ⚠️ Cabe justo, pero sin CUDA |
| RTX 5060 Ti 16 GB nueva | 16 GB | 746 € o más | ❌ Fuera de presupuesto ahora |
| RTX 5070 12 GB nueva | 12 GB | 774 € o más | ❌ Más cara y con menos VRAM |
| Cualquier tarjeta de **8 GB** | 8 GB | — | ❌ No comprar para IA |

Mismo nombre, dos memorias: comprueba siempre que el anuncio dice
**16 GB** (o 12 GB en la RTX 3060) antes de pagar.

### Recomendación

1. **Recomendada para el máster (Angel aún no ha decidido): RTX 3060 12 GB de segunda mano (~220–250 €).**
   Basta para el TFM y LLMs pequeños, y deja margen para cambiarla
   cuando bajen los precios.
2. **Solo si quieres 16 GB ya:** RTX 5060 Ti 16 GB de segunda mano (~540 €)
   con factura, o la RX 9060 XT 16 GB nueva (~593 €) si aceptas que la
   instalación de IA con AMD da más trabajo.
3. **Para la de 16 GB, esperar es opción:** la RTX 5060 Ti 16 GB está un ~48 %
   por encima de su media de 12 meses. Alerta de precio en idealo.es.

## 4. Puntos débiles y riesgos

- **Precios inflados ahora mismo.** En la UE, la RTX 5060 Ti 16 GB
  está un ~48 % por encima de su media de 12 meses (bestvaluegpu.com,
  septiembre 2026). Si no tienes prisa, crea una alerta de precio en
  idealo.es o Chollometro y espera una oferta.
- **Fuente de alimentación (PSU).** Estas tarjetas consumen unos
  160–180 W. Necesitas una fuente de calidad de **al menos 550 W** y con
  el conector PCIe de 8 pines. Es el error más común: la tarjeta no
  arranca o el PC se apaga.
- **Espacio en la caja.** Mide el hueco disponible (largo y grosor) y
  compáralo con la ficha de la tarjeta concreta; varía entre fabricantes.
- **Placa base antigua (PCIe 3.0).** La RTX 5060 Ti usa solo 8 carriles
  PCIe. En una placa PCIe 3.0 pierde algo de rendimiento; para IA
  importa poco, pero conviene saberlo.
- **Segunda mano (Wallapop, eBay).** Pide verla funcionando (un
  benchmark como FurMark o un juego durante 10 minutos), pregunta si se
  usó para minería, y paga por un método con protección al comprador
  (el envío protegido de Wallapop, no Bizum ni transferencia).
- **RAM del PC.** Para IA local conviene tener 32 GB de RAM; con 16 GB
  funciona, pero más justo.

## 5. Tu equipo: BOREY 2.0 Plus (Роботкомп)

| Pieza | Modelo | Qué implica |
|-------|--------|-------------|
| CPU | Intel Core i7-12700KF | **Sin gráficos integrados**: sin tarjeta, el PC no da imagen |
| Placa | ASUS Prime B660M-K D4 | Ranura PCIe 4.0 x16; cualquier opción de la tabla es compatible |
| RAM | 32 GB DDR4 3000 MHz | Suficiente para IA local |
| Almacenamiento | SSD 960 GB + SSD 480 GB (PCIe) | Sin problema |
| Monitor | MSI Optix G27C7 (1080p, 165 Hz, DisplayPort y HDMI) | Cualquier tarjeta de la tabla sobra para él |
| GPU anterior (dañada) | Gigabyte RTX 4070 Windforce (GV-N4070WF3-12GD), 12 GB | Consumía ~200 W: la fuente la aguantaba |
| Fuente | 1STPLAYER FK 7.0, modelo PS-700FK, 700 W (+12 V: 58 A / 696 W; foto de la etiqueta, 2026-10-08) | Sobra para las RTX 5060 Ti (180 W). Sin sello 80 Plus visible en la etiqueta. Fabricada ~2023 (código 230618). Falta confirmar que tiene cable PCIe de 8 pines libre |

Conclusiones:

- **Compatibilidad:** la RTX 5060 Ti funciona en PCIe 4.0 x8 en esta placa;
  la pérdida frente a x16 es mínima, sobre todo para IA.
- **Consumo:** todas las opciones consumen menos que la 4070 (160–180 W
  frente a ~200 W), así que la fuente debería valer. Confirmarlo con la
  etiqueta de todas formas.
- **Tamaño:** si cabía la 4070 Windforce, cabe una tarjeta de largo
  parecido o menor. Comparar el largo del modelo concreto antes de pagar.
- **Diagnóstico hecho:** Angel probó el PC con otra tarjeta y
  funcionaba. La averiada es la 4070, no el PC ni la fuente, así que una
  tarjeta nueva no corre el riesgo de estropearse por la misma causa.
- **La 4070 no tenía garantía ni arreglo.** Se vendió rota por unos
  110 € (2026-09-26), así que una RTX 3060 12 GB de segunda mano sale
  por unos 110–140 € netos.

## 6. Qué comprar y dónde (Salamanca)

**Recomendación (sin decidir):** ver el apartado 3. La fuente ya
aguantaba la 4070, así que no hace falta cambiar nada más. Una RTX 4070
de segunda mano no compensa: las SUPER rondan los 600 € y siguen
teniendo 12 GB.

Cualquier fabricante conocido vale (ASUS, MSI, Gigabyte, Zotac, PNY).
Mejor dos o tres ventiladores que uno, y un largo igual o menor que el de
la 4070 Windforce.

Tiendas físicas en Salamanca (datos del 2026-09-26; confirmar por
teléfono que tienen el modelo de **16 GB** antes de ir):

| Tienda | Dirección | Notas |
|--------|-----------|-------|
| PCBox Salamanca | P.º del Dr. Torres Villarroel, 17 · 923 188 118 | Tienda de informática. L–V 10:00–14:30 y 16:30–20:00, S 10:00–14:00. Pueden pedirla si no la tienen |
| MediaMarkt Salamanca | Parque Comercial Capuchinos, Ctra. N-501, Santa Marta de Tormes | Su web anuncia la MSI RTX 5060 Ti 16G a 1.282 €: muy por encima de idealo |

Por internet suele salir más barata (precios del apartado 3), con envío
a Salamanca. Tienes 14 días para devolverla si la compras en una tienda
española.

**Estrategia calidad-precio:** mirar el precio más bajo en idealo.es y
Chollometro, y pedir a PCBox que lo iguale o se acerque. Pagar unos
30–50 € más en una tienda física compensa si te da tranquilidad tener
la garantía cerca.

## 7. Lista de comprobación antes de comprar

- [x] Modelo de la fuente de alimentación y sus vatios (1STPLAYER
      PS-700FK, 700 W; hecho 2026-10-08)
- [ ] Cable PCIe de 8 pines libre en la fuente (no confundir con el
      EPS de 8 pines de la CPU)
- [ ] Largo máximo de tarjeta que cabe en la caja
- [ ] Modelo de placa base y de procesador
- [ ] Cantidad de RAM
- [ ] Sistema operativo (Windows 10/11 o Linux)
- [ ] El anuncio dice **16 GB** (o 12 GB en la RTX 3060)

Con estos datos, Claude puede confirmar que la tarjeta elegida es
compatible antes de pagar.

## 8. Después de montarla

1. Instalar el driver de NVIDIA más reciente.
2. Instalar PyTorch con CUDA siguiendo el selector de
   [pytorch.org](https://pytorch.org/get-started/locally/).
3. Comprobar en Python que la detecta:
   ```python
   import torch
   print(torch.cuda.is_available(), torch.cuda.get_device_name(0))
   ```
4. Para LLMs locales: instalar [Ollama](https://ollama.com/) o
   [LM Studio](https://lmstudio.ai/) y probar un modelo pequeño.
