---
name: Clases de Español — Nuevo Español en Marcha
description: Paper-and-ink interactive Spanish exercise artifacts, graded instantly, sent to the teacher by chat.
colors:
  paper: "#F3F5F0"
  paper-raised: "#FFFFFF"
  ink: "#17223B"
  ink-soft: "#4B5468"
  pencil: "#6E7280"
  gold: "#A8790C"
  gold-soft: "#F1E4C2"
  good: "#1F7A4C"
  good-bg: "#E7F3EC"
  bad: "#B23A2E"
  bad-bg: "#FBECE9"
  border: "#DCDFD3"
  input-bg: "#FCFDFB"
  results-bg: "#17223B"
  results-text: "#ECEEF3"
  results-text-soft: "#C7CEDD"
  results-accent: "#D9A441"
  results-bad: "#E17868"
typography:
  display:
    fontFamily: "Georgia, 'Iowan Old Style', 'Palatino Linotype', 'Book Antiqua', serif"
    fontSize: "clamp(1.6rem, 4vw, 2.2rem)"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "normal"
  headline:
    fontFamily: "Georgia, 'Iowan Old Style', 'Palatino Linotype', 'Book Antiqua', serif"
    fontSize: "1.15rem"
    fontWeight: 700
    lineHeight: 1.3
  body:
    fontFamily: "-apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif"
    fontSize: "1rem"
    fontWeight: 400
    lineHeight: 1.55
  label:
    fontFamily: "-apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif"
    fontSize: "0.78rem"
    fontWeight: 700
    letterSpacing: "0.06em"
  mono:
    fontFamily: "ui-monospace, SFMono-Regular, Menlo, Consolas, 'Liberation Mono', monospace"
rounded:
  sm: "6px"
  md: "8px"
  lg: "10px"
  card: "12px"
  pill: "999px"
spacing:
  sm: "0.6rem"
  md: "1.1rem"
  lg: "1.9rem"
components:
  button-primary:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.paper}"
    rounded: "{rounded.md}"
    padding: "0.75rem 1.5rem"
  button-primary-hover:
    backgroundColor: "{colors.gold}"
    textColor: "{colors.ink}"
  channel-button:
    backgroundColor: "{colors.results-text}"
    textColor: "{colors.results-bg}"
    rounded: "{rounded.md}"
    padding: "0.55rem 0.95rem"
  channel-button-hover:
    backgroundColor: "{colors.results-accent}"
  card:
    backgroundColor: "{colors.paper-raised}"
    rounded: "{rounded.lg}"
    padding: "1.4rem"
---

# Design System: Clases de Español

## Overview

**Creative North Star: "El Cuaderno del Profesor" (The Teacher's Notebook)**

This system is the visual language of a private Spanish tutor's own study materials — not a
language-learning product, not a school's LMS. It should read like the table of contents and
worksheets of a well-kept, handwritten notebook: cream paper, dark ink, a single gold pencil
mark for emphasis. Warmth comes from restraint and craft, not from mascots, streaks, or bright
primary colors. Every page in this system — an exercise, an index, a results panel — is a page
of the same notebook, so it must share the same paper, the same ink, the same margins.

The system explicitly rejects: gamified language-app aesthetics (badges, streaks, cartoon
mascots, saturated primary colors), generic corporate LMS/dashboard chrome (cold grays, dense
data tables, stock "education platform" photography), and SaaS-cream minimalism that isn't
actually this brand's own palette — the paper tone here is a specific, slightly green-gray
cream (`#F3F5F0`), not a generic warm off-white.

**Key Characteristics:**
- Warm paper background, cool dark-navy ink — a stationery pairing, not a screen pairing.
- Georgia serif for every heading; a plain system sans for body copy; monospace reserved for
  numbers (scores, codes, exercise numbers) so they read as measured, precise marks.
- One accent color (gold) used sparingly — hover states, focus rings, the score number, one
  progress bar. It marks emphasis the way a teacher's pencil does, not as branding.
- The results panel is the one deliberate exception to the shared palette: it always renders on
  a fixed dark-ink background regardless of site theme, because it's the "graded and handed
  back" moment and should feel distinct from the page the student was just writing on.
- Full dark-mode parity: every token has a light and dark value, switched by
  `prefers-color-scheme` (and overridable via `data-theme`), never a bolted-on dark variant.

## Colors

The palette is a stationery pairing — cream paper and navy ink — with a single warm gold accent
used only for emphasis, never as a field of color.

### Primary
- **Pencil Gold** (`#A8790C`, dark mode `#E0B44A`): the one accent. Used for hover states,
  focus rings, the progress bar fill, the score number, and link hover — never as a background
  fill larger than a button or badge.

### Neutral
- **Paper** (`#F3F5F0`, dark `#101626`): the page background. A specific cool-cream, not a
  generic warm off-white — do not drift it toward beige/sand.
- **Paper Raised** (`#FFFFFF`, dark `#182036`): cards, the gate/access panel, anything sitting
  visually above the page.
- **Ink** (`#17223B`, dark `#ECEEF3`): primary text and headings.
- **Ink Soft** (`#4B5468`, dark `#AEB6C9`): secondary text, subtitles, captions.
- **Pencil** (`#6E7280`, dark `#8B93A6`): the quietest text — table headers, placeholder-level
  labels.
- **Gold Soft** (`#F1E4C2`, dark `#3A3220`): rare tinted-background use behind gold accents
  (badges, highlighted state), never as a large surface.
- **Border** (`#DCDFD3`, dark `#2A3348`): hairline dividers and card outlines.
- **Input Background** (`#FCFDFB`, dark `#131A2C`): text input fields, distinct from card
  backgrounds so fillable areas read as fillable.

### Semantic
- **Good** (`#1F7A4C` on `#E7F3EC`, dark `#4CB47F` on `#163326`): correct answers, success
  states.
- **Bad** (`#B23A2E` on `#FBECE9`, dark `#E17868` on `#3A1E1B`): incorrect answers, errors.

### Results Panel (fixed, not theme-aware)
- **Results Ink** (`#17223B`): the panel's own background, ALWAYS this value regardless of
  light/dark mode — this is the one intentional break from the shared token system.
- **Results Text** (`#ECEEF3`) / **Results Text Soft** (`#C7CEDD`): text on the fixed dark panel.
- **Results Accent** (`#D9A441`): the panel's own gold, for the score number and hover states.
- **Results Bad** (`#E17868`): struck-through wrong answers inside the panel.

### Named Rules
**The Fixed Panel Rule.** The results panel never uses the swappable `--ink`/`--paper-raised`/
`--gold` tokens — it defines its own `--rp-*` set and stays dark in both light and dark site
themes. Wiring it to the swappable tokens inverts their meaning in dark mode and makes the
panel unreadable; this has broken in production before. Never "fix" this by pointing the panel
at the shared tokens.

**The One Voice Rule.** Gold appears on at most one or two elements per screen at a time
(a hover state, a score, a progress bar). If gold is filling more than a button or a badge, it's
being used as decoration, not emphasis — pull it back.

## Typography

**Display/Headline Font:** Georgia, "Iowan Old Style", "Palatino Linotype", "Book Antiqua", serif
**Body Font:** -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif
**Label/Mono Font:** ui-monospace, SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace

**Character:** A classic serif/sans pairing — the serif carries the handwritten-notebook warmth
in headings, the plain system sans keeps body copy fast-loading and legible on a student's
phone, and monospace isolates anything numeric (scores, exercise numbers, access codes) so it
reads as a precise, countable mark rather than prose.

### Hierarchy
- **Display** (700, `clamp(1.6rem, 4vw, 2.2rem)`, 1.2 line-height, Georgia): page-level h1s —
  exercise titles, the index page's main heading.
- **Headline** (700, 1.15rem, 1.3 line-height, Georgia): card/section titles — the gate card's
  `h2`, block titles, chapter names in the index.
- **Title** (700, 0.95rem, Georgia or sans depending on context): brand-title in the top bar,
  compact headings.
- **Body** (400, 1rem, 1.55 line-height, sans): all prose and exercise instructions. Cap at
  65–75ch measure.
- **Label** (700, 0.72–0.78rem, 0.06–0.12em letter-spacing, uppercase, sans): eyebrows, section
  kickers, results-panel "channel-label"/"results-errors-title".
- **Mono** (400–700, sizes vary, monospace): scores, exercise numbers (`.exnum`), nav-dot
  labels, form inputs for codes.

### Named Rules
**The Numbers-Are-Mono Rule.** Anything a student reads as a count or a code (score `12/20`,
exercise number, access code input) renders in monospace. Anything they read as prose does not.
This is a legibility signal, not decoration — mixing the two makes scores harder to scan.

## Elevation

Flat by default; a single soft, warm-tinted shadow marks anything raised above the paper
(cards, the gate panel), never a hard drop shadow. There is no multi-step elevation scale —
raised or not-raised is the entire vocabulary.

### Shadow Vocabulary
- **Raised** (`box-shadow: 0 1px 2px rgba(23,34,59,0.06), 0 4px 14px rgba(23,34,59,0.06)`;
  dark mode `0 1px 2px rgba(0,0,0,0.3), 0 8px 20px rgba(0,0,0,0.35)`): exercise cards, the gate
  overlay card. A tight near-shadow plus a soft diffuse one, tinted toward ink, never pure
  black.

### Named Rules
**The Two-State Rule.** An element is either flush with the paper (most content) or raised off
it (cards, the gate panel) with the single shadow above. Don't invent an intermediate "slightly
raised" state.

## Components

### Buttons
- **Shape:** 8px radius (`--rounded.md`), pill (999px) only for the tiny nav-dot chips.
- **Primary ("Corregir todos"):** ink background, paper text, bold; hover inverts to gold
  background with ink text (`background: var(--gold); color: var(--ink)`).
- **Gate button ("Entrar"):** same ink→gold hover pattern, full-width inside the gate card.
- **Channel buttons (send-to-teacher row):** background `var(--rp-text)` (light, near-white),
  text `var(--rp-bg)` (dark ink) — inverted from the primary button on purpose, since they live
  inside the fixed-dark results panel. Hover fills with `var(--rp-accent)` gold. **These are
  always plain `<a target="_blank" rel="noopener">` elements, never `<button onclick>` +
  `window.open()`** — a native link click is exempt from the browser's per-site popup-block
  permission; a scripted `window.open()` is not, and has broken this exact button in production.
  Where a channel needs a clipboard-copy fallback (Correo, Teams), attach it as an *additive*
  `addEventListener("click", ...)`, never as the element's only handler.

### Cards
- **Corner Style:** 10–12px radius.
- **Background:** `var(--paper-raised)`.
- **Shadow Strategy:** the single Raised shadow from Elevation.
- **Border:** 1px `var(--border)` on the gate card only; exercise cards rely on shadow alone.
- **Internal Padding:** ~1.4rem.

### Inputs / Fields
- **Style:** `var(--input-bg)` background (distinct from card white), 1px `var(--border)`,
  bottom-border style for inline fill-in-the-blank inputs (`input.blank`), full box style for
  the gate-code input.
- **Focus:** border/underline shifts to `var(--focus)` (the gold token) — no glow, no ring.
- **Error / Disabled:** graded-wrong inputs shift to the Bad palette (background `var(--bad-bg)`,
  text `var(--bad)`); never grayed out/disabled, since the student can always retry.

### Navigation
- **Top bar:** sticky, translucent paper background with `backdrop-filter: blur(8px)`, hairline
  bottom border. Nav dots are pill-shaped, bordered, uppercase-adjacent small text; active/hover
  state turns gold (text + border).

### Results Panel (signature component)
Fixed dark-ink surface (`--rp-bg`, always `#17223B` regardless of site theme), rounded 14px,
holding: a Georgia headline, a mono score number in gold, a translucent-white error list
(struck-through wrong answers in `--rp-bad`, correct answer following in gold), and the
channel-button row. This is the one component that intentionally does not follow the page's
light/dark toggle — see the Fixed Panel Rule under Colors.

## Do's and Don'ts

### Do:
- **Do** keep the paper tone a specific cool cream (`#F3F5F0`) — check any new page against this
  exact value, not a generic warm off-white.
- **Do** use Georgia (or its serif fallback stack) for every heading, and the system sans stack
  for every body paragraph, across every new artifact in this library.
- **Do** render scores, exercise numbers, and codes in the monospace stack.
- **Do** give the results panel its own fixed `--rp-*` dark palette on every new exercise —
  never wire it to the swappable `--ink`/`--paper-raised`/`--gold` tokens.
- **Do** implement every "send to teacher" channel button as a plain `<a target="_blank"
  rel="noopener">`, with any clipboard-copy behavior attached as an additive event listener.
- **Do** define both a light and a dark value for every color token; ship dark mode with every
  new page, not as a follow-up.

### Don't:
- **Don't** use gamified language-app styling — mascots, streak counters, bright saturated
  primary colors, badges. This is a private tutor's notebook, not a consumer app.
- **Don't** use generic corporate LMS/dashboard chrome — cold grays, dense data tables, stock
  "education platform" photography, sidebar-heavy layouts.
- **Don't** drift the paper background toward a generic warm SaaS-cream; the palette here is
  this project's own, not the default.
- **Don't** use `window.open()` or a `<button onclick>` for any external-link channel button —
  it silently breaks under Chrome's persistent per-site popup-block permission. Use a real `<a
  href>` every time.
- **Don't** point the results panel at the page's shared color tokens "to keep it consistent" —
  it inverts in dark mode and becomes unreadable. It is deliberately the one fixed-palette
  exception.
- **Don't** add a second elevation step ("more raised") or a hard black drop shadow — the system
  has exactly one shadow, warm-tinted, for anything above the paper.
