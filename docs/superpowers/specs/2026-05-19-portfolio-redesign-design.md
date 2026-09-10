# Portfolio Redesign — Design Spec
**Date:** 2026-05-19  
**Status:** Approved  
**Scope:** All 5 pages — index, about, projects, articles, connect

---

## Context

Roshan's portfolio is a zero-dependency vanilla HTML/CSS/JS site (5 self-contained pages). The current design is clean dark-terminal but visually inert — no background animation, no cursor interaction, no scroll-build effects. This redesign overlays a full aesthetic system on top of the existing content structure without changing the data layer (CONFIG objects stay intact).

The approved style direction combines three aesthetics:
- **ASCII matrix rain** — ambient animated background
- **Reactive dot grid + cursor glow** — interactive background layer
- **Glitch/CRT** — scanlines, chromatic split, particle trail

---

## Design System Changes

### Typography
Replace `Syne` (display headings) with:
- **Oxanium** — `font-weight: 700/800` — all section headings (`h1`, `h2`, section titles, nav brand, stat numbers, project names)
- **Share Tech Mono** — eyebrows, nav links, status labels, chip/badge text, section number labels, footer
- **JetBrains Mono** — unchanged for body text, terminal content, code blocks, skill subtitles

Google Fonts import (single request):
```
family=JetBrains+Mono:ital,wght@0,300;0,400;0,600;0,700;1,300&family=Oxanium:wght@400;600;700;800&family=Share+Tech+Mono
```

### Color tokens
No changes to existing tokens. All 5 pages already share the same `:root` variables.

### Spacing
8px base scale via CSS variables: `--s1` (8px) through `--s8` (128px). Applies to padding, gaps, margins.

---

## Effect Layers (shared across all pages)

All 5 pages receive the same fixed-position layer stack:

| z-index | Element | Description |
|---------|---------|-------------|
| 0 | `#rain-cv` (canvas) | ASCII matrix rain, opacity 0.055 |
| 1 | `#illus-cv` (canvas) | Contextual illustration overlay, fades in/out |
| 2 | `#dot-field` (div) | 28×28px radial dot grid |
| 3 | `#cur-glow` (div) | 420px radial gradient halo following cursor |
| 4 | `#scanlines` (div) | CRT scanline repeating gradient |
| 5 | `#vign` (div) | Radial vignette darkening edges |
| 9998 | `#cur-ring` | 30px cursor ring, eased follow |
| 9999 | `#cur` | 6px cyan cursor dot |

**Matrix rain behavior:** Characters drawn at `0.045` fade alpha per frame. Columns directly under cursor brighten to cyan for 3 columns' radius. Rain chars include Latin uppercase, katakana, digits, and box-drawing characters.

**Cursor behavior:**
- Dot follows mouse at 1:1, ring eases at 14% per frame
- Particle trail spawned at 32% chance per `mousemove`, 4 colors (cyan/green/purple/pink), 700ms fade
- Ring expands `30px → 46px` on hover of interactive elements
- Cursor glow expands `0 → 500px` on hover of cards/panels

**Contextual illustration layer:** A second canvas (`#illus-cv`) fades in when cursor enters a ±80px proximity zone around a registered component. Each zone has a matching ASCII art block that types in line-by-line (1.6 units/frame) in the corner furthest from the cursor. Fades out when cursor leaves all zones. Label tooltip follows cursor offset `+16px / -28px`.

---

## Page-by-Page Design

### index.html

**Hero section** — CSS Grid `1fr 480px`, 3 rows:
- Row 1 left: ASCII name stage + eyebrow + Oxanium headline + desc + chips + CTA buttons
- Row 1 right: Terminal window (existing content) + stack badges row below
- Row 2 left: Stats row (7+ yrs / 40+ systems / 12+ clients / 3× cost) with Oxanium numerals
- Row 2 right: (continues aside column)

**ASCII name stage** (height: 110px, `overflow: hidden`):
- 4 frames cycling every 8s with chromatic split glitch transition (60ms split-r → 60ms split-l → swap):
  - Frame 0: Block-letter `ROSHAN` ASCII art (cyan)
  - Frame 1: Server rack status panel (green) — `roshan-prod-01` with CPU/RAM/NET stats
  - Frame 2: House roofline ASCII built from name letters (orange)
  - Frame 3: Neural network topology with `[ROSHAN]` as output node (purple)
- Micro-glitch fires every 3.2s on frame 0 (no frame swap)
- ~22 orbital characters (`<>{}[]|/\*@#$%^&` + box-drawing) float around stage at varying speeds/sizes

**Skills section** — 2-column layout: skill list (left) + architecture panel (right):
- Skill cards: "compile code" overlay fades out 0.25s after `.visible` is added, real content fades in at 0.35s
- Architecture panel: Full production stack diagram with color-coded tiers (client → gateway → agent loop → retrieval+router → persistence)

**Illustration zones registered on index.html:**
- Hero main → terminal `whoami`/`curl` session
- Terminal window → server uptime/load/disk stats  
- Skills section → `npm install @roshan/brain` package list
- Architecture panel → compact topology
- Projects section → `git log --graph` of projects
- Stats row → performance metrics bar chart

---

### about.html

**Existing content:** experience timeline, full skills breakdown, education.

**New additions:**
- Same effect layers (rain, cursor, glow, scanlines, vignette)
- Section headings → Oxanium
- Timeline items get compile-reveal: dashed border outline animates in, then content fades
- Skills section already has bars — add compile overlay on each category group
- **Illustration zones:**
  - Timeline → `git log` style commit graph showing career progression
  - Skills → architecture overview (same as index)
  - Education → graduation ASCII art cap `(╥_╥)` / diploma

---

### projects.html

**Existing content:** featured project + project grid.

**New additions:**
- Same effect layers
- Project cards: compile-reveal (code overlay → rendered card)
- Featured project gets a full-width ASCII diagram of the system architecture specific to that project
- **Illustration zone:** hovering any project card → mini ASCII diagram of that project's stack (agent loop, VDB nodes, etc.)
- Tech badges styled with `Share Tech Mono`

---

### articles.html

**Existing content:** article list with tag filtering.

**New additions:**
- Same effect layers
- Article list items: line-by-line type-in reveal on scroll (each article "prints" like terminal output)
- Tag filter buttons → `Share Tech Mono`, styled like terminal flags (`--tag=llmops`)
- **Illustration zones:**
  - Article list → `cat articles.md` terminal output animation
  - Tag filter area → `grep --color=auto` command with matching results

---

### connect.html

**Existing content:** connection nodes with SVG lines.

**New additions:**
- Same effect layers
- SVG connection lines already animate with `stroke-dashoffset` — keep but restyle: lines thicken from 1px → 2px, glow filter intensifies
- Connection node cards: compile-reveal
- **Illustration zone:** → `ssh roshan@dev` handshake ASCII animation, ping RTT display

---

## Scroll Reveal Pattern

All animatable elements use `data-a` attribute + `IntersectionObserver` at `threshold: 0.1`.  
On `.visible`: `opacity 0 → 1`, `translateY(24px) → 0`, staggered via inline `transition-delay`.  
Compile overlay: absolute-positioned code text fades out 0.2s after `.visible`, real content fades in 0.35s after.

---

## Implementation Notes

- All CSS/JS remains inline per-page (no external files per CLAUDE.md constraint)
- Effect layers extracted as a shared JS snippet copy-pasted into each page — ~80 lines
- Illustration zones are page-specific (defined as a `ZONES` array in each page's `<script>`)
- ASCII rain canvas must resize on `window.resize` 
- `cursor: none` on `body` in all pages
- Existing `CONFIG` objects, `IntersectionObserver` observers, and SVG animations are preserved — new observers added alongside
- `.gitignore` should include `.superpowers/`

---

## Verification

1. Open each HTML file directly in browser (no server needed)
2. Confirm matrix rain visible but not competing with text (opacity ~0.055)
3. Move cursor to each major component — contextual illustration should appear in opposite corner
4. Scroll through page — cards/skills build themselves on entry
5. Check ASCII name cycles through all 4 frames every 8s with glitch
6. Confirm fonts: headings are Oxanium (narrow, angular), labels are Share Tech Mono
7. Verify cursor ring/dot/trail working
8. Check on mobile: effect layers should be disabled or heavily reduced below 768px (canvas opacity 0, cursor native)
