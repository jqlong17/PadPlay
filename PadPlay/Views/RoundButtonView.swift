import SwiftUI

/// Recessed round control — white ring active state, no purple neon glow.
struct RoundButtonView: View {
    let title: String?
    let systemImage: String?
    var accent: Color? = nil
    var isActive: Bool = false
    var pulse: Bool = false
    var compact: Bool = false
    let action: () -> Void
    var longPress: (() -> Void)? = nil

    var body: some View {
        let size: CGFloat = compact ? 38 : 44
        let ringColor: Color = {
            if isActive {
                if let accent, accent == PadTheme.accentRed { return PadTheme.accentRed.opacity(0.9) }
                return Color.white.opacity(0.9)
            }
            return Color.white.opacity(0.28)
        }()

        Button(action: action) {
            ZStack {
                // Recessed mount
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: size + 4, height: size + 4)

                Circle()
                    .fill(PadTheme.knobCap)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(ringColor, lineWidth: isActive ? 2.0 : 1.1)
                    )
                    .shadow(color: .black.opacity(0.35), radius: 1.5, y: 1)

                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: compact ? 13 : 15, weight: .semibold))
                        .foregroundStyle(
                            accent == PadTheme.accentRed && systemImage == "circle.fill"
                            ? PadTheme.accentRed
                            : Color.white
                        )
                } else if let title {
                    Text(title)
                        .font(.system(size: title.count > 3 ? 10 : 12, weight: .bold, design: .rounded))
                        .foregroundStyle(textColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.65)
                        .padding(5)
                }
            }
            .frame(width: size + 4, height: size + 4)
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
    let action: () -> Void
    var longPress: (() -> Void)? = nil

    var body: some View {
        RoundButtonView(
            title: label,
            systemImage: nil,
            accent: accent,
            isActive: isActive,
            pulse: pulse,
            action: action,
            longPress: longPress
        )
        .frame(maxWidth: .infinity)
        .accessibilityLabel(label)
    }
}
