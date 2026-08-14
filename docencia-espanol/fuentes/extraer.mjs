// Extrae a Markdown el contenido transcrito de un ejercicio interactivo ya publicado.
//
// Lee el artefacto RENDERIZADO en un navegador y recorre el DOM, en vez de reinterpretar
// el HTML fuente: así lo que se archiva es exactamente lo que se verificó que funciona, y
// no una segunda transcripción que podría desviarse del original.
//
// Las respuestas correctas se obtienen rellenando todos los huecos con texto imposible y
// pulsando "Corregir todos": el motor deja entonces la respuesta correcta en cada .reveal.
//
// Uso:  NODE_PATH=/opt/node22/lib/node_modules node extraer.mjs <archivo.html> <código> > salida.md

import { createRequire } from "node:module";
import path from "node:path";

// NODE_PATH no lo respetan los módulos ESM; se resuelve playwright a mano.
const require = createRequire(import.meta.url);
const { chromium } = require(process.env.NODE_PATH
  ? path.join(process.env.NODE_PATH.split(":")[0], "playwright")
  : "playwright");

const [file, code] = process.argv.slice(2);
if (!file || !code) {
  console.error("uso: extraer.mjs <archivo.html> <código-de-acceso>");
  process.exit(1);
}

const browser = await chromium.launch({
  executablePath: "/opt/pw-browsers/chromium",
  args: ["--no-sandbox"],
});
const page = await browser.newPage();
await page.goto("file://" + path.resolve(file));
await page.fill("#gateInput", code);
await page.click("#gateBtn");
await page.waitForTimeout(400);

// Marcar cada hueco para poder localizarlo en el texto una vez extraído.
await page.evaluate(() => {
  document.querySelectorAll("main input.blank").forEach((el, i) => {
    el.dataset.slot = String(i);
    el.value = " IMPOSIBLE ";
  });
  document.querySelectorAll("main select.blank-select").forEach((el, i) => {
    el.dataset.slot = "S" + i;
    el.selectedIndex = 0;
  });
});
// Corregir todo para que cada .reveal contenga la respuesta correcta.
const btn = await page.$("#correctAllBtn");
if (btn) { await btn.click(); await page.waitForTimeout(600); }
// Los ejercicios de opción (chips) se corrigen por ejercicio; pulsamos todos por si acaso.
for (const b of await page.$$(".check-btn")) { await b.click().catch(() => {}); }
await page.waitForTimeout(600);

const md = await page.evaluate(() => {
  const out = [];
  const push = (s = "") => out.push(s);
  const clean = (s) => (s || "").replace(/\s+/g, " ").trim();

  // Texto de un nodo sustituyendo cada hueco por ___ y anotando su respuesta.
  function textWithBlanks(root) {
    const answers = [];
    const walk = (node) => {
      let s = "";
      for (const ch of node.childNodes) {
        if (ch.nodeType === 3) s += ch.nodeValue;
        else if (ch.nodeType !== 1) continue;
        else if (ch.matches?.("input.blank, select.blank-select, .vf-wrap")) {
          // La respuesta vive en el .reveal INMEDIATAMENTE posterior al hueco. Buscarlo con
          // querySelector sobre el padre devolvería siempre el primero — y en un párrafo
          // con varios huecos todos acabarían con la respuesta del primero.
          //
          // `.vf-wrap` es el hueco de verdadero/falso: su input real vive OCULTO dentro,
          // así que el hueco es la envoltura, no el input. Al no descender por ella, el
          // texto de los botones ("V", "F") no se cuela en la frase archivada.
          const rev = ch.nextElementSibling?.matches?.(".reveal") ? ch.nextElementSibling : null;
          const ans = clean(rev?.textContent).replace(/^→\s*/, "");
          answers.push(ans || "?");
          // Dos huecos seguidos sin texto entre medias (una casilla y unos botones, p. ej.)
          // se pegarían en el archivo: "**habla****regular**".
          if (/____$/.test(s)) s += " ";
          s += "____";
        } else if (ch.matches?.(".choice-group")) {
          // Las opciones (chips) se listan aparte entre corchetes, con la correcta en
          // negrita; aquí solo dejan su hueco para no pegarse al texto de la frase.
          s += "____";
        } else if (ch.matches?.(".reveal")) {
          continue; // ya recogido junto a su hueco
        } else if (ch.matches?.(".grading-note")) {
          continue; // se emite aparte
        } else if (ch.matches?.("br")) {
          s += "\n";
        } else if (ch.matches?.(".item-pre")) {
          // Etiqueta fija al principio de la fila; sin el espacio quedaría pegada al hueco.
          s += clean(ch.textContent) + " ";
        } else if (ch.matches?.(".speaker")) {
          // La letra del interlocutor de un diálogo es un <span> pegado al texto siguiente;
          // sin este espacio el archivo saldría con "APerdona..." en vez de "A Perdona...".
          s += clean(ch.textContent) + " ";
        } else if (ch.matches?.(".turno")) {
          // Cada turno de un diálogo se pinta como bloque: en el archivo van en líneas
          // aparte, o el segundo se pegaría al primero ("...al colegio?B Vienen a ser...").
          s += (s && !/\n$/.test(s) ? "\n" : "") + clean(ch.textContent);
        } else if (ch.matches?.(".open-model, .signature")) {
          // Se pintan como bloque aunque sean <span>, así que sin esto la firma de la postal
          // y las líneas de modelo de una redacción se pegarían al párrafo anterior.
          s += "\n" + walk(ch);
        } else s += walk(ch);
      }
      return s;
    };
    return { text: walk(root).replace(/[ \t]+/g, " ").trim(), answers };
  }

  function emitTheory(wrap) {
    for (const el of wrap.querySelectorAll(
      ".theory-group > h3, .theory-lead, .theory-points > li, .rule-box, .theory-table, .vocab-title, .vocab-chips, .wordsearch"
    )) {
      if (el.matches("h3")) { push(); push("#### " + clean(el.textContent)); push(); }
      else if (el.matches(".theory-lead")) { push(clean(el.textContent)); push(); }
      else if (el.matches(".theory-points > li")) {
        const label = clean(el.querySelector(".use-label")?.textContent);
        if (label) push("- " + label);
        for (const ex of el.querySelectorAll(".example")) {
          push((label ? "  - " : "- ") + "*" + clean(ex.textContent) + "*");
        }
        if (!label && !el.querySelector(".example")) push("- " + clean(el.textContent));
      }
      else if (el.matches(".rule-box")) {
        push();
        const h4 = el.querySelector("h4");
        if (h4) push("> **" + clean(h4.textContent) + "**");
        for (const p of el.querySelectorAll("p")) push("> " + clean(p.textContent));
        push();
      }
      else if (el.matches(".theory-table")) { push(); emitTable(el); push(); }
      else if (el.matches(".vocab-title")) { push(); push("**" + clean(el.textContent) + "**"); }
      else if (el.matches(".vocab-chips")) {
        push([...el.querySelectorAll(".vocab-chip")].map((c) => clean(c.textContent)).join(" · "));
        push();
      }
      else if (el.matches(".wordsearch")) {
        push(); push("```"); push(el.textContent.trim()); push("```"); push();
      }
    }
  }

  function emitTable(table) {
    const rows = [...table.querySelectorAll("tr")];
    if (!rows.length) return;
    const cellText = (c) => {
      const { text, answers } = textWithBlanks(c);
      let t = text.replace(/\n/g, " ");
      answers.forEach((a) => { t = t.replace("____", "**" + a + "**"); });
      return clean(t) || " ";
    };
    let headerDone = false;
    for (const tr of rows) {
      const cells = [...tr.children].map(cellText);
      push("| " + cells.join(" | ") + " |");
      if (!headerDone) {
        push("|" + cells.map(() => " --- ").join("|") + "|");
        headerDone = true;
      }
    }
  }

  // Los documentos por secciones envuelven cada una en .block; los de un solo capítulo
  // (12C) cuelgan los ejercicios directamente de <main>. Se tratan igual usando main como
  // bloque implícito.
  const blocks = document.querySelectorAll(".block").length
    ? [...document.querySelectorAll(".block")]
    : [document.getElementById("main")];

  for (const block of blocks) {
    const num = clean(block.querySelector?.(".block-num")?.textContent);
    const title = clean(block.querySelector?.(".block-titles h2")?.textContent);
    const sub = clean(block.querySelector?.(".block-titles .sub")?.textContent);
    if (title) {
      push();
      push("## " + (num ? num + ". " : "") + title);
      if (sub) { push(); push("*" + sub + "*"); }
    }

    // La caja de gramática de 12C no es .theory-wrap; se recoge aparte más abajo.
    const theory = block.querySelector(".theory-wrap");
    if (theory) { push(); push("### Gramática y vocabulario"); emitTheory(theory); }

    const exercises = [...block.querySelectorAll(".exercise")];
    if (exercises.length) { push(); push("### Ejercicios"); }
    for (const ex of exercises) {
      const n = clean(ex.querySelector(".exnum")?.textContent);
      const h = clean(ex.querySelector(".exercise-title h3")?.textContent);
      push();
      push("#### " + (n ? n + " — " : "") + h);
      const instr = clean(ex.querySelector(".exercise-instr")?.textContent);
      if (instr) { push(); push("*" + instr + "*"); }
      const model = clean(ex.querySelector(".exercise-model")?.textContent);
      if (model) { push(); push("*" + model + "*"); }
      const ref = ex.querySelector(".exercise-ref");
      if (ref) {
        push();
        for (const lab of ref.querySelectorAll(".ref-label")) {
          const sib = lab.nextElementSibling;
          if (!sib) continue;
          // Un texto para leer (la postal del 10.4) no es una lista de opciones: su contenido
          // son nodos de texto y <br>, no hijos-elemento, así que enumerar sib.children lo
          // perdería entero y el archivo quedaría sin el texto del libro.
          if (sib.matches(".postcard")) {
            push("> **" + clean(lab.textContent) + ":**");
            for (const l of textWithBlanks(sib).text.split("\n")) {
              if (l.trim()) push("> " + l.trim());
            }
            continue;
          }
          // Se descartan los hijos sin texto (una <img> dentro del recuadro, por ejemplo):
          // si no, el archivo acaba con un separador " · " suelto al final.
          push("> **" + clean(lab.textContent) + ":** " +
            [...sib.children].map((c) => clean(c.textContent)).filter(Boolean).join(" · "));
        }
        const ws = ref.querySelector(".wordsearch");
        if (ws) { push(); push("```"); push(ws.textContent.trim()); push("```"); }
      }
      push();

      // Redacción libre: no genera huecos, pero su enunciado y las líneas de modelo del
      // libro son contenido de la página escaneada y tienen que quedar archivados igual.
      const open = ex.querySelector(".open-block");
      if (open) {
        for (const l of textWithBlanks(open).text.split("\n")) {
          if (l.trim()) push("> " + l.trim());
        }
        push();
      }

      // párrafos con huecos
      for (const p of ex.querySelectorAll(".paragraph")) {
        const { text, answers } = textWithBlanks(p);
        let t = text;
        answers.forEach((a) => { t = t.replace("____", "**" + a + "**"); });
        push(t.split("\n").map((l) => l.trim()).filter(Boolean).join("\n"));
        push();
      }
      // filas de ítems
      const rows = [...ex.querySelectorAll(".item-row")];
      rows.forEach((row, i) => {
        const letter = clean(row.querySelector(".item-letter")?.textContent) || (i + 1) + ".";
        const clone = row.cloneNode(true);
        clone.querySelector(".item-letter")?.remove();
        const { text, answers } = textWithBlanks(clone);
        let t = text;
        answers.forEach((a) => { t = t.replace("____", "**" + a + "**"); });
        // opciones tipo chip: marcar la correcta
        const chips = [...row.querySelectorAll(".chip")];
        if (chips.length) {
          const opts = chips.map((c) => {
            const txt = clean(c.textContent);
            // "missed" = opción correcta que no se marcó; al extraer no marcamos ninguna, así
            // que las correctas de los ejercicios de casillas llegan con esa clase.
            const ok = c.classList.contains("correct") || c.classList.contains("missed");
            return ok ? "**" + txt + "**" : txt;
          });
          // El ____ que dejó .choice-group se rellena con la lista de opciones.
          const inline = "[" + opts.join(" / ") + "]";
          t = t.includes("____") ? t.replace("____", inline) : clean(t) + " " + inline;
        }
        // Un ítem con saltos de línea es un diálogo: cada réplica va en su línea también en
        // el archivo. Aplanarlo con clean() dejaría a los dos interlocutores en una sola
        // frase corrida, que es justo lo que se corrigió en el artefacto.
        const lineas = t.split("\n").map(clean).filter(Boolean);
        push(letter + " " + lineas[0]);
        lineas.slice(1).forEach(function (l) { push("   " + l); });
        const note = clean(row.querySelector(".grading-note")?.textContent);
        if (note) push("   > " + note);
      });
      // tablas de conjugación
      for (const tw of ex.querySelectorAll(".table-wrap table")) { push(); emitTable(tw); }

      // Transcripción del audio (plegada en el artefacto). Es contenido del libro, así que
      // tiene que quedar archivado igual que lo demás — si no, este archivo dejaría de ser
      // suficiente para reconstruir el capítulo sin volver al PDF.
      const tr = ex.querySelector(".transcript");
      if (tr) {
        push();
        push("**" + clean(tr.querySelector("summary")?.textContent) + "**");
        push();
        for (const line of tr.querySelectorAll(".transcript-body .line")) {
          // No toda transcripción es un diálogo: la de la 6C es una sola línea sin hablante,
          // y con el prefijo vacío salía un "****" suelto delante del texto.
          const who = clean(line.querySelector(".who")?.textContent);
          const said = clean(line.textContent).slice(who.length).trim();
          push(who ? "> **" + who + "** " + said : "> " + said);
        }
        const note = clean(tr.querySelector(".transcript-note")?.textContent);
        if (note) { push(); push("*" + note + "*"); }
      }
      push();
    }
  }
  return out.join("\n");
});

console.log(md.replace(/\n{3,}/g, "\n\n").trim());
await browser.close();
