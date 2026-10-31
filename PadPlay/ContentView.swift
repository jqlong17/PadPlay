import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var controller: PadController
    @EnvironmentObject private var engine: DrumEngine

    var body: some View {
        GeometryReader { geo in
            let landscape = geo.size.width >= geo.size.height
            ZStack {
                background
                Group {
                    if landscape {
                        landscapeLayout(size: geo.size)
                    } else {
                        portraitLayout(size: geo.size)
                    }
                }
                .padding(edgePadding(for: geo.size))
            }
        }
        .ignoresSafeArea()
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.04, blue: 0.07),
                    Color(red: 0.09, green: 0.07, blue: 0.12),
                    Color(red: 0.03, green: 0.03, blue: 0.04),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [PadTheme.purple.opacity(0.18), .clear],
                center: .center,
                startRadius: 40,
                endRadius: 520
            )
        }
    }

    /// Preferred draft: one chassis — LEFT hardware cluster | RIGHT equal square 4×4.
    private func landscapeLayout(size: CGSize) -> some View {
        let inset = edgePadding(for: size)
        let innerH = size.height - inset * 2
        let innerW = size.width - inset * 2
        let chassisPad: CGFloat = 14
        let gap: CGFloat = 16
        let minLeft: CGFloat = 230

        let usableH = innerH - chassisPad * 2
        let usableW = innerW - chassisPad * 2
        // Right pad block is a perfect square; maximize it within chassis
        let padBlock = min(usableH, usableW - minLeft - gap)
        let leftWidth = max(minLeft, usableW - padBlock - gap)

        return deviceChassis {
            HStack(alignment: .center, spacing: gap) {
                ControlClusterView()
                    .frame(width: leftWidth)
                    .frame(maxHeight: .infinity, alignment: .top)

                // Complete equal-square 4×4 — all 16 pads visible, no scroll
                PadGridView()
                    .frame(width: padBlock, height: padBlock)
            }
            .padding(chassisPad)
        }
        .frame(width: innerW, height: innerH)
    }

    private func portraitLayout(size: CGSize) -> some View {
        let inset = edgePadding(for: size)
        let innerH = size.height - inset * 2
        let innerW = size.width - inset * 2
        let topH = min(innerH * 0.36, 300)
        let padBlock = min(innerW - 24, innerH - topH - 28)

        return deviceChassis {
            VStack(spacing: 12) {
                ControlClusterView()
                    .frame(height: topH)
                PadGridView()
                    .frame(width: padBlock, height: padBlock)
                Spacer(minLength: 0)
            }
            .padding(12)
        }
        .frame(width: innerW, height: innerH)
    }

    /// Matte black device body — surrounds both left controls and right pads.
    private func deviceChassis<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [PadTheme.chassisEdge, PadTheme.chassis],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.14),
                                    PadTheme.purple.opacity(0.4),
                                    Color.white.opacity(0.06),
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
