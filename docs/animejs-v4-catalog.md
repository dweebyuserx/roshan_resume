# anime.js v4 Animation Catalog
## Reference for terminal/engineering dark-mode portfolio

**Source confirmed:** `animejs@4.0.2` via jsDelivr CDN (76 KB minified)  
**Load pattern:** `<script src="https://cdn.jsdelivr.net/npm/animejs@4.0.2/lib/anime.iife.min.js" defer></script>`  
**Global:** `window.anime` — always guard with `if (typeof anime === 'undefined') return;`

---

## 1. Confirmed v4 API Syntax

### Core call signature
```js
anime({
  targets: '.selector' | DOMElement | NodeList | Array,
  translateX: [from, to],   // or single value (to)
  opacity: [0, 1],
  scaleX: [0, 1],
  duration: 600,            // ms
  delay: anime.stagger(80), // or number
  ease: 'outQuart',         // NOT easing:, NOT 'easeOutQuart'
  onComplete: (anim) => {}
});
```

### Key v4 API changes from v3
| v3 | v4 |
|----|----|
| `easing: 'easeOutQuart'` | `ease: 'outQuart'` |
| `anime.timeline()` | `anime.createTimeline()` |
| `targets` accepts same types | unchanged |
| `update` callback | `onUpdate` |
| `anime.running` | removed |

---

## 2. Easing Functions

### Confirmed available in v4 (verified from source + codebase usage)

**Polynomial curves** (best for data/technical UI — fast out, no wobble):
```
'outQuad'     — gentlest, nearly linear exit. Good for opacity, dim overlays
'outCubic'    — standard decel. Reliable workhorse
'outQuart'    — snappier decel, feels precise. Good for bars, panels
'outQuint'    — very sharp stop. Use for UI that snaps into place
'outExpo'     — fastest exit, near-instant settle. Good for count-up triggers
'inQuad'      — accelerates in. Use for elements leaving screen
'inOutSine'   — smooth S-curve. Good for looping/idle animations
'inOutCubic'  — heavier S-curve. Good for panel transitions
'inOutQuart'  — even heavier. For hero transitions
'linear'      — constant rate. Good for progress bars, typewriter timing
```

**Elastic/spring curves** (use sparingly — one or two elements per page):
```
'outElastic(amplitude, period)'   — e.g. 'outElastic(1, .5)'
                                    amplitude 1 = standard overshoot
                                    period .5 = fast oscillation, .8 = slow
'outBack'                         — slight overshoot, no oscillation
'outBounce'                       — multiple bounces. Avoid for technical UI
'inBack'                          — pulls back before launching
```

**Parametric elastic** (confirmed in `about.html` line 1418):
```js
ease: 'outElastic(1, .5)'   // amplitude=1, period=0.5 — fast snap with one bounce
ease: 'outElastic(1, .8)'   // slower, more organic
ease: 'outElastic(0.6, .4)' // reduced amplitude = subtle bounce
```

### v4 easing name format (critical)
Strip the "ease" prefix from v3 names:
- v3: `'easeOutQuart'` → v4: `'outQuart'`
- v3: `'easeInOutSine'` → v4: `'inOutSine'`
- v3: `'easeOutElastic'` → v4: `'outElastic(1, .5)` (parametric)

---

## 3. Springs — `anime.createSpring()`

### API
```js
const sp = anime.createSpring({
  mass:      1,   // inertia. Higher = slower settle
  stiffness: 80,  // pull force. Higher = faster spring
  damping:   10   // resistance. Higher = less oscillation
});

// Use the returned spring as an ease value:
anime({ targets: el, translateY: -6, ease: sp });
```

### Confirmed in codebase (`mass: 1, stiffness: 80, damping: 10`):
```js
// about.html, projects.html, articles.html, connect.html, index.html
const sp = anime.createSpring({ mass: 1, stiffness: 80, damping: 10 });
document.querySelectorAll('.card').forEach(el => {
  el.addEventListener('mouseenter', () => anime({ targets: el, translateY: -6, ease: sp }));
  el.addEventListener('mouseleave', () => anime({ targets: el, translateY: 0, ease: sp }));
});
```

### Preset tunings for technical/data aesthetics

| Preset | mass | stiffness | damping | Character |
|--------|------|-----------|---------|-----------|
| **Tight snap** | 1 | 200 | 20 | Immediate, crisp. Good for tag entry |
| **Data readout** | 1 | 80 | 10 | Current site default. Confident hover |
| **Structural settle** | 2 | 100 | 18 | Heavier, deliberate. Good for panels |
| **Soft ping** | 0.8 | 60 | 8 | Light, quick. Good for small icons |
| **Oscillator** | 1 | 40 | 4 | Bouncy — use only for decorative elements |

**Rule of thumb for terminal aesthetic:** High stiffness (80–200), moderate damping (10–20) avoids prolonged wobble. Mass 1 is almost always correct.

---

## 4. Stagger — `anime.stagger()`

### Full API
```js
anime.stagger(value, options?)

// options:
{
  start: 0,          // delay before first element (ms or '+=100')
  from: 0,           // index to start stagger from, or 'first'|'last'|'center'
  direction: 'normal' | 'reverse',
  easing: 'linear',  // easing of the stagger offsets themselves
  grid: [cols, rows],// for 2D grid staggers
  axis: 'x' | 'y'   // for grid staggers
}
```

### Patterns for this portfolio

**Sequential bar reveal (skill bars):**
```js
anime({
  targets: '.skill-fill',
  scaleX: [0, 1],
  duration: 700,
  delay: anime.stagger(60, { from: 0 }),
  ease: 'outQuart'
});
```

**Section-level cascade (reveal rows in a group before the next group starts):**
```js
// Stagger from center creates a scanner effect — good for skill groups
anime({
  targets: '.skill-fill',
  scaleX: [0, 1],
  duration: 600,
  delay: anime.stagger(50, { from: 'center' }),
  ease: 'outExpo'
});
```

**Tag entry (right-to-left then settle):**
```js
anime({
  targets: '.ptag',
  translateX: [12, 0],
  opacity: [0, 1],
  duration: 280,
  delay: anime.stagger(35, { from: 'last', direction: 'reverse' }),
  ease: 'outQuart'
});
```

**Meta row stagger (left-edge slide):**
```js
anime({
  targets: '.meta-item',
  translateX: [-16, 0],
  opacity: [0, 1],
  duration: 320,
  delay: anime.stagger(45),
  ease: 'outCubic'
});
```

---

## 5. Timeline / Sequencing — `anime.createTimeline()`

### API
```js
const tl = anime.createTimeline({
  // default properties shared by all .add() calls
  ease: 'outQuart',
  duration: 400
});

tl.add(targets, properties, timeOffset?)
  .add(targets, properties, '+=100')  // 100ms after previous ends
  .add(targets, properties, '-=50')   // overlap previous by 50ms
  .add(targets, properties, 200)      // absolute time (ms from start)
```

### Panel reveal sequence (project detail):
```js
function revealPanel(panel) {
  const tl = anime.createTimeline({ ease: 'outQuart' });
  tl
    .add(panel,                    { opacity: [0, 1], translateY: [8, 0], duration: 180 })
    .add('.stat-num',              { innerHTML: [0, targetVal], duration: 600, round: 1 }, '+=0')
    .add('.meta-item',             { translateX: [-12, 0], opacity: [0, 1], duration: 280,
                                     delay: anime.stagger(40) }, '-=400')
    .add('.ptag',                  { scale: [0.7, 1], opacity: [0, 1], duration: 220,
                                     delay: anime.stagger(30) }, '-=200');
}
```

### ASCII bar typewriter via timeline (replaces setInterval):
```js
// Each character span gets a sequential reveal
const spans = asciiEl.querySelectorAll('span');
anime.createTimeline({ ease: 'linear' })
  .add(spans, { opacity: [0, 1], duration: 1, delay: anime.stagger(18) });
```

---

## 6. Scroll-Linked Animations

### v4 scroll support status: MANUAL ONLY

**anime.js v4 does not include a built-in ScrollObserver or scroll-scrub API.**  
The v3 `anime.running` scroll hacks don't apply. Scroll-linked animation requires:

1. `IntersectionObserver` (trigger once on enter) — already in use site-wide
2. Manual `scroll` event listener with math (already used for Gantt bars in `about.html`)
3. A third-party lib (`ScrollMagic`, GSAP ScrollTrigger, Lenis+observer) if you want scrub

### Current Gantt scroll-scrub pattern (from `about.html` line 1461–1474):
```js
function initTimelineScrub() {
  const section = document.querySelector('.timeline-section');
  const bars = document.querySelectorAll('.tl-bar');
  bars.forEach(b => { b.style.transform = 'scaleX(0)'; b.style.transition = 'none'; });

  window.addEventListener('scroll', () => {
    const rect = section.getBoundingClientRect(), wh = window.innerHeight;
    // raw: 0 when section top hits viewport bottom, 1 when section bottom hits viewport top
    const raw = -(rect.top - wh) / (rect.bottom - rect.top + wh);
    const progress = Math.max(0, Math.min(1, raw));
    bars.forEach((bar, i) => {
      // Each bar starts growing at a different scroll threshold
      bar.style.transform = `scaleX(${Math.max(0, Math.min(1, progress * (N+1) - i))})`;
    });
  }, { passive: true });
}
```
This is efficient as-is. No anime.js needed for continuous scrub — CSS transforms via direct style assignment are faster.

### Alternative: anime.js `seek()` for scroll scrub
If you want anime.js easing on scroll progress (e.g. ease the bar growth curve):
```js
// Create animation but don't autoplay
const anim = anime({
  targets: bars,
  scaleX: [0, 1],
  duration: 1000,
  delay: anime.stagger(100),
  ease: 'outQuart',
  autoplay: false   // v4: autoplay: false prevents auto-start
});

window.addEventListener('scroll', () => {
  const rect = section.getBoundingClientRect(), wh = window.innerHeight;
  const progress = Math.max(0, Math.min(1, -(rect.top - wh) / (rect.height + wh)));
  anim.seek(progress * anim.duration);  // seek(ms) scrubs timeline
}, { passive: true });
```
**Note:** `seek()` confirmed in anime.js v4 source. `autoplay: false` is the v4 way to create a paused animation.

---

## 7. Component-Specific Patterns

### 7.1 Skill Segment Bars (20 █/░ blocks)

**Current:** `scaleX: [0, target*1.06, target]` with `outElastic(1, .5)` — overshoots then settles. This is the strongest choice for the "data loading" feel. Additional ideas:

**A — Per-block stagger (block-by-block fill instead of whole bar growing):**
```js
// Render each block as a <span>, then:
function animateBlockBar(rowEl, filledCount) {
  const blocks = rowEl.querySelectorAll('.block');
  anime({
    targets: blocks,
    opacity: (el, i) => i < filledCount ? [0, 1] : 0,
    scale:   (el, i) => i < filledCount ? [0.5, 1] : 1,
    duration: 120,
    delay: anime.stagger(28, { from: 0 }),
    ease: 'outBack'
  });
}
```

**B — Hover scan pulse (highlight bar momentarily on hover):**
```js
const sp = anime.createSpring({ mass: 1, stiffness: 120, damping: 14 });
skillRows.forEach(row => {
  const fill = row.querySelector('.skill-fill');
  const base = parseFloat(fill.style.width) / 100;
  row.addEventListener('mouseenter', () => {
    anime({ targets: fill, scaleX: base * 1.04, ease: sp });
    anime({ targets: fill, opacity: 1,         ease: sp });
  });
  row.addEventListener('mouseleave', () => {
    anime({ targets: fill, scaleX: base, opacity: 0.85, ease: sp });
  });
});
```

**C — Section-group cascade (fill cyan group, then green, then orange sequentially):**
```js
// Use createTimeline with group offsets
const groups = document.querySelectorAll('.skill-group');
const tl = anime.createTimeline();
groups.forEach((group, gi) => {
  const bars = group.querySelectorAll('.skill-fill');
  tl.add(bars, {
    scaleX: (el) => parseFloat(el.style.width) / 100,
    duration: 700,
    delay: anime.stagger(60),
    ease: 'outElastic(1, .5)'
  }, gi === 0 ? 0 : '-=200'); // overlap groups slightly
});
```

---

### 7.2 Gantt Timeline Bars (scroll-scrubbed)

Current manual scroll-math approach is optimal for continuous scrub. Use anime.js only for the **initial entrance trigger** (when section first scrolls into view):

**A — Trigger-once cascade on intersection (instead of continuous scrub):**
```js
new IntersectionObserver(entries => {
  entries.forEach(e => {
    if (!e.isIntersecting) return;
    const bars = e.target.querySelectorAll('.tl-bar');
    anime({
      targets: bars,
      scaleX: [0, 1],
      duration: 800,
      delay: anime.stagger(120, { from: 0 }),
      ease: 'outQuart',
      transformOrigin: 'left center'  // set via CSS: transform-origin: left
    });
    e.target.style.setProperty('transform-origin', 'left');
  });
}, { threshold: 0.2 }).observe(document.querySelector('.timeline-section'));
```

**B — Staggered scaleX with seek() scrub (anime easing on scroll):**
```js
const bars = document.querySelectorAll('.tl-bar');
const tl = anime.createTimeline({
  ease: 'outCubic',
  autoplay: false
});
bars.forEach((bar, i) => {
  tl.add(bar, { scaleX: [0, 1], duration: 400 }, i * 150);
});

window.addEventListener('scroll', () => {
  const section = document.querySelector('.timeline-section');
  const rect = section.getBoundingClientRect();
  const progress = Math.max(0, Math.min(1, -(rect.top - window.innerHeight) / (rect.height + window.innerHeight)));
  tl.seek(progress * tl.duration);
}, { passive: true });
```

---

### 7.3 Project Detail Panel

**Current working pattern (no changes needed to core logic, these are additive):**

**A — Panel swap with `createTimeline()` (fade out, swap content, fade in):**
```js
function switchPanel(panelEl, renderFn) {
  const sp = anime.createSpring({ mass: 1.5, stiffness: 100, damping: 18 });
  const tl = anime.createTimeline();
  tl
    // Phase 1: out
    .add(panelEl, { opacity: [1, 0], translateY: [0, -4], duration: 120, ease: 'inQuad' })
    // DOM update happens at phase boundary
    .add({ targets: {}, duration: 1, onBegin: renderFn })
    // Phase 2: in
    .add(panelEl,          { opacity: [0, 1], translateY: [6, 0], duration: 200, ease: 'outQuart' })
    .add('.stat-num',      { innerHTML: [0, (el) => +el.dataset.target],
                             duration: 800, round: 1, ease: 'outExpo' }, '-=160')
    .add('.meta-item',     { translateX: [-10, 0], opacity: [0, 1], duration: 260,
                             delay: anime.stagger(40), ease: 'outCubic' }, '-=700')
    .add('.ptag',          { scale: [0.75, 1], opacity: [0, 1], duration: 200,
                             delay: anime.stagger(25, { from: 'center' }), ease: sp }, '-=400');
}
```
**Note on `innerHTML` animation:** anime.js v4 supports `innerHTML: [fromVal, toVal]` on elements — it interpolates the numeric content. Use with `round: 1` for integer count-up. Replaces manual `setInterval` counter cleanly.

**B — ASCII bar typewriter (anime.js replaces setInterval):**
```js
function typewriterAsciiBar(rowEl, filledCount, totalBlocks = 20) {
  // Render all blocks as spans first, opacity 0
  const chars = Array.from({ length: totalBlocks }, (_, i) =>
    `<span style="opacity:0">${i < filledCount ? '█' : '░'}</span>`
  ).join('');
  rowEl.querySelector('.a-bar').innerHTML = chars;

  anime({
    targets: rowEl.querySelectorAll('.a-bar span'),
    opacity: [0, 1],
    duration: 80,
    delay: anime.stagger(22, { from: 0 }),
    ease: 'linear'
  });
}
```

**C — Tech tag spring bounce from center:**
```js
const sp = anime.createSpring({ mass: 0.8, stiffness: 180, damping: 12 });
anime({
  targets: '.ptag',
  scale: [0, 1],
  opacity: [0, 1],
  duration: 300,
  delay: anime.stagger(30, { from: 'center' }),
  ease: sp
});
```

---

## 8. Additional Terminal-Aesthetic Patterns

### 8.1 Compile-progress bar (█ fill counting up)
Already implemented via `setInterval` in the codebase. The anime.js equivalent using `innerHTML`:
```js
anime({
  targets: compileEl,
  innerHTML: [0, 100],
  round: 1,
  duration: 800,
  ease: 'linear',
  onUpdate: (anim) => {
    const pct = Math.round(anim.animations[0].currentValue);
    const filled = Math.round(pct / 100 * 6);
    compileEl.textContent = `[${'■'.repeat(filled)}${'□'.repeat(6-filled)} ${pct}%]  errors: 0`;
  }
});
```

### 8.2 Data-table row entry (translateY stagger with opacity)
```js
// Rows enter from below like log lines being appended
anime({
  targets: '.table-row',
  translateY: [10, 0],
  opacity: [0, 1],
  duration: 200,
  delay: anime.stagger(30, { from: 'last', direction: 'reverse' }),
  ease: 'outQuart'
});
```

### 8.3 SVG path draw (skill tree lines)
```js
// Set stroke-dasharray/dashoffset in CSS first, then animate offset to 0
// Already partially implemented in about.html via CSS transitions
anime({
  targets: '.tree-line',
  strokeDashoffset: [anime.setDashoffset, 0],  // v4: anime.setDashoffset helper
  duration: 800,
  delay: anime.stagger(60),
  ease: 'outCubic'
});
```
**Verify:** `anime.setDashoffset` exists in v4 source (confirmed as a utility function in anime.js that reads the element's `getTotalLength()` and sets `stroke-dasharray` and `stroke-dashoffset` equal to it).

### 8.4 Cursor blink / status pulse (looping)
```js
// Single element pulse loop — for availability indicator
anime({
  targets: '.status-dot',
  opacity: [1, 0.2],
  scale: [1, 1.4],
  duration: 900,
  ease: 'inOutSine',
  loop: true,       // v4: loop: true for infinite, loop: 3 for count
  direction: 'alternate'
});
```

### 8.5 HUD number rollover (status bar digits)
```js
// Cycle through terminal "uptime" style numbers
anime({
  targets: '.uptime-val',
  innerHTML: (el) => [+el.dataset.from, +el.dataset.to],
  round: 1,
  duration: 1200,
  ease: 'outExpo'
});
```

---

## 9. Quick Reference — API Checklist

```js
// ── Core ──
anime({ targets, ...props, ease, duration, delay, loop, direction,
        autoplay, onBegin, onUpdate, onComplete, onLoop });

// ── Factory functions ──
anime.createSpring({ mass, stiffness, damping }) → easeFunction
anime.createTimeline({ ...defaults })            → timeline
  .add(targets, props, timeOffset?)

// ── Helpers ──
anime.stagger(ms, { start, from, direction, easing, grid, axis })
anime.setDashoffset                              // SVG helper
anime.random(min, max)                           // random number

// ── Control (on returned animation object) ──
anim.seek(ms)                                    // scrub to position
anim.play()
anim.pause()
anim.restart()

// ── Loop / direction values ──
loop: true | false | number
direction: 'normal' | 'reverse' | 'alternate'

// ── Autoplay ──
autoplay: false    // create paused; call .play() or .seek() manually

// ── NO built-in scroll API ──
// Use IntersectionObserver to trigger, or manual scroll listener + anim.seek()
```

---

## 10. What to Avoid for Terminal Aesthetic

| Pattern | Reason to avoid |
|---------|----------------|
| `'outBounce'` | Looks playful, not technical |
| Long elastic (period > .8) | Wobbles too long for data UI |
| `scale: [0, 1]` on large panels | Prefer `translateY + opacity` |
| `loop: true` on content elements | Reserve loops for status indicators only |
| Multiple simultaneous springs | Overlapping springs create visual noise |
| `direction: 'alternate'` on panels | Reads as broken — panels don't exit the way they entered |

---

*Last updated: 2026-05-28. Source: animejs@4.0.2 CDN + codebase analysis of about.html, projects.html, index.html, articles.html, connect.html.*
