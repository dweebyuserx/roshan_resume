# PORTFOLIO_ARCH.md
## Architecture, Curation & Audience Strategy Guide

This document is the strategic reference for the `roshan.dev` portfolio site. It covers audience routing, content curation decisions, design token philosophy, and maintenance guidelines — written so future edits preserve the intent behind each design choice.

---

## 1. Audiences & Routing Strategy

The site serves three distinct visitor types. Every design decision should be evaluated against all three.

### Recruiter (30-second scan)
**Goal:** Instantly confirm role, availability, and download CV — without scrolling or exploring.
**What they need:** Name, title, years of experience, availability status, one-click CV download.
**How to serve them:**
- Hero section must answer "who is this, what do they do, are they available" within 3 seconds of page load
- Download CV link must be in the top 400px of the page or always-visible in nav/HUD
- Availability indicator (green pulsing dot, "available for work") must be above the fold
- Do not hide essential info behind interactive elements (games, commands, animations)

### Technical Peer (deep explorer)
**Goal:** Evaluate architecture decisions, project depth, and technical credibility.
**What they need:** Project specifics, tech stack choices, GitHub/HuggingFace links, evidence of production work.
**How to serve them:**
- Projects page must show all 11 projects — none hidden or de-emphasized
- Each project needs: description, tech stack, and a contact or demo link
- The featured project (Agentic PR Platform, AI Hackathon Winner) should always be most prominent
- GitHub (`@dweebyuserx`) and HuggingFace (`@dweebster`) must be reachable within 2 clicks from any page
- Multi-variant projects (RAG Systems v1–v4, ChatBot Systems v1–v3) should display all variants, not flatten them

### Article Reader (intellectual engagement)
**Goal:** Read thoughtfully, discover more writing, potentially share.
**What they need:** Clean reading experience, author context, easy navigation to related content.
**How to serve them:**
- Articles must load in a legible reading mode: max 680–720px width, comfortable line-height (1.9+)
- Author bio teaser visible near each article
- Share mechanism (clipboard copy or native share) without third-party scripts
- "Coming soon" placeholder for future articles — signals active intellectual output, not a one-post blog

---

## 2. Content Source of Truth

### Canonical Data: `ROSHAN_ABRAHAM.md`
This markdown file is the authoritative record of all factual content. Before editing any HTML CONFIG object, check this file first. When adding new projects, experience entries, or certifications, update `ROSHAN_ABRAHAM.md` first, then propagate to the relevant HTML files.

**Known discrepancies to resolve on next edit:**
- `ROSHAN_ABRAHAM.md` lists `LlamaIndex / ADK` at 95% and `Advance RAG / Vector DBs` at 92%; `about.html` CONFIG uses slightly different names — align on the `about.html` version as the display-facing canonical form
- `ROSHAN_ABRAHAM.md` has `OpenUI / W&B / ` with a trailing space and missing item — this is a placeholder; fill with the intended skill before next deploy
- `index.html` stack array: `["LangChain", "PyTorch", "Vertex AI", "FastAPI", "Docker", "Vector DBs"]` — differs from `ROSHAN_ABRAHAM.md` which lists `ADK, claudeSDK, PyTorch, Vertex AI, FastAPI, Docker, Vector DBs` as the primary stack. **Recommended:** update `index.html` CONFIG to `["ADK / Claude SDK", "Vertex AI", "FastAPI", "Docker", "Vector DBs", "LlamaIndex"]` to reflect current tooling

### The CONFIG Pattern
Every HTML page contains a `CONFIG` object or equivalent JS data structure. This is the only place content should be edited — never hardcode content directly in the HTML markup.

```
index.html    → CONFIG object (~line 737)
about.html    → inline CONFIG + experience array
projects.html → PROJECTS array
articles.html → ARTICLES array
connect.html  → CONFIG or inline links
```

---

## 3. Content Curation Decisions

### Projects (11 total)

**Ordering rationale:** Lead with impact, sequence by complexity.
1. Agentic PR Platform *(featured — AI Hackathon Winner, current employer)*
2. Medical AI Infrastructure *(enterprise scale, FHIR integration)*
3. RAG Systems *(4 builds — demonstrates progression)*
4. Custom LLM Foundry *(public artifact on HuggingFace)*
5. MLOps Engine *(production reliability story)*
6. Disease Detection in Cattle *(hardware + ML, memorable)*
7. Stable Diffusion Pipeline *(generative AI, visual impact)*
8. Claude Agent Code Conversion *(Claude SDK showcase)*
9. Education Data Pipeline *(social impact story)*
10. In-Store Navigation AI *(graph reasoning, unusual domain)*
11. ChatBot Systems *(foundational, 3 builds)*

**On multi-variant projects:** RAG v1–v4 and ChatBot v1–v3 should always be shown as progression stories, not collapsed into one card. The evolution from RASA → Dialogflow → LLM-backed RAG demonstrates learning velocity — that's the signal technical interviewers look for.

**What not to remove:** IoT Garden (Raspberry Pi + YOLO) is small but humanizes the profile — shows tinkering mindset beyond enterprise work. Keep it, just don't feature it.

### Experience (6 entries)

The parallel 2022–2023 roles (MyDiGiRecords + Tasset concurrent with Appsynergies AI Lead) are intentional — they represent genuine concurrent consulting, which is common in AI consulting. Display them with a `concurrent` tag or visual treatment so it reads as intentional, not as a timeline error.

**The career arc narrative:** QDgrees (learning) → Appsynergies AI Engineer (building) → concurrent consulting (expanding) → Appsynergies AI Lead (leading) → Deloitte USI (enterprise scale). This should be legible at a glance from the timeline visualization.

### Skills

**Honest calibration note:** The 45% for `NumPy / JAX / TensorFlow` is notably lower than all other skills. This is accurate but creates visual noise. Options:
1. Keep it (honest, shows self-awareness)
2. Remove it from the visual display but keep in `ROSHAN_ABRAHAM.md`
3. Reframe the skill as `Classical ML` at 65% (covers the conceptual domain without overstating framework fluency)

Current recommendation: keep it visible. Self-awareness about tool familiarity vs. expertise is a positive signal to technical interviewers.

### Articles

Currently one published article. The `articles.html` should show:
- Published: "The End of Seeing is Believing" (Feb 2026)
- In progress: 1–2 ghost/placeholder cards at reduced opacity to signal active writing

Placeholder article ideas already hinted at by expertise:
- "Building Production RAG Systems: What the Tutorials Don't Tell You"
- "LLMOps in Enterprise: Lessons from Deloitte USI"

Add these as `status: "coming-soon"` entries in the ARTICLES config once titles are confirmed.

---

## 4. Design System

### Shared Color Tokens (current — may change per chosen design option)

```css
/* Background scale */
--bg:     #0a0b0d  /* page background */
--bg2:    #0f1117  /* card / panel bg */
--bg3:    #141720  /* elevated surface / hover */
--border: #1e2230  /* dividers, borders */
--dim:    #3a4055  /* very muted text */
--muted:  #5a6380  /* secondary text */

/* Text scale */
--text:   #c8cfe8  /* body text */
--bright: #e8eeff  /* headings */

/* Accent palette */
--cyan:   #4dd9f0  /* primary accent */
--green:  #3dffa0  /* secondary accent */
--orange: #ff9f4a  /* tertiary */
--purple: #a78bfa
--pink:   #f472b6
--yellow: #fbbf24
--red:    #f87171
```

### Typography

**JetBrains Mono** (weights 100, 300, 400, 600, 700, italic variants) — body, nav, tags, code, metadata  
**Syne** (weights 400, 700, 800) — section headings, card titles, display text

These two fonts together create the intended contrast: Syne is geometric and editorial; JetBrains Mono is technical and precise. Don't swap them. If a redesign changes the overall aesthetic, update both.

### Animation Principles

All animations follow these rules:
1. **Fade-up on scroll** (IntersectionObserver, threshold 0.1, `opacity 0→1 + translateY 24px→0`, 0.5–0.6s `ease`)
2. **Staggered delays** on grid items (`i * 0.05s` to `i * 0.2s` per item)
3. **No looping animations** on content (only status indicators and decorative elements loop)
4. **Reduced motion**: all transition-heavy elements should respect `@media (prefers-reduced-motion: reduce)`

---

## 5. Maintenance Guide

### Adding a New Project
1. Add entry to `ROSHAN_ABRAHAM.md` first
2. Add to `PROJECTS` array in `projects.html`
3. If it should appear on the homepage preview, add to `CONFIG.projects` in `index.html`
4. If it's the new featured project, update the first item in the array and set `featured: true`

### Adding a New Article
1. Write the content in `ROSHAN_ABRAHAM.md`
2. Add to `ARTICLES` array in `articles.html` with full body content
3. Update the preview entry in `CONFIG.articles` in `index.html`
4. Add any new article images to `assets/` directory

### Updating Availability Status
In `index.html` CONFIG:
```js
status: "available for work",      // or "open to consulting" or "not available"
statusMessage: "open to opportunities",
```
The same text appears in the nav pulsing indicator and the hero terminal output. Change it in one place (CONFIG) and it propagates.

### Analytics Token Deployment
Never commit real analytics tokens. The build pipeline handles this:
1. Set `CF_ANALYTICS_TOKEN` and `CLARITY_ID` as environment variables in Cloudflare Pages dashboard
2. The `build.sh` script injects them into placeholder strings at deploy time
3. For local development: `cp .env.example .env`, fill in real tokens, run `source .env && bash build.sh`

### Checking CSP After Edits
If you add any new external resources (fonts, CDN libraries, tracking scripts), update the CSP in two places:
- The `<meta http-equiv="Content-Security-Policy">` tag in each affected HTML file's `<head>`
- The `/` route in `_headers` (the Cloudflare-enforced server-side CSP)

Both must match. The `_headers` CSP is authoritative for Cloudflare Pages deployments.

---

## 6. File Map

```
/
├── index.html          ← Homepage (hero, skills preview, articles, projects, connections)
├── about.html          ← Experience timeline, skill tree, certifications, hobbies
├── projects.html       ← Full projects showcase (11 projects)
├── articles.html       ← Articles listing + full article body rendering
├── connect.html        ← Social links and contact
│
├── assets/
│   ├── verity-doc-correction.png   ← Article image: document correction flow
│   ├── verity-protocol-diagram.png ← Article image: VeriStasis protocol
│   ├── verity-selfheal-diagram.png ← Article image: self-healing diagram
│   └── verity-vdb-cluster.png      ← Article image: vector DB cluster
│
├── roshan-abraham-cv.pdf   ← Downloadable CV (served with Content-Disposition: attachment)
├── CNAME                   ← Custom domain: roshan.dev
├── _headers                ← Cloudflare security headers (CSP, HSTS, etc.)
├── build.sh                ← Analytics token injection script
├── .env.example            ← Template for local dev env vars
│
├── CLAUDE.md               ← Claude Code guidance (build commands, architecture)
├── PORTFOLIO_ARCH.md       ← This file
└── ROSHAN_ABRAHAM.md       ← Canonical content source of truth
```
