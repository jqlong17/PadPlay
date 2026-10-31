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
        PadTheme.chassis
    }

    /// LEFT compact chrome | RIGHT 4×4 horizontal pad stage (mock proportions).
    private func landscapeLayout(size: CGSize) -> some View {
        let inset = edgePadding(for: size)
        let innerH = size.height - inset * 2
        let innerW = size.width - inset * 2
        let narrow = innerW < 700
        let chassisPad: CGFloat = narrow ? 8 : 12
        let gap: CGFloat = narrow ? 10 : 14

        let usableH = max(0, innerH - chassisPad * 2)
        let usableW = max(0, innerW - chassisPad * 2)

        // Pads are wider than tall (~1.384); grid is wider than a square block.
        // Left chrome targets ~340pt content width (ACCEPT metrics); scale down on phone.
        let minLeft: CGFloat = narrow ? 168 : 220
        let maxLeft: CGFloat = narrow ? usableW * 0.38 : min(360, usableW * 0.34)
        var leftWidth = min(max(minLeft, usableW * 0.30), maxLeft)
        var padWidth = max(0, usableW - leftWidth - gap)
        let padHeight = usableH

        // If pad stage would be too narrow for 4 horizontal pads, shrink left further.
        if padWidth < usableH * 0.95 {
            leftWidth = min(leftWidth, max(148, usableW * 0.28))
            padWidth = max(0, usableW - leftWidth - gap)
        }

        return deviceChassis {
            HStack(alignment: .center, spacing: gap) {
                ControlClusterView()
                    .frame(width: leftWidth, alignment: .top)
                    .frame(maxHeight: .infinity, alignment: .top)

                PadGridView()
                    .frame(width: padWidth, height: padHeight)
            }
            .padding(chassisPad)
        }
        .frame(width: innerW, height: innerH)
    }

    private func deviceChassis<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PadTheme.chassis)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.45), radius: 14, y: 6)

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
