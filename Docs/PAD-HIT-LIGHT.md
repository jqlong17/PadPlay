# Pad 激发光效 v2.1（播放 / 循环 / 录制）

> Recipe **A+** — 装机默认。原则：**边缘先亮**（rim-first），不是整块紫霓虹或近白闪屏。

目标：循环或播放时，图案里每个 note-on 让对应垫**边缘亮一下**；手指点垫同样。

## 触发源（同一套视觉）
1. 手指按下垫
2. 走带播放 / 循环时 sequencer 打到该垫
3. 录制中手指按下（与 1 相同；录制中不要另起红色垫面）

回放与指点**共用**同一 flash。

## 视觉重点：Recipe A+（rim + inset）

| 状态 | 垫面填色 | 边缘 | 说明 |
|------|----------|------|------|
| idle | `#CB85F3` | `#B15EEC`，**1.5pt** | 现基线，无外晕 |
| hit peak | 微提 **`#D2A0F4`** | **外描边 `#FFFFFF`，3.0pt** + **inset 白环 α ≈ 0.55**（~1.75pt，~2pt inset，clip 在垫内） | 主体是 rim |
| held（仅指尖按住） | `#D0A0F3` | 外边 ~2.5pt `#F5E8FF`；inset α ~0.35 | 松手 Decay |
| playback note | 同 hit peak | 同 hit peak | **one-shot**：无 held，peak → Decay |

实现：每垫 flash 强度 **0…1**；retrigger → 1；`intensity *= exp(-dt * k)` 指数衰减。动画主驱动是 **stroke 线宽 + 颜色**。填色次要。

### 禁止
- 垫外大面积紫外 bloom / 大半径外扩 `shadow`
- 整垫近白 whiteout、整屏闪
- 左栏旋钮/走带跟着闪

## 时序
- Attack：0 → peak，**~100ms**（允许 90–120），easeOut（**边先到**）
- Decay：peak → idle，**~250ms**（允许 220–300），easeOut
- Held：仅手指按住维持 held；松手 Decay
- Playback：每个 note-on 一次 Attack→Decay，无 held
- 连击：retrigger — 打断 Decay，立刻再 Attack

## 循环播放
- 每个 note-on 闪边一次；停 / 停录立刻回 idle

## 验收
- 开 Loop：肉眼跟到的是**哪颗垫的边在跳**，不是整块变白
- 指点与回放观感一致
- 无垫外紫晕、无左栏误闪
