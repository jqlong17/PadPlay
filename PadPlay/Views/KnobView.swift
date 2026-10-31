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
        GeometryReader { geo in
            let outer = min(64, max(46, geo.size.width * 0.72))
            let cap = outer * 0.72

            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.black.opacity(0.55),
                                    PadTheme.chassisWell,
                                    Color.black.opacity(0.35),
                                ],
                                center: .center,
                                startRadius: 2,
                                endRadius: outer * 0.55
                            )
                        )
                        .frame(width: outer + 5, height: outer + 5)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.07), lineWidth: 1)
                        )

                    KnobTickRing()
                        .stroke(PadTheme.label.opacity(0.55), style: StrokeStyle(lineWidth: 1.3, lineCap: .butt))
                        .frame(width: outer, height: outer)

                    Circle()
                        .trim(from: 0, to: CGFloat(value) * 0.75)
                        .stroke(
                            AngularGradient(
                                colors: [PadTheme.purple, PadTheme.purpleGlow],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 2.2, lineCap: .round)
                        )
                        .frame(width: outer, height: outer)
                        .rotationEffect(.degrees(135))

                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        PadTheme.metalHighlight,
                                        PadTheme.metal,
                                        PadTheme.knobCap,
                                    ],
                                    center: UnitPoint(x: 0.35, y: 0.28),
                                    startRadius: 1,
                                    endRadius: cap * 0.72
                                )
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.35),
                                                Color.white.opacity(0.05),
                                                Color.black.opacity(0.45),
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.1
                                    )
                            )
                            .shadow(color: .black.opacity(0.65), radius: 3, y: 2)

                        Ellipse()
                            .fill(Color.white.opacity(0.16))
                            .frame(width: cap * 0.55, height: cap * 0.2)
                            .offset(y: -cap * 0.22)

                        Capsule()
                            .fill(Color.white.opacity(0.92))
                            .frame(width: 2.8, height: max(10, cap * 0.3))
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
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(PadTheme.label)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .frame(minHeight: 78)
        .aspectRatio(0.95, contentMode: .fit)
    }
}

private struct KnobTickRing: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let ticks = 11
        for i in 0..<ticks {
            let t = Double(i) / Double(ticks - 1)
            let degrees = -135.0 + t * 270.0
            let rad = degrees * .pi / 180
            let outer = CGPoint(
                x: center.x + CGFloat(cos(rad)) * radius,
                y: center.y + CGFloat(sin(rad)) * radius
            )
            let innerR = radius - (i == 0 || i == ticks - 1 || i == ticks / 2 ? 5.5 : 3.2)
            let inner = CGPoint(
                x: center.x + CGFloat(cos(rad)) * innerR,
                y: center.y + CGFloat(sin(rad)) * innerR
            )
            path.move(to: inner)
            path.addLine(to: outer)
        }
        return path
    }
}
