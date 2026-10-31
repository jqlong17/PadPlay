import SwiftUI

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
        let ring = isActive ? (accent ?? PadTheme.purpleGlow) : PadTheme.label.opacity(0.4)

        Button(action: action) {
            ZStack {
                // Recessed mount
                Circle()
                    .fill(Color.black.opacity(0.45))
                    .frame(width: size + 4, height: size + 4)
                    .blur(radius: 0.2)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                PadTheme.metalHighlight.opacity(0.95),
                                PadTheme.knobCap,
                                Color.black.opacity(0.85),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .overlay(
                        // Top sheen
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.22),
                                        Color.white.opacity(0.04),
                                        Color.clear,
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                            .padding(1)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(isActive ? 0.55 : 0.28),
                                        ring.opacity(isActive ? 0.95 : 0.55),
                                        Color.black.opacity(0.55),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isActive ? 2.2 : 1.2
                            )
                    )
                    .shadow(color: (isActive ? (accent ?? PadTheme.purple) : .black).opacity(isActive ? 0.55 : 0.4),
                            radius: pulse ? 9 : (isActive ? 5 : 2),
                            y: isActive ? 0 : 2)

                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: compact ? 13 : 15, weight: .semibold))
                        .foregroundStyle(
                            accent == PadTheme.accentRed && systemImage == "circle.fill"
                            ? PadTheme.accentRed
                            : PadTheme.label
                        )
                        .shadow(color: .black.opacity(0.45), radius: 1, y: 1)
                } else if let title {
                    Text(title)
                        .font(.system(size: title.count > 3 ? 10 : 12, weight: .bold, design: .rounded))
                        .foregroundStyle(accent ?? PadTheme.label)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.65)
                        .padding(5)
                        .shadow(color: .black.opacity(0.35), radius: 1, y: 1)
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
        .scaleEffect(isActive && pulse ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: pulse)
    }
}

struct LabeledRoundButton: View {
    let label: String
    var accent: Color? = nil
    var isActive: Bool = false
    var pulse: Bool = false
    let action: () -> Void
    var longPress: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 5) {
            RoundButtonView(
                title: shortTitle,
                systemImage: nil,
                accent: accent,
                isActive: isActive,
                pulse: pulse,
                action: action,
                longPress: longPress
            )
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(accent ?? PadTheme.dimLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var shortTitle: String {
        // Face text mirrors the caption for beginners
        label
    }
}
