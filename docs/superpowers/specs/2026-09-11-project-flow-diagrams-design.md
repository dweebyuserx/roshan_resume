# Project Flow Diagrams — Design

**Date:** 2026-09-11
**Status:** Approved design, pending implementation plan
**Scope:** `projects.html` only

## Problem

The projects page describes systems with real moving parts — a multi-agent
orchestration platform, four generations of RAG, an agent loop that converts and
tests code — but presents all of them as the same thing: a paragraph, a row of
stat counters, and a list of tech pills. Nothing shows *how* any of it fits
together. A technical reader evaluating architecture depth (the second audience
in `PORTFOLIO_ARCH.md`) gets no more signal than a recruiter skimming for job
titles.

This adds an animated architecture diagram to the projects that have a topology
worth seeing.

## Decisions

Settled during brainstorming, 2026-09-10:

| Question | Decision |
|---|---|
| Placement | A third `[flow]` tab on the existing featured panel |
| Coverage | 4 flagship projects; the tab is absent for the other 8 |
| Behaviour | Continuous packet flow, with detail on hover/tap/focus |
| Visual | Inline SVG, monospace labels, existing colour tokens |

**Placement rationale.** Clicking any project card already swaps the featured
panel and resets its tabs (`animateFeatPanel`, `projects.html`). Every project
therefore already has a detail surface with a working tab mechanism. A third tab
reuses all of it — no new page, no new navigation, no modal focus-trap.

**Coverage rationale.** The four chosen projects have four genuinely different
shapes (fan-out, converging-parallel, cycle, linear). Several of the remaining
eight collapse to the same three-box line; rendering them would dilute the strong
diagrams and invite the reaction that they all look alike.

## Sourcing policy — derive, don't invent

Every node, label, and figure in the four graphs below traces to text already in
the repository: the `desc`, `tech`, `stats`, and `variants` fields in
`projects.html`, cross-checked against `ROSHAN_ABRAHAM.md`.

No new quantitative claims are introduced. Where a number appears (9 agents,
4 builds, 100+ GB, 2 integrations) it is a figure already published on the site.
Where the source text is silent — exact agent names, latency per hop, index
sizes — the diagram stays silent too.

This matters because these are credentials. A diagram that looks authoritative
but misstates a system is worse than no diagram, and the reader most likely to
study it is the one most likely to ask about it in an interview.

**These graphs are a faithful reading of the existing copy, not a verified
architecture record. They should be corrected against reality before shipping.**

## Architecture

### 1. Data model

An optional `flow` key on a project's CONFIG entry. No separate data file, no new
structure to keep in sync:

```js
flow: {
  nodes: [
    { id:'q',  label:'query',   col:0, row:1, kind:'io' },
    { id:'rt', label:'router',  col:1, row:1, kind:'router',
      detail:'ADK multi-agent router — picks retrieval strategy per query' },
  ],
  edges: [
    { from:'q',  to:'rt' },
    { from:'ev', to:'rt', kind:'feedback' },
  ]
}
```

Nodes declare a coarse `col`/`row` grid slot, never pixel coordinates. The
renderer resolves the grid to geometry, which is what makes the responsive
transpose in §5 possible without a second hand-authored layout.

`kind` drives colour and shape, mapping to tokens already in `:root`:

| kind | token | role |
|---|---|---|
| `io` | `--green` | entry and exit points |
| `router` | `--cyan` | dispatch and routing |
| `agent` | `--cyan` | LLM agents |
| `process` | `--text` | transforms |
| `store` | `--purple` | indexes, caches, state |
| `tool` | `--orange` | external tools and integrations |
| `eval` | `--yellow` | evaluation and gates |

Edge `kind: 'feedback'` renders dashed and curved, travelling against the main
flow direction — the visual cue that a loop exists.

### 2. Renderer

One function, `renderFlow(flow, mountEl)`, serving all four diagrams. Adding a
fifth diagram later is a data change, not a code change.

It emits an `<svg viewBox>` containing a `<g>` per node (rect + mono `<text>`)
and a `<path>` per edge. Grid slot → geometry is a fixed cell size times
`col`/`row`, so the viewBox dimensions fall out of the largest slot used.

### 3. Motion — CSS only

Packets are circles riding their edge with `offset-path: path(...)` and an
`offset-distance: 0% → 100%` keyframe, staggered by `animation-delay` so the
flow reads as a sequence rather than a pulse.

No `requestAnimationFrame`, no per-frame JS, and no anime.js dependency —
`CLAUDE.md` already warns that the CDN can fail, and this degrades to a static
diagram rather than a blank box if the stylesheet is all that loads. While the
tab is hidden the container is `display:none`, so nothing animates off-screen.

### 4. Detail on demand

Hover, tap, or keyboard-focus on a node renders its `detail` string into a single
shared slot beneath the diagram.

A shared slot rather than floating tooltips: no positioning maths, no
viewport-edge collision handling, and identical behaviour on touch, where hover
does not exist.

### 5. Responsive

Below ~600px the renderer transposes the grid — `col`/`row` swap — so a
three-wide fan-out becomes a vertical run instead of shrinking to unreadable.
This is the reason nodes declare grid slots rather than coordinates.

### 6. Accessibility

- Nodes are focusable, with `aria-label` combining label and detail
- The detail slot is `aria-live="polite"`
- The SVG carries `<title>` and `<desc>`
- Under `prefers-reduced-motion: reduce` packets are hidden; the diagram stays
  fully legible and the inspect interaction is unaffected

### 7. Tab integration

`setupFeatTabs()` generalises from its current two-way info/diff toggle to
show-by-name across three views. The `[flow]` button renders only when `p.flow`
exists, so the eight projects without a graph show the current two tabs and
nothing appears broken or empty.

Two places currently hard-code the two-view assumption and both must learn the
third: `setupFeatTabs()` itself, and the tab-reset inside `animateFeatPanel()`
that fires on card select (it sets `info` active and hides `.feat-diff-view`
directly). Leaving the second unchanged would strand a visible flow diagram
behind an `[info]`-active tab strip when switching projects.

## The four graphs

### Agentic PR Platform — fan-out from a router

Source: `desc` (multi-agent orchestration, specialized prompt routers,
chain-of-thought, MCP tool integrations, Firebase-backed state, Gemma/Claude on
GCP, ADK orchestration), `tech`, `stats` (9 agents).

```
  PR request ──▶ FastAPI ──▶ ADK orchestrator ──▶ prompt routers
                                   ▲                    │
                                   │            ┌───────┼───────┐
                              Firebase          ▼       ▼       ▼
                               state         agent   agent   agent    (×9)
                                   ▲            │       │       │
                                   │            └───────┼───────┘
                                   │                    ▼
                                   └──── chain-of-thought loop
                                                        │
                                          MCP tools ◀───┤
                                       Gemma / Claude ◀─┤
                                                        ▼
                                                    response
```

Teaches: one orchestrator dispatching to a pool, with shared state read and
written across the whole run.

### RAG Systems — parallel retrieval converging, with an eval loop

Source: `variants` v1–v4, `tech`, `stats`, and the `ROSHAN_ABRAHAM.md` line
covering routers, embedded knowledge indexing, prompt caching, chunking strategy,
eval testing, and hybrid search with re-ranking.

```
   documents ──▶ chunking ──▶ embedding index ──▶ vector store
                                                   (Weaviate /
                                                    Milvus /
                                                    Pinecone)
                                                        │
   query ──▶ multi-agent router ──┬─────────────────────┘
                   ▲              ├──▶ hybrid / sparse search
                   │              └──▶ Redis prompt cache
                   │                         │
                   │                         ▼
                   │                    re-ranking
                   │                         │
                   │                         ▼
                   │                   LLM generation
                   │                         │
                   │                         ▼
                   └──── RAGAS eval ◀─── response
```

Teaches: three retrieval paths running in parallel and converging on a re-ranker,
plus a quality loop feeding back to the router. The richest of the four, and the
one that justifies the "4 builds" stat.

### Claude Agent Code Conversion — a cycle with a pass/fail branch

Source: `desc` (automated code conversion, dynamic test generation, structured
reporting, prompt caching, context pruning, tool-use optimisation), `tech`.

```
   source repo ──▶ context pruning ──▶ converter agent ──▶ converted code
                                        ▲    ▲   ▲                │
                          prompt cache ─┘    │   └─ MCP tools     ▼
                                             │              test generator
                                             │                    │
                                             │                    ▼
                                             │            dynamic test harness
                                             │                    │
                                             │                    ▼
                                             └──── fail ──── results ──── pass ──▶ report
```

Teaches: the retry cycle. This is the most genuinely *moving* of the four — a
packet that loops back on failure and only exits on pass, which is exactly the
behaviour a static diagram cannot convey.

### Medical AI Infrastructure — linear pipeline into a fan-out

Source: `desc` (OCR engine, NER parser, FHIR translation, LLM knowledge base,
EPIC and Cerner integration, ABHA-compliant OCR→NER→FHIR), `tech`, `stats`
(2 integrations).

```
   medical docs ──▶ Document AI ──▶ NER parser ──▶ FHIR translation
                        OCR                              │
                                                         ├──▶ LLM knowledge base
                                                         ▼
                                                  ABHA compliance
                                                         │
                                                   ┌─────┴─────┐
                                                   ▼           ▼
                                                 EPIC       Cerner
```

Teaches: a strict ordered pipeline behind a compliance gate, terminating in two
external systems. Deliberately the simplest of the four — its value is the
contrast with the other three.

## Non-goals

- No diagrams for the other eight projects
- No new page, modal, or route
- No shared `.js` or `.css` file — everything inline in `projects.html`, per
  the self-contained-page convention in `CLAUDE.md`
- No stage controls, scrubbing, or playback UI
- No change to the existing `[info]` or `[diff]` tabs beyond generalising the
  toggle

## Risks

| Risk | Mitigation |
|---|---|
| Graphs misrepresent the real systems | Derived only from published copy; flagged for correction before ship |
| `projects.html` growth (~63KB today) | Budget ~15KB; one renderer, four data blocks, no duplication |
| `offset-path` support | Well-supported in current browsers; absent support degrades to a static diagram, which is still legible |
| Diagram competes with the rain canvas behind it | Diagram sits inside `main` (`position: relative`), painting above the canvases and below the vignette — same as all other content |
| Four diagrams read as samey | Chosen specifically for four distinct topologies; verified at review |

## Success criteria

1. `[flow]` appears for exactly the four projects and is absent for the other eight
2. Switching projects rebuilds the diagram and resets to `[info]`
3. Packets animate continuously while the tab is open, and stop when it is not
4. Every node reveals its detail on hover, tap, and keyboard focus
5. Legible and usable at 390px width
6. Static and fully legible under `prefers-reduced-motion`
7. No regression to the effect-layer parity established on 2026-09-10
8. No new console errors
