# Product

## Register

brand

## Users

Angel Luis Acosta González, a private Spanish teacher, and his students (adults learning
Spanish as a second language, levels A1 through B2, mostly Russian-speaking based on the
existing student profiles in `docencia-espanol/planificacion/`). Students open these pages
on their own phones or laptops, often mid-lesson or right after one, to do a graded
exercise and send their results back to Angel. Angel himself browses this same library to
find, publish, and link new material as he creates it.

## Product Purpose

A small, growing library of self-contained interactive Spanish exercises (fill-in-the-blank,
instant grading, results sent to the teacher), published as individual Claude Artifacts and
organized by textbook manual, level, and chapter. The index/hub page ties the library
together: it's the front door that lets a student or Angel find the right chapter fast, and
it visibly reflects the structure new material should follow (manual → nivel → capítulo).
Success looks like: a student can go from "open this page" to "in the right exercise" in one
tap, and Angel can tell at a glance which chapters exist and which are still missing.

## Brand Personality

Warm, personal, academic-but-not-corporate — three words: **cercano, cuidado, ordenado**
(close/personal, cared-for, orderly). This is bespoke one-to-one tutoring, not a gamified
edtech platform or a school's LMS. The existing exercise artifacts already set the tone: a
paper/ink palette (cream paper, dark ink, gold accents), Georgia/serif headings for a
handwritten-notebook warmth, monospace for scores and numbers. The hub should feel like the
table of contents of a well-kept notebook Angel made for his students, not a dashboard or a
marketing page for a product.

## Anti-references

Not a gamified language-app aesthetic (Duolingo-style mascots, streaks, bright primary
colors, badges). Not a generic corporate LMS/dashboard (cold grays, dense data tables, stock
"education platform" imagery). Not SaaS-cream minimalism divorced from the paper/ink system
already established — new pages should extend that system, not reinvent it.

## Design Principles

- **Extend the existing notebook, don't restart it.** Every new artifact (this hub included)
  reuses the paper/ink CSS variables, serif headings, and gold accents already proven in the
  A1 and 12C exercise artifacts — visual consistency across the library matters more than any
  single page looking novel.
- **Manual → nivel → capítulo is the spine.** The hub's structure must make this hierarchy
  physically obvious (not just labeled) so it doubles as the template for how future chapters
  get organized and linked.
- **Missing chapters are shown, not hidden.** A level with only one chapter published should
  visibly show the gap ("próximamente") rather than silently omitting the rest of the
  curriculum — it's a working table of contents, not just a list of what exists today.
- **One tap from index to exercise, on a phone.** The primary real-world use is a student on
  their phone finding their chapter quickly; touch targets, load speed, and scannability on
  small screens outrank any desktop-first layout instinct.

## Accessibility & Inclusion

Body text and links must hit ≥4.5:1 contrast against the paper background in both light and
dark mode (the existing exercise artifacts already define light/dark CSS variables — reuse
them). Respect `prefers-reduced-motion`. No motion or interaction pattern should depend on
hover (students are on touch devices). Keep language simple, accented Spanish throughout
(the audience is Spanish learners themselves, so clarity matters more than idiom).
