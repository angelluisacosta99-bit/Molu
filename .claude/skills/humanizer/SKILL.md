---
name: humanizer
description: Use when Angel asks to "humanizar" a text, make it sound less like AI/a chatbot wrote it, or remove AI writing tells before publishing something under his own name (blog posts, emails, messages to alumnos). Triggers: "humanízalo", "que no suene a IA", "/humanizer".
version: 1.0.0
user-invocable: true
license: MIT (adaptado de github.com/blader/humanizer)
---

> Adaptado del skill open-source `blader/humanizer` (MIT,
> https://github.com/blader/humanizer). Copiado a mano en este repo en
> vez de instalarlo vía `npx skills add` para no ejecutar código de
> terceros sin revisar — este archivo es solo texto de instrucciones.

# Humanizer: Overview

This skill helps rewrite AI-generated text to sound more natural and
human. It identifies structural patterns that models use by
default—like staged openings, forced triads, and inflated
language—and provides strategies to remove them.

## Core Principles

The tool rests on two main ideas: every kept sentence must give
readers something new, and patterns matter most when they appear
together. Structural habits (staging, rhythm by rule, inflation) are
stronger tells than vocabulary alone.

## Key Patterns Addressed

The skill catalogs 25 tells across five categories:

**Staging instead of stating** includes not-X-but-Y contrasts,
one-line closers, and dramatic fragments that add weight without
adding facts.

**Rhythm by rule** covers forced triads, repeated openings, and
overuse of dashes as connectors.

**Inflation** involves overused words like "pivotal" and "landscape,"
vague associations, and borrowed authority from unnamed experts.

**Formatting by rule** flags excessive bolding, decorative headings,
and emoji use.

**Leftovers** catches chatbot residue like "I hope this helps" and
knowledge-limit disclaimers that admit guesses.

## Workflow

The process involves marking tells in order of strength, drafting a
rewrite while preserving all factual claims, checking for remaining
patterns, and producing final text that varies sentence length and
matches the source voice where provided.
