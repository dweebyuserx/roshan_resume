# Portfolio Visual Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Overlay a full terminal-aesthetic visual system (ASCII matrix rain, reactive cursor glow, contextual ASCII illustrations, glitch effects, compile-reveal scroll animations, new fonts) across all 5 portfolio pages while preserving all existing content and data structures.

**Architecture:** Each page is a self-contained HTML file with inline CSS + JS. The redesign adds: (1) a shared 6-layer effect system (rain canvas, illustration canvas, dot grid, cursor glow, scanlines, vignette) injected into every page's `<body>`, (2) font swap from Syne → Oxanium + Share Tech Mono, (3) page-specific `ZONES` arrays for contextual illustrations, (4) compile-reveal CSS pattern on cards. No external files are created — everything stays inline per project convention.

**Tech Stack:** Vanilla HTML/CSS/JS, Canvas 2D API, IntersectionObserver, CSS custom properties, Google Fonts (Oxanium + Share Tech Mono + JetBrains Mono)

**Reference mockup:** `/mnt/BatLair/Resume/.superpowers/brainstorm/3360794-1779179922/content/layout-v3.html`

---

## File Map

| File | Changes |
|------|---------|
| `.gitignore` | Create — add `.superpowers/` |
| `index.html` | Font swap, CSS layer additions, hero restructure, effect JS, illustration ZONES, compile-reveal cards |
| `about.html` | Font swap, CSS layer additions, effect JS, illustration ZONES, compile-reveal on timeline + skills |
| `projects.html` | Font swap, CSS layer additions, effect JS, illustration ZONES, compile-reveal on project cards |
| `articles.html` | Font swap, CSS layer additions, effect JS, illustration ZONES, type-in article reveal |
| `connect.html` | Font swap, CSS layer additions, effect JS, illustration ZONES, compile-reveal on nodes |

---

## Shared Snippets (referenced by tasks below)

### SNIPPET A — Google Fonts import (replace existing `@import` line in every page)

```css
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:ital,wght@0,100;0,300;0,400;0,600;0,700;1,300&family=Oxanium:wght@400;600;700;800&family=Share+Tech+Mono&display=swap');
```

### SNIPPET B — CSS variable additions (add inside `:root {}` block in every page, after existing vars)

```css
    --font-display: 'Oxanium', sans-serif;
    --font-label: 'Share Tech Mono', monospace;
    --s1: 8px; --s2: 16px; --s3: 24px; --s4: 32px; --s5: 48px; --s6: 64px;
```

### SNIPPET C — Effect layer HTML (insert immediately after `<body>` opening tag, before cursor divs, in every page)

```html
<canvas id="rain-cv"></canvas>
<canvas id="illus-cv"></canvas>
<div id="dot-field"></div>
<div id="cur-glow"></div>
<div id="vign"></div>
<div id="illus-label"></div>
```

### SNIPPET D — Effect layer CSS (add inside `<style>` in every page, after existing cursor rules)

```css
  /* ── EFFECT LAYERS ── */
  #rain-cv { position: fixed; inset: 0; z-index: 0; opacity: 0.055; pointer-events: none; }
  #illus-cv { position: fixed; inset: 0; z-index: 1; pointer-events: none; opacity: 0; transition: opacity 0.6s ease; }
  #illus-cv.show { opacity: 1; }
  #dot-field { position: fixed; inset: 0; z-index: 2; pointer-events: none;
    background-image: radial-gradient(circle, var(--dim) 1px, transparent 1px);
    background-size: 28px 28px; }
  #cur-glow { position: fixed; z-index: 3; pointer-events: none; border-radius: 50%;
    width: 0; height: 0;
    background: radial-gradient(circle, rgba(77,217,240,0.06) 0%, transparent 65%);
    transform: translate(-50%, -50%);
    transition: left 0.06s linear, top 0.06s linear, width 0.4s ease, height 0.4s ease; }
  #vign { position: fixed; inset: 0; z-index: 5; pointer-events: none;
    background: radial-gradient(ellipse at 50% 50%, transparent 55%, rgba(0,0,0,0.55) 100%); }
  #illus-label { position: fixed; z-index: 50; font-family: var(--font-label); font-size: 9px;
    letter-spacing: 1.5px; color: var(--cyan); background: rgba(6,7,9,0.85);
    border: 1px solid rgba(77,217,240,0.25); border-radius: 3px; padding: 4px 10px;
    pointer-events: none; opacity: 0; transition: opacity 0.3s; white-space: nowrap; }
  #illus-label.show { opacity: 1; }

  /* ── UPDATED CURSOR ── */
  .cursor { box-shadow: 0 0 10px var(--cyan); }
  .cursor-ring { transition: width 0.15s, height 0.15s, border-color 0.15s; }

  /* ── PARTICLE TRAIL ── */
  .particle-trail { position: fixed; pointer-events: none; z-index: 9997; border-radius: 50%;
    width: 3px; height: 3px; animation: pt-fade 0.7s ease-out forwards; }
  @keyframes pt-fade { to { opacity: 0; transform: translate(var(--dx), var(--dy)) scale(0); } }

  /* ── MOBILE: disable effects ── */
  @media (max-width: 768px) {
    #rain-cv, #illus-cv, #dot-field, #cur-glow, #vign, #illus-label { display: none; }
    .cursor, .cursor-ring { display: none; }
    body { cursor: auto; }
  }
```

### SNIPPET E — Effect layer JS (insert at TOP of each page's `<script>` block, before existing JS)

```javascript
// ── EFFECT LAYERS INIT ──
(function initEffects(ZONES) {
  if (window.innerWidth <= 768) return; // disable on mobile

  const curEl   = document.getElementById('cursor');
  const ringEl  = document.getElementById('cursorRing');
  const glowEl  = document.getElementById('cur-glow');
  const ilCv    = document.getElementById('illus-cv');
  const ilCtx   = ilCv.getContext('2d');
  const ilLabel = document.getElementById('illus-label');
  const rainCv  = document.getElementById('rain-cv');
  const rCtx    = rainCv.getContext('2d');

  let mx = window.innerWidth / 2, my = window.innerHeight / 2;
  let rx = mx, ry = my;

  // Canvas resize
  function resizeCv() {
    rainCv.width  = ilCv.width  = window.innerWidth;
    rainCv.height = ilCv.height = window.innerHeight;
  }
  resizeCv();
  window.addEventListener('resize', resizeCv);

  // ── CURSOR + PARTICLES ──
  document.addEventListener('mousemove', e => {
    mx = e.clientX; my = e.clientY;
    if (curEl)  { curEl.style.left  = mx + 'px'; curEl.style.top  = my + 'px'; }
    if (glowEl) { glowEl.style.left = mx + 'px'; glowEl.style.top = my + 'px'; }
    ilLabel.style.left = (mx + 16) + 'px';
    ilLabel.style.top  = (my - 28) + 'px';
    if (Math.random() > 0.68) spawnParticle(mx, my);
    checkZones(mx, my);
  });

  function spawnParticle(x, y) {
    const p = document.createElement('div');
    p.className = 'particle-trail';
    const cols = ['#4dd9f0','#3dffa0','#a78bfa','#f472b6'];
    const c = cols[Math.floor(Math.random() * 4)];
    const dx = (Math.random() - 0.5) * 52, dy = (Math.random() - 0.5) * 52;
    p.style.cssText = `left:${x}px;top:${y}px;background:${c};box-shadow:0 0 5px ${c};--dx:${dx}px;--dy:${dy}px`;
    document.body.appendChild(p);
    setTimeout(() => p.remove(), 700);
  }

  // Eased ring follow
  (function animRing() {
    rx += (mx - rx) * 0.14; ry += (my - ry) * 0.14;
    if (ringEl) { ringEl.style.left = rx + 'px'; ringEl.style.top = ry + 'px'; }
    requestAnimationFrame(animRing);
  })();

  // Ring expand on interactive elements
  document.querySelectorAll('a, .btn, button, [data-hover]').forEach(el => {
    el.addEventListener('mouseenter', () => {
      if (ringEl) { ringEl.style.width = '46px'; ringEl.style.height = '46px'; ringEl.style.borderColor = 'rgba(77,217,240,0.8)'; }
      if (glowEl) { glowEl.style.width = '500px'; glowEl.style.height = '500px'; }
    });
    el.addEventListener('mouseleave', () => {
      if (ringEl) { ringEl.style.width = '28px'; ringEl.style.height = '28px'; ringEl.style.borderColor = 'rgba(77,217,240,0.4)'; }
      if (glowEl) { glowEl.style.width = '0'; glowEl.style.height = '0'; }
    });
  });

  // ── ASCII RAIN ──
  const RAIN_CH = 'ABCDEFGHIJKLMNOPQRSTUVWXYZアイウエオカキクケ0123456789@#{}[]|<>╔╗╚╝║═';
  let drops = [];
  function initDrops() {
    drops = Array(Math.floor(rainCv.width / 14)).fill(0).map(() => Math.random() * rainCv.height / 14);
  }
  initDrops();
  window.addEventListener('resize', initDrops);

  setInterval(() => {
    rCtx.fillStyle = 'rgba(6,7,9,0.045)';
    rCtx.fillRect(0, 0, rainCv.width, rainCv.height);
    rCtx.font = '12px Courier New';
    const cursorCol = Math.floor(mx / 14);
    drops.forEach((d, i) => {
      const c = RAIN_CH[Math.floor(Math.random() * RAIN_CH.length)];
      const x = i * 14, y = d * 14, r = Math.random();
      const nearCursor = Math.abs(i - cursorCol) <= 2;
      rCtx.fillStyle = nearCursor ? `rgba(77,217,240,${0.6 - Math.abs(i-cursorCol)*0.2})` :
                       r > 0.98 ? '#fff' : r > 0.93 ? '#4dd9f0' : '#0c2010';
      rCtx.fillText(c, x, y);
      if (y > rainCv.height && Math.random() > 0.977) drops[i] = 0;
      drops[i] += 0.45 + Math.random() * 0.28;
    });
  }, 58);

  // ── CONTEXTUAL ILLUSTRATIONS ──
  let currentZone = null, ilT = 0, ilLines = [], ilColor = '#4dd9f0';

  function drawIllus() {
    ilCtx.clearRect(0, 0, ilCv.width, ilCv.height);
    if (!currentZone || !ilLines.length) return;
    const offX = mx < ilCv.width / 2  ? ilCv.width - 340 : 40;
    const offY = my < ilCv.height / 2 ? ilCv.height - 200 : 80;
    ilCtx.font = '11px "JetBrains Mono", monospace';
    const shown = Math.min(ilLines.length, Math.floor(ilT / 60) + 1);
    for (let i = 0; i < shown; i++) {
      const isLast = i === shown - 1;
      const lineStr = isLast ? ilLines[i].substring(0, Math.floor(((ilT % 60) / 60) * ilLines[i].length)) : ilLines[i];
      ilCtx.fillStyle = ilColor;
      ilCtx.globalAlpha = 0.5;
      ilCtx.fillText(lineStr, offX, offY + i * 16);
    }
    ilCtx.globalAlpha = 1;
  }

  function startZone(zone) {
    if (currentZone === zone.id) return;
    currentZone = zone.id; ilLines = zone.art; ilColor = zone.color; ilT = 0;
    ilCv.classList.add('show');
    ilLabel.textContent = zone.label;
    ilLabel.classList.add('show');
  }
  function stopZone() {
    currentZone = null;
    ilCv.classList.remove('show');
    ilLabel.classList.remove('show');
  }

  function checkZones(mx_, my_) {
    for (const zone of ZONES) {
      const el = document.querySelector(zone.sel);
      if (!el) continue;
      const r = el.getBoundingClientRect();
      const PAD = 80;
      if (mx_ > r.left - PAD && mx_ < r.right + PAD && my_ > r.top - PAD && my_ < r.bottom + PAD) {
        startZone(zone); return;
      }
    }
    stopZone();
  }

  (function animIllus() {
    if (currentZone) { ilT += 1.6; drawIllus(); }
    requestAnimationFrame(animIllus);
  })();

})(typeof ZONES !== 'undefined' ? ZONES : []);
```

### SNIPPET F — Compile-reveal CSS (add inside `<style>` in every page)

```css
  /* ── COMPILE-REVEAL ── */
  .compile-card { position: relative; overflow: hidden; }
  .compile-overlay {
    position: absolute; inset: 0; padding: 14px 16px;
    font-size: 9px; line-height: 1.5; color: var(--dim);
    white-space: pre; pointer-events: none;
    background: inherit; z-index: 1;
    opacity: 1; transition: opacity 0.25s ease;
  }
  .compile-card.visible .compile-overlay { opacity: 0; transition-delay: 0.2s; }
  .compile-real { opacity: 0; transition: opacity 0.3s ease 0.35s; }
  .compile-card.visible .compile-real { opacity: 1; }
  .compile-card::after {
    content: ''; position: absolute; top: 0; left: 0; right: 0; height: 1px;
    background: linear-gradient(90deg, transparent, var(--cyan), transparent);
    transform: scaleX(0); transform-origin: left;
    transition: transform 0.5s ease 0.15s; z-index: 2;
  }
  .compile-card.visible::after { transform: scaleX(1); }
```

---

## Task 1: Git branch + .gitignore

**Files:**
- Create: `.gitignore`
- Git: new branch `redesign/terminal-aesthetic`

- [ ] **Step 1: Create the branch**

```bash
git checkout -b redesign/terminal-aesthetic
```

Expected: `Switched to a new branch 'redesign/terminal-aesthetic'`

- [ ] **Step 2: Create `.gitignore`**

Create `/mnt/BatLair/Resume/.gitignore` with this content:

```
.superpowers/
.env
*.local
```

- [ ] **Step 3: Commit**

```bash
git add .gitignore
git commit -m "chore: add gitignore, start redesign branch"
```

---

## Task 2: index.html — fonts, CSS vars, effect layer CSS

**Files:**
- Modify: `index.html:10` (font import)
- Modify: `index.html:28-29` (font vars)
- Modify: `index.html:70-77` (body::before scanlines → keep but reduce; add new CSS)

- [ ] **Step 1: Replace the Google Fonts `@import` on line 10**

Replace:
```css
  @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:ital,wght@0,100;0,300;0,400;0,600;0,700;1,300&family=Syne:wght@400;700;800&display=swap');
```
With **SNIPPET A**.

- [ ] **Step 2: Update font CSS variables (lines 28-29)**

Replace:
```css
    --font-mono: 'JetBrains Mono', monospace;
    --font-display: 'Syne', sans-serif;
```
With:
```css
    --font-mono: 'JetBrains Mono', monospace;
    --font-display: 'Oxanium', sans-serif;
    --font-label: 'Share Tech Mono', monospace;
    --s1: 8px; --s2: 16px; --s3: 24px; --s4: 32px; --s5: 48px; --s6: 64px;
```

- [ ] **Step 3: Weaken existing body::before scanlines (lines 70-77)**

Replace:
```css
  body::before {
    content: '';
    position: fixed;
    inset: 0;
    background: repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0,0,0,0.08) 2px, rgba(0,0,0,0.08) 4px);
    pointer-events: none;
    z-index: 1000;
  }
```
With:
```css
  body::before {
    content: '';
    position: fixed;
    inset: 0;
    background: repeating-linear-gradient(0deg, transparent, transparent 3px, rgba(0,0,0,0.09) 3px, rgba(0,0,0,0.09) 4px);
    pointer-events: none;
    z-index: 4;
  }
```

- [ ] **Step 4: Add effect layer CSS + compile-reveal CSS**

Find the end of the `.cursor-ring` rule block (after line ~67). Add **SNIPPET D** immediately after, then add **SNIPPET F** after that.

- [ ] **Step 5: Update section heading font references**

In `index.html`, these lines use `var(--font-display)` — since we changed `--font-display` to Oxanium, they auto-update. Verify the lines: 220, 379, 455, 535, 716. No edit needed — variable swap handles it.

- [ ] **Step 6: Open index.html in browser, verify**

Open `file:///mnt/BatLair/Resume/index.html` — check that the page still renders (no JS errors, fonts load). Effects will be wired in Task 4.

- [ ] **Step 7: Commit**

```bash
git add index.html
git commit -m "feat(index): swap fonts to Oxanium + Share Tech Mono, add effect layer CSS"
```

---

## Task 3: index.html — effect layer HTML + canvas elements

**Files:**
- Modify: `index.html:637-638` (after cursor divs, add canvas/div layers)

- [ ] **Step 1: Add effect layer HTML elements**

Find lines 637-638 in `index.html`:
```html
<div class="cursor" id="cursor"></div>
<div class="cursor-ring" id="cursorRing"></div>
```

Replace with:
```html
<canvas id="rain-cv"></canvas>
<canvas id="illus-cv"></canvas>
<div id="dot-field"></div>
<div id="cur-glow"></div>
<div id="vign"></div>
<div id="illus-label"></div>
<div class="cursor" id="cursor"></div>
<div class="cursor-ring" id="cursorRing"></div>
```

- [ ] **Step 2: Remove the existing cursor mousemove handler**

The existing JS (around line 1093 in the original, now shifted) directly positions `cursorRing` on every `mousemove`. SNIPPET E replaces this with an eased animation loop — both running simultaneously will cause the ring to snap rather than ease. Find and **delete** this block from the existing `<script>`:

```javascript
document.addEventListener('mousemove', e => {
  cursor.style.left = e.clientX + 'px';
  cursor.style.top = e.clientY + 'px';
  cursorRing.style.left = e.clientX + 'px';
  cursorRing.style.top = e.clientY + 'px';
});
```

SNIPPET E's `initEffects` handles cursor dot + ring positioning entirely. Also remove the `const cursor = document.getElementById('cursor')` and `const cursorRing = document.getElementById('cursorRing')` declarations if they appear only in that handler block (SNIPPET E uses `curEl`/`ringEl` internally).

- [ ] **Step 3: Verify page still renders**

Open `file:///mnt/BatLair/Resume/index.html` — canvas elements exist in DOM (check DevTools), no layout breaks.

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "feat(index): add effect layer canvas and div elements, remove legacy cursor handler"
```

---

## Task 4: index.html — hero restructure

**Files:**
- Modify: `index.html` — hero section (lines 657–677), hero CSS (lines ~174–260)

The current hero is a simple two-div flex layout. We're adding: ASCII name stage (4 glitch frames), stats row, and stack badges below terminal.

- [ ] **Step 1: Replace hero CSS**

Find the existing `.hero` rule block and all `.hero-content`, `.hero-terminal`, `.hero-tagline`, `.hero-tags`, `.hero-cta` rules. Replace the entire hero CSS block with:

```css
  /* ── HERO ── */
  #hero {
    min-height: 100vh;
    padding-top: 60px;
    display: grid;
    grid-template-columns: 1fr 460px;
    grid-template-rows: 1fr auto;
    gap: 0 52px;
  }
  .hero-main {
    grid-column: 1; grid-row: 1;
    display: flex; flex-direction: column; justify-content: center;
    padding: var(--s6) 0 var(--s4) var(--s5);
  }
  .hero-aside {
    grid-column: 2; grid-row: 1 / 3;
    display: flex; flex-direction: column; gap: 14px;
    padding: var(--s6) var(--s5) var(--s4) 0;
    justify-content: center;
  }
  .hero-bottom {
    grid-column: 1; grid-row: 2;
    padding: 0 0 var(--s4) var(--s5);
  }

  /* ASCII name stage */
  .ascii-stage { position: relative; height: 110px; overflow: hidden; margin-bottom: 22px; }
  .ascii-frame {
    position: absolute; inset: 0;
    font-family: var(--font-mono);
    font-size: clamp(5px, 0.75vw, 6.8px);
    line-height: 1.22; white-space: pre; letter-spacing: 0;
    text-shadow: 0 0 8px rgba(77,217,240,0.3);
    opacity: 0; transition: opacity 0.1s;
  }
  .ascii-frame.show { opacity: 1; }
  .ascii-frame.split-r { transform: translateX(2px); }
  .ascii-frame.split-l { transform: translateX(-2px); }
  .orb {
    position: absolute; font-family: var(--font-mono); pointer-events: none;
    color: rgba(77,217,240,0.3);
    animation: orb-drift linear infinite;
  }
  @keyframes orb-drift {
    0%   { opacity: 0.1; transform: translate(0,0); }
    25%  { opacity: 0.45; }
    75%  { opacity: 0.5; }
    100% { opacity: 0.05; transform: translate(var(--ex), var(--ey)); }
  }

  .hero-eyebrow {
    font-family: var(--font-label);
    font-size: 10px; color: var(--muted);
    letter-spacing: 3px; text-transform: uppercase;
    margin-bottom: 14px;
  }
  .hero-main h1 {
    font-family: var(--font-display);
    font-size: clamp(22px, 2.8vw, 38px);
    font-weight: 800; color: var(--bright);
    line-height: 1.08; letter-spacing: 1px;
    margin-bottom: 14px;
  }
  .hero-main h1 em { color: var(--cyan); font-style: normal; }
  .hero-desc {
    font-size: 11.5px; color: var(--muted);
    line-height: 1.85; max-width: 400px; margin-bottom: 20px;
  }
  .hero-tags { display: flex; flex-wrap: wrap; gap: 7px; margin-bottom: 22px; }
  .hero-tags .tag {
    font-family: var(--font-label);
    font-size: 9px; padding: 3px 9px;
    border: 1px solid var(--border); border-radius: 2px;
    color: var(--muted); letter-spacing: 1.5px; text-transform: uppercase;
    transition: border-color 0.2s, color 0.2s;
  }
  .hero-tags .tag:hover { border-color: var(--cyan); color: var(--cyan); }
  .hero-cta { display: flex; gap: 12px; }

  /* Stats row */
  .stats-row {
    display: flex; gap: 40px;
    padding: 20px 0; border-top: 1px solid var(--border);
  }
  .stat-num {
    font-family: var(--font-display);
    font-size: 30px; font-weight: 800; color: var(--bright); line-height: 1;
  }
  .stat-num em { color: var(--cyan); font-style: normal; font-size: 18px; }
  .stat-lbl {
    font-family: var(--font-label);
    font-size: 9px; color: var(--muted);
    letter-spacing: 2px; text-transform: uppercase; margin-top: 4px;
  }

  /* Stack badges */
  .stack-row { display: flex; flex-wrap: wrap; gap: 6px; }
  .stack-badge {
    font-family: var(--font-label); font-size: 9px;
    padding: 4px 8px; background: var(--bg3);
    border: 1px solid var(--border); border-radius: 2px; color: var(--muted);
  }

  /* Mobile hero */
  @media (max-width: 900px) {
    #hero { grid-template-columns: 1fr; grid-template-rows: auto; }
    .hero-aside { display: none; }
    .hero-main { padding: 80px var(--s3) var(--s3); }
    .hero-bottom { padding: 0 var(--s3) var(--s4); }
  }
```

- [ ] **Step 2: Replace hero HTML (lines 657–677)**

Replace:
```html
<!-- HERO -->
<section id="hero">
  <div class="hero-content fade-up">
    <h1 id="heroName"></h1>
    <p class="hero-tagline" id="heroTagline"></p>
    <div class="hero-tags" id="heroTags"></div>
    <div class="hero-cta">
      <a href="#connections" class="btn btn-primary">get in touch</a>
      <a href="#projects" class="btn btn-ghost">view projects</a>
    </div>
  </div>

  <div class="hero-terminal fade-up" style="transition-delay:0.2s">
    <div class="term-bar">
      <div class="term-dot r"></div>
      <div class="term-dot y"></div>
      <div class="term-dot g"></div>
      <div class="term-title" id="termTitle"></div>
    </div>
    <div class="term-body" id="termBody"></div>
  </div>
</section>
```

With:
```html
<!-- HERO -->
<section id="hero">
  <div class="hero-main">
    <!-- ASCII name stage — 4 glitch frames, JS-controlled -->
    <div class="ascii-stage" id="asciiStage">
      <div class="ascii-frame show" id="asciiFrame0" style="color:var(--cyan)">
 ██████╗  ██████╗ ███████╗██╗  ██╗ █████╗ ███╗   ██╗
 ██╔══██╗██╔═══██╗██╔════╝██║  ██║██╔══██╗████╗  ██║
 ██████╔╝██║   ██║███████╗███████║███████║██╔██╗ ██║
 ██╔══██╗██║   ██║╚════██║██╔══██║██╔══██║██║╚██╗██║
 ██║  ██║╚██████╔╝███████║██║  ██║██║  ██║██║ ╚████║
 ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝</div>
      <div class="ascii-frame" id="asciiFrame1" style="color:var(--green)">
 ╔════════════════════════════════════════════════════╗
 ║  SERVER: roshan-prod-01    STATUS: ● ONLINE        ║
 ╠════════╦══════════╦═════════════╦══════════════════╣
 ║ CPU 3% ║ RAM 12GB ║ DISK 240GB  ║ NET ▲ 1.2GB/s   ║
 ╠════════╩══════════╩═════════════╩══════════════════╣
 ╚════════════════════════════════════════════════════╝</div>
      <div class="ascii-frame" id="asciiFrame2" style="color:var(--orange)">
          /\    /\    /\    /\    /\    /\    /\
         /  \  /██\  /  \  /██\  /  \  /██\  /  \
        / RA \/ ██ \/ SH \/ ██ \/ AN \/ ██ \/    \
       /──────────────────────────────────────────\
      |  ┌──┐        ┌──────────────┐        ┌──┐  |
      |  │  │ OPEN   │  roshan.dev  │ ALWAYS │  │  |
      |  └──┘        └──────────────┘        └──┘  |</div>
      <div class="ascii-frame" id="asciiFrame3" style="color:var(--purple)">
 INPUT          HIDDEN                        OUTPUT
  ◉ ──────────── ◉ ──── ◉ ──────────────────── ◉
   \   ╲        / \ ╲  / \                    /
    ◉   ╲──── ◉    ╲◉╱   ◉ ── ◉ ── [ROSHAN] ◉
   /     ╲  /       X    /       ╲            \
  ◉       ◉         ◉  ◉    ◉    ◉─────────── ◉
   \     / \       / \/      \  /
    ◉ ─── ◉ ╲─── ◉  /\   ◉──◉ ──────────────  ◉</div>
    </div>

    <p class="hero-eyebrow" id="heroEyebrow">AI Solutions Consultant · roshan.dev</p>
    <h1 id="heroName"></h1>
    <p class="hero-desc" id="heroDesc"></p>
    <div class="hero-tags" id="heroTags"></div>
    <div class="hero-cta">
      <a href="#connections" class="btn btn-primary">get in touch</a>
      <a href="#projects" class="btn btn-ghost">view projects →</a>
    </div>
  </div>

  <div class="hero-aside">
    <div class="hero-terminal" id="heroTerminal">
      <div class="term-bar">
        <div class="term-dot r"></div>
        <div class="term-dot y"></div>
        <div class="term-dot g"></div>
        <div class="term-title" id="termTitle"></div>
      </div>
      <div class="term-body" id="termBody"></div>
    </div>
    <div class="stack-row" id="stackRow"></div>
  </div>

  <div class="hero-bottom">
    <div class="stats-row" id="statsRow">
      <div><div class="stat-num">7<em>+</em></div><div class="stat-lbl">Years Experience</div></div>
      <div><div class="stat-num">40<em>+</em></div><div class="stat-lbl">AI Systems Shipped</div></div>
      <div><div class="stat-num">12<em>+</em></div><div class="stat-lbl">Enterprise Clients</div></div>
      <div><div class="stat-num">3<em>×</em></div><div class="stat-lbl">Avg Cost Reduction</div></div>
    </div>
  </div>
</section>
```

- [ ] **Step 3: Populate `heroDesc` and `stackRow` from CONFIG in the JS render block**

Find the JS block that renders the hero (around line 953 — `document.getElementById('heroName').innerHTML = ...`). Add these two lines after the existing hero render calls:

```javascript
  // hero desc (use first about paragraph as sub-tagline)
  const heroDescEl = document.getElementById('heroDesc');
  if (heroDescEl) heroDescEl.textContent = CONFIG.aboutParagraphs[0]
    ? CONFIG.aboutParagraphs[0].substring(0, 180) + '…'
    : '';

  // stack row badges
  const stackRowEl = document.getElementById('stackRow');
  if (stackRowEl && CONFIG.stack) {
    stackRowEl.innerHTML = CONFIG.stack.map(s =>
      `<span class="stack-badge">${s}</span>`
    ).join('');
  }
```

- [ ] **Step 4: Open in browser, verify hero grid layout**

Open `file:///mnt/BatLair/Resume/index.html`. Check:
- Two-column hero (left: eyebrow + heading + tags + CTA, right: terminal)
- Stats row at hero bottom
- ASCII name stage visible (frame 0 showing ROSHAN block letters)

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "feat(index): hero grid restructure with ASCII stage, stats row, stack badges"
```

---

## Task 5: index.html — ASCII glitch cycle + orbital chars + effect JS

**Files:**
- Modify: `index.html` — `<script>` block (add before existing JS)

- [ ] **Step 1: Add `ZONES` array + insert SNIPPET E**

Find the opening `<script>` tag in `index.html`. Insert the following immediately after `<script>`:

```javascript
// ── ILLUSTRATION ZONES (index.html) ──
const ZONES = [
  {
    id: 'hero-main', sel: '.hero-main', label: '// profile loaded',
    color: '#4dd9f0',
    art: [
      '  ┌──────────────────────────────┐  ',
      '  │  ❯ whoami                    │  ',
      '  │  > roshan.abraham            │  ',
      '  │  ❯ curl roshan.dev/api/me    │  ',
      '  │  > {"role":"AI Consultant",  │  ',
      '  │     "yoe":7,"status":"open"} │  ',
      '  │  ❯ █                        │  ',
      '  └──────────────────────────────┘  ',
    ]
  },
  {
    id: 'terminal', sel: '#heroTerminal', label: '// zsh session active',
    color: '#3dffa0',
    art: [
      '   ╭─────────────────────╮   ',
      '   │  roshan@dev  ✓ zsh  │   ',
      '   ├─────────────────────┤   ',
      '   │  uptime: 7y 3m      │   ',
      '   │  load:   0.04       │   ',
      '   │  mem:    free 14GB  │   ',
      '   │  disk:   ██░░ 42%   │   ',
      '   ╰─────────────────────╯   ',
    ]
  },
  {
    id: 'about', sel: '#about', label: '// skills resolved',
    color: '#a78bfa',
    art: [
      '   npm install @roshan/brain    ',
      '   ┌──────────────────────────┐ ',
      '   │ ✓ llm-finetuning  v9.2.0 │ ',
      '   │ ✓ rag-systems     v8.8.1 │ ',
      '   │ ✓ agentic-pipelines v9.5 │ ',
      '   │ ✓ vector-db       v8.5.0 │ ',
      '   │ ✓ mlops-infra     v8.0.3 │ ',
      '   └──────────────────────────┘ ',
    ]
  },
  {
    id: 'projects', sel: '#projects', label: '// projects compiled',
    color: '#ff9f4a',
    art: [
      '  git log --oneline --graph      ',
      '  * 8f2a1c  verity-protocol      ',
      '  │ ✓ 94% accuracy  │ prod       ',
      '  * 3d9b4f  rag-optimizer        ',
      '  │ ✓ eval harness  │ prod       ',
      '  * 1c7e2a  llm-cost-guard       ',
      '    ✓ 3× cheaper    │ prod       ',
    ]
  },
  {
    id: 'stats', sel: '.stats-row', label: '// metrics loaded',
    color: '#fbbf24',
    art: [
      '  ┌──────────────────────────┐  ',
      '  │  PERFORMANCE METRICS     │  ',
      '  ├──────────────────────────┤  ',
      '  │  Experience  ████████ 7y │  ',
      '  │  Systems     ███████ 40+ │  ',
      '  │  Clients     █████  12+  │  ',
      '  │  Cost↓       ████   3×   │  ',
      '  └──────────────────────────┘  ',
    ]
  },
];
```

Then insert **SNIPPET E** (the full `initEffects` IIFE) immediately after the ZONES array.

- [ ] **Step 2: Add ASCII glitch cycle JS**

After SNIPPET E, add:

```javascript
// ── ASCII NAME GLITCH CYCLE ──
(function initGlitch() {
  const frames = [0,1,2,3].map(i => document.getElementById('asciiFrame' + i));
  if (!frames[0]) return;
  let cf = 0;

  function switchTo(n) {
    const cur = frames[cf], nxt = frames[n];
    cur.classList.add('split-r');
    setTimeout(() => { cur.classList.remove('split-r'); cur.classList.add('split-l'); }, 60);
    setTimeout(() => { cur.classList.remove('split-l', 'show'); nxt.classList.add('show'); cf = n; }, 120);
  }

  // Cycle every 8s
  setInterval(() => switchTo((cf + 1) % 4), 8000);

  // Micro-glitch on frame 0 every 3.2s (no swap)
  setInterval(() => {
    if (cf === 0) {
      frames[0].classList.add('split-r');
      setTimeout(() => frames[0].classList.remove('split-r'), 80);
      setTimeout(() => { frames[0].classList.add('split-l'); setTimeout(() => frames[0].classList.remove('split-l'), 80); }, 100);
    }
  }, 3200);

  // Orbital characters
  const stage = document.getElementById('asciiStage');
  if (stage) {
    '<>{}[]|/\\*@#$%^&~;:=+-×÷≠∞∑░▒▓│─╭╮╰╯'.split('').forEach(c => {
      const o = document.createElement('div');
      o.className = 'orb';
      o.textContent = c;
      const l = Math.random() * 100, t = Math.random() * 100;
      const dur = 3 + Math.random() * 6, del = Math.random() * 4;
      const ex = (Math.random() - 0.5) * 80, ey = (Math.random() - 0.5) * 60;
      o.style.cssText = `left:${l}%;top:${t}%;font-size:${8 + Math.random()*5}px;` +
        `--ex:${ex}px;--ey:${ey}px;animation-duration:${dur}s;animation-delay:-${del}s`;
      stage.appendChild(o);
    });
  }
})();
```

- [ ] **Step 3: Open in browser, verify all effects**

Open `file:///mnt/BatLair/Resume/index.html`:
- Matrix rain visible behind page content (faint green/dark)
- Moving cursor produces particle trail (cyan/green/purple/pink dots)
- Hovering any link expands the cursor ring
- ASCII name in hero, wait 8s → glitch transition to server rack frame
- Moving cursor near hero/terminal/skills/projects → ASCII illustration appears in corner
- Stats row shows at bottom of hero left column

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "feat(index): effect JS — rain, cursor particles, glitch cycle, orbital chars, illustration zones"
```

---

## Task 6: index.html — compile-reveal on skill and project cards

**Files:**
- Modify: `index.html` — JS section that renders `skillsGrid` and `projectsGrid`

The existing `skillsGrid` and `projectsGrid` are rendered by CONFIG-driven JS. We wrap each generated card in the compile-reveal pattern.

- [ ] **Step 1: Update skill card rendering**

Find the JS that renders skill cards into `#skillsGrid` (search for `skillsGrid.innerHTML` or where `.skill-item` is assembled). Each skill category block renders `.skill-item` elements. Wrap each `.skill-item` div as a `compile-card` by adding the class and a `.compile-overlay` child.

Find the template literal that creates a skill item — it will look something like:
```javascript
`<div class="skill-item fade-up" style="transition-delay:${delay}s">
  <div class="skill-header">...</div>
  <div class="skill-bar">...</div>
</div>`
```

Change `"skill-item fade-up"` to `"skill-item fade-up compile-card"` and add a compile overlay as the first child:
```javascript
`<div class="skill-item fade-up compile-card" style="transition-delay:${delay}s">
  <div class="compile-overlay">// resolving skill module...\nimport SkillModule from '@ra/core'\nexport default { id: "${s.name.toLowerCase().replace(/\s+/g,'-')}", pct: ${s.pct} }</div>
  <div class="compile-real">
    <div class="skill-header">...</div>
    <div class="skill-bar">...</div>
  </div>
</div>`
```

(Preserve all existing inner markup inside `.compile-real`.)

- [ ] **Step 2: Update project card rendering**

Find the JS that renders project cards into `#projectsGrid`. Wrap each project card element similarly:

Change the project card template to add `compile-card` class and wrap real content in `.compile-real`, with a `.compile-overlay`:

```javascript
`<div class="project-card fade-up compile-card" ...>
  <div class="compile-overlay">// building project component...\nconst proj = {\n  name: "${p.name}",\n  stack: [${p.tech.slice(0,3).map(t=>`"${t}"`).join(', ')}]\n}</div>
  <div class="compile-real">
    ... (existing project card inner HTML) ...
  </div>
</div>`
```

- [ ] **Step 3: Verify compile-reveal in browser**

Open `file:///mnt/BatLair/Resume/index.html`, scroll to skills section. Cards should initially show the "// resolving skill module..." code text, which fades out after 0.25s once visible, revealing the real content. If cards are already visible on load before scroll, trigger visibility by scrolling past and back.

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "feat(index): compile-reveal on skill and project cards"
```

---

## Task 7: about.html — full treatment

**Files:**
- Modify: `about.html` — fonts, CSS, effect layers, compile-reveal on timeline + skills

- [ ] **Step 1: Font import + CSS vars (line 10, lines 28-29)**

Same as Task 2 Steps 1-2. Apply **SNIPPET A** and the updated font vars.

- [ ] **Step 2: Weaken body::before scanlines**

Same as Task 2 Step 3. Find `body::before` and change its z-index to `4` and opacity to `0.09`.

- [ ] **Step 3: Add effect layer CSS + compile-reveal CSS**

Add **SNIPPET D** and **SNIPPET F** after the `.cursor-ring` rule block.

- [ ] **Step 4: Add effect layer HTML**

Find the `<div class="cursor" id="cursor"></div>` line (around line 556). Insert **SNIPPET C** immediately before that line.

- [ ] **Step 5: Add ZONES + SNIPPET E to `<script>`**

Insert at the top of `<script>`:

```javascript
const ZONES = [
  {
    id: 'timeline', sel: '.timeline', label: '// career history',
    color: '#4dd9f0',
    art: [
      '  git log --graph --oneline      ',
      '  * 2024  Senior AI Consultant   ',
      '  │                              ',
      '  * 2022  ML Engineer            ',
      '  │                              ',
      '  * 2020  Data Scientist         ',
      '  │                              ',
      '  * 2018  Software Engineer      ',
    ]
  },
  {
    id: 'skills', sel: '.skills-section', label: '// skill modules',
    color: '#a78bfa',
    art: [
      '   npm install @roshan/brain    ',
      '   ┌──────────────────────────┐ ',
      '   │ ✓ llm-finetuning  v9.2.0 │ ',
      '   │ ✓ rag-systems     v8.8.1 │ ',
      '   │ ✓ agentic-pipelines v9.5 │ ',
      '   └──────────────────────────┘ ',
    ]
  },
  {
    id: 'education', sel: '.education-section', label: '// credentials',
    color: '#fbbf24',
    art: [
      '         .------.              ',
      '        /|  🎓  |\\            ',
      '       / |      | \\           ',
      '      /  | GRAD |  \\          ',
      '     /____|______|___\\         ',
      '     |  DIPLOMA: AI  |        ',
      '     |_______________|        ',
    ]
  },
];
```

Then insert **SNIPPET E** after the ZONES array.

- [ ] **Step 6: Remove existing cursor mousemove handler**

Same as Task 3 Step 2 — find and delete the block:
```javascript
document.addEventListener('mousemove', e => {
  cursor.style.left = e.clientX + 'px';
  cursor.style.top = e.clientY + 'px';
  cursorRing.style.left = e.clientX + 'px';
  cursorRing.style.top = e.clientY + 'px';
});
```
Also remove the `const cursor`/`const cursorRing` declarations if they are only used in that block.

- [ ] **Step 7: Add compile-reveal to timeline items**

Find the JS that renders timeline items (search for `.timeline-item` template literal). Add `compile-card` class to each item and wrap its content:

```javascript
`<div class="timeline-item fade-up compile-card" style="transition-delay:${i * 0.1}s">
  <div class="compile-overlay">// loading experience entry...\nconst exp = {\n  role: "${exp.title}",\n  company: "${exp.company}",\n  year: "${exp.period}"\n}</div>
  <div class="compile-real">
    ... existing timeline item inner HTML ...
  </div>
</div>`
```

- [ ] **Step 7: Verify in browser**

Open `file:///mnt/BatLair/Resume/about.html`. Check: rain + cursor + particles, section heading font is Oxanium (narrow/angular), timeline items compile-reveal on scroll, illustration appears near timeline/skills zones.

- [ ] **Step 8: Commit**

```bash
git add about.html
git commit -m "feat(about): effect layers, font swap, compile-reveal timeline, illustration zones"
```

---

## Task 8: projects.html — full treatment

**Files:**
- Modify: `projects.html`

- [ ] **Step 1: Font import + CSS vars (line 10, lines 28-29)** — same as Task 2 Steps 1-2.

- [ ] **Step 2: Weaken body::before** — same as Task 2 Step 3.

- [ ] **Step 3: Add effect layer CSS + compile-reveal CSS** — same as Task 2 Step 4.

- [ ] **Step 4: Add effect layer HTML** — find cursor divs (~line 534), insert SNIPPET C before them.

- [ ] **Step 5: Add ZONES + SNIPPET E to `<script>`**

```javascript
const ZONES = [
  {
    id: 'featured', sel: '.featured-project', label: '// featured project',
    color: '#4dd9f0',
    art: [
      '  ┌──────────────────────────┐  ',
      '  │   VERITY PROTOCOL v2.1   │  ',
      '  ├──────────────────────────┤  ',
      '  │  [client]──▶[gateway]    │  ',
      '  │       │                  │  ',
      '  │  [agent loop]            │  ',
      '  │   ╱         ╲           │  ',
      '  │ [vdb]    [gpt-4o]        │  ',
      '  └──────────────────────────┘  ',
    ]
  },
  {
    id: 'projects-grid', sel: '.projects-grid', label: '// project registry',
    color: '#ff9f4a',
    art: [
      '  git log --oneline --graph      ',
      '  * 8f2a1c  verity-protocol      ',
      '  * 3d9b4f  rag-optimizer        ',
      '  * 1c7e2a  llm-cost-guard       ',
      '  * 9a4f3b  agent-framework      ',
      '  * 2e8c1d  embed-pipeline       ',
    ]
  },
];
```

Then insert **SNIPPET E**.

- [ ] **Step 6: Remove existing cursor mousemove handler** — same as Task 3 Step 2.

- [ ] **Step 7: Add compile-reveal to project cards**

Find the JS or HTML that creates each `.project-card`. Add `compile-card` class and compile overlay (same pattern as Task 6 Step 2).

- [ ] **Step 7: Verify in browser** — `file:///mnt/BatLair/Resume/projects.html`. Rain, cursor, particles, Oxanium headings, compile-reveal on project cards, illustrations on hover.

- [ ] **Step 8: Commit**

```bash
git add projects.html
git commit -m "feat(projects): effect layers, font swap, compile-reveal cards, illustration zones"
```

---

## Task 9: articles.html — full treatment

**Files:**
- Modify: `articles.html`

- [ ] **Step 1: Font import + CSS vars** — same as Task 2 Steps 1-2.

- [ ] **Step 2: Weaken body::before** — same as Task 2 Step 3.

- [ ] **Step 3: Add effect layer CSS + compile-reveal CSS** — same as Task 2 Step 4.

- [ ] **Step 4: Add effect layer HTML** — find cursor divs, insert SNIPPET C before them.

- [ ] **Step 5: Add ZONES + SNIPPET E**

```javascript
const ZONES = [
  {
    id: 'articles-list', sel: '.articles-list', label: '// articles index',
    color: '#3dffa0',
    art: [
      '  cat articles/index.md         ',
      '  ┌──────────────────────────┐  ',
      '  │ # LLMOps in Production   │  ',
      '  │ # RAG Beyond Basics      │  ',
      '  │ # Agent Architecture     │  ',
      '  │ # Vector DB Benchmark    │  ',
      '  └──────────────────────────┘  ',
    ]
  },
  {
    id: 'tag-filter', sel: '.tag-filter', label: '// grep --color=auto',
    color: '#f472b6',
    art: [
      '  grep -r "llmops" ./articles   ',
      '  > LLMOps in Production.md     ',
      '  > CI for LLM Pipelines.md     ',
      '                                ',
      '  grep -r "rag" ./articles      ',
      '  > RAG Beyond Basics.md        ',
      '  > Hybrid Retrieval.md         ',
    ]
  },
];
```

Then insert **SNIPPET E**.

- [ ] **Step 6: Remove existing cursor mousemove handler** — same as Task 3 Step 2.

- [ ] **Step 7: Add type-in reveal on article list items**

Find the JS that renders `.article-item` elements (around line 1008 in index.html pattern, but here in articles.html). Add `compile-card` class to each article row and a compile overlay:

```javascript
`<a class="article-item fade-up compile-card" href="${a.url}" ...>
  <div class="compile-overlay">// loading article entry...\ncat articles/${a.title.toLowerCase().replace(/\s+/g,'-')}.md</div>
  <div class="compile-real">
    ... existing article item inner HTML ...
  </div>
</a>`
```

- [ ] **Step 7: Style tag filter buttons with Share Tech Mono**

Find the CSS for tag filter buttons (`.tag-btn` or similar). Add:
```css
  .tag-btn { font-family: var(--font-label); letter-spacing: 1.5px; }
```

- [ ] **Step 8: Verify in browser** — `file:///mnt/BatLair/Resume/articles.html`. Rain, cursor, Oxanium section headings, article items compile-reveal on scroll, tag filter shows `grep` illustration on hover.

- [ ] **Step 9: Commit**

```bash
git add articles.html
git commit -m "feat(articles): effect layers, font swap, compile-reveal articles, illustration zones"
```

---

## Task 10: connect.html — full treatment

**Files:**
- Modify: `connect.html`

- [ ] **Step 1: Font import + CSS vars** — same as Task 2 Steps 1-2.

- [ ] **Step 2: Weaken body::before** — same as Task 2 Step 3.

- [ ] **Step 3: Add effect layer CSS + compile-reveal CSS** — same as Task 2 Step 4.

- [ ] **Step 4: Add effect layer HTML** — find cursor divs (~line 428), insert SNIPPET C before them.

- [ ] **Step 5: Add ZONES + SNIPPET E**

```javascript
const ZONES = [
  {
    id: 'connections', sel: '.connections-content', label: '// establishing connection',
    color: '#4dd9f0',
    art: [
      '  ssh roshan@dev                 ',
      '  > Connecting to roshan.dev...  ',
      '  > Authenticating...            ',
      '  > ✓ Connected                  ',
      '  roshan@dev:~$ ping -c 1 you    ',
      '  > 64 bytes  RTT: 1ms           ',
      '  > ✓ Reachable                  ',
    ]
  },
  {
    id: 'node-center', sel: '#centerNode', label: '// node graph',
    color: '#a78bfa',
    art: [
      '   ◉─────◉─────◉              ',
      '   │  LinkedIn  │              ',
      '   ◉─────◉─────◉              ',
      '   │   GitHub   │              ',
      '   ◉─────◉─────◉              ',
      '   │   Email    │              ',
      '   ◉─────◉─────◉              ',
    ]
  },
];
```

Then insert **SNIPPET E**.

- [ ] **Step 6: Remove existing cursor mousemove handler** — same as Task 3 Step 2.

- [ ] **Step 7: Add compile-reveal to connection nodes**

Find the JS that renders `.node-card` or connection items. Add `compile-card` class and overlay:

```javascript
`<div class="node-card fade-up compile-card" ...>
  <div class="compile-overlay">// resolving contact node...\nconst node = {\n  platform: "${c.name}",\n  handle: "${c.handle}"\n}</div>
  <div class="compile-real">
    ... existing node inner HTML ...
  </div>
</div>`
```

- [ ] **Step 7: Enhance SVG connection line glow**

Find the SVG line-drawing code (around `connObs` / `strokeDashoffset`). Update line stroke styles:

```javascript
// Change stroke-width from 1 to 1.5 and add filter for glow
path.style.strokeWidth = '1.5';
path.style.filter = 'drop-shadow(0 0 3px currentColor)';
```

- [ ] **Step 8: Verify in browser** — `file:///mnt/BatLair/Resume/connect.html`. Rain, cursor, connection node compile-reveal, SVG lines with glow, `ssh` illustration on hover.

- [ ] **Step 9: Commit**

```bash
git add connect.html
git commit -m "feat(connect): effect layers, font swap, compile-reveal nodes, SVG glow, illustration zones"
```

---

## Task 11: Final QA pass + merge prep

**Files:** All 5 HTML files (read-only verification)

- [ ] **Step 1: Cross-page font consistency check**

Open each page. Verify section titles use Oxanium (narrow, angular), body text is JetBrains Mono. Grep to confirm no stray `'Syne'` references remain:

```bash
grep -n "Syne" /mnt/BatLair/Resume/index.html /mnt/BatLair/Resume/about.html /mnt/BatLair/Resume/projects.html /mnt/BatLair/Resume/articles.html /mnt/BatLair/Resume/connect.html
```

Expected: no output (zero matches).

- [ ] **Step 2: Effect layer presence check**

```bash
grep -l "rain-cv" /mnt/BatLair/Resume/index.html /mnt/BatLair/Resume/about.html /mnt/BatLair/Resume/projects.html /mnt/BatLair/Resume/articles.html /mnt/BatLair/Resume/connect.html
```

Expected: all 5 files listed.

- [ ] **Step 3: Mobile check**

Resize browser to 375px wide. Verify: cursor hidden, canvas elements hidden (`display:none`), native cursor restored, layout still readable.

- [ ] **Step 4: Check analytics placeholders intact**

```bash
grep -c "CLOUDFLARE_TOKEN_HERE\|CLARITY_ID_HERE" /mnt/BatLair/Resume/index.html
```

Expected: 2 (one per placeholder — build.sh injects real tokens at deploy time).

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "feat: complete terminal aesthetic redesign across all 5 pages"
```

- [ ] **Step 6: Summarize branch for PR**

```bash
git log main..HEAD --oneline
```

Review the commit list and confirm all 5 pages are covered before opening a PR to `main`.
