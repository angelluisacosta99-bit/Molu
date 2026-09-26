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

## 3. Opciones dentro del presupuesto

| Opción | VRAM | Precio aprox. (sept. 2026) | Veredicto |
|--------|------|----------------------------|-----------|
| **NVIDIA RTX 5060 Ti 16 GB** (nueva) | 16 GB | 490–600 € | ✅ **Recomendada.** 16 GB + CUDA, nueva y con garantía |
| NVIDIA RTX 3060 12 GB (segunda mano) | 12 GB | 235–250 € | 👍 La más barata que sirve de verdad. Riesgo de segunda mano |
| AMD RX 9060 XT 16 GB (nueva) | 16 GB | 350–490 € | ⚠️ Más barata por GB, pero sin CUDA: más difícil para empezar |
| RTX 5060 / 5060 Ti **8 GB** | 8 GB | — | ❌ No comprar para IA |

Cuidado: la RTX 5060 Ti existe en **8 GB y en 16 GB** con el mismo
nombre. Comprueba que el anuncio dice **16 GB** antes de pagar.

### Recomendación

1. **Si puedes llegar a ~500 €:** RTX 5060 Ti **16 GB** nueva. Es la
   opción con menos sorpresas para aprender y para el máster.
2. **Si quieres gastar lo mínimo:** RTX 3060 **12 GB** de segunda mano
   (~240 €). Suficiente para el TFM y LLMs pequeños.
3. La AMD solo si encuentras una oferta muy buena y no te importa pelear
   con la instalación.

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
| Fuente | **Pendiente** (mirar la etiqueta lateral) | — |

Conclusiones:

- **Compatibilidad:** la RTX 5060 Ti funciona en PCIe 4.0 x8 en esta placa;
  la pérdida frente a x16 es mínima, sobre todo para IA.
- **Consumo:** todas las opciones consumen menos que la 4070 (160–180 W
  frente a ~200 W), así que la fuente debería valer. Confirmarlo con la
  etiqueta de todas formas.
- **Tamaño:** si cabía la 4070 Windforce, cabe una tarjeta de largo
  parecido o menor. Comparar el largo del modelo concreto antes de pagar.
- **Antes de comprar, averiguar qué falló.** Si fue la fuente o un pico
  de tensión, la tarjeta nueva puede acabar igual. La prueba más barata:
  poner la 4070 en otro PC, o una tarjeta prestada en este.
- **Garantía de la 4070:** el equipo es de Роботкомп. Revisar su garantía
  (y la de Gigabyte, con el número de serie) antes de darla por perdida.

## 6. Lista de comprobación antes de comprar

- [ ] Modelo de la fuente de alimentación y sus vatios (mirar la
      etiqueta de la fuente)
- [ ] Largo máximo de tarjeta que cabe en la caja
- [ ] Modelo de placa base y de procesador
- [ ] Cantidad de RAM
- [ ] Sistema operativo (Windows 10/11 o Linux)
- [ ] El anuncio dice **16 GB** (o 12 GB en la RTX 3060)

Con estos datos, Claude puede confirmar que la tarjeta elegida es
compatible antes de pagar.

## 7. Después de montarla

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
