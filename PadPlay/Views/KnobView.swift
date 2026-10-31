import SwiftUI

/// Vision A knobs: recessed inset ring + white rim + white tip.
/// Mid value 0.5 → indicator at 6 o'clock (into the bottom ring gap).
/// CSS: inset 0 0 0 ~9px dark + light top inset; diameter `--knob-d` 84.
struct KnobView: View {
    let index: Int
    @Binding var value: Float
    var title: String = ""
    /// Face diameter. When set, layout uses a fixed size (left chrome metrics).
    var diameter: CGFloat? = nil

    @State private var dragStart: Float = 0

    /// Value maps across ~270° with a bottom ring gap; mid (0.5) points at 6 o'clock.
    /// Pill rests at 12 o'clock before rotation — add 180° so rest/mid reads downward.
    private var angle: Double {
        Double(value) * 270 - 135 + 180
    }

    var body: some View {
        if let diameter {
            knobColumn(outer: diameter)
                .frame(width: diameter)
        } else {
            GeometryReader { geo in
                let outer = min(84, max(52, geo.size.width * 0.85))
                knobColumn(outer: outer)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            }
            .frame(minHeight: 96)
            .aspectRatio(0.95, contentMode: .fit)
        }
    }

    private func knobColumn(outer: CGFloat) -> some View {
        // Inner cap sits inside the ~9pt recessed ring band.
        let recess: CGFloat = max(7, outer * (9.0 / 84.0))
        let cap = max(28, outer - recess * 2 - 2)
        return VStack(spacing: 6) {
            ZStack {
                // Face + outer white rim
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 56 / 255, green: 56 / 255, blue: 60 / 255),
                                Color(red: 30 / 255, green: 30 / 255, blue: 34 / 255),
                            ],
                            center: UnitPoint(x: 0.5, y: 0.35),
                            startRadius: 1,
                            endRadius: outer * 0.55
                        )
                    )
                    .frame(width: outer, height: outer)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.85), lineWidth: 1.5)
                    )
                    // Recessed dark band — CSS `inset 0 0 0 9px #0f0f12`
                    .overlay(
                        Circle()
                            .strokeBorder(PadTheme.recessDark, lineWidth: recess)
                    )
                    // Light top inset — CSS `inset 0 10px 2px rgba(255,255,255,0.12)`
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.18),
                                        Color.white.opacity(0.04),
                                        Color.clear,
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                ),
                                lineWidth: 2
                            )
                            .padding(recess * 0.15)
                            .blur(radius: 0.4)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 4, y: 2)

                // Inner rotating cap + indicator
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    PadTheme.metalHighlight.opacity(0.9),
                                    PadTheme.metal,
                                    PadTheme.knobCap,
                                ],
                                center: UnitPoint(x: 0.5, y: 0.32),
                                startRadius: 1,
                                endRadius: cap * 0.72
                            )
                        )

                    // Short white pill — mid rests near 6 o'clock on the inner cap.
                    Capsule()
                        .fill(Color.white.opacity(0.95))
                        .frame(width: max(3, cap * 0.07), height: max(7, cap * 0.18))
                        .offset(y: -cap * 0.28)
                        .rotationEffect(.degrees(angle))
                }
                .frame(width: cap, height: cap)
            }
            .frame(width: outer, height: outer)
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
                .font(.system(size: max(11, min(13, outer * 0.155)), weight: .semibold, design: .rounded))
                .foregroundStyle(PadTheme.chromeCaption)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: outer + 4)
        }
    }
}
