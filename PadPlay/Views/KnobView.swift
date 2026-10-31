import SwiftUI

/// Preview-mock knobs: dark cap + thin white ring (no purple progress arc) + white tip.
struct KnobView: View {
    let index: Int
    @Binding var value: Float
    var title: String = ""

    @State private var dragStart: Float = 0

    /// Value maps across ~270° with a bottom gap (mock ring break near 6 o'clock).
    private var angle: Double {
        Double(value) * 270 - 135
    }

    var body: some View {
        GeometryReader { geo in
            let outer = min(64, max(44, geo.size.width * 0.7))
            let cap = outer * 0.78

            VStack(spacing: 4) {
                ZStack {
                    // Recessed well
                    Circle()
                        .fill(Color.black.opacity(0.45))
                        .frame(width: outer + 4, height: outer + 4)

                    // Thin white ring with micro gap at bottom — no purple arc.
                    KnobWhiteRing(gapDegrees: 28)
                        .stroke(Color.white.opacity(0.92), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                        .frame(width: outer, height: outer)

                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        PadTheme.metalHighlight.opacity(0.85),
                                        PadTheme.metal,
                                        PadTheme.knobCap,
                                    ],
                                    center: UnitPoint(x: 0.35, y: 0.3),
                                    startRadius: 1,
                                    endRadius: cap * 0.7
                                )
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.55), radius: 2, y: 1)

                        // Short white pill indicator on the cap face
                        Capsule()
                            .fill(Color.white.opacity(0.95))
                            .frame(width: max(3, cap * 0.08), height: max(8, cap * 0.22))
                            .offset(y: -cap * 0.28)
                            .rotationEffect(.degrees(angle))
                    }
                    .frame(width: cap, height: cap)
                }
                .frame(maxWidth: .infinity)
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
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(PadTheme.dimLabel)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .frame(minHeight: 72)
        .aspectRatio(0.95, contentMode: .fit)
    }
}

/// Nearly-full circle with a small open gap centered at the bottom (6 o'clock).
private struct KnobWhiteRing: Shape {
    var gapDegrees: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        // SwiftUI angles: 0° = right; clockwise with trimmed Circle uses different API —
        // use Path addArc: 90° is bottom in UIKit coords (y down).
        let gap = gapDegrees * .pi / 180
        let start = (.pi / 2) + gap / 2
        let end = (.pi / 2) + (2 * .pi) - gap / 2
        path.addArc(center: center, radius: radius, startAngle: .radians(start), endAngle: .radians(end), clockwise: false)
        return path
    }
}
