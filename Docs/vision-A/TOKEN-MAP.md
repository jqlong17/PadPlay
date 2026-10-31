# Vision A / C → SwiftUI token map

Source: `patch-vision-A.css` + `patch-vision-C.txt`. App Icon unchanged. PadHitLight Recipe **A++** retained.

| CSS var / rule | Value | Swift |
|----------------|-------|-------|
| `--left-w` | 340 | `LeftChromeMetrics.refWidth` |
| `--cluster-w` | 200 | `LeftChromeMetrics.clusterWidth` (= `56×3+16×2`) |
| `.left` / `.left-stack` `justify-content` | `flex-start` | top-aligned `VStack` + bottom `Spacer` (no space-between) |
| `--section-gap` | 26 | `LeftChromeMetrics.sectionGap` |
| `--brand-bottom` | 20 | `LeftChromeMetrics.brandBottom` |
| `--title-size` / `--status-size` | 22 / 12 | `titleSize` / `statusSize` |
| `--knob-d` / `--knob-col` / `--knob-row` | 84 / 32 / 14 | `knobDiameter` / `knobColGap` / `knobRowGap` |
| knob outer width | `84×2+32=200` | `knobGridWidth` aligns to cluster |
| knob inset ring | `inset 0 0 0 9px` + top light | `KnobView` `strokeBorder` recess |
| mid indicator | 6 o’clock | unchanged angle map |
| `--btn-d` / `--btn-col` / `--btn-row` / `--btn-slot` | 56 / 16 / 14 / 56 | `buttonDiameter` / `colGap` / `rowGap` / `buttonSlot` |
| round-btn inset | `inset 0 0 0 3.5px` | `RoundButtonView` recess |
| `.round-btn.active` | white ring, dark face | `ChromeRing.activeColor` α0.75; face `#28282e` |
| `--gear-d` + `.right-top .gear-tr` | ⌀34, inset top/right **18**, stroke `rgba(255,255,255,0.18)` | pad-stage top-trailing; `LeftChromeMetrics.gearInset` |
| pads (1180×820 landscape v0 note) | padW≈172 padH≈124 padGapH=24 padGapV≈32 | flex stage; report `padGapV` = face-to-face row gutter |
| settings sheet | top-right under gear | `popover` + `.presentationCompactAdaptation(.popover)` |
| `.pad` `border-radius` | **4px** | `PadTheme.padCornerRadius` (was 8.5%) |
| `.pad` fill | radial `#e5aaff→#b24bf7→#8d27d9` | `PadTheme.padRadial*` |
| `--pad-edge` | `#9B3FE0` | `PadTheme.padEdge` / idle rim |
| `.pad-label` | `#dcdce2` weight 600 | `PadTheme.padLabel` + `.semibold` |
| hit A++ | rim + soft outer halo | `PadHitLight` unchanged |

## Calibration mode (debug)

Settings → **矫正模式 / Calibration mode** (default OFF, persisted). When ON, the main stage is a wireframe HUD only (rects, crosses, ids, gap labels) covering left chrome (knobs / btn / transport), gear, and pads 1–16. **复制布局报告** pastes QA schema `PadPlay layout report v0` (frames in pt relative to root chassis content; token + measured−token deltas for left-w / cluster / knob⌀ / btn⌀ / gear⌀ / sectionGap / knobCol / knobRow / btnCol; padGapH/V measured only — **padGapV = face-to-face row gutter from pad frames**, not VStack `vGap`). App Icon and Recipe A++ hit path unchanged when mode is OFF.
