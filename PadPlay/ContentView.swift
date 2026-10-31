import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var controller: PadController
    @EnvironmentObject private var engine: DrumEngine

    var body: some View {
        GeometryReader { geo in
            ZStack {
                background
                landscapeLayout(size: geo.size)
                    .padding(edgePadding(for: geo.size))
            }
        }
        .ignoresSafeArea()
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.035, green: 0.03, blue: 0.05),
                    Color(red: 0.07, green: 0.055, blue: 0.09),
                    Color(red: 0.02, green: 0.015, blue: 0.025),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [PadTheme.purple.opacity(0.16), .clear],
                center: UnitPoint(x: 0.72, y: 0.5),
                startRadius: 20,
                endRadius: 520
            )
        }
    }

    /// One hardware chassis: LEFT compact chrome | RIGHT equal-square 4×4 pads.
    /// Pad square is sized first (fills chassis height); left takes the remaining strip.
    private func landscapeLayout(size: CGSize) -> some View {
        let inset = edgePadding(for: size)
        let innerH = size.height - inset * 2
        let innerW = size.width - inset * 2
        let narrow = innerW < 700
        let chassisPad: CGFloat = narrow ? 8 : 12
        let gap: CGFloat = narrow ? 10 : 14

        let usableH = max(0, innerH - chassisPad * 2)
        let usableW = max(0, innerW - chassisPad * 2)

        // Fill the chassis as one device: pad square uses full usable height;
        // left chrome takes the remaining width (no orphan empty strip / sidebar gap).
        let minLeft: CGFloat = narrow ? 148 : 196
        var padBlock = min(usableH, max(0, usableW - minLeft - gap))
        var leftWidth = max(0, usableW - padBlock - gap)
        if leftWidth < minLeft {
            leftWidth = min(minLeft, usableW * 0.4)
            padBlock = max(0, min(usableH, usableW - leftWidth - gap))
            leftWidth = max(0, usableW - padBlock - gap)
        }

        return deviceChassis {
            HStack(alignment: .center, spacing: gap) {
                ControlClusterView()
                    .frame(width: leftWidth, alignment: .top)
                    .frame(maxHeight: .infinity, alignment: .top)

                PadGridView()
                    .frame(width: padBlock, height: padBlock)
            }
            .padding(chassisPad)
        }
        .frame(width: innerW, height: innerH)
    }

    private func deviceChassis<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.17, green: 0.15, blue: 0.19),
                            PadTheme.chassisEdge,
                            PadTheme.chassis,
                            Color(red: 0.035, green: 0.03, blue: 0.045),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.09),
                                    Color.white.opacity(0.015),
                                    Color.clear,
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .allowsHitTesting(false)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    PadTheme.purple.opacity(0.4),
                                    Color.white.opacity(0.07),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.55), radius: 18, y: 8)

            content()
        }
    }

    private func edgePadding(for size: CGSize) -> CGFloat {
        size.width < 700 ? 8 : 14
    }
}

#Preview {
    ContentView()
        .environmentObject(DrumEngine())
        .environmentObject(PadController())
        .environmentObject(AppSettings())
        .preferredColorScheme(.dark)
}
