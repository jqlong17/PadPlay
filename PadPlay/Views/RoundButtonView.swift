import SwiftUI

/// VISUAL-P0 LED cavity — idle deep well / activePurple / activeRollRed (连击 = red).
/// Layout token `--btn-d` 56 stays in `LeftChromeMetrics` (passed as `diameter`).
enum RoundButtonLEDState {
    case idle
    case activePurple
    case activeRollRed
}

struct RoundButtonView: View {
    let title: String?
    let systemImage: String?
    var accent: Color? = nil
    var isActive: Bool = false
    var pulse: Bool = false
    /// Face diameter. Defaults keep prior compact/regular sizes.
    var diameter: CGFloat? = nil
    var compact: Bool = false
    /// Optional caption under the icon (transport). Kept ≤10pt gray when used.
    var caption: String? = nil
    let action: () -> Void
    var longPress: (() -> Void)? = nil

    private var size: CGFloat {
        if let diameter { return diameter }
        return compact ? 40 : 56
    }

    private var iconFont: CGFloat {
        max(12, size * 0.32)
    }

    private var titleFont: CGFloat {
        let long = (title?.count ?? 0) > 3
        return max(10, size * (long ? 0.18 : 0.20))
    }

    /// 连击 / record use red LED when selected; other actives use purple.
    private var ledState: RoundButtonLEDState {
        guard isActive else { return .idle }
        if let accent, accent == PadTheme.accentRed { return .activeRollRed }
        return .activePurple
    }

    private var bgColor: Color {
        switch ledState {
        case .idle: return Color(hex: 0x161618)
        case .activePurple: return Color(hex: 0xA855F7, alpha: 0.18)
        case .activeRollRed: return Color(hex: 0xEF4444, alpha: 0.18)
        }
    }

    private var strokeColor: Color {
        switch ledState {
        case .idle: return Color.white.opacity(0.06)
        case .activePurple: return Color(hex: 0xC084FC)
        case .activeRollRed: return Color(hex: 0xF87171)
        }
    }

    private var strokeWidth: CGFloat {
        ledState == .idle ? 1.0 : 1.5
    }

    private var fgColor: Color {
        switch ledState {
        case .idle:
            // Mock baseline: 连击 label + record dot stay red in the idle deep well.
            if let accent, accent == PadTheme.accentRed {
                return PadTheme.accentRed
            }
            return Color.white.opacity(0.75)
        case .activePurple:
            return Color(hex: 0xF3E8FF)
        case .activeRollRed:
            return Color(hex: 0xFECACA)
        }
    }

    private var innerGlowColor: Color {
        switch ledState {
        case .idle: return .clear
        case .activePurple: return Color(hex: 0xA855F7, alpha: 0.35)
        case .activeRollRed: return Color(hex: 0xEF4444, alpha: 0.35)
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: caption == nil ? 0 : 3) {
                ZStack {
                    // 1. Face fill
                    Circle()
                        .fill(bgColor)

                    // 2. Inner cavity — idle inset shadow; active LED glow
                    if ledState == .idle {
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

                    // 3. Outer stroke (no cheap white active ring)
                    Circle()
                        .strokeBorder(strokeColor, lineWidth: strokeWidth)

                    // 4. Label / icon
                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: iconFont, weight: .semibold))
                            .foregroundStyle(fgColor)
                    } else if let title {
                        Text(title)
                            .font(.system(size: titleFont, weight: .semibold, design: .rounded))
                            .foregroundStyle(fgColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.65)
                            .padding(max(4, size * 0.08))
                    }
                }
                .frame(width: size, height: size)

                if let caption {
                    Text(caption)
                        .font(.system(size: ChromeRing.transportCaptionSize, weight: .medium, design: .rounded))
                        .foregroundStyle(ChromeRing.transportCaptionColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(width: size + 8)
                }
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.45).onEnded { _ in
                longPress?()
            }
        )
        .scaleEffect(pulse ? 1.04 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: pulse)
        .animation(.easeInOut(duration: 0.12), value: isActive)
    }
}

/// Function pad: label on the button face only (no duplicate caption under).
struct LabeledRoundButton: View {
    let label: String
    var accent: Color? = nil
    var isActive: Bool = false
    var pulse: Bool = false
    var diameter: CGFloat? = nil
    let action: () -> Void
    var longPress: (() -> Void)? = nil

    var body: some View {
        RoundButtonView(
            title: label,
            systemImage: nil,
            accent: accent,
            isActive: isActive,
            pulse: pulse,
            diameter: diameter,
            action: action,
            longPress: longPress
        )
        .accessibilityLabel(label)
    }
}

#if DEBUG
#Preview("RoundButton P0 LED") {
    HStack(spacing: 16) {
        RoundButtonView(title: "鼓组", systemImage: nil, isActive: false, diameter: 56, action: {})
        RoundButtonView(title: "节拍器", systemImage: nil, isActive: true, diameter: 56, action: {})
        RoundButtonView(
            title: "连击",
            systemImage: nil,
            accent: PadTheme.accentRed,
            isActive: false,
            diameter: 56,
            action: {}
        )
        RoundButtonView(
            title: "连击",
            systemImage: nil,
            accent: PadTheme.accentRed,
            isActive: true,
            diameter: 56,
            action: {}
        )
        RoundButtonView(
            title: nil,
            systemImage: "circle.fill",
            accent: PadTheme.accentRed,
            isActive: false,
            diameter: 56,
            action: {}
        )
    }
    .padding(24)
    .background(PadTheme.chassis)
}
#endif
