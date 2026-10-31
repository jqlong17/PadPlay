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
        let size: CGFloat = compact ? 40 : 46
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(PadTheme.knobCap)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(
                                (isActive ? (accent ?? PadTheme.purpleGlow) : PadTheme.label.opacity(0.35)),
                                lineWidth: isActive ? 2 : 1
                            )
                    )
                    .shadow(color: (isActive ? (accent ?? PadTheme.purple) : .clear).opacity(0.55), radius: pulse ? 8 : 4)

                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: compact ? 12 : 14, weight: .semibold))
                        .foregroundStyle(accent == PadTheme.accentRed && systemImage == "circle.fill" ? PadTheme.accentRed : PadTheme.label)
                } else if let title {
                    Text(title)
                        .font(.system(size: title.count > 3 ? 10 : 12, weight: .bold, design: .rounded))
                        .foregroundStyle(accent ?? PadTheme.label)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.65)
                        .padding(5)
                }
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.45).onEnded { _ in
                longPress?()
            }
        )
        .scaleEffect(isActive && pulse ? 1.04 : 1.0)
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
        VStack(spacing: 4) {
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
