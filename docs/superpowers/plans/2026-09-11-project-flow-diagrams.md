# Project Flow Diagrams Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `[flow]` tab to the `projects.html` featured panel that renders an animated SVG architecture diagram for four flagship projects.

**Architecture:** One data-driven renderer (`renderFlow`) turns a declarative node/edge graph into inline SVG. Nodes declare coarse `col`/`row` grid slots, not pixels, so the same data reflows to a vertical stack on phones. Packets ride their edge with CSS `offset-path` — no per-frame JS and no anime.js dependency. All code is inline in `projects.html`.

**Tech Stack:** Vanilla JS, inline SVG, CSS Motion Path (`offset-path` / `offset-distance`). No build step, no npm, no test framework.

**Spec:** `docs/superpowers/specs/2026-09-11-project-flow-diagrams-design.md`

## Global Constraints

- **Single file.** All changes land in `projects.html`. No new `.js` or `.css` files — the self-contained-page convention in `CLAUDE.md`.
- **No anime.js for motion.** Packet animation is CSS-only. The diagram must stay legible if the CDN fails.
- **Colours come from `:root` tokens** (`--cyan --green --orange --purple --yellow --text --muted --border --bg2 --bg3`). No new hex literals.
- **Four projects only:** Agentic PR Platform (featured), RAG Systems, Claude Agent Code Conversion & Testing Workflow, Medical AI Infrastructure. The other eight must not render a `[flow]` tab.
- **Derive, don't invent.** Node labels and details come from existing `desc`/`tech`/`stats`/`variants` copy. Introduce no new quantitative claims.
- **`cursor: none`** on interactive elements — the site uses a custom cursor.
- **Do not disturb effect-layer parity** established 2026-09-10 (`#rain-cv`→`#illus-label` block, scanline at 4px period). Do not touch those rules.
- **No new `IntersectionObserver` for fade-up** — `CLAUDE.md` forbids it. Diagrams render on tab open, not on scroll.

## Verification Environment

There is no test runner. Every task verifies in a real browser against the local static server.

Start it once (skip if already listening on 8811):

```bash
cd /mnt/BatLair/Resume
nohup python3 -m http.server 8811 --bind 127.0.0.1 > /tmp/portfolio-server.log 2>&1 &
```

Verify with Playwright MCP: `browser_navigate` to `http://127.0.0.1:8811/projects.html`, then `browser_evaluate` for DOM assertions and `browser_take_screenshot` for visual checks. Screenshots go to `.playwright-mcp/` (gitignored).

---

### Task 1: Tab plumbing for a third view

Generalise the two-way info/diff toggle to show-by-name across three views, add the flow container, and make the `[flow]` button appear only for projects that have a `flow` key. No diagram yet — this task proves the plumbing.

**Files:**
- Modify: `projects.html` — `.feat-diff-view` CSS block (~line 592), `#featuredProject` template in `render()` (~line 982), `setupFeatTabs()` (~line 1258), both tab-reset sites in `animateFeatPanel()` (~line 1170 and ~line 1201)

**Interfaces:**
- Produces: `showFeatView(name)` — switches visible view, `name` is `'info' | 'diff' | 'flow'`; also syncs `.active` on the tab buttons
- Produces: `syncFlowTab(p)` — adds or removes the `[flow]` button for project object `p`, based on `p.flow`
- Produces: `.feat-flow-view` container element inside `#featuredProject`

- [ ] **Step 1: Add a temporary `flow` stub to one project so the tab has something to key off**

In `projects.html`, inside the `featuredProject` object (~line 795), after the `ascii:` line, add:

```js
    flow: { title: 'Agentic PR Platform', caption: 'stub — replaced in Task 6', nodes: [], edges: [] },
```

- [ ] **Step 2: Add the flow view container and CSS**

Find the `.feat-diff-view` rule (~line 592):

```css
  .feat-diff-view { font-family:var(--font-mono); font-size:11px; line-height:1.8; display:none; }
```

Add immediately after it:

```css
  .feat-flow-view { display:none; }
```

Then in the `#featuredProject` template inside `render()`, find the `.feat-diff-view` div (~line 1006) and add a sibling container immediately after that div closes:

```html
      <div class="feat-flow-view"></div>
```

- [ ] **Step 3: Replace the tab toggle with a named-view switcher**

Replace the whole of `setupFeatTabs()` (~line 1258):

```js
function showFeatView(show) {
  const infoEl = document.getElementById('featuredSwap');
  const diffEl = document.querySelector('.feat-diff-view');
  const flowEl = document.querySelector('.feat-flow-view');
  if (infoEl) infoEl.style.display = show === 'info' ? '' : 'none';
  if (diffEl) diffEl.style.display = show === 'diff' ? 'block' : 'none';
  if (flowEl) flowEl.style.display = show === 'flow' ? 'block' : 'none';
  document.querySelectorAll('.feat-tab').forEach(t => t.classList.toggle('active', t.dataset.tab === show));
}

function syncFlowTab(p) {
  const tabs = document.querySelector('.feat-tabs');
  if (!tabs) return;
  let btn = tabs.querySelector('[data-tab="flow"]');
  if (p && p.flow) {
    if (!btn) {
      btn = document.createElement('button');
      btn.className = 'feat-tab';
      btn.dataset.tab = 'flow';
      btn.textContent = '[flow]';
      tabs.appendChild(btn);
    }
  } else if (btn) {
    btn.remove();
  }
}

function setupFeatTabs() {
  document.querySelector('.feat-tabs')?.addEventListener('click', e => {
    const tab = e.target.closest('.feat-tab');
    if (!tab) return;
    showFeatView(tab.dataset.tab);
  });
}
```

- [ ] **Step 4: Point both reset sites at the new switcher**

`animateFeatPanel()` hard-codes the two-view assumption in two places. In the anime.js branch (~line 1170), replace:

```js
        document.querySelectorAll('.feat-tab').forEach(t => t.classList.toggle('active', t.dataset.tab === 'info'));
        const diffEl = document.querySelector('.feat-diff-view');
        if (diffEl) diffEl.style.display = 'none';
```

with:

```js
        syncFlowTab(p);
        showFeatView('info');
```

In the non-anime fallback branch (~line 1201), replace the identical three lines with the same two lines.

- [ ] **Step 5: Call `syncFlowTab` for the initially-rendered featured project**

In `render()`, immediately after the `#featuredProject` innerHTML assignment completes, add:

```js
  syncFlowTab(CONFIG.featuredProject);
```

- [ ] **Step 6: Verify the tab appears only where expected**

Navigate to `http://127.0.0.1:8811/projects.html`, then evaluate:

```js
() => {
  const tabNames = [...document.querySelectorAll('.feat-tab')].map(t => t.dataset.tab);
  return { tabs: tabNames, hasFlow: tabNames.includes('flow') };
}
```

Expected: `{ tabs: ['info','diff','flow'], hasFlow: true }` — the featured project has the stub.

Then click a project card without a flow key (e.g. the MLOps Engine card) and re-evaluate:

```js
() => {
  document.querySelectorAll('.project-card')[4].click();
  return new Promise(r => setTimeout(() => {
    r([...document.querySelectorAll('.feat-tab')].map(t => t.dataset.tab));
  }, 600));
}
```

Expected: `['info','diff']` — no flow tab.

- [ ] **Step 7: Verify switching views works**

```js
() => {
  document.querySelector('[data-tab="diff"]').click();
  const diff = document.querySelector('.feat-diff-view');
  const info = document.getElementById('featuredSwap');
  return { diffShown: diff.style.display === 'block', infoHidden: info.style.display === 'none' };
}
```

Expected: `{ diffShown: true, infoHidden: true }` — no regression to the existing diff tab.

- [ ] **Step 8: Commit**

```bash
cd /mnt/BatLair/Resume
git add projects.html
git commit -m "feat(projects): generalise featured tabs to three views, add flow container

Replaces the two-way info/diff toggle with showFeatView(name) and adds
syncFlowTab() so the [flow] button renders only for projects declaring a
flow graph. Both tab-reset sites in animateFeatPanel now route through the
same switcher, so a visible flow view cannot be stranded behind an active
[info] tab when switching projects.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01RqVA831FhmV3EjonHKTycX"
```

---

### Task 2: Static SVG renderer

Build `renderFlow` and render the RAG graph as a static diagram — nodes, edges, labels, no motion yet.

**Files:**
- Modify: `projects.html` — CSS after `.feat-flow-view`, new renderer functions near `setupFeatTabs()`, `flow` data on the RAG Systems project (~line 836)

**Interfaces:**
- Consumes: `syncFlowTab(p)` and `.feat-flow-view` from Task 1
- Produces: `flowGeometry(flow, stack)` → `{ pos: {id: {x,y,w,h}}, width, height }`
- Produces: `flowEdgePath(a, b)` → SVG path `d` string, where `a`/`b` are `{x,y,w,h}`
- Produces: `renderFlow(flow, mount, stack)` — renders into `mount`; `stack` boolean transposes the grid
- Produces: `escFlow(s)` → HTML/attribute-escaped string

- [ ] **Step 1: Add the renderer**

Insert above `function setupFeatTabs()`:

```js
// ── FLOW DIAGRAM ──────────────────────────────────────────────────
const FLOW_CELL_W = 148, FLOW_CELL_H = 82, FLOW_NODE_W = 112, FLOW_NODE_H = 34;

function escFlow(s) {
  return String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

function flowGeometry(flow, stack) {
  const pos = {};
  flow.nodes.forEach(n => {
    const col = stack ? n.row : n.col;
    const row = stack ? n.col : n.row;
    pos[n.id] = {
      x: col * FLOW_CELL_W + (FLOW_CELL_W - FLOW_NODE_W) / 2,
      y: row * FLOW_CELL_H + (FLOW_CELL_H - FLOW_NODE_H) / 2,
      w: FLOW_NODE_W, h: FLOW_NODE_H
    };
  });
  let maxX = 0, maxY = 0;
  Object.values(pos).forEach(p => {
    maxX = Math.max(maxX, p.x + p.w);
    maxY = Math.max(maxY, p.y + p.h);
  });
  return { pos, width: maxX + 24, height: maxY + 48 };
}

function flowEdgePath(a, b) {
  if (b.x >= a.x + a.w) {
    const ax = a.x + a.w, ay = a.y + a.h / 2, bx = b.x, by = b.y + b.h / 2;
    const mx = (ax + bx) / 2;
    return `M ${ax} ${ay} C ${mx} ${ay}, ${mx} ${by}, ${bx} ${by}`;
  }
  if (Math.abs(b.x - a.x) < a.w) {
    const down = b.y > a.y;
    const ax = a.x + a.w / 2, ay = down ? a.y + a.h : a.y;
    const bx = b.x + b.w / 2, by = down ? b.y : b.y + b.h;
    const my = (ay + by) / 2;
    return `M ${ax} ${ay} C ${ax} ${my}, ${bx} ${my}, ${bx} ${by}`;
  }
  const ax = a.x + a.w / 2, ay = a.y + a.h;
  const bx = b.x + b.w / 2, by = b.y + b.h;
  const dip = Math.max(ay, by) + 34;
  return `M ${ax} ${ay} C ${ax} ${dip}, ${bx} ${dip}, ${bx} ${by}`;
}

function renderFlow(flow, mount, stack) {
  if (!flow || !flow.nodes || !flow.nodes.length) { mount.innerHTML = ''; return; }
  const { pos, width, height } = flowGeometry(flow, stack);
  const edges = flow.edges
    .filter(e => pos[e.from] && pos[e.to])
    .map((e, i) => ({ i, kind: e.kind, d: flowEdgePath(pos[e.from], pos[e.to]) }));

  const edgeSvg = edges.map(e =>
    `<path class="fedge${e.kind === 'feedback' ? ' fedge-fb' : ''}" d="${e.d}" />`).join('');

  const nodeSvg = flow.nodes.map(n => {
    const p = pos[n.id];
    const aria = n.label + (n.detail ? '. ' + n.detail : '');
    return `<g class="fnode fnode-${escFlow(n.kind)}" tabindex="0" role="button" data-detail="${escFlow(n.detail || '')}" aria-label="${escFlow(aria)}">`
      + `<rect x="${p.x}" y="${p.y}" width="${p.w}" height="${p.h}" rx="3" />`
      + `<text x="${p.x + p.w / 2}" y="${p.y + p.h / 2}" dominant-baseline="middle" text-anchor="middle">${escFlow(n.label)}</text>`
      + `</g>`;
  }).join('');

  mount.innerHTML =
    `<svg class="flow-svg" viewBox="0 0 ${width} ${height}" role="img" aria-labelledby="flowTitle flowDesc">`
    + `<title id="flowTitle">${escFlow(flow.title || 'System flow')}</title>`
    + `<desc id="flowDesc">${escFlow(flow.caption || '')}</desc>`
    + edgeSvg + nodeSvg
    + `</svg>`
    + `<div class="flow-detail" aria-live="polite">${escFlow(flow.caption || '')}</div>`;
}
```

- [ ] **Step 2: Add the diagram CSS**

Replace the `.feat-flow-view { display:none; }` rule from Task 1 with:

```css
  .feat-flow-view { display:none; }
  .flow-svg { width:100%; height:auto; display:block; overflow:visible; }
  .fedge { fill:none; stroke:var(--border); stroke-width:1.2; }
  .fedge-fb { stroke:var(--orange); stroke-dasharray:3 4; opacity:0.5; }
  .fnode { cursor:none; outline:none; }
  .fnode rect { fill:var(--bg3); stroke:var(--border); stroke-width:1; transition:stroke 0.2s ease, fill 0.2s ease; }
  .fnode text { font-family:var(--font-mono); font-size:10px; fill:var(--text); letter-spacing:0.02em; pointer-events:none; }
  .fnode-io rect { stroke:rgba(61,255,160,0.5); }
  .fnode-router rect, .fnode-agent rect { stroke:rgba(77,217,240,0.5); }
  .fnode-store rect { stroke:rgba(167,139,250,0.5); }
  .fnode-tool rect { stroke:rgba(255,159,74,0.5); }
  .fnode-eval rect { stroke:rgba(251,191,36,0.5); }
  .fnode:hover rect, .fnode:focus rect { stroke:var(--cyan); fill:var(--bg2); }
  .fnode:focus-visible rect { stroke-width:1.8; }
  .flow-detail { margin-top:14px; font-family:var(--font-label); font-size:11px; color:var(--muted); letter-spacing:0.04em; min-height:16px; }
```

- [ ] **Step 3: Wire the renderer into `syncFlowTab`**

In `syncFlowTab(p)`, replace the whole function body with:

```js
function syncFlowTab(p) {
  const tabs = document.querySelector('.feat-tabs');
  const flowView = document.querySelector('.feat-flow-view');
  if (!tabs) return;
  let btn = tabs.querySelector('[data-tab="flow"]');
  if (p && p.flow && p.flow.nodes && p.flow.nodes.length) {
    if (!btn) {
      btn = document.createElement('button');
      btn.className = 'feat-tab';
      btn.dataset.tab = 'flow';
      btn.textContent = '[flow]';
      tabs.appendChild(btn);
    }
    currentFlow = p.flow;
    if (flowView) renderFlow(p.flow, flowView, window.innerWidth < 600);
  } else {
    if (btn) btn.remove();
    currentFlow = null;
    if (flowView) flowView.innerHTML = '';
  }
}
```

Add above it:

```js
let currentFlow = null;
```

Note the stub added in Task 1 has an empty `nodes` array, so the tab will now correctly disappear until Step 4 gives it real data.

- [ ] **Step 4: Add the RAG Systems graph**

In the RAG Systems project object (~line 836), after the `ascii:` line, add:

```js
      flow: {
        title: 'RAG Systems',
        caption: 'four builds — parallel retrieval converging on a re-ranker, with an eval loop',
        nodes: [
          { id:'docs',   label:'documents',    col:0, row:0, kind:'io',      detail:'Source corpus — enterprise and Govt document sets' },
          { id:'chunk',  label:'chunking',     col:1, row:0, kind:'process', detail:'Specialised chunking strategy, tuned per corpus (v3)' },
          { id:'index',  label:'embed index',  col:2, row:0, kind:'process', detail:'Embedded knowledge indexing (v2)' },
          { id:'vstore', label:'vector store', col:3, row:0, kind:'store',   detail:'Weaviate, Milvus or Pinecone depending on the build' },
          { id:'query',  label:'query',        col:0, row:2, kind:'io',      detail:'Incoming user or agent query' },
          { id:'router', label:'agent router', col:1, row:2, kind:'router',  detail:'ADK multi-agent router — picks retrieval strategy per query (v2, v4)' },
          { id:'hybrid', label:'hybrid search',col:2, row:2, kind:'process', detail:'Dense plus sparse hybrid retrieval (v1)' },
          { id:'cache',  label:'prompt cache', col:2, row:3, kind:'store',   detail:'Redis prompt caching (v2)' },
          { id:'rerank', label:'re-ranking',   col:3, row:2, kind:'process', detail:'Re-ranking pass over merged candidates (v1)' },
          { id:'llm',    label:'LLM gen',      col:4, row:2, kind:'agent',   detail:'Generation with tool use for Govt document retrieval (v4)' },
          { id:'resp',   label:'response',     col:5, row:2, kind:'io',      detail:'Answer returned to the caller' },
          { id:'eval',   label:'RAGAS eval',   col:4, row:3, kind:'eval',    detail:'RAGAS evaluation — scores feed strategy tuning (v3)' }
        ],
        edges: [
          { from:'docs',   to:'chunk' },
          { from:'chunk',  to:'index' },
          { from:'index',  to:'vstore' },
          { from:'query',  to:'router' },
          { from:'router', to:'vstore' },
          { from:'router', to:'hybrid' },
          { from:'router', to:'cache' },
          { from:'vstore', to:'rerank' },
          { from:'hybrid', to:'rerank' },
          { from:'cache',  to:'rerank' },
          { from:'rerank', to:'llm' },
          { from:'llm',    to:'resp' },
          { from:'resp',   to:'eval',   kind:'feedback' },
          { from:'eval',   to:'router', kind:'feedback' }
        ]
      },
```

- [ ] **Step 5: Verify the graph renders with correct structure**

Navigate to the page, click the RAG Systems card, open `[flow]`, then evaluate:

```js
() => {
  const card = [...document.querySelectorAll('.project-card')]
    .find(c => c.textContent.includes('RAG Systems'));
  card.click();
  return new Promise(r => setTimeout(() => {
    document.querySelector('[data-tab="flow"]').click();
    const svg = document.querySelector('.flow-svg');
    r({
      hasSvg: !!svg,
      nodes: document.querySelectorAll('.fnode').length,
      edges: document.querySelectorAll('.fedge').length,
      feedback: document.querySelectorAll('.fedge-fb').length,
      viewBox: svg && svg.getAttribute('viewBox'),
      noNaN: svg ? !svg.innerHTML.includes('NaN') : false
    });
  }, 700));
}
```

Expected: `hasSvg: true`, `nodes: 12`, `edges: 14`, `feedback: 2`, `viewBox: "0 0 894 352"`, `noNaN: true`.

The `noNaN` check matters — a missing node id in an edge would silently produce `NaN` in a path `d` and render nothing.

- [ ] **Step 6: Screenshot and eyeball the layout**

`browser_take_screenshot` to `.playwright-mcp/flow-rag-static.png`, then read it. Confirm: no overlapping boxes, labels fit inside their rects, edges land on box edges rather than crossing through boxes.

- [ ] **Step 7: Commit**

```bash
cd /mnt/BatLair/Resume
git add projects.html
git commit -m "feat(projects): add SVG flow diagram renderer and RAG graph

renderFlow turns a declarative node/edge graph into inline SVG. Nodes
declare coarse col/row grid slots rather than pixel coordinates, which is
what allows the responsive transpose in a later task. Edge routing picks
between rightward, vertical and dip-under bezier paths based on relative
node position.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01RqVA831FhmV3EjonHKTycX"
```

---

### Task 3: Packet motion

Add travelling packets via CSS `offset-path`, staggered per edge, with reduced-motion handling.

**Files:**
- Modify: `projects.html` — `renderFlow` packet emission, diagram CSS

**Interfaces:**
- Consumes: `renderFlow`, `flowEdgePath` from Task 2
- Produces: `.fpacket` circles, one per edge, carrying inline `offset-path` and `animation-delay`

- [ ] **Step 1: Emit a packet per edge**

In `renderFlow`, immediately after the `edgeSvg` assignment, add:

```js
  const packetSvg = edges.map(e =>
    `<circle class="fpacket${e.kind === 'feedback' ? ' fpacket-fb' : ''}" r="3.2" cx="0" cy="0" `
    + `style="offset-path:path('${e.d}');animation-delay:${(e.i * 0.32).toFixed(2)}s" />`).join('');
```

Then change the SVG assembly line from:

```js
    + edgeSvg + nodeSvg
```

to:

```js
    + edgeSvg + packetSvg + nodeSvg
```

Packets are emitted between edges and nodes so they ride above the lines but never occlude a node label.

- [ ] **Step 2: Add the motion CSS**

Append to the diagram CSS block:

```css
  .fpacket { fill:var(--cyan); transform-box:view-box; offset-rotate:0deg; animation:fpacket-run 2.8s linear infinite; }
  .fpacket-fb { fill:var(--orange); }
  @keyframes fpacket-run { from { offset-distance:0%; } to { offset-distance:100%; } }
  @media (prefers-reduced-motion: reduce) { .fpacket { display:none; } }
```

`transform-box: view-box` is required — without it the packet's offset origin resolves against its own zero-size bounding box and the circles pile up at the SVG origin.

- [ ] **Step 3: Verify packets exist and are positioned along their paths**

```js
() => {
  const ps = [...document.querySelectorAll('.fpacket')];
  const boxes = ps.slice(0, 4).map(p => {
    const b = p.getBoundingClientRect();
    return { x: Math.round(b.x), y: Math.round(b.y) };
  });
  const distinct = new Set(boxes.map(b => b.x + ',' + b.y)).size;
  return { count: ps.length, boxes, distinct };
}
```

Expected: `count: 14`, and `distinct > 1`. If all packets report the same coordinates, `transform-box` is not applying — recheck Step 2.

- [ ] **Step 4: Verify packets actually move**

Presence is not motion. Sample one packet twice, 900ms apart:

```js
() => {
  const p = document.querySelector('.fpacket');
  const a = p.getBoundingClientRect();
  return new Promise(r => setTimeout(() => {
    const b = p.getBoundingClientRect();
    r({ moved: Math.abs(a.x - b.x) > 1 || Math.abs(a.y - b.y) > 1,
        from: [Math.round(a.x), Math.round(a.y)],
        to: [Math.round(b.x), Math.round(b.y)] });
  }, 900));
}
```

Expected: `moved: true`. A `false` here means `offset-path` is not animating and the task is not done, regardless of how the screenshot looks.

- [ ] **Step 5: Verify reduced-motion hides packets**

Emulate the preference, reload, open the flow tab, then:

```js
() => ({
  packetsVisible: [...document.querySelectorAll('.fpacket')]
    .filter(p => getComputedStyle(p).display !== 'none').length,
  nodesStillVisible: document.querySelectorAll('.fnode').length
})
```

Expected: `packetsVisible: 0`, `nodesStillVisible: 12` — motion gone, diagram intact.

- [ ] **Step 6: Commit**

```bash
cd /mnt/BatLair/Resume
git add projects.html
git commit -m "feat(projects): animate flow packets along edges with CSS offset-path

One packet per edge, staggered by animation-delay so the flow reads as a
sequence rather than a pulse. Pure CSS means no requestAnimationFrame and
no anime.js dependency, so a CDN failure degrades to a static but legible
diagram. Packets are hidden under prefers-reduced-motion.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01RqVA831FhmV3EjonHKTycX"
```

---

### Task 4: Detail on demand

Hover, tap, or keyboard-focus a node to render its detail into the shared slot.

**Files:**
- Modify: `projects.html` — new `bindFlowDetail()`, called from `renderFlow`

**Interfaces:**
- Consumes: `.fnode[data-detail]` and `.flow-detail` from Task 2
- Produces: `bindFlowDetail(mount, caption)` — attaches pointer/focus handlers to every node in `mount`

- [ ] **Step 1: Add the binding function**

Insert directly below `renderFlow`:

```js
function bindFlowDetail(mount, caption) {
  const slot = mount.querySelector('.flow-detail');
  if (!slot) return;
  const show = el => { slot.textContent = el.dataset.detail || caption || ''; };
  const reset = () => { slot.textContent = caption || ''; };
  mount.querySelectorAll('.fnode').forEach(node => {
    node.addEventListener('mouseenter', () => show(node));
    node.addEventListener('focus', () => show(node));
    node.addEventListener('mouseleave', reset);
    node.addEventListener('blur', reset);
    node.addEventListener('click', e => { e.preventDefault(); show(node); });
  });
}
```

The `click` handler is what makes this work on touch, where `mouseenter` never fires.

- [ ] **Step 2: Call it at the end of `renderFlow`**

Append as the last statement of `renderFlow`, after the `mount.innerHTML = ...` assignment:

```js
  bindFlowDetail(mount, flow.caption || '');
```

- [ ] **Step 3: Verify hover updates the slot**

```js
() => {
  const node = document.querySelector('.fnode[data-detail]');
  const slot = document.querySelector('.flow-detail');
  const before = slot.textContent;
  node.dispatchEvent(new MouseEvent('mouseenter', { bubbles: true }));
  const during = slot.textContent;
  node.dispatchEvent(new MouseEvent('mouseleave', { bubbles: true }));
  return { before, during, after: slot.textContent,
           changed: during !== before, restored: slot.textContent === before };
}
```

Expected: `changed: true`, `restored: true`.

- [ ] **Step 4: Verify keyboard focus works**

```js
() => {
  const nodes = [...document.querySelectorAll('.fnode')];
  const slot = document.querySelector('.flow-detail');
  nodes[3].focus();
  return {
    focusable: document.activeElement === nodes[3],
    detailShown: slot.textContent.length > 0,
    matchesNode: slot.textContent === nodes[3].dataset.detail
  };
}
```

Expected: all three `true`.

- [ ] **Step 5: Verify accessibility attributes**

```js
() => {
  const n = document.querySelector('.fnode');
  const svg = document.querySelector('.flow-svg');
  return {
    role: n.getAttribute('role'),
    hasAriaLabel: !!n.getAttribute('aria-label'),
    tabindex: n.getAttribute('tabindex'),
    liveRegion: document.querySelector('.flow-detail').getAttribute('aria-live'),
    svgTitle: !!svg.querySelector('title')
  };
}
```

Expected: `role: 'button'`, `hasAriaLabel: true`, `tabindex: '0'`, `liveRegion: 'polite'`, `svgTitle: true`.

- [ ] **Step 6: Commit**

```bash
cd /mnt/BatLair/Resume
git add projects.html
git commit -m "feat(projects): reveal node detail on hover, tap and keyboard focus

Detail renders into one shared slot below the diagram rather than floating
tooltips: no positioning maths, no viewport-edge collisions, and identical
behaviour on touch where hover does not exist. The slot is aria-live so
screen readers announce the change.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01RqVA831FhmV3EjonHKTycX"
```

---

### Task 5: Responsive transpose

Below 600px, transpose the grid so wide fan-outs become vertical runs instead of shrinking to unreadable.

**Files:**
- Modify: `projects.html` — resize listener near the other window listeners

**Interfaces:**
- Consumes: `currentFlow` and `renderFlow(flow, mount, stack)` from Task 2

- [ ] **Step 1: Re-render on resize across the breakpoint**

Add near the existing `window.addEventListener('scroll', ...)` registrations:

```js
let flowStacked = window.innerWidth < 600;
window.addEventListener('resize', () => {
  const wantStacked = window.innerWidth < 600;
  if (wantStacked === flowStacked) return;
  flowStacked = wantStacked;
  const flowView = document.querySelector('.feat-flow-view');
  if (currentFlow && flowView) renderFlow(currentFlow, flowView, flowStacked);
});
```

Guarding on a breakpoint crossing rather than every resize event keeps this from re-rendering the SVG on every pixel of a window drag.

- [ ] **Step 2: Verify the desktop layout is wider than tall**

At 1440x900, with the RAG flow open:

```js
() => {
  const vb = document.querySelector('.flow-svg').getAttribute('viewBox').split(' ');
  return { w: +vb[2], h: +vb[3], landscape: +vb[2] > +vb[3] };
}
```

Expected: `landscape: true`.

- [ ] **Step 3: Verify the phone layout transposes**

Resize to 390x844, reload, open the RAG flow, then run the same evaluation.

Expected: `landscape: false` — the graph is now taller than wide.

- [ ] **Step 4: Verify no horizontal overflow at phone width**

```js
() => ({
  bodyScrollW: document.body.scrollWidth,
  innerW: window.innerWidth,
  overflows: document.body.scrollWidth > window.innerWidth + 1
})
```

Expected: `overflows: false`. `CLAUDE.md` requires the page body never scroll horizontally.

- [ ] **Step 5: Screenshot the stacked layout**

`browser_take_screenshot` to `.playwright-mcp/flow-rag-mobile.png` and read it. Confirm labels are legible and boxes do not overlap.

- [ ] **Step 6: Commit**

```bash
cd /mnt/BatLair/Resume
git add projects.html
git commit -m "feat(projects): transpose flow grid to a vertical stack below 600px

A six-column fan-out scaled to phone width would be unreadable, so the
renderer swaps col and row instead of shrinking. Re-render is guarded on a
breakpoint crossing rather than firing on every resize event.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01RqVA831FhmV3EjonHKTycX"
```

---

### Task 6: The remaining three graphs

Replace the Task 1 stub with the real Agentic PR Platform graph, and add graphs for Code Conversion and Medical AI.

**Files:**
- Modify: `projects.html` — `featuredProject` (~line 795), Claude Agent Code Conversion (~line 903), Medical AI Infrastructure (~line 810)

**Interfaces:**
- Consumes: `renderFlow`, `syncFlowTab` from Tasks 1–2

- [ ] **Step 1: Replace the featured-project stub with the real graph**

In `featuredProject`, replace the entire `flow: { ... }` stub line from Task 1 with:

```js
    flow: {
      title: 'Agentic PR Platform',
      caption: 'one orchestrator dispatching to a pool of 9, over shared state',
      nodes: [
        { id:'req',   label:'PR request',   col:0, row:1, kind:'io',      detail:'State Government PR workflow request' },
        { id:'api',   label:'FastAPI',      col:1, row:1, kind:'process', detail:'Service gateway' },
        { id:'orch',  label:'ADK orch',     col:2, row:1, kind:'router',  detail:'ADK orchestration layer' },
        { id:'route', label:'prompt router',col:3, row:1, kind:'router',  detail:'Specialised prompt routers per workflow' },
        { id:'a1',    label:'agent',        col:4, row:0, kind:'agent',   detail:'One of 9 specialised agents' },
        { id:'a2',    label:'agent',        col:4, row:1, kind:'agent',   detail:'Chain-of-thought reasoning' },
        { id:'a3',    label:'agent',        col:4, row:2, kind:'agent',   detail:'9 agents across the platform' },
        { id:'mcp',   label:'MCP tools',    col:5, row:0, kind:'tool',    detail:'Tool integrations via MCP' },
        { id:'model', label:'Gemma/Claude', col:5, row:2, kind:'agent',   detail:'Model backends running on GCP' },
        { id:'fb',    label:'Firebase',     col:2, row:3, kind:'store',   detail:'Firebase-backed state management' },
        { id:'out',   label:'response',     col:6, row:1, kind:'io',      detail:'Generated PR output' }
      ],
      edges: [
        { from:'req',  to:'api' },
        { from:'api',  to:'orch' },
        { from:'orch', to:'route' },
        { from:'route',to:'a1' },
        { from:'route',to:'a2' },
        { from:'route',to:'a3' },
        { from:'a1',   to:'mcp' },
        { from:'a3',   to:'model' },
        { from:'a2',   to:'out' },
        { from:'orch', to:'fb' },
        { from:'fb',   to:'orch', kind:'feedback' },
        { from:'a2',   to:'orch', kind:'feedback' }
      ]
    },
```

- [ ] **Step 2: Add the Code Conversion graph**

In the Claude Agent Code Conversion project object (~line 903), after the `ascii:` line, add:

```js
      flow: {
        title: 'Claude Agent Code Conversion',
        caption: 'a retry cycle — failures route back to the converter, only passes exit',
        nodes: [
          { id:'src',   label:'source repo',  col:0, row:1, kind:'io',      detail:'Source codebase to convert' },
          { id:'prune', label:'context prune',col:1, row:1, kind:'process', detail:'Context pruning — holds token cost down' },
          { id:'cache', label:'prompt cache', col:2, row:0, kind:'store',   detail:'Aggressive prompt caching' },
          { id:'conv',  label:'converter',    col:2, row:1, kind:'agent',   detail:'Conversion agent on the Claude Agent SDK' },
          { id:'mcp',   label:'MCP tools',    col:2, row:2, kind:'tool',    detail:'Optimised tool-use patterns via MCP' },
          { id:'tests', label:'dynamic tests',col:3, row:1, kind:'agent',   detail:'Test generation agent plus dynamic test harness' },
          { id:'res',   label:'results',      col:4, row:1, kind:'eval',    detail:'Pass routes to the report, fail routes back to the converter' },
          { id:'rep',   label:'report',       col:5, row:1, kind:'io',      detail:'Structured reporting' }
        ],
        edges: [
          { from:'src',   to:'prune' },
          { from:'prune', to:'conv' },
          { from:'cache', to:'conv' },
          { from:'mcp',   to:'conv' },
          { from:'conv',  to:'tests' },
          { from:'tests', to:'res' },
          { from:'res',   to:'rep' },
          { from:'res',   to:'conv', kind:'feedback' }
        ]
      },
```

- [ ] **Step 3: Add the Medical AI graph**

In the Medical AI Infrastructure project object (~line 810), after the `ascii:` line, add:

```js
      flow: {
        title: 'Medical AI Infrastructure',
        caption: 'an ordered pipeline behind a compliance gate, ending in two integrations',
        nodes: [
          { id:'docs',  label:'medical docs', col:0, row:1, kind:'io',      detail:'Incoming medical documents' },
          { id:'ocr',   label:'Document AI',  col:1, row:1, kind:'process', detail:'OCR engine over 100+ GB of training data' },
          { id:'ner',   label:'NER parser',   col:2, row:1, kind:'process', detail:'Named-entity recognition for medical terms' },
          { id:'fhir',  label:'FHIR layer',   col:3, row:1, kind:'process', detail:'FHIR translation layer' },
          { id:'kb',    label:'knowledge base',col:4, row:0, kind:'store',  detail:'LLM-powered knowledge base' },
          { id:'abha',  label:'ABHA check',   col:4, row:1, kind:'eval',    detail:'ABHA compliance validation' },
          { id:'epic',  label:'EPIC',         col:5, row:0, kind:'tool',    detail:'EPIC distributor integration' },
          { id:'cern',  label:'Cerner',       col:5, row:2, kind:'tool',    detail:'Cerner distributor integration' }
        ],
        edges: [
          { from:'docs', to:'ocr' },
          { from:'ocr',  to:'ner' },
          { from:'ner',  to:'fhir' },
          { from:'fhir', to:'kb' },
          { from:'fhir', to:'abha' },
          { from:'abha', to:'epic' },
          { from:'abha', to:'cern' }
        ]
      },
```

- [ ] **Step 4: Verify all four render, and only those four**

```js
() => {
  const cards = [...document.querySelectorAll('.project-card')];
  const want = ['Agentic PR Platform', 'RAG Systems', 'Code Conversion', 'Medical AI'];
  const results = {};
  return (async () => {
    for (const name of want) {
      const card = cards.find(c => c.textContent.includes(name));
      card.click();
      await new Promise(r => setTimeout(r, 700));
      const btn = document.querySelector('[data-tab="flow"]');
      if (btn) {
        btn.click();
        const svg = document.querySelector('.flow-svg');
        results[name] = {
          nodes: document.querySelectorAll('.fnode').length,
          edges: document.querySelectorAll('.fedge').length,
          noNaN: !svg.innerHTML.includes('NaN')
        };
      } else {
        results[name] = 'NO FLOW TAB';
      }
    }
    return results;
  })();
}
```

Expected: Agentic PR Platform `{nodes:11, edges:12}`, RAG `{nodes:12, edges:14}`, Code Conversion `{nodes:8, edges:8}`, Medical AI `{nodes:8, edges:7}`, all with `noNaN: true`.

- [ ] **Step 5: Verify the eight other projects have no flow tab**

```js
() => {
  const withFlow = ['Agentic PR Platform','RAG Systems','Code Conversion','Medical AI'];
  const cards = [...document.querySelectorAll('.project-card')];
  return (async () => {
    const offenders = [];
    for (let i = 0; i < cards.length; i++) {
      const name = cards[i].querySelector('.project-name')?.textContent || cards[i].textContent.slice(0, 30);
      if (withFlow.some(w => name.includes(w))) continue;
      cards[i].click();
      await new Promise(r => setTimeout(r, 550));
      if (document.querySelector('[data-tab="flow"]')) offenders.push(name.trim());
    }
    return { offenders, clean: offenders.length === 0 };
  })();
}
```

Expected: `clean: true`.

- [ ] **Step 6: Screenshot each of the four**

Capture `.playwright-mcp/flow-pr.png`, `flow-rag.png`, `flow-codeconv.png`, `flow-medical.png`. Read all four. Confirm each reads as a distinct shape — fan-out, converging-parallel, cycle, linear — and that no labels overflow their boxes.

- [ ] **Step 7: Commit**

```bash
cd /mnt/BatLair/Resume
git add projects.html
git commit -m "feat(projects): add flow graphs for PR platform, code conversion, medical AI

Completes the four flagship diagrams. Each was chosen for a distinct
topology: a fan-out from one orchestrator to a pool, a retry cycle where
failures route back, and a linear pipeline behind a compliance gate.
Labels and figures derive from copy already published on the site.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01RqVA831FhmV3EjonHKTycX"
```

---

### Task 7: Regression sweep and documentation

Confirm nothing else on the page broke, and record the feature in `CLAUDE.md`.

**Files:**
- Modify: `CLAUDE.md` — the shared-widgets section

- [ ] **Step 1: Verify no console errors beyond the known local-only noise**

Navigate to the page, open a flow tab, and collect console errors.

Expected: only the three known local-only errors — `CLARITY_ID_HERE` 400, `cloudflareinsights.com` CORS, and `favicon.ico` 404. Any error mentioning `flow`, `offset`, `NaN`, or `undefined` is a failure.

- [ ] **Step 2: Verify the effect-layer parity from 2026-09-10 still holds**

```bash
cd /mnt/BatLair/Resume
for f in index about projects articles connect; do
  printf "%-9s " "$f:"; grep -o "rgba(0,0,0,0.09) 3px, rgba(0,0,0,0.09) [0-9]*px" $f.html | head -1
done
```

Expected: all five report `4px`.

- [ ] **Step 3: Verify the existing tabs and card selection still work**

```js
() => {
  const card = [...document.querySelectorAll('.project-card')][0];
  card.click();
  return new Promise(r => setTimeout(() => {
    const info = document.getElementById('featuredSwap');
    const activeTab = document.querySelector('.feat-tab.active')?.dataset.tab;
    document.querySelector('[data-tab="diff"]').click();
    r({
      resetsToInfo: activeTab === 'info',
      infoHasContent: info.innerHTML.length > 100,
      diffWorks: document.querySelector('.feat-diff-view').style.display === 'block'
    });
  }, 700));
}
```

Expected: all three `true`.

- [ ] **Step 4: Document the feature in `CLAUDE.md`**

In the "Shared interactive widgets" section, add a bullet:

```markdown
- **Flow diagrams** (`projects.html` only): four flagship projects declare a `flow: { nodes, edges }` graph on their CONFIG entry, rendered by `renderFlow()` into inline SVG behind a `[flow]` tab on the featured panel. Nodes use coarse `col`/`row` grid slots, not pixels — `flowGeometry()` transposes them below 600px. Packets animate with CSS `offset-path`, deliberately not anime.js, so a CDN failure degrades to a static diagram. To add a fifth, add a `flow` key; no renderer change needed.
```

- [ ] **Step 5: Commit**

```bash
cd /mnt/BatLair/Resume
git add CLAUDE.md
git commit -m "docs: record the flow diagram system in CLAUDE.md

Notes the data-driven shape (add a flow key, no renderer change), the
grid-slot layout that enables the mobile transpose, and why packet motion
is CSS rather than anime.js.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01RqVA831FhmV3EjonHKTycX"
```

---

## Self-Review

**Spec coverage:**

| Spec section | Task |
|---|---|
| §1 Data model (`flow` key, `col`/`row`, `kind` tokens) | 2 (shape + RAG), 6 (remaining three) |
| §2 Renderer (`renderFlow`, one function for all four) | 2 |
| §3 Motion (CSS `offset-path`, no anime.js, stops when hidden) | 3 |
| §4 Detail on demand (shared slot, not tooltips) | 4 |
| §5 Responsive (transpose below 600px) | 5 |
| §6 Accessibility (focus, aria-label, aria-live, title/desc, reduced-motion) | 2 (attributes), 3 (reduced-motion), 4 (focus + live region) |
| §7 Tab integration (both hard-coded reset sites) | 1 |
| Four graphs | 2 (RAG), 6 (other three) |
| Non-goal: no diagrams for the other eight | 6 Step 5 verifies |
| Success criteria 1–8 | 6 Step 4/5, 1 Step 7, 3 Step 4, 4 Step 3/4, 5 Step 3/4, 3 Step 5, 7 Step 2, 7 Step 1 |

**Placeholder scan:** No TBD/TODO. Every code step carries literal code. The Task 1 stub is explicitly temporary and Task 6 Step 1 replaces it by name.

**Type consistency:** `renderFlow(flow, mount, stack)`, `flowGeometry(flow, stack)`, `flowEdgePath(a, b)`, `bindFlowDetail(mount, caption)`, `showFeatView(name)`, `syncFlowTab(p)`, `escFlow(s)` — each defined once and called with matching arity throughout. `currentFlow` and `flowStacked` are module-level; `currentFlow` is declared in Task 2 Step 3 and first read in Task 5 Step 1. Node `kind` values (`io`, `router`, `agent`, `process`, `store`, `tool`, `eval`) match the CSS classes in Task 2 Step 2 and the spec's token table.

**Known ordering dependency:** Task 1's stub carries `nodes: []`, so after Task 2 Step 3 tightens the guard to require a non-empty `nodes` array, the featured project loses its `[flow]` tab until Task 6 Step 1 supplies the real graph. This is intentional and called out in Task 2 Step 3, but a reviewer checking the featured project between Tasks 2 and 6 should expect two tabs, not three.
