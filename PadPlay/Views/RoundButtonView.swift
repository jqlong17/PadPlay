import SwiftUI

/// Recessed round control — vision A inset ring; selected = white ring only, no fill-white face.
/// CSS: inset ~3.5px dark + light top; diameter `--btn-d` 56.
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

    /// Recess band scales with CSS 3.5 / 56.
    private var recessWidth: CGFloat {
        max(2.5, size * (3.5 / 56.0))
    }

    var body: some View {
        let ringColor = isActive ? ChromeRing.activeColor : ChromeRing.idleColor
        let ringWidth = isActive ? ChromeRing.activeWidth : ChromeRing.idleWidth
        let face = isActive ? PadTheme.roundButtonFaceActive : PadTheme.roundButtonFace

        Button(action: action) {
            VStack(spacing: caption == nil ? 0 : 3) {
                ZStack {
                    Circle()
                        .fill(face)
                        .frame(width: size, height: size)
                        // Recessed dark band — CSS `inset 0 0 0 3.5px #0e0e11`
                        .overlay(
                            Circle()
                                .strokeBorder(PadTheme.recessButtonDark, lineWidth: recessWidth)
                        )
                        // Light top inset — CSS `inset 0 4px 1px rgba(255,255,255,0.15)`
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.16),
                                            Color.white.opacity(0.03),
                                            Color.clear,
                                        ],
                                        startPoint: .top,
                                        endPoint: .center
                                    ),
                                    lineWidth: 1.2
                                )
                                .padding(recessWidth * 0.2)
                        )
                        // Outer ring — idle #45454a; active white α0.75 (no fill-white face).
                        .overlay(
                            Circle()
                                .stroke(ringColor, lineWidth: ringWidth)
                        )

                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: iconFont, weight: .semibold))
                            .foregroundStyle(
                                accent == PadTheme.accentRed && systemImage == "circle.fill"
                                ? PadTheme.accentRed
                                : Color.white.opacity(isActive ? 1.0 : 0.92)
                            )
                    } else if let title {
                        Text(title)
                            .font(.system(size: titleFont, weight: .semibold, design: .rounded))
                            .foregroundStyle(textColor)
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
    }

    private var textColor: Color {
        // 连击 / record keep red text accent; selection itself is white ring only.
        if let accent, accent == PadTheme.accentRed {
            return PadTheme.accentRed
        }
        return Color.white.opacity(isActive ? 1.0 : 0.86)
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
