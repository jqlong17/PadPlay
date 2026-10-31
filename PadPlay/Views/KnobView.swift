import SwiftUI

/// Beauty v2 knobs: track groove `#0A0A0D` + quieter arc `#6D28D9` + tightened drop shadow.
/// Layout token `--knob-d` 84 stays in `LeftChromeMetrics` (passed as `diameter`).
/// Value 0…1 → pointer −150°…+150° (0° = 12 o'clock; 60° bottom gap for label).
/// No purple outer bloom around the cap.
struct KnobView: View {
    let index: Int
    @Binding var value: Float
    var title: String = ""
    /// Face diameter. When set, layout uses a fixed size (left chrome metrics).
    var diameter: CGFloat? = nil

    @State private var dragStart: Float = 0

    /// Designer angle: 0° at 12 o'clock, travel −150…+150 over value 0…1.
    private var angleDegrees: Double {
        Double(min(1, max(0, value))) * 300.0 - 150.0
    }

    private var normalizedProgress: CGFloat {
        let clamped = min(max(angleDegrees, -150.0), 150.0)
        return CGFloat((clamped + 150.0) / 300.0)
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
        // Scale insets from the 84pt reference so metrics.scale stays proportional.
        let trackInset = outer * (2.5 / 84.0)
        let capInset = outer * (9.0 / 84.0)
        let capSize = max(28, outer - capInset * 2)
        let trackWidth = max(2.0, outer * (2.5 / 84.0))
        let pointerW = max(2.0, outer * (2.5 / 84.0))
        let pointerH = max(9.0, outer * (12.0 / 84.0))

        return VStack(spacing: 6) {
            ZStack {
                // 0. Track bottom groove well — `#0A0A0D` (Should from beauty v2).
                Circle()
                    .fill(PadTheme.knobTrackGroove)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.75), lineWidth: 1)
                            .blur(radius: 0.5)
                            .mask(Circle())
                    )

                // 1. Dark track — 300° arc, 60° bottom gap (idle ring faint).
                Circle()
                    .trim(from: 0.0, to: 300.0 / 360.0)
                    .stroke(
                        Color.white.opacity(0.05),
                        style: StrokeStyle(lineWidth: trackWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(120))
                    .padding(trackInset)

                // 2. Active purple value arc — quieter `#6D28D9`, NO outer bloom.
                Circle()
                    .trim(from: 0.0, to: (300.0 / 360.0) * normalizedProgress)
                    .stroke(
                        PadTheme.knobArc,
                        style: StrokeStyle(lineWidth: trackWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(120))
                    .padding(trackInset)

                // 3. Gradient cap + tightened drop stack + hairline rim.
                // CSS: 0 4px 8px @0.65 + 0 1px 2px @0.85; zero purple cap glow.
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [PadTheme.knobCapTop, PadTheme.knobCapBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: capSize, height: capSize)
                    .shadow(color: Color.black.opacity(0.85), radius: 1, x: 0, y: 1)
                    .shadow(color: Color.black.opacity(0.65), radius: 4, x: 0, y: 4)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.12),
                                        Color.white.opacity(0.03),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .overlay(
                        // Cap inset dark — micro concave top edge.
                        Circle()
                            .stroke(Color.black.opacity(0.55), lineWidth: 2)
                            .blur(radius: 1)
                            .offset(y: 1)
                            .mask(Circle())
                    )

                // 4. Quiet pointer — white@0.90 + soft lilac tick glow (not neon).
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.90))
                    .frame(width: pointerW, height: pointerH)
                    .shadow(color: Color(hex: 0x8F5BFF, alpha: 0.35), radius: 1.5, x: 0, y: 0)
                    .offset(y: -(capSize * 0.5 - max(8, outer * (10.0 / 84.0))))
                    .rotationEffect(.degrees(angleDegrees))
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
            .accessibilityValue(Text("\(Int((Double(value) * 300 - 150).rounded()))°"))

            Text(title.isEmpty ? "\(index + 1)" : title)
                .font(.system(size: max(11, min(13, outer * 0.155)), weight: .medium, design: .rounded))
                .foregroundStyle(PadTheme.chromeCaption)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: outer + 4)
        }
    }
}

#if DEBUG
#Preview("Knob beauty v2 angles") {
    HStack(spacing: 24) {
        ForEach([(-40.0, "−40°"), (25.0, "+25°"), (-110.0, "−110°"), (95.0, "+95°")], id: \.1) { deg, label in
            VStack(spacing: 8) {
                KnobView(
                    index: 0,
                    value: .constant(Float((deg + 150) / 300)),
                    title: label,
                    diameter: 84
                )
            }
        }
    }
    .padding(24)
    .background(PadTheme.chassis)
}
#endif
