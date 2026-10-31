import SwiftUI

/// Recessed round control — white ring active state, no purple neon glow, no fill-white face.
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
        return compact ? 38 : 44
    }

    private var iconFont: CGFloat {
        max(11, size * 0.34)
    }

    private var titleFont: CGFloat {
        let long = (title?.count ?? 0) > 3
        return max(9, size * (long ? 0.20 : 0.24))
    }

    var body: some View {
        let ringColor = isActive ? ChromeRing.activeColor : ChromeRing.idleColor
        let ringWidth = isActive ? ChromeRing.activeWidth : ChromeRing.idleWidth

        Button(action: action) {
            VStack(spacing: caption == nil ? 0 : 3) {
                ZStack {
                    // Recessed mount
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: size + 4, height: size + 4)

                    // Face stays dark (knobCap) — never fill-white when selected.
                    Circle()
                        .fill(PadTheme.knobCap)
                        .frame(width: size, height: size)
                        .overlay(
                            Circle()
                                .stroke(ringColor, lineWidth: ringWidth)
                        )
                        .shadow(color: .black.opacity(0.35), radius: 1.5, y: 1)

                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: iconFont, weight: .semibold))
                            .foregroundStyle(
                                accent == PadTheme.accentRed && systemImage == "circle.fill"
                                ? PadTheme.accentRed
                                : Color.white
                            )
                    } else if let title {
                        Text(title)
                            .font(.system(size: titleFont, weight: .bold, design: .rounded))
                            .foregroundStyle(textColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.65)
                            .padding(max(4, size * 0.08))
                    }
                }
                .frame(width: size + 4, height: size + 4)

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
        return Color.white.opacity(isActive ? 1.0 : 0.82)
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
