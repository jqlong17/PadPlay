# VISUAL-P0-swiftui.md

## 1. P0 色值表

| 名称 | hex / opacity | 用途 |
| :--- | :--- | :--- |
| `padCenter` | `#6D28D9` | 打击垫常态径向中心（扩至 ~75%） |
| `padEdge` | `#2E1065` | 打击垫常态径向边缘 |
| `padTopSheen` | `#FFFFFF @ 0.07` | 打击垫顶光起点 |
| `padBottomShade` | `#000000 @ 0.45` | 打击垫底光压暗终点 |
| `padRimHighlight` | `#FFFFFF @ 0.22` | 打击垫顶部物理倒角内高光 |
| `padRimShadow` | `#000000 @ 0.65` | 打击垫底部内阴影 & 外部投射阴影 |
| `padGrooveStroke` | `#09090B` | 打击垫嵌入黑槽外描边 (1.5pt) |
| `knobTrackIdle` | `#FFFFFF @ 0.07` | 旋钮底部暗轨 (2.5pt) |
| `knobArcActive` | `#A855F7` | 旋钮有效值紫弧 & 弧光 (`@ 0.50`) |
| `knobCapTop` | `#323236` | 旋钮帽体顶部渐变色 |
| `knobCapBottom` | `#18181B` | 旋钮帽体底部渐变色 |
| `knobCapRim` | `#FFFFFF @ 0.18` | 旋钮帽顶 0.5pt 发丝高光边 |
| `knobDropShadow` | `#000000 @ 0.85` | 旋钮帽体悬浮底影 |
| `knobPointer` | `#FFFFFF` | 旋钮指针本体 |
| `knobPointerGlow` | `#C084FC` | 旋钮指针外发光 |
| `btnIdleBg` | `#161618` | 圆钮未选底色 |
| `btnIdleStroke` | `#FFFFFF @ 0.06` | 圆钮未选外描边 |
| `btnIdleInset` | `#000000 @ 0.70` | 圆钮未选内凹顶影 |
| `btnPurpleBg` | `#A855F7 @ 0.18` | 常亮紫选中底色 |
| `btnPurpleGlow` | `#A855F7 @ 0.35` | 常亮紫选中内发光 |
| `btnPurpleStroke` | `#C084FC` | 常亮紫选中描边 (1.5pt) |
| `btnPurpleText` | `#F3E8FF` | 常亮紫选中文字/图标 |
| `btnRedBg` | `#EF4444 @ 0.18` | 连击红选中底色 |
| `btnRedGlow` | `#EF4444 @ 0.35` | 连击红选中内发光 |
| `btnRedStroke` | `#F87171` | 连击红选中描边 (1.5pt) |
| `btnRedText` | `#FECACA` | 连击红选中文字/图标 |

```swift
import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
```

---

## 2. Pad 面（常态材质与倒角黑槽）

仅替换 `.background` / `.overlay` / `.shadow` 材质层，**禁止修改外部传入的 `padW`、`padH`、间距及 `padRadius = 4` 等任何几何布局 token**。

```swift
struct PadSurfaceP0: View {
    // 几何 token 严格保持原工程常量，切勿修改尺寸与圆角
    let padRadius: CGFloat = 4

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: padRadius, style: .continuous)

        GeometryReader { geo in
            let maxDim = max(geo.size.width, geo.size.height)

            shape
                // 1. 压掉死白圆心：#6D28D9 扩至 ~75%，边缘压入 #2E1065
                .fill(
                    RadialGradient(
                        stops: [
                            .init(color: Color(hex: 0x6D28D9), location: 0.0),
                            .init(color: Color(hex: 0x5B21B6), location: 0.72),
                            .init(color: Color(hex: 0x2E1065), location: 1.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: maxDim * 0.65
                    )
                )
                // 2. 叠顶光与底压暗：white 0.07 -> black 0.45
                .overlay(
                    shape.fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.07),
                                Color.black.opacity(0.45)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                )
                // 3. 物理倒角顶高光：inset 0 1.5px 1px rgba(255,255,255,0.22)
                .overlay(
                    shape
                        .stroke(Color.white.opacity(0.22), lineWidth: 1.5)
                        .offset(y: 1.0)
                        .blur(radius: 0.5)
                        .mask(
                            shape.fill(
                                LinearGradient(
                                    colors: [.black, .clear],
                                    startPoint: .top,
                                    endPoint: UnitPoint(x: 0.5, y: 0.28)
                                )
                            )
                        )
                )
                // 4. 物理倒角底暗面：inset 0 -3px 2px rgba(0,0,0,0.65)
                .overlay(
                    shape
                        .stroke(Color.black.opacity(0.65), lineWidth: 3.0)
                        .offset(y: -2.0)
                        .blur(radius: 1.0)
                        .mask(
                            shape.fill(
                                LinearGradient(
                                    colors: [.black, .clear],
                                    startPoint: .bottom,
                                    endPoint: UnitPoint(x: 0.5, y: 0.72)
                                )
                            )
                        )
                )
                // 5. 嵌入黑槽外描边：#09090B 1.5px
                .overlay(
                    shape.strokeBorder(Color(hex: 0x09090B), lineWidth: 1.5)
                )
                // 6. 垫体底投影：0 6px 12px rgba(0,0,0,0.65)
                .shadow(color: Color.black.opacity(0.65), radius: 6, x: 0, y: 6)
        }
    }
}
```

---

## 3. Knob（暗轨 + 紫弧 + 立体帽体 + 发光指针）

保持外框布局 token `knob-d = 84` 不动；底部留出 `60°` 缺口避开标签（总行程 `300°`，指针 `0°` 为 12 点钟方向，范围 `-150° ... +150°`）。

```swift
struct KnobP0: View {
    /// 指针角度（0° = 12点方向，有效行程 -150° ... +150°）
    let angleDegrees: Double
    /// 严禁改动既有布局 token: knob⌀84
    private let knobDiameter: CGFloat = 84
    private let trackInset: CGFloat = 2.5
    private let capInset: CGFloat = 9.0

    private var normalizedProgress: CGFloat {
        let clamped = min(max(angleDegrees, -150.0), 150.0)
        return CGFloat((clamped + 150.0) / 300.0)
    }

    var body: some View {
        let capSize = knobDiameter - capInset * 2

        ZStack {
            // 1. 底部暗轨：拔除纯白圈，底开 60° (trim 0 ... 300/360 = 0.8333)
            Circle()
                .trim(from: 0.0, to: 300.0 / 360.0)
                .stroke(
                    Color.white.opacity(0.07),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .rotationEffect(.degrees(120)) // 120° 起笔(7点钟) -> 顺时针300°至5点钟
                .padding(trackInset)

            // 2. 有效值紫弧：#A855F7 + shadow #A855F7 @0.5 r4
            Circle()
                .trim(from: 0.0, to: (300.0 / 360.0) * normalizedProgress)
                .stroke(
                    Color(hex: 0xA855F7),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .rotationEffect(.degrees(120))
                .shadow(color: Color(hex: 0xA855F7, alpha: 0.50), radius: 4, x: 0, y: 0)
                .padding(trackInset)

            // 3. 立体帽体：LinearGradient(#323236 -> #18181B) + 底影 + 顶发丝边
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x323236), Color(hex: 0x18181B)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: capSize, height: capSize)
                .shadow(color: Color.black.opacity(0.85), radius: 7, x: 0, y: 8)
                // 顶发丝高光边 0.5px white@0.18
                .overlay(
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
                                    Color.white.opacity(0.03)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                )

            // 4. 真实角度指针：#FFF + 0 0 6px #C084FC
            Capsule(style: .continuous)
                .fill(Color.white)
                .frame(width: 2.5, height: 12)
                .shadow(color: Color(hex: 0xC084FC), radius: 6, x: 0, y: 0)
                .offset(y: -(capSize * 0.5 - 10))
                .rotationEffect(.degrees(angleDegrees))
        }
        .frame(width: knobDiameter, height: knobDiameter)
    }
}

// 4 个真实角度对照示例（严禁锁死 6 点钟）：-40° / +25° / -110° / +95°
struct KnobP0Examples: View {
    var body: some View {
        HStack(spacing: 24) {
            KnobP0(angleDegrees: -40)   // 示例 1：左偏微收 (-40°)
            KnobP0(angleDegrees: 25)    // 示例 2：右偏微推 (+25°)
            KnobP0(angleDegrees: -110)  // 示例 3：低值区 (-110°)
            KnobP0(angleDegrees: 95)    // 示例 4：高值区 (+95°)
        }
    }
}
```

---

## 4. RoundButton（未选内凹态 / 常亮紫 LED / 连击红 LED）

保持圆钮直径 token `btn-d = 56` 不动，废除纯白描边，统一为 LED 背光腔体结构。

```swift
enum RoundButtonP0State {
    case idle          // 未选
    case activePurple  // 常亮功能选中
    case activeRollRed // 连击红选中
}

struct RoundButtonP0<Label: View>: View {
    let state: RoundButtonP0State
    /// 严禁改动既有布局 token: btn⌀56
    private let btnDiameter: CGFloat = 56
    @ViewBuilder let label: () -> Label

    private var bgColor: Color {
        switch state {
        case .idle:          return Color(hex: 0x161618)
        case .activePurple:  return Color(hex: 0xA855F7, alpha: 0.18)
        case .activeRollRed: return Color(hex: 0xEF4444, alpha: 0.18)
        }
    }

    private var strokeColor: Color {
        switch state {
        case .idle:          return Color.white.opacity(0.06)
        case .activePurple:  return Color(hex: 0xC084FC)
        case .activeRollRed: return Color(hex: 0xF87171)
        }
    }

    private var strokeWidth: CGFloat {
        state == .idle ? 1.0 : 1.5
    }

    private var fgColor: Color {
        switch state {
        case .idle:          return Color.white.opacity(0.75)
        case .activePurple:  return Color(hex: 0xF3E8FF)
        case .activeRollRed: return Color(hex: 0xFECACA)
        }
    }

    private var innerGlowColor: Color {
        switch state {
        case .idle:          return .clear
        case .activePurple:  return Color(hex: 0xA855F7, alpha: 0.35)
        case .activeRollRed: return Color(hex: 0xEF4444, alpha: 0.35)
        }
    }

    var body: some View {
        ZStack {
            // 1. 底色层
            Circle()
                .fill(bgColor)

            // 2. 内腔光影：未选 inset 0 2px 4px black@0.7；选中 inset glow @0.35
            if state == .idle {
                Circle()
                    .stroke(Color.black.opacity(0.70), lineWidth: 4)
                    .blur(radius: 2)
                    .offset(y: 2)
                    .mask(Circle())
            } else {
                Circle()
                    .stroke(innerGlowColor, lineWidth: 6)
                    .blur(radius: 4)
                    .mask(Circle())
            }

            // 3. 外描边（未选 1pt white@0.06 / 紫 #C084FC 1.5pt / 红 #F87171 1.5pt）
            Circle()
                .strokeBorder(strokeColor, lineWidth: strokeWidth)

            // 4. 文字或图标前景
            label()
                .foregroundStyle(fgColor)
        }
        .frame(width: btnDiameter, height: btnDiameter)
    }
}

// 三态对照示例
struct RoundButtonP0Examples: View {
    var body: some View {
        HStack(spacing: 16) {
            RoundButtonP0(state: .idle) {
                Text("静音").font(.system(size: 13, weight: .medium))
            }
            RoundButtonP0(state: .activePurple) {
                Text("循环").font(.system(size: 13, weight: .semibold))
            }
            RoundButtonP0(state: .activeRollRed) {
                Text("连击").font(.system(size: 13, weight: .semibold))
            }
        }
    }
}
```
