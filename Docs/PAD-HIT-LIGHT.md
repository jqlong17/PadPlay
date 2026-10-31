# Pad 激发光效 v2.2（播放 / 循环 / 录制）

> 修订：2026-10-31 · 用户反馈「缺四周光环感」→ 在 Recipe A+ 描边之上加 **可控外环光晕**。  
> 原则：rim + **四周 halo**；仍禁止脏大紫 bloom、整垫近白。

目标：note-on / 指点时垫像被点亮——边缘亮，且**四周有一圈柔光环**。

## 触发源（同一套）
手指按下 · 播放/循环 note-on · 录制中按下。回放=指点。

---

## 装机默认：Recipe A++（A+ + soft halo）

| 层 | idle | hit peak |
|----|------|----------|
| 填色 | `#CB85F3` | `#D2A0F4`（微提） |
| 外描边 | `#B15EEC` 1.5pt | `#FFFFFF` **3pt** |
| 内环 | 无 | inset 白 α≈0.55 · ~1.75pt（裁在垫内） |
| **四周光环** | 无 | 见下方 CSS → SwiftUI |

### Peak CSS（web baseline → SwiftUI 对齐）

```css
box-shadow:
  inset 0 0 0 1.75px rgba(255,255,255,0.55),
  0 0 6px 2px rgba(245,232,255,0.50),
  0 0 10px 3px rgba(255,255,255,0.28);
```

SwiftUI 映射（`PadHitLight`）：
- 保留 A+ 外描边 `#FFFFFF` 3pt + inset 白 α≈0.55（≈1.75pt）
- 柔光外晕两层（描边 + blur，**贴垫四周**，非整垫 bloom）：
  1. lilac `#F5E8FF` α0.50 · blur≈6pt · spread≈2pt
  2. white α0.28 · blur≈10pt · spread≈3pt
- clip / 外扩约 **8pt**，避免糊进邻垫
- 同一 `flash` 强度驱动 rim + halo；Attack ~100ms / Decay ~250ms

### 禁止
- blur ≥ 20、紫 `#CB85F3` 当 glow 色、整屏闪
- 整垫近白 whiteout、左栏旋钮/走带跟着闪

### 时序（同前）
Attack ~100ms → Decay ~250ms；边与光环同相；retrigger 打断。

### 验收
- Loop 时肉眼是「哪颗垫四周在亮一圈」，不只是细白线
- 邻垫不被光糊成一片
- 对照：`Docs/baseline-hit-rim.png`、`Docs/compare-rim-recipes.png`

Recipe A+（仅描边无外晕）保留作退路；Recipe B 内 LED 仍为可选抛光。
