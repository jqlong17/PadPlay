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
                    Color(red: 0.04, green: 0.03, blue: 0.06),
                    Color(red: 0.08, green: 0.06, blue: 0.11),
                    Color(red: 0.02, green: 0.02, blue: 0.03),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [PadTheme.purple.opacity(0.22), .clear],
                center: .center,
                startRadius: 40,
                endRadius: 560
            )
        }
    }

    /// Landscape chassis only: LEFT hardware cluster | RIGHT equal square 4×4.
    /// On narrow iPhone landscape, both sides scale down so all 16 pads stay visible (no scroll).
    private func landscapeLayout(size: CGSize) -> some View {
        let inset = edgePadding(for: size)
        let innerH = size.height - inset * 2
        let innerW = size.width - inset * 2
        let narrow = innerW < 700
        let chassisPad: CGFloat = narrow ? 10 : 14
        let gap: CGFloat = narrow ? 12 : 16

        let usableH = innerH - chassisPad * 2
        let usableW = innerW - chassisPad * 2

        // Prefer ~230pt left cluster; on narrow phones shrink so the pad square still fits.
        let preferredLeft = min(230, max(160, usableW * 0.38))
        let padBlock = min(usableH, max(0, usableW - preferredLeft - gap))
        let leftWidth = max(0, usableW - padBlock - gap)

        return deviceChassis {
            HStack(alignment: .center, spacing: gap) {
                ControlClusterView()
                    .frame(width: leftWidth)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .layoutPriority(0)

                // Complete equal-square 4×4 — all 16 pads visible, no scroll
                PadGridView()
                    .frame(width: padBlock, height: padBlock)
                    .layoutPriority(1)
            }
            .padding(chassisPad)
        }
        .frame(width: innerW, height: innerH)
    }

    /// Matte black device body — surrounds both left controls and right pads.
    private func deviceChassis<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.18, green: 0.16, blue: 0.20),
                            PadTheme.chassisEdge,
                            PadTheme.chassis,
                            Color(red: 0.04, green: 0.035, blue: 0.05),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    // Soft plastic top sheen
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.10),
                                    Color.white.opacity(0.02),
                                    Color.clear,
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .allowsHitTesting(false)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.22),
                                    PadTheme.purple.opacity(0.45),
                                    Color.white.opacity(0.08),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.6
                        )
                )
                .shadow(color: .black.opacity(0.6), radius: 20, y: 10)
                .shadow(color: PadTheme.purple.opacity(0.12), radius: 28, y: 0)

            content()
        }
    }

    private func edgePadding(for size: CGSize) -> CGFloat {
        size.width < 700 ? 10 : 16
    }
}

#Preview {
    ContentView()
        .environmentObject(DrumEngine())
        .environmentObject(PadController())
        .environmentObject(AppSettings())
        .preferredColorScheme(.dark)
}
