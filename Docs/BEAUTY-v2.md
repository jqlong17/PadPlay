# PadPlay beauty v2 (after beauty v1)

Layout tokens frozen (TOKEN-MAP). Override layer: `patch-beauty-v2.css` linked **after** `patch-beauty-v1.css`.

Source of truth: `beauty-second-opinion.md` (Gemini 视觉 Must).

Archive: `archive-preview-before-beauty-v2.png`, `archive-baseline-before-beauty-v2.png` (v1).
New baseline / preview: `baseline-landscape.png`, `preview-beauty-v2.png` @ 1180×820 chassis.

## Gemini Must checklist

| # | Must | Done |
|---|------|------|
| 1 | Pad idle dormant: face `#1C1C22` + purple halo opacity **≈0.16**; soft matte, not jelly radial | ✅ charcoal + ellipse purple@0.16 / 0.08 |
| 2 | Well 镶嵌: pads & round btns `0 0 0 1.5px #070709` (+ micro rim white@0.04) | ✅ |
| 3 | Knob shadow tighten: `0 4px 8px @0.65` + `0 1px 2px @0.85`; arc quieter; no purple mud | ✅ labels `#8E8E98` readable |
| 4 | Selected LED: **zero** outer purple fog; inset light-guide `#8F5BFF` + inset glow@0.25 | ✅ computed: well + inset ring only |

## Should (included)

| Item | Done |
|------|------|
| Silkscreen labels `#71717A`–`#8E8E98`; active brightens | ✅ pad/knob/round idle; active `#F2ECFF` |
| Chassis deeper `#0E0E11` feel | ✅ `#121214 → #0E0E11 → #0A0A0C` + stronger vignette |
| Knob track bottom groove `#0A0A0D` + inset dark | ✅ moat `#0A0A0D` + `inset 0 1px 2px` |

## What changed vs beauty v1

| Area | Beauty v1 | Beauty v2 |
|------|-----------|-----------|
| Pad face | radial candy `#4C1D95→#5B21B6→#1E1035` | charcoal `#1C1C22` + purple halo **@0.16** |
| Pad sheen | white@0.045 full vertical | softer matte; top white@0.055 fading |
| Pad / btn Well | none (floating sheets) | `1.5px #070709` + rim white@0.04 |
| Knob drop | `0 8px 14px` + purple bloom | `0 4px 8px @0.65` + `0 1px 2px @0.85`; bloom **0** |
| Knob arc | `#7C3AED` + outer glow | `#6D28D9` quieter; track groove `#0A0A0D` |
| Round idle | flat `#141416` | `#18181D` micro-convex + Well |
| Round selected | purple fill + **outer** fog | `#1A1A20` + **inset** `#8F5BFF` guide only |
| Danger selected | outer red fog | inset `#D9534F` guide only |
| Labels | white@0.46–0.54 | silkscreen `#8E8E98` / `#71717A` |
| Chassis | `#1C1C1F→#101012` | `#0E0E11` band + deeper vignette |

## Unchanged (hard)

sizes, gaps, knobTop=padTop, gear 18/18, pad radius 4, left width, knob⌀, btn⌀, all TOKEN-MAP geometry. Pointer angles / arc lengths from P0 kept.

## SwiftUI port

Materials live in `PadTheme` / `PadHitLight` (`PadPlay/Theme.swift`) and face views:

| Web CSS | SwiftUI |
|---------|---------|
| `.pad` charcoal + halo | `ForcePadCell` in `PadGridView.swift` |
| `.knob` shadow / arc | `KnobView.swift` |
| `.round-btn` / `.active` inset guide | `RoundButtonView.swift` |
| `.chassis` gradient + vignette | `ContentView.deviceChassis` |
| hit Recipe A++ | `PadHitLight` + flash overlays in `ForcePadCell` |

CSS reference: `Docs/patch-beauty-v2.css`. Hit SoT: `Docs/PAD-HIT-LIGHT.md`.
Geometry: `LeftChromeMetrics` / `Docs/vision-A/TOKEN-MAP.md` — **do not change**.

## QA eyeball (computed + preview)

- [x] Pads charcoal-ish idle; faint purple only (headroom for hit)
- [x] Embedded wells on pads + round buttons
- [x] Knob shadows compact; 「音色/音调」readable
- [x] Selected = inset guide, not page-game outer fog
- [x] Geometry: pad 172×124, chassis 1180×820 verified in capture
