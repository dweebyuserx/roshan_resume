# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A static, zero-dependency HTML portfolio/resume site for **Roshan Abraham** (AI Solutions Consultant). Five self-contained HTML pages with inline CSS and vanilla JS — no npm, no build tools, no frameworks.

Live at: `roshan.dev` (Cloudflare Pages, custom domain via `CNAME`)

## Pages

| File | Purpose |
|------|---------|
| `index.html` | Homepage — hero, skills, article/project previews |
| `about.html` | Full experience timeline and skills breakdown |
| `projects.html` | Projects showcase with featured project |
| `articles.html` | Articles listing with tag filtering |
| `connect.html` | Contact/social links page |

## Content Source of Truth

**`ROSHAN_ABRAHAM.md`** is the canonical record of Roshan's bio, experience, projects, skills, and articles. When updating content in the HTML files, cross-reference this file to keep things consistent.

The primary content-bearing object in `index.html` is `CONFIG` (line ~737). It drives hero tags, stack display, about paragraphs, skills bars, articles list, projects list, and connections. Each other HTML page has its own hardcoded equivalents.

**`PORTFOLIO_ARCH.md`** is the strategic reference layer on top of that: audience routing (recruiter / technical peer / article reader), content curation rationale (project ordering, why things are shown/hidden), and a running list of known content discrepancies between `ROSHAN_ABRAHAM.md` and the HTML `CONFIG` objects that still need reconciling. Check it before restructuring any page's content hierarchy.

**`docs/`** holds process reference, not shipped content: `docs/animejs-v4-catalog.md` (v3→v4 API differences, useful when touching any `anime()` call), `docs/mockups/portfolio-v3.html` (a standalone design mockup, not wired into the live pages), and `docs/superpowers/` (the spec and plan from the terminal-aesthetic redesign — historical context for why the current structure looks the way it does).

## Design System

All CSS is inline per-page. Each HTML file duplicates the same CSS custom properties — there is no shared stylesheet. When updating colors or typography, the same change must be applied across all five files.

Color tokens (defined in `:root` in every page):
- `--cyan: #4dd9f0` — primary accent (links, highlights)
- `--green: #3dffa0` — secondary accent
- `--orange: #ff9f4a` — tertiary accent
- `--purple: #a78bfa`, `--pink: #f472b6`, `--yellow: #fbbf24`, `--red: #f87171`
- `--bg: #0a0b0d` — main background
- `--text: #c8cfe8` — body text, `--bright: #e8eeff` — headings

Fonts: **JetBrains Mono** (body/code) and **Syne** (display headings), both loaded from Google Fonts.

## Build & Deployment

**Local preview:** Open any `.html` file directly in a browser — no server required.

**Production build** (Cloudflare Pages): The `build.sh` script injects analytics tokens into placeholder strings before deploy. It requires two env vars:

```bash
cp .env.example .env   # fill in CF_ANALYTICS_TOKEN and CLARITY_ID
source .env && bash build.sh
```

Placeholders in HTML: `CLOUDFLARE_TOKEN_HERE` (Cloudflare Web Analytics) and `CLARITY_ID_HERE` (Microsoft Clarity). Do **not** commit real tokens — Cloudflare Pages injects them at build time via environment variables.

**Deployment:** Push to `main` — Cloudflare Pages auto-deploys. The `_headers` file sets security headers (CSP, HSTS, etc.) for all routes.

## Key Conventions

- **No shared JS or CSS files** — each page is fully self-contained. Avoid creating external `.css` or `.js` files; keep changes inline.
- The custom cursor (`.cursor` + `.cursor-ring`) and CRT scanline overlay (`body::before`) appear on every page — preserve these when editing layout.
- The PDF CV (`roshan-abraham-cv.pdf`) is served with `Content-Disposition: attachment` via `_headers` — don't rename it without updating that rule.

## CSS Stacking — Critical Rule

The background canvas stack (`#rain-cv`, `#hex-cv`, `#illus-cv`, `#dot-field`, `#cur-glow`, `#vign`) is `position: fixed` with explicit `z-index` values. In the CSS paint order, fixed/positioned elements at `z-index ≥ 0` are painted **above** `position: static` content. The rain canvas fills itself with `rgba(6,7,9,0.045)` every 58ms and becomes progressively opaque — it will gradually cover any static content sitting below it in the stacking order.

**Rule: every content wrapper must have `position: relative` (or any non-static position).** This promotes it to the same paint step as `z-index: 0` elements, and since content wrappers appear later in the DOM than the canvases, they render on top.

- `index.html` achieves this via the global `section { position: relative; }` rule.
- `about.html`, `articles.html`, `projects.html`, `connect.html` achieve this via `main { position: relative; }`.

**When adding a new top-level content wrapper** (a new `<div>`, `<section>`, `<article>`, etc. that sits directly in `<body>` alongside the canvases), always give it `position: relative`. If you forget, content will visibly fade within seconds of page load as the rain canvas fills.

### Background z-index hierarchy (do not change without care)

| Element | z-index | Role |
|---------|---------|------|
| `#rain-cv`, `#hex-cv` | 0 | ASCII rain + hex ambient |
| `#illus-cv` | 1–2 | Contextual zone illustrations |
| `#dot-field` | 2 | Faint dot grid overlay |
| `#cur-glow` | 3 | Cursor radial glow |
| `body::before` | 4 | CRT scanline overlay |
| `#vign` | 5 | Edge vignette |
| `#wave-cv` | 6 | ASCII waveform bar (index only) |
| nav | 100 | Navigation |
| cursor / cursor-ring | 9998–9999 | Custom cursor |

Content wrappers (`section`, `main`) sit at `z-index: auto` with `position: relative` — they paint above the z-index:0 canvases (later in DOM) but below the explicit z-index overlays (1–5). This is intentional: the vignette, scanlines, and dot grid overlay all content.

## Animations — What Exists

There is **no scroll-reveal / fade-up system**. Do not add `opacity: 0` as an initial state on content sections expecting an IntersectionObserver to reveal them — there is no such observer for content (only `compileObs` for `.compile-card` elements).

Active animation patterns:

- **Compile-card reveal** (`compileObs` IntersectionObserver): elements with class `compile-card` get a progress-bar animation when they scroll into view, then a `::after` line draws via `transform: scaleX(0→1)`. Use this pattern for card-style content reveals.
- **`charStagger(el, delay)`**: splits a heading's text into `<span>`s and slides them in from `translateX(-10px)` + `opacity: 0`. Used for page title entrances. Safe to reuse.
- **`@keyframes pt-fade`**: cursor particle trail fade-out. Do not remove.
- **`@keyframes pulse` / `@keyframes tlpulse`**: status dot and timeline node pulsing glows. Do not remove.
- **anime.js v4**: loaded via CDN on every page. The v4 API (`ease:` not `easing:`, `anime.stagger()`, `anime.createSpring()`) is shimmed inside the `load` event handler to support the older v3 call style. Always call anime.js inside or after the `load` shim. **Do not call `anime()` directly in inline event handlers** (e.g. SVG `onmouseenter`) — the shim may not have run yet. Full v3→v4 diffs are in `docs/animejs-v4-catalog.md`.

There is also no scroll-driven fade-up anymore anywhere — a prior `IntersectionObserver` + `opacity:0` reveal system was fully removed across all five pages (see commit history around "remove fade-up animation"). Don't reintroduce it; use compile-card or charStagger instead.

### Shared interactive widgets (present identically on all five pages)

These were added during the terminal-aesthetic redesign (see `docs/superpowers/plans/2026-05-19-portfolio-redesign.md` for the original spec) and each page has its own copy of the implementation — when changing one, change all five:

- **`setupSpringHovers()`**: anime.js spring-based hover response on interactive elements (cards, buttons, nav links), driven by `anime.createSpring()`.
- **Command palette** (`#cmd-palette`, hidden by default): a `Cmd/Ctrl+K`-style fuzzy nav palette. If you add a new route or action, register it in every page's palette command list, not just one.
- **`uptimeWidget()`** (IIFE): a small "site uptime" HUD counter, purely cosmetic, ticks on an interval — no server state involved.
- **`konamiEgg()`** (IIFE): listens for the Konami code (`↑↑↓↓←→←→ba`) and triggers a glitch-overlay easter egg (`triggerGlitchEgg()`). Harmless; keep it last in the script block.
- **Animated stat counters** (`initCounters()` on `index.html`/`projects.html`): elements with `data-target`/`data-suffix` count up from 0 when scrolled into view via a dedicated `IntersectionObserver` — separate from `compileObs`, do not merge them.
- **`drawConnections()`** (`index.html`/`connect.html`): animates the SVG connection-line paths between the center node and connection cards.
- Page-specific extras: `initTimelineScrub()` and the git-diff-styled skill section (`about.html`), the featured-project diff tab (`projects.html`, `setupFeatTabs()`), the packet/particle animation (`connect.html`).

## Adding New Sections or Components

Checklist:
1. Give any new top-level body child `position: relative` in its CSS.
2. Do not start content at `opacity: 0` unless you have explicit JS that sets it back to `1` (compile-card pattern or charStagger).
3. Do not create a new `const observer = new IntersectionObserver(...)` for fade-up — use `compileObs` or charStagger instead.
4. If the new element needs to appear above the vignette/scanline overlays (z-index 4–5), give it an explicit `z-index ≥ 6` and `position: relative/absolute/fixed`.
5. If using anime.js, check `typeof anime !== 'undefined'` before calling it (CDN load can fail).
