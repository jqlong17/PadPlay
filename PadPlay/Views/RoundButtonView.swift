import SwiftUI

/// Beauty v2 round buttons — idle Well + micro-convex; selected = inset light-guide only.
/// Zero outer purple / red fog. Layout token `--btn-d` 56 stays in `LeftChromeMetrics`.
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

    /// 连击 / record use red inset guide when selected; other actives use purple guide.
    private var ledState: RoundButtonLEDState {
        guard isActive else { return .idle }
        if let accent, accent == PadTheme.accentRed { return .activeRollRed }
        return .activePurple
    }

    private var isDangerIdle: Bool {
        !isActive && accent == PadTheme.accentRed
    }

    private var bgColor: Color {
        switch ledState {
        case .idle: return PadTheme.roundButtonFace
        case .activePurple: return PadTheme.roundButtonFaceActive
        case .activeRollRed: return PadTheme.roundButtonFaceDangerActive
        }
    }

    private var fgColor: Color {
        switch ledState {
        case .idle:
            // Beauty v2: danger idle silkscreen-ish red `#D9534F` quieter.
            if isDangerIdle {
                return PadTheme.accentRed.opacity(0.85)
            }
            return PadTheme.chromeCaption
        case .activePurple:
            return PadTheme.chromeCaptionActive
        case .activeRollRed:
            return Color(hex: 0xFECACA)
        }
    }

    /// Icon opacity — idle muted; active near full.
    private var iconOpacity: Double {
        switch ledState {
        case .idle: return isDangerIdle ? 0.85 : 0.50
        case .activePurple, .activeRollRed: return 0.95
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: caption == nil ? 0 : 3) {
                ZStack {
                    // 1. Face fill
                    Circle()
                        .fill(bgColor)

                    // 2. Idle micro-convex + well; active inset light-guide + inset glow.
                    // Must 4: selected = inset `#8F5BFF` / danger `#D9534F`; outer fog = 0.
                    if ledState == .idle {
                        // Top micro highlight
                        Circle()
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            .offset(y: 0.5)
                            .blur(radius: 0.3)
                            .mask(
                                Circle().fill(
                                    LinearGradient(
                                        colors: [.black, .clear],
                                        startPoint: .top,
                                        endPoint: UnitPoint(x: 0.5, y: 0.45)
                                    )
                                )
                            )
                        // Bottom inset shade
                        Circle()
                            .stroke(Color.black.opacity(0.55), lineWidth: 2)
                            .blur(radius: 1)
                            .offset(y: -0.5)
                            .mask(
                                Circle().fill(
                                    LinearGradient(
                                        colors: [.black, .clear],
                                        startPoint: .bottom,
                                        endPoint: UnitPoint(x: 0.5, y: 0.55)
                                    )
                                )
                            )
                        // Idle border + Well ring
                        Circle()
                            .strokeBorder(
                                isDangerIdle
                                    ? PadTheme.accentRed.opacity(0.18)
                                    : PadTheme.roundButtonIdleRing,
                                lineWidth: 1.0
                            )
                        Circle()
                            .strokeBorder(PadTheme.wellRing, lineWidth: 1.5)
                    } else {
                        // Inset glow contained inside face (α≈0.25 / 0.28) — no outer fog.
                        let guide = ledState == .activeRollRed
                            ? PadTheme.roundButtonGuideRed
                            : PadTheme.roundButtonGuidePurple
                        let glowAlpha: Double = ledState == .activeRollRed ? 0.28 : 0.25
                        Circle()
                            .fill(guide.opacity(glowAlpha))
                            .blur(radius: 5)
                            .padding(4)
                            .mask(Circle())
                        // Well ring (outer) + inset light-guide ring
                        Circle()
                            .strokeBorder(PadTheme.wellRing, lineWidth: 1.5)
                        Circle()
                            .strokeBorder(guide, lineWidth: 1.5)
                            .padding(1.5)
                    }

                    // 3. Label / icon
                    Group {
                        if let systemImage {
                            Image(systemName: systemImage)
                                .font(.system(size: iconFont, weight: .semibold))
                                .foregroundStyle(fgColor)
                        } else if let title {
                            Text(title)
                                .font(.system(size: titleFont, weight: .medium, design: .rounded))
                                .foregroundStyle(fgColor)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.65)
                                .padding(max(4, size * 0.08))
                        }
                    }
                    .opacity(iconOpacity)
                }
                .frame(width: size, height: size)
                // Compact drop only — no purple/red outer bloom.
                .shadow(color: Color.black.opacity(0.60), radius: 1.5, x: 0, y: 2)

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
#Preview("RoundButton beauty v2") {
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
        RoundButtonView(
            title: nil,
            systemImage: "repeat",
            isActive: true,
            diameter: 56,
            action: {}
        )
    }
    .padding(24)
    .background(PadTheme.chassis)
}
#endif
