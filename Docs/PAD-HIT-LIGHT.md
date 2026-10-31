# Pad 激发光效 v2.2（播放 / 循环 / 录制）

> 修订：2026-10-31 · 用户反馈「缺四周光环感」→ 在 Recipe A+ 描边之上加 **可控外环光晕**。  
> 原则：rim + **四周 halo**；仍禁止脏大紫 bloom、整垫近白。  
> 2026-10-31 beauty v2：idle 面改为炭黑 `#1C1C22`（见 `BEAUTY-v2.md`）；hit 仍为本 Recipe A++（白 rim + soft halo；面可向 lilac 微提）。

目标：note-on / 指点时垫像被点亮——边缘亮，且**四周有一圈柔光环**。

## 触发源（同一套）
手指按下 · 播放/循环 note-on · 录制中按下。回放=指点。

---

## 装机默认：Recipe A++（A+ + soft halo）

| 层 | idle（beauty v2） | hit peak |
|----|------|----------|
| 填色 | `#1C1C22` charcoal + purple halo ≈0.16 | lilac/white 径向微提（`#F5E8FF`→`#D2A0F4`） |
| 外描边 | Well `#070709` 1.5pt | `#FFFFFF` **3pt** |
| 内环 | 无 | inset 白 α≈0.55 · ~1.75pt（裁在垫内） |
| **四周光环** | 无 | **柔光外晕**：色 `#F5E8FF`～白，α 峰值 **0.45–0.55**，模糊半径约 **6–10pt**，扩散约 **2–4pt**；**贴垫四周一圈**，不要铺满缝到邻垫 |

> 注：旧表 idle 填色 `#CB85F3` 对应 beauty v1 / P0 糖果径向，已被 beauty v2 炭黑 supersede。Hit peak 仍用 lilac 提亮，与 charcoal idle 形成对比。

### 光环怎么做（SwiftUI）
- 用 `shadow` / 双层 overlay：**小半径、中等 α**，颜色偏白lilac，不是高饱和紫  
- 或：垫外再叠一层略大的圆角矩形，stroke 白 α0.25 + blur 8，clip 到「垫外扩 8pt」区域，避免糊进邻垫  
- **禁止**：blur ≥ 20、紫 `#CB85F3` 当 glow 色、整屏闪

### 时序（同前）
Attack ~100ms → Decay ~250ms；边与光环同相；retrigger 打断。

### 验收
- Loop 时肉眼是「哪颗垫四周在亮一圈」，不只是细白线  
- 邻垫不被光糊成一片  
- 对照：`Docs/baseline-hit-rim.png`（halo 版）、`Docs/compare-rim-recipes.png`、`preview-beauty-v2-hit.png`

Recipe A+（仅描边无外晕）保留作退路；Recipe B 内 LED 仍为可选抛光。

---

## 装机映射（`PadHitLight` — 视觉对齐 mock 亮度）

Peak CSS 参考（web baseline；CSS `box-shadow` 的 spread 后峰值 α 不易被稀释）：

```css
box-shadow:
  inset 0 0 0 1.75px rgba(255,255,255,0.55),
  0 0 6px 2px rgba(245,232,255,0.50),
  0 0 10px 3px rgba(255,255,255,0.28);
```

> **SwiftUI 注：** 字面搬 CSS α + 仅 stroke+blur 时，设备实测外环峰值仅约 L≈59（灰抬升），远低于设计师 mock 白lilac 软环约 L≈110。装机用 **soft fill ring（垫外环带）** + 略抬的 pre-blur α / expand，对齐 mock 亮度；仍禁止整垫 bloom、邻垫糊面。

| Token | 值 | 对应 SoT / 说明 |
|-------|----|----------|
| `idleFill` | `#1C1C22` | beauty v2 charcoal |
| `haloRingWidth` / opacity / blur | **3.0** / α**0.55** / **5** | 垫外 soft fill 环带（主亮度）；非整垫 fill |
| `haloLilac` / opacity | `#F5E8FF` α**0.55** | α 0.45–0.55 上沿 + stroke 补色 |
| `haloLilacBlur` / spread | **7** / **3** | blur 6–10 · spread 2–4 |
| `haloWhite` opacity / blur / spread | α**0.45** · **8** / **3.5** | 第二层白外晕（相对 CSS 0.28 抬高以补偿 blur 稀释） |
| `haloPathExpand` | **4pt** | 光晕路径相对垫面外扩 2–4pt |
| `haloClipExpand` | **8pt** | clip 垫外扩 8pt（防邻垫糊面） |
| `attackDuration` / `decayDuration` | **0.10** / **0.25** | Attack ~100ms → Decay ~250ms |

同一 `flash` 强度驱动 rim + halo；fill ring + 双层 stroke+blur 画在**外扩路径**上（四周 soft ring，非整垫 bloom）；hit 峰值淡出 idle 黑影以免压晕。
