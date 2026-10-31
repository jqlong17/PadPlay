import SwiftUI

struct KnobView: View {
    let index: Int
    @Binding var value: Float
    var title: String = ""

    @State private var dragStart: Float = 0

    private var angle: Double {
        Double(value) * 270 - 135
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(PadTheme.label.opacity(0.55), lineWidth: 1.5)
                    .frame(width: 64, height: 64)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [PadTheme.metal, PadTheme.knobCap],
                            center: .center,
                            startRadius: 2,
                            endRadius: 28
                        )
                    )
                    .frame(width: 52, height: 52)
                    .shadow(color: .black.opacity(0.55), radius: 3, y: 2)
                    .overlay(
                        Capsule()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 3, height: 14)
                            .offset(y: -14)
                            .rotationEffect(.degrees(angle))
                    )

                Circle()
                    .trim(from: 0, to: CGFloat(value) * 0.75)
                    .stroke(PadTheme.purpleGlow.opacity(0.7), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 64, height: 64)
                    .rotationEffect(.degrees(135))
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        if g.translation == .zero { dragStart = value }
                        let delta = Float(-g.translation.height / 120)
                        value = min(1, max(0, dragStart + delta))
                    }
            )
            .accessibilityLabel(title.isEmpty ? "Knob \(index + 1)" : title)

            Text(title.isEmpty ? "\(index + 1)" : title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(PadTheme.label)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}
